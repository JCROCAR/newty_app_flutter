import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../services/actividad_registrada_service.dart';
import 'package:educapp_demo/widgets/instructions_text.dart';

class ScienceScreen6 extends StatefulWidget {
  final int actividadId;
  const ScienceScreen6({super.key, required this.actividadId});

  @override
  State<ScienceScreen6> createState() => _ScienceScreen6State();
}

class _ScienceScreen6State extends State<ScienceScreen6> {
  // pares originales (id + asset)
  final List<Map<String, dynamic>> arribaOriginal = [
    {"id": 0, "asset": "assets/beaker_rosado.png"},
    {"id": 1, "asset": "assets/beaker_verde.png"},
    {"id": 2, "asset": "assets/beaker_azul.png"},
  ];

  late List<Map<String, dynamic>> arriba; // mostradas (en orden)
  late List<Map<String, dynamic>> abajo; // mostradas (barajadas)

  // mapping: topIndex -> bottomIndex (null si no emparejado)
  Map<int, int?> emparejado = {0: null, 1: null, 2: null};

  // claves para obtener posiciones en pantalla
  final List<GlobalKey> topKeys = [GlobalKey(), GlobalKey(), GlobalKey()];
  final List<GlobalKey> bottomKeys = [GlobalKey(), GlobalKey(), GlobalKey()];

  // dibujo en tiempo real
  Offset? dragStartLocal; // punto inicial local en el Stack
  Offset? dragCurrentLocal;
  int? draggingTopIndex;

  // líneas permanentes guardadas como pares de Offsets
  final List<_Line> lines = [];

  @override
  void initState() {
    super.initState();
    arriba = arribaOriginal.map((m) => Map<String, dynamic>.from(m)).toList();
    abajo = arribaOriginal.map((m) => Map<String, dynamic>.from(m)).toList();
    abajo.shuffle();
  }

  // obtiene el centro de un widget referenciado por key, relativo al Stack (context)
  Offset? _centerOfKey(GlobalKey key, RenderBox? stackBox) {
    if (key.currentContext == null || stackBox == null) return null;
    final renderBox = key.currentContext!.findRenderObject() as RenderBox;
    final topLeft = renderBox.localToGlobal(Offset.zero, ancestor: stackBox);
    final size = renderBox.size;
    return topLeft + Offset(size.width / 2, size.height / 2);
  }

  Future<void> _checkCompletion() async {
    final allMatched = emparejado.values.every((v) => v != null);
    if (!allMatched) return;

    // validar que cada emparejamiento sea correcto (defensivo)
    for (var topIndex = 0; topIndex < arriba.length; topIndex++) {
      final bottomIndex = emparejado[topIndex];
      if (bottomIndex == null) return;
      final topId = arriba[topIndex]['id'];
      final bottomId = abajo[bottomIndex]['id'];
      if (topId != bottomId) return;
    }

    // Todo ok -> mostrar animación y registrar
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
    Navigator.pop(context); // cierra dialog
    Navigator.pop(context); // vuelve atrás
  }

  // Detecta al empezar el trazo tocando un elemento top
  void _onPanStart(DragStartDetails details, RenderBox stackBox) {
    // convertir global a local del stack
    final local = stackBox.globalToLocal(details.globalPosition);

    // Verificar si tocó el centro de alguna imagen superior (por su bbox)
    for (int i = 0; i < topKeys.length; i++) {
      final key = topKeys[i];
      if (key.currentContext == null) continue;
      final rb = key.currentContext!.findRenderObject() as RenderBox;
      final topLeft = rb.localToGlobal(Offset.zero, ancestor: stackBox);
      final rect = topLeft & rb.size;
      if (rect.contains(details.globalPosition)) {
        // si ya emparejado, ignorar
        if (emparejado[i] != null) return;
        draggingTopIndex = i;
        dragStartLocal = stackBox.globalToLocal(details.globalPosition);
        dragCurrentLocal = dragStartLocal;
        setState(() {});
        return;
      }
    }
  }

  void _onPanUpdate(DragUpdateDetails details, RenderBox stackBox) {
    if (draggingTopIndex == null) return;
    dragCurrentLocal = stackBox.globalToLocal(details.globalPosition);
    setState(() {});
  }

