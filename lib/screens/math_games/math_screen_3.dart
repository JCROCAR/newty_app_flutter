import 'package:educapp_demo/widgets/instructions_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:educapp_demo/utils/audio_singleton.dart';
import 'package:audioplayers/audioplayers.dart';

import '../../services/actividad_registrada_service.dart';



class MathScreen3 extends StatefulWidget {
  final int actividadId;

  MathScreen3({required this.actividadId});

  @override
  _MathScreen3State createState() => _MathScreen3State();
}

class _MathScreen3State extends State<MathScreen3>
    with SingleTickerProviderStateMixin {

  List<int> _sequence = [];
  int? _correctAnswer;
  List<int> _options = [];
  bool _showFeedback = false;
  bool _isCorrect = false;
  bool _buttonsEnabled = true;
  late AnimationController _popController;
  late Animation<double> _popAnimation;
  final FlutterTts _flutterTts = FlutterTts();

  final BackgroundMusic _backgroundMusic = BackgroundMusic();
  bool _wasBackgroundMusicPlaying = false;

  @override
  void initState() {
    super.initState();
    _popController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _popAnimation = Tween<double>(begin: 1.0, end: 1.3)
        .chain(CurveTween(curve: Curves.easeOut))
        .animate(_popController);
    _generateSequence();

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
    _popController.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    if (_wasBackgroundMusicPlaying) {
      _backgroundMusic.play();
    }
    
    super.dispose();
  }

  void _generateSequence() {
    Random rng = Random();
    int start = rng.nextInt(3) + 1; // 1 to 3 for simpler start
    int step = 1; // fixed simple step

    _sequence = List.generate(3, (i) => start + (i * step));
    _correctAnswer = start + (3 * step);

    Set<int> optionsSet = {_correctAnswer!};
    while (optionsSet.length < 3) {
      int offset = rng.nextInt(3) + 1;
      int wrongAnswer = rng.nextBool()
          ? _correctAnswer! + offset
          : _correctAnswer! - offset;
      if (wrongAnswer != _correctAnswer && wrongAnswer > 0) {
        optionsSet.add(wrongAnswer);
      }
    }
    _options = optionsSet.toList()..shuffle();

    setState(() {
      _showFeedback = false;
      _buttonsEnabled = true;
    });

    // Lee la secuencia cuando se genera una nueva
    _readSequence();
  }

  Future<void> _playAudio(String filename) async {
    final player = AudioPlayer();
    await player.play(AssetSource('$filename.wav'));
  }

  void _readSequence() {
    String seqText = 'Completa la secuencia: ';
    seqText += _sequence.join(', ');
    seqText += ', ... ¿Cuál sigue?';
    _playAudio('completascuencia');
  }

  void _checkAnswer(int selected) {
    if (!_buttonsEnabled) return;

    setState(() {
      _isCorrect = selected == _correctAnswer;
      _showFeedback = true;
      _buttonsEnabled = false;
    });

    if (_isCorrect) {
      _popController.forward(from: 0);
      Future.delayed(Duration(seconds: 2), () async {
        await PostRegistrarActividad.submitData(actividad: widget.actividadId);
        Navigator.pop(context);
      });
    } else {
      // En caso de error, solo muestra la animación, y luego permite intentar de nuevo sin cambiar secuencia
      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          _showFeedback = false;
          _buttonsEnabled = true;
        });
        // Puedes repetir la secuencia para dar pista al usuario
        _readSequence();
      });
    }
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: TitleText(text: 'Completa la secuencia:')
                      ),
                      Positioned(
                        top: 20,
                        right: 20,
                        child: IconButton(
                          icon: Icon(Icons.volume_up, size: 40, color: Color(0xFFFF9800).withOpacity(0.8)),
                          onPressed: () {
                            _readSequence();
                          },
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var number in _sequence)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            number.toString(),
                            style: GoogleFonts.openSans(
                              textStyle: TextStyle(
                                fontSize: 36,
                                color: Colors.blueAccent.withOpacity(0.8),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          '...',
                          style: TextStyle(
                            fontSize: 36,
                            fontFamily: 'kbdarkhour',
                            color: Colors.blueAccent.withOpacity(0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: _options.map((number) {
                      return ElevatedButton(
                        onPressed:
                        _buttonsEnabled ? () => _checkAnswer(number) : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFEF898F).withOpacity(0.9),
                          padding: EdgeInsets.all(20),
                          shape: CircleBorder(),
                          elevation: 6,
                        ),
                        child: Text(
                          number.toString(),
                          style: GoogleFonts.openSans(
                            textStyle: TextStyle(
                              fontSize: 28,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
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
          if (_showFeedback)
            Center(
              child: ScaleTransition(
                scale: _isCorrect ? _popAnimation : AlwaysStoppedAnimation(1),
                child: Lottie.asset(
                  _isCorrect
                      ? 'assets/correct.json'
                      : 'assets/incorrect.json',
                  width: 200,
                  height: 200,
                  repeat: false,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
