import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import '../../services/actividad_registrada_service.dart';

class ScienceScreen7 extends StatefulWidget {
  final int actividadId;
  const ScienceScreen7({super.key, required this.actividadId});

  @override
  State<ScienceScreen7> createState() => _ScienceScreen7State();
}

class _ScienceScreen7State extends State<ScienceScreen7> {
  final GlobalKey stackKey = GlobalKey();

  late List<Map<String, dynamic>> arriba;
  late List<Map<String, dynamic>> abajo;

  // keys para widgets
  final List<GlobalKey> topKeys = List.generate(4, (_) => GlobalKey());
  final List<GlobalKey> bottomKeys = List.generate(4, (_) => GlobalKey());

  // emparejamientos: topIndex -> bottomIndex (null si no)
  final Map<int, int?> emparejado = {0: null, 1: null, 2: null, 3: null};

  // líneas permanentes
  final List<_Line> lines = [];

  // estado de arrastre
  int? draggingTopIndex;
  Offset? dragStartLocal; // relativo al Stack
  Offset? dragCurrentLocal; // relativo al Stack

  @override
  void initState() {
    super.initState();

    // Forzar orientación horizontal real
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    arriba = [
      {"id": 0, "asset": "assets/pez.png", "especie": "pez"},
      {"id": 1, "asset": "assets/ave.png", "especie": "pajaro"},
      {"id": 2, "asset": "assets/perro.png", "especie": "perro"},
      {"id": 3, "asset": "assets/mariquita.png", "especie": "insecto"},
    ];

    abajo = [
      {"id": 0, "asset": "assets/pez_azul.png", "especie": "pez"},
      {"id": 1, "asset": "assets/pollito_amarillo.png", "especie": "pajaro"},
      {"id": 2, "asset": "assets/perrito_2.png", "especie": "perro"},
      {"id": 3, "asset": "assets/oruga.png", "especie": "insecto"},
    ];

    abajo.shuffle();
  }


  // Devuelve el centro del widget referido por la key, relativo al Stack (coordenadas locales del Stack)
  Offset? _centerOfKey(GlobalKey key) {
    if (key.currentContext == null || stackKey.currentContext == null) return null;
    final renderBox = key.currentContext!.findRenderObject() as RenderBox;
    final stackBox = stackKey.currentContext!.findRenderObject() as RenderBox;
    final globalCenter = renderBox.localToGlobal(renderBox.size.center(Offset.zero));
    return stackBox.globalToLocal(globalCenter);
  }

