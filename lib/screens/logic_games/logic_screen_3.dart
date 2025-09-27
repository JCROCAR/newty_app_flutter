import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:educapp_demo/utils/audio_singleton.dart'; // Importa tu Singleton
import 'package:audioplayers/audioplayers.dart';

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
      body: Stack(
        children: [
          Container(color: Color(0xFF87C5C4).withOpacity(0.7)),
          Positioned(
            top: 20,
            right: 20,
            child: IconButton(
              icon: Icon(Icons.volume_up, size: 40, color: Colors.white),
              onPressed: () => _playAudio('tocacolor${targetColor.toLowerCase()}'),

            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Toca el color:',
                  style: GoogleFonts.openSans(
                    textStyle: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF7C3AC8),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  targetColor.toUpperCase(),
                  style: GoogleFonts.openSans(
                    textStyle: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: colors[targetColor],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  alignment: WrapAlignment.center,
                  children: colors.entries.map((entry) {
                    return GestureDetector(
                      onTap: () => _handleTap(entry.key),
                      child: Container(
                        width: 100,
                        height: 100,
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
                if (isCorrect != null)
                  isCorrect!
                      ? Lottie.asset('assets/correct.json', height: 100)
                      : Lottie.asset('assets/incorrect.json', height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