  void _onPanEnd(DragEndDetails details, RenderBox stackBox) {
    if (draggingTopIndex == null || dragStartLocal == null) {
      // limpiar
      draggingTopIndex = null;
      dragStartLocal = null;
      dragCurrentLocal = null;
      setState(() {});
      return;
    }

    // buscar bottom cercano al punto final
    final endGlobal = stackBox.localToGlobal(dragCurrentLocal!);
    int? nearestIndex;
    double nearestDist = double.infinity;
    for (int j = 0; j < bottomKeys.length; j++) {
      final center = _centerOfKey(bottomKeys[j], stackBox);
      if (center == null) continue;
      final d = (center - endGlobal).distance;
      if (d < nearestDist) {
        nearestDist = d;
        nearestIndex = j;
      }
    }

    // Umbral de aceptación en px (ajustable)
    const acceptThreshold = 90.0;

    if (nearestIndex != null && nearestDist <= acceptThreshold) {
      // Verificar si coincide por id
      final topId = arriba[draggingTopIndex!]['id'];
      final bottomId = abajo[nearestIndex]['id'];

      if (topId == bottomId) {
        // marcar emparejado y crear línea permanente
        final topCenter = _centerOfKey(topKeys[draggingTopIndex!], stackBox)!;
        final bottomCenter = _centerOfKey(bottomKeys[nearestIndex], stackBox)!;

        emparejado[draggingTopIndex!] = nearestIndex;
        lines.add(_Line(start: topCenter, end: bottomCenter));

        // opcional: reducir visibilidad del top item (se muestra por opacidad en build)
        setState(() {});
        _checkCompletion();
      } else {
        // si no coincide, no emparejar; podrías mostrar feedback si quieres
        // por ahora solo revertimos (sin emparejar)
        // TODO: puedes mostrar incorrect.json o vibración aquí
      }
    }

    // limpiar estado de arrastre
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
          final stackSize = constraints.biggest;

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Stack(
              children: [
                // Contenido principal (columnas y filas)
                Column(
                  children: [
                    const SizedBox(height: 12),
                    const TitleText(text: "Une cada imagen con su pareja"),
                    const SizedBox(height: 20),

                    // Fila superior
                    Expanded(
                      flex: 4,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(3, (i) {
                          final item = arriba[i];
                          final matched = emparejado[i] != null;

                          return Opacity(
                            opacity: matched ? 0.35 : 1,
                            child: Container(
                              key: topKeys[i],
                              alignment: Alignment.center,
                              child: Image.asset(
                                item['asset'],
                                height: 100,   // Reducido para evitar overflow
                                fit: BoxFit.contain,
                              ),
                            ),
                          );
                        }),
                      ),
                    ),

                    // Espacio entre filas
                    Expanded(flex: 1, child: SizedBox()),

                    // Fila inferior
                    Expanded(
                      flex: 4,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(3, (i) {
                          final item = abajo[i];
                          return Container(
                            key: bottomKeys[i],
                            alignment: Alignment.center,
                            child: Image.asset(
                              item['asset'],
                              height: 100,   // Igual que arriba
                              fit: BoxFit.contain,
                            ),
                          );
                        }),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
                // Canvas de líneas permanentes y línea dinámica
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onPanStart: (d) {
                      final box = context.findRenderObject() as RenderBox;
                      _onPanStart(d, box);
                    },
                    onPanUpdate: (d) {
                      final box = context.findRenderObject() as RenderBox;
                      _onPanUpdate(d, box);
                    },
                    onPanEnd: (d) {
                      final box = context.findRenderObject() as RenderBox;
                      _onPanEnd(d, box);
                    },
                    child: CustomPaint(
                      size: stackSize,
                      painter: _MatchPainter(lines: lines, dragStart: dragStartLocal, dragCurrent: dragCurrentLocal),
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

// estructura para guardar una línea permanente
class _Line {
  final Offset start;
  final Offset end;
  _Line({required this.start, required this.end});
}

// painter que dibuja líneas permanentes y la línea de arrastre
class _MatchPainter extends CustomPainter {
  final List<_Line> lines;
  final Offset? dragStart;
  final Offset? dragCurrent;

  _MatchPainter({required this.lines, this.dragStart, this.dragCurrent});

  @override
  void paint(Canvas canvas, Size size) {
    final paintPermanent = Paint()
      ..color = const Color(0xFF6BACB4)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final paintDrag = Paint()
      ..color = Colors.black54
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    // líneas permanentes
    for (var l in lines) {
      canvas.drawLine(l.start, l.end, paintPermanent);
    }

    // línea dinámica
    if (dragStart != null && dragCurrent != null) {
      canvas.drawLine(dragStart!, dragCurrent!, paintDrag);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