  // Chequea si completó todos los emparejamientos correctos
  Future<void> _checkCompletion() async {
    final allMatched = emparejado.values.every((v) => v != null);
    if (!allMatched) return;

    // Validación defensiva: comprobar ids coinciden
    for (int topIndex = 0; topIndex < arriba.length; topIndex++) {
      final bottomIndex = emparejado[topIndex];
      if (bottomIndex == null) return;
      final topId = arriba[topIndex]['id'];
      final bottomId = abajo[bottomIndex]['id'];
      if (topId != bottomId) return;
    }

    // Mostrar animación correcta y registrar
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: SizedBox(
          width: 220,
          height: 220,
          child: Lottie.asset('assets/correct.json', repeat: false),
        ),
      ),
    );

    await PostRegistrarActividad.submitData(actividad: widget.actividadId);

    await Future.delayed(const Duration(seconds: 2));
    Navigator.pop(context);
    Navigator.pop(context);
  }

  // Detectar si el punto global (en coordenadas del Stack) está dentro del rect del widget referenciado
  bool _pointInsideKey(Offset pointLocalToStack, GlobalKey key) {
    if (key.currentContext == null || stackKey.currentContext == null) return false;
    final renderBox = key.currentContext!.findRenderObject() as RenderBox;
    final stackBox = stackKey.currentContext!.findRenderObject() as RenderBox;
    final topLeftGlobal = renderBox.localToGlobal(Offset.zero);
    final topLeftLocal = stackBox.globalToLocal(topLeftGlobal);
    final rect = topLeftLocal & renderBox.size;
    return rect.contains(pointLocalToStack);
  }

  // HANDLERS: usamos GestureDetector sobre todo el Stack
  void _handlePanStart(DragStartDetails details) {
    final stackBox = stackKey.currentContext!.findRenderObject() as RenderBox;
    final local = stackBox.globalToLocal(details.globalPosition);

    // buscar si tocó algún top que no esté emparejado
    for (int i = 0; i < topKeys.length; i++) {
      if (emparejado[i] != null) continue; // ya emparejado
      if (_pointInsideKey(local, topKeys[i])) {
        draggingTopIndex = i;
        dragStartLocal = _centerOfKey(topKeys[i]);
        dragCurrentLocal = dragStartLocal;
        setState(() {});
        return;
      }
    }
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (draggingTopIndex == null) return;
    final stackBox = stackKey.currentContext!.findRenderObject() as RenderBox;
    dragCurrentLocal = stackBox.globalToLocal(details.globalPosition);
    setState(() {});
  }

  void _handlePanEnd(DragEndDetails details) {
    if (draggingTopIndex == null || dragCurrentLocal == null || dragStartLocal == null) {
      // limpiar
      draggingTopIndex = null;
      dragStartLocal = null;
      dragCurrentLocal = null;
      setState(() {});
      return;
    }

    // encontrar el bottom más cercano al punto final
    int? nearestIndex;
    double nearestDist = double.infinity;
    for (int j = 0; j < bottomKeys.length; j++) {
      final center = _centerOfKey(bottomKeys[j]);
      if (center == null) continue;
      final d = (center - dragCurrentLocal!).distance;
      if (d < nearestDist) {
        nearestDist = d;
        nearestIndex = j;
      }
    }

    const acceptThreshold = 90.0; // px

    if (nearestIndex != null && nearestDist <= acceptThreshold) {
      // Verificar especie/id (aquí arriba id must match abajo id)
      final topId = arriba[draggingTopIndex!]['id'];
      final bottomId = abajo[nearestIndex]['id'];
      if (topId == bottomId) {
        // emparejar
        final topCenter = _centerOfKey(topKeys[draggingTopIndex!])!;
        final bottomCenter = _centerOfKey(bottomKeys[nearestIndex])!;
        emparejado[draggingTopIndex!] = nearestIndex;
        lines.add(_Line(start: topCenter, end: bottomCenter));
        // limpiar arrastre
        draggingTopIndex = null;
        dragStartLocal = null;
        dragCurrentLocal = null;
        setState(() {});
        _checkCompletion();
        return;
      } else {
        // opcional: podrías mostrar incorrect.json aquí o feedback
      }
    }

    // si no emparejó, limpiar arrastre sin agregar línea
    draggingTopIndex = null;
    dragStartLocal = null;
    dragCurrentLocal = null;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2FBFC),
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          final imgHeight = constraints.maxHeight * 0.20;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Stack(
              key: stackKey,
              children: [
                Column(
                  children: [
                    const SizedBox(height: 12),
                    const Text(
                      "Une los animales de la misma especie",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6BACB4),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // FILA SUPERIOR
                    Expanded(
                      flex: 4,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(4, (i) {
                          final matched = emparejado[i] != null;
                          return Opacity(
                            opacity: matched ? 0.35 : 1,
                            child: Container(
                              key: topKeys[i],
                              width: constraints.maxWidth / 5,
                              alignment: Alignment.center,
                              child: Image.asset(
                                arriba[i]['asset'],
                                height: imgHeight,
                                fit: BoxFit.contain,
                              ),
                            ),
                          );
                        }),
                      ),
                    ),

                    // espacio
                    Expanded(flex: 2, child: const SizedBox()),

                    // FILA INFERIOR
                    Expanded(
                      flex: 4,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(4, (i) {
                          final matched = emparejado.containsValue(i);
                          return Opacity(
                            opacity: matched ? 0.35 : 1,
                            child: Container(
                              key: bottomKeys[i],
                              width: constraints.maxWidth / 5,
                              alignment: Alignment.center,
                              child: Image.asset(
                                abajo[i]['asset'],
                                height: imgHeight,
                                fit: BoxFit.contain,
                              ),
                            ),
                          );
                        }),
                      ),
                    ),

                    const SizedBox(height: 12),
                  ],
                ),

                // Canvas de líneas y zona de interacción (gestos)
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onPanStart: _handlePanStart,
                    onPanUpdate: _handlePanUpdate,
                    onPanEnd: _handlePanEnd,
                    child: CustomPaint(
                      painter: _MatchPainter(
                        lines: lines,
                        dragStart: dragStartLocal,
                        dragCurrent: dragCurrentLocal,
                      ),
                      child: Container(), // ocupa el área
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// linea permanente
class _Line {
  final Offset start;
  final Offset end;
  _Line({required this.start, required this.end});
}

// painter que dibuja las líneas permanentes y la dinámica
class _MatchPainter extends CustomPainter {
  final List<_Line> lines;
  final Offset? dragStart;
  final Offset? dragCurrent;

  _MatchPainter({required this.lines, this.dragStart, this.dragCurrent});

  @override
  void paint(Canvas canvas, Size size) {
    final paintPerm = Paint()
      ..color = const Color(0xFF6BACB4)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final paintDrag = Paint()
      ..color = Colors.black54
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    for (var l in lines) {
      canvas.drawLine(l.start, l.end, paintPerm);
    }

    if (dragStart != null && dragCurrent != null) {
      canvas.drawLine(dragStart!, dragCurrent!, paintDrag);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
