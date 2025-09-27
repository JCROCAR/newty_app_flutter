import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/services.dart';
import 'package:educapp_demo/utils/audio_singleton.dart'; // Importa tu Singleton
import 'package:audioplayers/audioplayers.dart';

import '../../services/actividad_registrada_service.dart';



class LanguageScreen2 extends StatefulWidget {

  final int actividadId;

  LanguageScreen2({required this.actividadId});

  @override
  _LanguageScreen2State createState() => _LanguageScreen2State();
}

class _LanguageScreen2State extends State<LanguageScreen2> {

  final int gameID = 2;

  final List<_WordItem> _items = [
    _WordItem(image: 'assets/sol.png', word: 'sol', missingIndex: 1),           // S_L
    _WordItem(image: 'assets/luna.png', word: 'luna', missingIndex: 1),         // L_NA
    _WordItem(image: 'assets/nube.png', word: 'nube', missingIndex: 1),         // N_BE
  ];

  late AudioPlayer audioPlayer; // Reproductor para el sonido del pollo
  final BackgroundMusic _backgroundMusic = BackgroundMusic(); // Singleton para la música de fondo
  bool _wasBackgroundMusicPlaying = false; // Estado previo de la música de fondo

  late _WordItem _currentItem;
  String? _droppedLetter;

  @override
  void initState() {
    super.initState();

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

    _currentItem = _items[Random().nextInt(_items.length)];
    _speakCurrentWord();
  }


  Future<void> _speakCurrentWord() async {
    final player = AudioPlayer();
    final fileName = _currentItem.word.toLowerCase(); // sol, nube, luna
    await player.play(AssetSource('$fileName.wav'));
  }


  void _checkAnswer(String letter) async {
    final correctLetter = _currentItem.word[_currentItem.missingIndex];

    setState(() {
      _droppedLetter = letter.toUpperCase();
    });

    await Future.delayed(Duration(milliseconds: 500));

    if (letter.toLowerCase() == correctLetter.toLowerCase()) {
      _showFeedbackAnimation(true);
    } else {
      _showFeedbackAnimation(false);
    }
  }

  Future<void> _showFeedbackAnimation(bool isCorrect) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        Future.delayed(Duration(seconds: 2), () async {
          Navigator.of(context).pop();
          if (isCorrect) {
            await PostRegistrarActividad.submitData(actividad: widget.actividadId);
            Navigator.of(this.context).pop();
          } else {
            setState(() {
              _droppedLetter = null;
            });
          }
        });

        return Center(
          child: Container(
            width: 200,
            height: 200,
            child: Lottie.asset(
              isCorrect ? 'assets/correct.json' : 'assets/incorrect.json',
              repeat: false,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final missingIndex = _currentItem.missingIndex;
    final displayedWord = List.generate(
      _currentItem.word.length,
          (i) => i == missingIndex ? '_' : _currentItem.word[i].toUpperCase(),
    ).join();

    return Scaffold(
      backgroundColor: Color(0xFFEAF6F6),
      body: Stack(
        children: [
          Positioned(
            top: 40,
            right: 20,
            child: ElevatedButton(
              onPressed: () => _speakCurrentWord(),
              child: Icon(Icons.volume_up, size: 20),
              style: ElevatedButton.styleFrom(
                  shape: CircleBorder(),
                  padding: EdgeInsets.all(10)
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  constraints: BoxConstraints(maxHeight: 160, maxWidth: 160),
                  child: Image.asset(_currentItem.image, fit: BoxFit.contain),
                ),
                SizedBox(height: 20),
                DragTarget<String>(
                  onAccept: _checkAnswer,
                  builder: (context, candidateData, rejectedData) {
                    return Text(
                      _droppedLetter == null
                          ? displayedWord
                          : (_currentItem.word
                          .replaceRange(missingIndex, missingIndex + 1, _droppedLetter!)
                          .toUpperCase()),
                      style: GoogleFonts.openSans(
                        textStyle: TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7C3AC8)
                        ),
                      )
                    );
                  },
                ),

                SizedBox(height: 40),
                Wrap(
                  spacing: 20,
                  children: ['A', 'E', 'I', 'O', 'U']
                      .map((letter) => Draggable<String>(
                    data: letter,
                    feedback: _buildDraggableCircle(letter),
                    childWhenDragging: Opacity(
                      opacity: 0.3,
                      child: _buildDraggableCircle(letter),
                    ),
                    child: _buildDraggableCircle(letter),
                  ))
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),

    );
  }

  Widget _buildDraggableCircle(String letter) {
    return CircleAvatar(
      radius: 30,
      backgroundColor: Colors.white,
      child: Text(
        letter,
        style: GoogleFonts.openSans(
          textStyle: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Color(0xFF7C3AC8)
          ),
        )
      ),
    );
  }

  @override
  void dispose() {

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
}

class _WordItem {
  final String image;
  final String word;
  final int missingIndex;

  _WordItem({required this.image, required this.word, required this.missingIndex});
}
