import 'package:educapp_demo/widgets/instructions_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:educapp_demo/utils/audio_singleton.dart';
import '../../services/actividad_registrada_service.dart';

// Clase para recortar un Container en forma de triángulo
class TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height)
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
  final BackgroundMusic _backgroundMusic = BackgroundMusic();
  bool _wasBackgroundMusicPlaying = false;

  Map<String, bool?> silhouettes = {
    'square': null,
    'triangle': null,
    'circle': null,
  };

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
    if (_wasBackgroundMusicPlaying) _backgroundMusic.stop();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    if (_wasBackgroundMusicPlaying) _backgroundMusic.play();
    super.dispose();
  }

  Future<void> _speakIntro() async {
    await _audioPlayer.stop();
    await _audioPlayer.play(AssetSource('arrastrafigurasilueta.wav'));
  }

  void _checkCompletion() {
    if (silhouettes.values.every((v) => v == true)) {
      Future.delayed(const Duration(seconds: 2), () async {
        if (mounted) {
          await PostRegistrarActividad.submitData(actividad: widget.actividadId);
          Navigator.pop(context);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Usamos el mismo color exacto que tu versión anterior, sin cambio de opacidad
    const backgroundColor =  Color(0xFFEAF6F6);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Calculamos tamaño base, pero sin hacerlas demasiado pequeñas
          double baseSize = constraints.maxWidth * 0.12;
          if (baseSize < 80) baseSize = 80; // tamaño mínimo
          if (baseSize > 100) baseSize = 100; // tamaño máximo

          return Container(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            color: backgroundColor,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Título + botón de sonido
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: TitleText(text: 'Arrastra cada figura a su silueta')
                    ),
                    IconButton(
                      icon:  Icon(Icons.volume_up, size: 40, color: Color(0xFFFF9800).withOpacity(0.8)),
                      onPressed: _speakIntro,
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Siluetas
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 40,
                  runSpacing: 20,
                  children: [
                    _buildSilhouette('square', Colors.blue, baseSize),
                    _buildSilhouette('triangle', Colors.red, baseSize),
                    _buildSilhouette('circle', Colors.green, baseSize),
                  ],
                ),

                const SizedBox(height: 40),

                // Figuras arrastrables
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 40,
                  runSpacing: 20,
                  children: [
                    _buildDraggableFigure('triangle', Colors.red, baseSize),
                    _buildDraggableFigure('circle', Colors.green, baseSize),
                    _buildDraggableFigure('square', Colors.blue, baseSize),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

  }

  Widget _buildSilhouette(String shape, Color color, double size) {
    bool? isCorrect = silhouettes[shape];
    return DragTarget<String>(
      onAccept: (receivedShape) {
        setState(() {
          silhouettes[shape] = receivedShape == shape;
          if (silhouettes[shape] == true) _checkCompletion();
          else {
            Future.delayed(const Duration(seconds: 1), () {
              if (mounted) setState(() => silhouettes[shape] = null);
            });
          }
        });
      },
      builder: (context, candidateData, rejectedData) {
        Color fillColor = isCorrect == null
            ? Colors.white.withOpacity(0.8)
            : isCorrect
            ? color.withOpacity(0.5)
            : Colors.red.withOpacity(0.5);

        return Stack(
          alignment: Alignment.center,
          children: [
            _buildShape(shape, fillColor, size),
            if (isCorrect != null)
              Lottie.asset(
                isCorrect ? 'assets/correct.json' : 'assets/incorrect.json',
                height: size,
                width: size,
                repeat: false,
              ),
          ],
        );
      },
    );
  }

  Widget _buildDraggableFigure(String shape, Color color, double size) {
    if (silhouettes[shape] == true) {
      return SizedBox(width: size, height: size);
    }
    return Draggable<String>(
      data: shape,
      feedback: Material(
        color: Colors.transparent,
        child: _buildShape(shape, color, size),
      ),
      childWhenDragging: SizedBox(width: size, height: size),
      child: _buildShape(shape, color, size),
    );
  }

  Widget _buildShape(String shape, Color color, double size) {
    if (shape == 'square') {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color),
      );
    } else if (shape == 'circle') {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      );
    } else if (shape == 'triangle') {
      return ClipPath(
        clipper: TriangleClipper(),
        child: Container(width: size, height: size, color: color),
      );
    }
    return const SizedBox.shrink();
  }
}
