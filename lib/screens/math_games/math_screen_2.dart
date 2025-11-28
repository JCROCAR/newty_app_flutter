import 'package:educapp_demo/widgets/instructions_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/services.dart';
import 'package:educapp_demo/utils/audio_singleton.dart';
import 'package:audioplayers/audioplayers.dart';

import '../../services/actividad_registrada_service.dart';



class MathScreen2 extends StatefulWidget {

  final int actividadId;

  MathScreen2({required this.actividadId});

  @override
  _MathScreen2State createState() => _MathScreen2State();
}

class _MathScreen2State extends State<MathScreen2> {


  final List<int> _numbers = [1, 2, 3];
  final numberWords = {1: "uno", 2: "dos", 3: "tres"};
  late int _targetNumber;
  late List<int> _shuffledNumbers;
  bool _showFeedback = false;
  bool _isCorrect = false;

  final BackgroundMusic _backgroundMusic = BackgroundMusic();
  bool _wasBackgroundMusicPlaying = false;

  @override
  void initState() {
    super.initState();
    _generateNewRound();

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

  Future<void> _playAudio(String filename) async {
    final player = AudioPlayer();
    await player.play(AssetSource('$filename.wav'));
  }


  void _generateNewRound() {
    _shuffledNumbers = List.from(_numbers)..shuffle();
    _targetNumber = (_shuffledNumbers..shuffle()).first;
    _showFeedback = false;
    setState(() {});
    _playAudio('dondeestanumero$_targetNumber');
  }

  void _checkAnswer(int selected) {
    setState(() {
      _isCorrect = selected == _targetNumber;
      _showFeedback = true;
    });

    if (_isCorrect) {
      Future.delayed(Duration(seconds: 2), () async {
        await PostRegistrarActividad.submitData(actividad: widget.actividadId);
        Navigator.pop(context); // Regresa a la pantalla anterior
      });
    } else {
      Future.delayed(Duration(seconds: 2), _generateNewRound);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2FBFC),
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Texto superior
                  TitleText(text: '¿Dónde está el número ${numberWords[_targetNumber]}?'),
                  const SizedBox(height: 30),

                  // Botones
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: _shuffledNumbers.map((number) {
                      return ElevatedButton(
                        onPressed: () => _checkAnswer(number),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF87c5c4),
                          padding: const EdgeInsets.all(26),
                          shape: const CircleBorder(),
                          elevation: 6,
                        ),
                        child: Text(
                          number.toString(),
                          style: GoogleFonts.openSans(
                            textStyle: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          // Aquí agregamos el icono de bocina en la esquina superior derecha
          Positioned(
            top: 20,
            right: 20,
            child: IconButton(
              icon: Icon(Icons.volume_up, size: 40, color: Color(0xFFFF9800).withOpacity(0.8)),
              onPressed: () {
                _playAudio('dondeestanumero$_targetNumber');
                print('dondeestanumero$_targetNumber');
              },
            ),
          ),

          if (_showFeedback)
            Center(
              child: Lottie.asset(
                _isCorrect ? 'assets/correct.json' : 'assets/incorrect.json',
                width: 200,
                height: 200,
                repeat: false,
              ),
            ),
        ],
      ),
    );
  }
}
