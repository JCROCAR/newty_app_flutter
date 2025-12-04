import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'dart:ui' as ui;
import '../../services/actividad_registrada_service.dart';
import '../../widgets/instructions_text.dart';


class ScienceScreen8 extends StatefulWidget {
  final int actividadId;
  const ScienceScreen8({super.key, required this.actividadId});

  @override
  State<ScienceScreen8> createState() => _ScienceScreen8State();
}

class _ScienceScreen8State extends State<ScienceScreen8> {
  final List<Offset> points = [];
  bool showCorrectAnimation = false;

  // Coordenadas globales del objeto a detectar (manzana)
  Rect? targetRect;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2FBFC),
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // 📌 INSTRUCCIÓN
              TitleText(text:
                "Circula el objeto que no pertenece"
              ),

              const SizedBox(height: 20),

              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return  GestureDetector(
                      onPanUpdate: (details) {
                        setState(() {
                          final RenderBox box = context.findRenderObject() as RenderBox;
                          points.add(box.globalToLocal(details.globalPosition));
                        });
                      },
                      onPanEnd: (_) {
                        _validateCircle();
                      },
                      child: Stack(
                        children: [
                          _buildImagesGrid(), // 🖼️ IMAGENES

                          // ✏️ DIBUJO DEL DEDO ENCIMA DE TODO
                          Positioned.fill(
                            child: CustomPaint(
                              painter: CirclePainter(points: points),
                            ),
                          ),
                        ],
                      ),
                    );

                  },
                ),
              ),
            ],
          ),

          // 🎉 ANIMACIÓN CORRECTA
          if (showCorrectAnimation)
            Center(
              child: Lottie.asset(
                'assets/correct.json',
                repeat: false,
                onLoaded: (_) {
                  Future.delayed(const Duration(seconds: 2), () {
                    setState(() async {
                      showCorrectAnimation = false;
                      points.clear();
                      await PostRegistrarActividad.submitData(actividad: widget.actividadId);
                      await Future.delayed(const Duration(seconds: 1));
                      Navigator.pop(context);
                    });
                  });
                },
              ),
            ),
        ],
      ),
    );
  }

  // 📌 GRID DE IMÁGENES
  Widget _buildImagesGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        final imgSize = width * 0.18; // Tamaño responsivo de las imágenes

        return Stack(
          children: [
            // 🌸 FILA SUPERIOR (FLORES)
            Positioned(
              left: width * 0.10,
              top: height * 0.10,
              child: _buildObject("assets/flor_rosa_roja.png", imgSize),
            ),
            Positioned(
              left: width * 0.40,
              top: height * 0.12,
              child: _buildObject("assets/tulipan.png", imgSize),
            ),
            Positioned(
              left: width * 0.70,
              top: height * 0.10,
              child: _buildObject("assets/flor.png", imgSize),
            ),
            Positioned(
              left: width * 0.25,
              top: height * 0.40,
              child: _buildObject("assets/girasol.png", imgSize),
            ),

            // 🍎 MANZANA — OBJETO QUE NO PERTENECE
            Positioned(
              left: width * 0.60,
              top: height * 0.45,
              child: Builder(
                builder: (context) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    final renderBox =
                    context.findRenderObject() as RenderBox?;
                    if (renderBox != null) {
                      final pos = renderBox.localToGlobal(Offset.zero);
                      targetRect = pos & renderBox.size;
                    }
                  });

                  return _buildObject("assets/manzana_verde.png", imgSize);
                },
              ),
            ),
          ],
        );
      },
    );
  }


  Widget _buildObject(String assetPath, double size) {
    return Image.asset(
      assetPath,
      width: size,
      height: size,
    );
  }


  // 📌 DETECCIÓN DEL CÍRCULO SOBRE LA MANZANA
  void _validateCircle() {
    if (targetRect == null) return;

    for (var p in points) {
      if (targetRect!.contains(p)) {
        setState(() {
          showCorrectAnimation = true;
        });
        break;
      }
    }

    points.clear();
  }
}

// 🎨 PAINTER QUE DIBUJA LA LÍNEA DEL DEDO
class CirclePainter extends CustomPainter {
  final List<Offset> points;

  CirclePainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != Offset.zero && points[i + 1] != Offset.zero) {
        canvas.drawLine(points[i], points[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
