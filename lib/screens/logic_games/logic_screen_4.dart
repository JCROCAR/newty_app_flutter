import 'package:educapp_demo/widgets/instructions_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/services.dart';
import 'package:educapp_demo/services/actividad_registrada_service.dart';


class LogicScreen4 extends StatefulWidget {
  final int actividadId;

  const LogicScreen4({required this.actividadId});

  @override
  _LogicScreen4State createState() => _LogicScreen4State();
}

class _LogicScreen4State extends State<LogicScreen4> {
  List<Offset> _points = [];
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details, Size canvasSize) {
    final localPos = details.localPosition;
    setState(() {
      _points = List.from(_points)..add(localPos);
    });

    // Detecta si llegó cerca del punto final dentro del canvas
    final end = Offset(canvasSize.width * 0.9, canvasSize.height * 0.5);
    if ((localPos - end).distance < 60) {
      setState(() => _completed = true);
      _showSuccessAnimation();
    }
  }

  void _onPanEnd(DragEndDetails details) {
    if (!_completed) {
      setState(() => _points = []);
    }
  }

  void _showSuccessAnimation() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        Future.delayed(const Duration(seconds: 1), () async {
          Navigator.of(dialogContext).pop();
          await PostRegistrarActividad.submitData(actividad: widget.actividadId);
          Navigator.of(context).pop();
        });

        return Center(
          child: SizedBox(
            width: 200,
            height: 200,
            child: Lottie.asset('assets/correct.json', repeat: false),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEAF6F6),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Center(
                    child: TitleText(text: 'Llega al punto rojo'),
                  ),
                  Positioned(
                    right: 125,
                    child: IconButton(
                      icon:  Icon(Icons.volume_up,
                          size: 40, color: Color(0xFFFF9800).withOpacity(0.8)),
                      onPressed: () {}, // 🔈 Aquí irá la función para reproducir audio
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final canvasSize = Size(
                        constraints.maxWidth,
                        constraints.maxHeight,
                      );

                      return Container(
                        margin: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 6,
                              offset: const Offset(2, 2),
                            ),
                          ],
                        ),
                        child: GestureDetector(
                          onPanUpdate: (details) =>
                              _onPanUpdate(details, canvasSize),
                          onPanEnd: _onPanEnd,
                          child: CustomPaint(
                            painter: _MazePainter(
                              points: _points,
                            ),
                            child: Container(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MazePainter extends CustomPainter {
  final List<Offset> points;

  _MazePainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    final mazePaint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke;

    final pathPaint = Paint()
      ..color = const Color(0xFF7C3AC8)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Dibuja un laberinto simple, centrado y proporcional
    final path = Path()
      ..moveTo(size.width * 0.1, size.height * 0.5)
      ..lineTo(size.width * 0.3, size.height * 0.5)
      ..lineTo(size.width * 0.3, size.height * 0.3)
      ..lineTo(size.width * 0.7, size.height * 0.3)
      ..lineTo(size.width * 0.7, size.height * 0.7)
      ..lineTo(size.width * 0.9, size.height * 0.7)
      ..lineTo(size.width * 0.9, size.height * 0.5);

    canvas.drawPath(path, mazePaint);

    // Dibuja el trazo del usuario
    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], pathPaint);
    }

    // Dibuja inicio y fin (dentro del canvas visible)
    final start = Offset(size.width * 0.1, size.height * 0.5);
    final end = Offset(size.width * 0.9, size.height * 0.5);

    final startPaint = Paint()..color = Colors.green;
    final endPaint = Paint()..color = Colors.red;

    canvas.drawCircle(start, 20, startPaint);
    canvas.drawCircle(end, 20, endPaint);
  }

  @override
  bool shouldRepaint(_MazePainter oldDelegate) => true;
}
