import 'package:educapp_demo/utils/audio_singleton.dart'; // Importa tu Singleton
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/actividad_registrada_service.dart';


class ScienceScreen1 extends StatefulWidget {
  final int actividadId;

  ScienceScreen1({required this.actividadId});

  @override
  _ScienceScreen1State createState() => _ScienceScreen1State();
}

class _ScienceScreen1State extends State<ScienceScreen1> {

  bool hasAnswered = false;
  bool isCorrectAnswer = false;
  int selectedIndex = -1; // Índice de la imagen seleccionada
  late AudioPlayer audioPlayer; // Reproductor para el sonido del pollo
  final BackgroundMusic _backgroundMusic = BackgroundMusic(); // Singleton para la música de fondo
  bool _wasBackgroundMusicPlaying = false; // Estado previo de la música de fondo

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();

    // Forzar orientación horizontal y ocultar barra de estado
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // Verificar si la música de fondo está sonando y detenerla si es necesario
    _wasBackgroundMusicPlaying = _backgroundMusic.isPlaying;
    if (_wasBackgroundMusicPlaying) {
      _backgroundMusic.stop();
    }

    // Reproducir el sonido del pollo
    playChickenSound();
  }

  @override
  void dispose() {
    audioPlayer.dispose(); // Liberar recursos del reproductor del pollo

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

  Future<void> playChickenSound() async {
    await audioPlayer.play(AssetSource('chick_sound.mp3')); // Sonido del pollo
  }

  void checkAnswer(bool isChicken, int index) {
    setState(() {
      selectedIndex = index;
      hasAnswered = true;
      isCorrectAnswer = isChicken;
      if (isCorrectAnswer) {
        Future.delayed(const Duration(seconds: 2), () async {
          if (mounted) {
            await PostRegistrarActividad.submitData(actividad: widget.actividadId);
            Navigator.pop(context); // Salir si es correcto
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF87C5C4).withOpacity(0.7),
      body: Stack(
        children: [
          Positioned(
            top: 20,
            right: 20,
            child: IconButton(
              icon: Icon(Icons.volume_up, size: 40, color: Colors.white),
              onPressed: playChickenSound,
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Texto
                 Text(
                  '¿Qué animal hace este sonido?',
                  style: GoogleFonts.openSans(
                    textStyle: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF7C3AC8)
                    ),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 25),
                // Imágenes en fila horizontal
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      buildAnimalOption(0, 'assets/cow.png', false), // Vaca
                      const SizedBox(width: 20),
                      buildAnimalOption(1, 'assets/chicken.png', true), // Pollo
                      const SizedBox(width: 20),
                      buildAnimalOption(2, 'assets/dog.png', false), // Perro
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Animación de resultado
                if (hasAnswered)
                  isCorrectAnswer
                      ? Lottie.asset('assets/correct.json', height: 150, width: 150)
                      : Lottie.asset('assets/incorrect.json', height: 150, width: 150),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildAnimalOption(int index, String imagePath, bool isChicken) {
    bool isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () => checkAnswer(isChicken, index),
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[100] : Colors.white,
          border: Border.all(
            color: isSelected
                ? (isCorrectAnswer && isChicken ? Colors.green : Colors.red)
                : Colors.black,
            width: 3,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Image.asset(imagePath, fit: BoxFit.contain),
      ),
    );
  }
}