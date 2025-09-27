import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:educapp_demo/utils/audio_singleton.dart';

import '../../services/actividad_registrada_service.dart';




class ScienceScreen2 extends StatefulWidget {
  final int actividadId;

  ScienceScreen2({required this.actividadId});

  @override
  _ScienceScreen2State createState() => _ScienceScreen2State();
}

class _ScienceScreen2State extends State<ScienceScreen2> {


  final List<Map<String, dynamic>> _questions = [
    {
      'animal': 'Vaca',
      'image': 'assets/cow.png',
      'correctEnv': 'Granja',
    },
    {
      'animal': 'Tigre',
      'image': 'assets/tiger.png',
      'correctEnv': 'Jungla',
    },
    {
      'animal': 'Perro',
      'image': 'assets/dog.png',
      'correctEnv': 'Casa',
    },
    {
      'animal': 'Elefante',
      'image': 'assets/elephant.png',
      'correctEnv': 'Jungla',
    },
    {
      'animal': 'Pollito',
      'image': 'assets/chicken.png',
      'correctEnv': 'Granja',
    },
  ];


  late int _currentIndex;
  bool _showFeedback = false;
  bool _isCorrect = false;
  bool _buttonsEnabled = true;

  final BackgroundMusic _backgroundMusic = BackgroundMusic();
  bool _wasBackgroundMusicPlaying = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = _getRandomIndex();

    // Forzar orientación horizontal y ocultar barra de estado
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    _wasBackgroundMusicPlaying = _backgroundMusic.isPlaying;
    if (_wasBackgroundMusicPlaying) {
      _backgroundMusic.stop();
    }

    _playAudio('dondeviveesteanimal');
  }

  int _getRandomIndex() {
    return (DateTime.now().millisecondsSinceEpoch % _questions.length);
  }

  Future<void> _playAudio(String filename) async {
    final player = AudioPlayer();
    await player.play(AssetSource('$filename.wav'));
  }


  void _checkAnswer(String selectedEnv) {
    if (!_buttonsEnabled) return;

    final currentQuestion = _questions[_currentIndex];
    final correctEnv = currentQuestion['correctEnv']?.toString().trim();
    print('selectedEnv: $selectedEnv');
    print('correctEnv: $correctEnv');

    final bool correct = selectedEnv.trim() == correctEnv;

    setState(() {
      _isCorrect = correct;
      _showFeedback = true;
      _buttonsEnabled = false;
    });

    if (correct) {
      Future.delayed(Duration(seconds: 2), () async {
        await PostRegistrarActividad.submitData(actividad: widget.actividadId);
        if (mounted) Navigator.pop(context);
      });
    } else {
      Future.delayed(Duration(milliseconds: 1500), () {
        if (mounted) {
          setState(() {
            _showFeedback = false;
            _buttonsEnabled = true;
          });
        }
      });
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
    final question = _questions[_currentIndex];

    return Scaffold(
      backgroundColor: Color(0xFF6BACB4).withOpacity(0.7),
      body: Container(
        color: const Color(0xFF6BACB4).withOpacity(0.7),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Texto + ícono de volumen
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '¿Dónde vive este animal?',
                      style: GoogleFonts.openSans(
                        textStyle: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7C3AC8),
                        ),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: const Icon(Icons.volume_up, size: 40, color: Colors.white),
                      onPressed: () {
                        _playAudio('dondeviveesteanimal');
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Imagen del animal
                Image.asset(
                  question['image'],
                  height: 100,
                ),

                const SizedBox(height: 30),

                // Opciones: Granja, Jungla, Casa
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 20,
                  runSpacing: 20,
                  children: ['Granja', 'Jungla', 'Casa'].map((env) {
                    String imagePath;
                    switch (env) {
                      case 'Granja':
                        imagePath = 'assets/farm.jpg';
                        break;
                      case 'Jungla':
                        imagePath = 'assets/jungla.jpg';
                        break;
                      case 'Casa':
                        imagePath = 'assets/house.jpg';
                        break;
                      default:
                        imagePath = '';
                    }

                    return GestureDetector(
                      onTap: _buttonsEnabled ? () => _checkAnswer(env) : null,
                      child: Column(
                        children: [
                          Container(
                            width: 90,
                            height: 90,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 6,
                                  offset: Offset(2, 2),
                                ),
                              ],
                            ),
                            child: Image.asset(imagePath, fit: BoxFit.contain),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            env,
                            style: GoogleFonts.openSans(
                              textStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
