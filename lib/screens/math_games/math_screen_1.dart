import 'dart:math';
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
    {'name': 'manzana', 'image': 'apple.png', 'plural': 'manzanas'},
    {'name': 'banana', 'image': 'banana.png', 'plural': 'bananas'},
    {'name': 'naranja', 'image': 'orange.png', 'plural': 'naranjas'},
    {'name': 'fresa', 'image': 'strawberry.png', 'plural': 'fresas'},
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
      backgroundColor: const Color(0xFF87C5C4).withOpacity(0.7),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // 🟣 Pregunta
            Column(
              children: [
                Text(
                  "¿Cuántas ${fruits.firstWhere((f) => f['name'] == selectedFruit)['plural']} puedes ver?",
                  style: GoogleFonts.openSans(
                    textStyle: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF7C3AC8),
                    ),
                  ),
                  textAlign: TextAlign.center,
                ),
                Positioned(
                  top: 20,
                  right: 20,
                  child: IconButton(
                    icon: Icon(Icons.volume_up, size: 40, color: Colors.white),
                    onPressed: () {
                      _playAudio("cuantas${fruits.firstWhere((f) => f['name'] == selectedFruit)['plural']}");
                    },
                  ),
                ),
              ],
            ),

            // 🍎 Frutas mostradas horizontalmente
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  fruitCount,
                      (_) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Image.asset(
                      'assets/$fruitImage',
                      width: 70,
                      height: 70,
                    ),
                  ),
                ),
              ),
            ),

            // 🔢 Opciones de respuesta
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: options.map((value) {
                bool isSelected = selectedAnswer == value;
                return GestureDetector(
                  onTap: () => _handleAnswer(value),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.lightBlue[100],
                      border: Border.all(
                        color: isSelected
                            ? (isCorrect == true ? Colors.green : Colors.red)
                            : Colors.blue,
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      value.toString(),
                      style: GoogleFonts.openSans(
                        textStyle: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7C3AC8),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            // ✅ Feedback
            if (isCorrect != null)
              Lottie.asset(
                isCorrect!
                    ? 'assets/correct.json'
                    : 'assets/incorrect.json',
                width: 120,
                height: 120,
                repeat: false,
              ),
          ],
        ),
      ),
    );
  }
}
