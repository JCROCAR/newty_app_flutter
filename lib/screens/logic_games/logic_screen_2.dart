import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:educapp_demo/utils/audio_singleton.dart'; // Importa tu Singleton

import '../../services/actividad_registrada_service.dart';




// Clase para recortar un Container en forma de triángulo
class TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()
      ..moveTo(size.width / 2, 0) // Vértice superior
      ..lineTo(0, size.height) // Vértice inferior izquierdo
      ..lineTo(size.width, size.height) // Vértice inferior derecho
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class LogicScreen2 extends StatefulWidget {
  final int actividadId;
  final VoidCallback? onComplete;
  const LogicScreen2({super.key, this.onComplete, required this.actividadId});

  @override
  _LogicScreen2State createState() => _LogicScreen2State();
}

class _LogicScreen2State extends State<LogicScreen2> {

  final AudioPlayer _audioPlayer = AudioPlayer();
  Map<String, bool?> silhouettes = {
    'square': null,
    'triangle': null,
    'circle': null,
  };

  final BackgroundMusic _backgroundMusic = BackgroundMusic();
  bool _wasBackgroundMusicPlaying = false;

  @override
  void initState() {
    super.initState();
    _speakIntro();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    _wasBackgroundMusicPlaying = _backgroundMusic.isPlaying;
    if (_wasBackgroundMusicPlaying) {
      _backgroundMusic.stop();
    }

  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    if (_wasBackgroundMusicPlaying) {
      _backgroundMusic.play();
    }

    super.dispose();
  }

  void _checkCompletion() {
    if (silhouettes.values.every((value) => value == true)) {
      Future.delayed(const Duration(seconds: 2), () async {
        if (mounted) {
          await PostRegistrarActividad.submitData(actividad: widget.actividadId);
          Navigator.pop(context);
        } 
      });
    }
  }


  Future<void> _speakIntro() async {
    await _audioPlayer.stop();
    await _audioPlayer.play(AssetSource('arrastrafigurasilueta.wav'));
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFF87C5C4).withOpacity(0.7),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Texto + icono juntos en una fila
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Arrastra cada figura a su silueta',
                      style: GoogleFonts.openSans(
                        textStyle: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7C3AC8),
                        ),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(width: 10),
                    Positioned(
                      top: 20,
                      right: 20,
                      child : IconButton(
                        icon: const Icon(Icons.volume_up, size: 40, color: Colors.white),
                        onPressed: () => _speakIntro(),
                      ),
                    )

                  ],
                ),

                const SizedBox(height: 30),

                // Siluetas
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSilhouette('square', Colors.blue),
                    const SizedBox(width: 40),
                    _buildSilhouette('triangle', Colors.red),
                    const SizedBox(width: 40),
                    _buildSilhouette('circle', Colors.green),
                  ],
                ),

                const SizedBox(height: 40),

                // Figuras arrastrables
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildDraggableFigure('triangle', Colors.red),
                    const SizedBox(width: 40),
                    _buildDraggableFigure('circle', Colors.green),
                    const SizedBox(width: 40),
                    _buildDraggableFigure('square', Colors.blue),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSilhouette(String shape, Color color) {
    bool? isCorrect = silhouettes[shape];
    return DragTarget<String>(
      onAccept: (receivedShape) {
        setState(() {
          if (receivedShape == shape) {
            silhouettes[shape] = true;
            _checkCompletion();
          } else {
            silhouettes[shape] = false;
            Future.delayed(const Duration(seconds: 1), () {
              if (mounted) {
                setState(() {
                  silhouettes[shape] = null;
                });
              }
            });
          }
        });
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          width: 100,
          height: 100,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (shape == 'square')
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: isCorrect == null
                        ? Colors.white.withOpacity(0.3)
                        : isCorrect
                        ? color.withOpacity(0.5)
                        : Colors.red.withOpacity(0.5),
                  ),
                )
              else if (shape == 'circle')
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCorrect == null
                        ? Colors.white.withOpacity(0.3)
                        : isCorrect
                        ? color.withOpacity(0.5)
                        : Colors.red.withOpacity(0.5),
                  ),
                )
              else if (shape == 'triangle')
                  ClipPath(
                    clipper: TriangleClipper(),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: isCorrect == null
                            ? Colors.white.withOpacity(0.3)
                            : isCorrect
                            ? color.withOpacity(0.5)
                            : Colors.red.withOpacity(0.5),
                      ),
                    ),
                  ),
              if (isCorrect != null)
                isCorrect
                    ? Lottie.asset('assets/correct.json', height: 80, width: 80)
                    : Lottie.asset('assets/incorrect.json', height: 80, width: 80),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDraggableFigure(String shape, Color color) {
    if (silhouettes[shape] == true) {
      return const SizedBox(width: 100, height: 100);
    }
    return Draggable<String>(
      data: shape,
      feedback: Container( // Cambiado de Material a Container con fondo transparente
        width: 80,
        height: 80,
        color: Colors.transparent, // Fondo transparente
        child: _buildShape(shape, color, isFeedback: true),
      ),
      childWhenDragging: Container(
        width: 100,
        height: 100,
        color: Colors.transparent,
      ),
      child: Container(
        width: 100,
        height: 100,
        child: _buildShape(shape, color),
      ),
    );
  }

  Widget _buildShape(String shape, Color color, {bool isFeedback = false}) {
    if (shape == 'square') {
      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: color,
        ),
      );
    } else if (shape == 'circle') {
      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      );
    } else if (shape == 'triangle') {
      return ClipPath(
        clipper: TriangleClipper(),
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: color,
          ),
        ),
      );
    }
    return SizedBox.shrink();
  }
}