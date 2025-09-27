import 'package:educapp_demo/services/actividad_registrada_service.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:educapp_demo/utils/audio_singleton.dart'; // Importa tu Singleton
import 'package:flutter/services.dart';


class LanguageScreen1 extends StatefulWidget {

  final int actividadId;

  LanguageScreen1({required this.actividadId});


  @override
  _LanguageScreen1State createState() => _LanguageScreen1State();
}

class _LanguageScreen1State extends State<LanguageScreen1> {


  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _showCorrect = false;
  bool _showIncorrect = false;

  late AudioPlayer audioPlayer; // Reproductor para el sonido del pollo
  final BackgroundMusic _backgroundMusic = BackgroundMusic(); // Singleton para la música de fondo
  bool _wasBackgroundMusicPlaying = false; // Estado previo de la música de fondo

  final List<Map<String, dynamic>> _questions = [
    {
      'sound': 'assets/cow_sound.mp3',
      'correct': 'cow.png',
      'options': ['cow.png', 'dog.png', 'cat.png']
    },
    {
      'sound': 'assets/dog_sound.mp3',
      'correct': 'dog.png',
      'options': ['cat.png', 'dog.png', 'cow.png']
    },
    {
      'sound': 'assets/cat_sound.mp3',
      'correct': 'cat.png',
      'options': ['cow.png', 'cat.png', 'dog.png']
    },
  ];

  late Map<String, dynamic> _currentQuestion;

  void _playSound(String path) async {
    await _audioPlayer.stop();
    await _audioPlayer.play(AssetSource(path.replaceFirst('assets/', '')));
  }

  void _showSuccessAndExit(bool answer) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        Future.delayed(Duration(seconds: 1), () async {
          Navigator.of(dialogContext).pop(); // Siempre cierra el diálogo

          if (answer) {
            // Solo sale de la pantalla si la respuesta es correcta
            await PostRegistrarActividad.submitData(actividad: widget.actividadId);
            Navigator.of(context).pop();
          }
        });

        return Center(
          child: Container(
            width: 200,
            height: 200,
            child: Lottie.asset(
              answer ? 'assets/correct.json' : 'assets/incorrect.json',
              repeat: false,
            ),
          ),
        );
      },
    );
  }


  void _checkAnswer(String selected) async {
    if (selected == _currentQuestion['correct']) {
      _showSuccessAndExit(true);
    } else {
      _showSuccessAndExit(false);
    }
  }

  void _playIntroAndQuestion() async {
    _playSound('queanimalsuenasi.wav');

    await Future.delayed(Duration(seconds: 3)); // espera 2 segundos (ajusta según necesites)

    _playSound(_currentQuestion['sound']);
  }


  @override
  void initState() {
    super.initState();

    audioPlayer = AudioPlayer();

    // Verificar si la música de fondo está sonando y detenerla si es necesario
    _wasBackgroundMusicPlaying = _backgroundMusic.isPlaying;
    if (_wasBackgroundMusicPlaying) {
      _backgroundMusic.stop();
    }

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    _currentQuestion = (_questions..shuffle()).first; // elige aleatorio al entrar

    _playIntroAndQuestion();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();

    // Restaurar la música de fondo si estaba sonando antes de entrar
    if (_wasBackgroundMusicPlaying) {
      _backgroundMusic.play();
    }

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_showCorrect) {
      return Container(
        width: 200,
        height: 200,
        child: Lottie.asset('assets/correct.json', repeat: false),
      );
    }

    if (_showIncorrect) {
      return Container(
        width: 200,
        height: 200,
        child: Lottie.asset('assets/incorrect.json', repeat: false),
      );
    }

    return Scaffold(
      backgroundColor: Color(0xFFEAF6F6),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Espaciado lateral si se quiere
            SizedBox(width: 40),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '¿Qué suena así?',
                    style: GoogleFonts.openSans(
                      textStyle: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF7C3AC8) )
                    )
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () => _playIntroAndQuestion(),
                    child: Icon(Icons.volume_up, size: 40),
                    style: ElevatedButton.styleFrom(
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(20),
                    ),
                  ),
                  SizedBox(height: 40),
                  Wrap(
                    spacing: 30,
                    runSpacing: 30,
                    alignment: WrapAlignment.center,
                    children: _currentQuestion['options'].map<Widget>((img) {
                      return GestureDetector(
                        onTap: () => _checkAnswer(img),
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset('assets/$img', width: 80, height: 80),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            SizedBox(width: 40),
          ],
        ),
      ),
    );
  }
}
