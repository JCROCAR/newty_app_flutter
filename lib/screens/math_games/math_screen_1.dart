import 'dart:math';
import 'package:educapp_demo/widgets/instructions_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:educapp_demo/utils/audio_singleton.dart';
import 'package:audioplayers/audioplayers.dart';

import '../../services/actividad_registrada_service.dart';


class MathScreen1 extends StatefulWidget {
  final int actividadId;

  MathScreen1({required this.actividadId});

  @override
  _MathScreen1State createState() => _MathScreen1State();

}

class _MathScreen1State extends State<MathScreen1>  {


  final Random _random = Random();

  int fruitCount = 1;
  String selectedFruit = 'manzana';
  String fruitImage = 'apple.png';
  List<int> options = [];
  int? selectedAnswer;
  bool? isCorrect;

  final BackgroundMusic _backgroundMusic = BackgroundMusic();
  bool _wasBackgroundMusicPlaying = false;

  final List<Map<String, String>> fruits = [
    {'name': 'manzana', 'image': 'manzana.png', 'plural': 'manzanas'},
    {'name': 'banana', 'image': 'banana.png', 'plural': 'bananas'},
    {'name': 'naranja', 'image': 'naranja.png', 'plural': 'naranjas'},
    {'name': 'fresa', 'image': 'fresa.png', 'plural': 'fresas'},
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _generateQuestion();

    _wasBackgroundMusicPlaying = _backgroundMusic.isPlaying;
    if (_wasBackgroundMusicPlaying) {
      _backgroundMusic.stop();
    }
  }

  Future<void> _playAudio(String fileName) async {
    final player = AudioPlayer();
    await player.play(AssetSource('$fileName.wav'));
  }



  void _generateQuestion() {
    setState(() {
      selectedAnswer = null;
      isCorrect = null;

      fruitCount = _random.nextInt(5) + 1; // 1–5
      final fruit = fruits[_random.nextInt(fruits.length)];
      selectedFruit = fruit['name']!;
      fruitImage = fruit['image']!;

      options = _generateOptions(fruitCount);
    });

    _playAudio("cuantas${fruits.firstWhere((f) => f['name'] == selectedFruit)['plural']}");
    print("cuantas${fruitCount == 1 ? selectedFruit : fruits.firstWhere((f) => f['name'] == selectedFruit)['plural']}_$fruitCount");

  }

  List<int> _generateOptions(int correctAnswer) {
    final options = <int>{correctAnswer};
    while (options.length < 3) {
      options.add(_random.nextInt(5) + 1);
    }
    return options.toList()..sort();
  }

  void _handleAnswer(int value) {
    setState(() {
      selectedAnswer = value;
      isCorrect = value == fruitCount;
    });

    if (isCorrect!) {
      Future.delayed(const Duration(seconds: 3), () async {
        if (mounted) {
          await PostRegistrarActividad.submitData(actividad: widget.actividadId);
          Navigator.pop(context);
        }
      });
    } else {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            selectedAnswer = null;
            isCorrect = null;
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
    return Scaffold(
      backgroundColor: const Color(0xFFF2FBFC),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenHeight = constraints.maxHeight;
            final screenWidth = constraints.maxWidth;

            return Stack(
              alignment: Alignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: screenHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // 🟣 Pregunta + Botón de audio
                            Stack(
                              alignment: Alignment.centerRight,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 60),
                                  child: TitleText(text: "¿Cuántas ${fruits.firstWhere((f) => f['name'] == selectedFruit)['plural']} puedes ver?")
                                ),
                                IconButton(
                                  icon:  Icon(Icons.volume_up,
                                      size: 40, color: Color(0xFFFF9800).withOpacity(0.8)),
                                  onPressed: () {
                                    _playAudio(
                                        "cuantas${fruits.firstWhere((f) => f['name'] == selectedFruit)['plural']}");
                                  },
                                ),
                              ],
                            ),

                            SizedBox(height: screenHeight * 0.04),

                            // 🍎 Frutas mostradas horizontalmente
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  fruitCount,
                                      (_) => Padding(
                                    padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                    child: Image.asset(
                                      'assets/$fruitImage',
                                      width: screenWidth * 0.15,
                                      height: screenHeight * 0.25,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: screenHeight * 0.05),

                            // 🔢 Opciones de respuesta
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: options.map((value) {
                                bool isSelected = selectedAnswer == value;
                                return GestureDetector(
                                  onTap: () => _handleAnswer(value),
                                  child: Container(
                                    padding: const EdgeInsets.all(18),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.1),
                                      border: Border.all(
                                        color: isSelected
                                            ? (isCorrect == true
                                            ? Colors.blueAccent
                                            : Colors.red)
                                            : Colors.transparent,
                                        width: 3,
                                      ),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Text(
                                      value.toString(),
                                      style: GoogleFonts.openSans(
                                        textStyle: TextStyle(
                                          fontSize: screenHeight * 0.08,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blueAccent,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),

                            SizedBox(height: screenHeight * 0.05),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // ✅ Animación superpuesta centrada
                if (isCorrect != null)
                  Center(
                    child: Lottie.asset(
                      isCorrect! ? 'assets/correct.json' : 'assets/incorrect.json',
                      width: screenWidth * 0.5,
                      height: screenHeight * 0.6,
                      repeat: false,
                    ),
                  ),
              ],
            );
          },
        ),
      ),


    );
  }
}
