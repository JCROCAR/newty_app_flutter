import 'dart:math';
import 'package:educapp_demo/widgets/instructions_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:educapp_demo/utils/audio_singleton.dart';
import '../../services/actividad_registrada_service.dart';

class LogicScreen3 extends StatefulWidget {
  final int actividadId;

  const LogicScreen3({required this.actividadId});

  @override
  _LogicScreen3State createState() => _LogicScreen3State();
}

class _LogicScreen3State extends State<LogicScreen3> {
  final Map<String, Color> colors = {
    'rojo': Colors.red,
    'azul': Colors.blue,
    'verde': Colors.green,
    'amarillo': Colors.yellow,
    'naranja': Colors.orange,
  };

  late String targetColor;
  bool? isCorrect;

  final BackgroundMusic _backgroundMusic = BackgroundMusic();
  bool _wasBackgroundMusicPlaying = false;

  @override
  void initState() {
    super.initState();
    _setRandomColor();
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

  Future<void> _playAudio(String fileName) async {
    final player = AudioPlayer();
    await player.play(AssetSource('$fileName.wav'));
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

  Future<void> _setRandomColor() async {
    final random = Random();
    final colorNames = colors.keys.toList();
    targetColor = colorNames[random.nextInt(colorNames.length)];
    isCorrect = null;
    await _playAudio('tocacolor${targetColor.toLowerCase()}');
  }

  void _handleTap(String selectedColor) {
    if (isCorrect == true) return;

    setState(() {
      isCorrect = selectedColor == targetColor;
    });

    if (isCorrect!) {
      Future.delayed(const Duration(seconds: 2), () async {
        await PostRegistrarActividad.submitData(actividad: widget.actividadId);
        if (mounted) Navigator.pop(context);
      });
    } else {
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) _playAudio('tocacolor${targetColor.toLowerCase()}');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final screenHeight = constraints.maxHeight;

          // Tamaños base escalables
          final circleSize = screenWidth * 0.12; // tamaño de botones
          final animationSize = screenWidth * 0.25; // tamaño animación

          return Container(
            width: screenWidth,
            height: screenHeight,
            color: Color(0xFFEAF6F6),
            child: Stack(
              children: [
                Positioned(
                  top: 20,
                  right: 20,
                  child: IconButton(
                    icon:  Icon(Icons.volume_up, size: 40, color: Color(0xFFFF9800).withOpacity(0.8)),
                    onPressed: () => _playAudio('tocacolor${targetColor.toLowerCase()}'),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Texto "Toca el color" y nombre del color en FittedBox
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Column(
                          children: [
                            TitleText(text: 'Toca el color:'),
                            const SizedBox(height: 10),
                            Text(
                              targetColor.toUpperCase(),
                              style: GoogleFonts.openSans(
                                textStyle: TextStyle(
                                  fontSize: screenWidth * 0.05,
                                  fontWeight: FontWeight.bold,
                                  color: colors[targetColor],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Botones circulares
                      Wrap(
                        spacing: 20,
                        runSpacing: 20,
                        alignment: WrapAlignment.center,
                        children: colors.entries.map((entry) {
                          return GestureDetector(
                            onTap: () => _handleTap(entry.key),
                            child: Container(
                              width: circleSize.clamp(70, 120),
                              height: circleSize.clamp(70, 120),
                              decoration: BoxDecoration(
                                color: entry.value,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 20),

                      // Animación responsive con Flexible
                      if (isCorrect != null)
                        Flexible(
                          child: Center(
                            child: Lottie.asset(
                              isCorrect!
                                  ? 'assets/correct.json'
                                  : 'assets/incorrect.json',
                              width: animationSize.clamp(100, 200),
                              height: animationSize.clamp(100, 200),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

  }
}
