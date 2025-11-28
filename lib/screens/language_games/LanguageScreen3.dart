import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:educapp_demo/utils/audio_singleton.dart'; // Importa tu Singleton
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

import '../../services/actividad_registrada_service.dart';
import '../../widgets/instructions_text.dart';


class LanguageScreen3 extends StatefulWidget {

  final int actividadId;

  LanguageScreen3({required this.actividadId});

  @override
  _LanguageScreen3State createState() => _LanguageScreen3State();
}

class _LanguageScreen3State extends State<LanguageScreen3> {

  final int gameID = 3;

  final FlutterTts _flutterTts = FlutterTts();
  final List<_WordItem> _items = [
    _WordItem(image: 'assets/casa.png', word: 'CASA'),
    _WordItem(image: 'assets/pelota.png', word: 'PELOTA'),
    _WordItem(image: 'assets/vehiculo.png', word: 'VEHICULO'),
    _WordItem(image: 'assets/estrella.png', word: 'ESTRELLA'),
    _WordItem(image: 'assets/silla.png', word: 'SILLA'),
  ];

  late AudioPlayer audioPlayer; // Reproductor para el sonido del pollo
  final BackgroundMusic _backgroundMusic = BackgroundMusic(); // Singleton para la música de fondo
  bool _wasBackgroundMusicPlaying = false; // Estado previo de la música de fondo

  late _WordItem _currentItem;
  List<Color> _letterColors = [];
  final Color _fixedColor = Color(0XFFEF898F); // Color fijo para colorear letras

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

    _speakIntro();

    _currentItem = _items[Random().nextInt(_items.length)];
    _letterColors = List.generate(_currentItem.word.length, (index) => Colors.grey);
  }


  Future<void> _speakCurrentWord() async {
    final player = AudioPlayer();
    final fileName = _currentItem.word.toLowerCase(); // sol, nube, luna
    await player.play(AssetSource('$fileName.wav'));
  }

  Future<void> _speakIntro() async {
    final player = AudioPlayer();
    await player.play(AssetSource('colorealasletras.wav'));
  }


  Future<void> _onLetterTap(int index) async {
    setState(() {
      _letterColors[index] = _fixedColor;
    });

    final allColored = _letterColors.every((color) => color != Colors.black.withOpacity(0.5));
    if (allColored) {
      await _speakCurrentWord();
      await Future.delayed(Duration(milliseconds: 1000));
      await _showCorrectAnimation();
      await PostRegistrarActividad.submitData(actividad: widget.actividadId);
      Navigator.of(context).pop();
    }
  }

  Future<void> _showCorrectAnimation() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        Future.delayed(Duration(seconds: 2), () {
          Navigator.of(context).pop();
        });

        return Center(
          child: Container(
            width: 200,
            height: 200,
            child: Lottie.asset(
              'assets/correct.json',
              repeat: false,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2FBFC),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Center(
                    child: TitleText(text: 'Colorea las letras'),
                  ),
                  Positioned(
                    right: 125,
                    child: IconButton(
                      icon:  Icon(Icons.volume_up,
                          size: 40, color: Color(0xFFFF9800).withOpacity(0.8)),
                      onPressed: _speakIntro, // 🔈 Aquí irá la función para reproducir audio
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            Container(
              constraints: BoxConstraints(maxHeight: 150, maxWidth: 150),
              child: Image.asset(_currentItem.image, fit: BoxFit.contain),
            ),
            SizedBox(height: 20),
            Wrap(
              spacing: 8,
              children: List.generate(
                _currentItem.word.length,
                    (index) => GestureDetector(
                  onTap: () => _onLetterTap(index),
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.transparent),
                      color: _letterColors[index],
                    ),
                    child: Text(
                      _currentItem.word[index],
                      style:GoogleFonts.openSans(
                        textStyle: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      )
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
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

  _WordItem({required this.image, required this.word});
}
