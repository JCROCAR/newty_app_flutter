import 'package:educapp_demo/widgets/instructions_text.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'dart:math';
import '../../services/actividad_registrada_service.dart';


class MathScreen5 extends StatefulWidget {
  final int actividadId;

  MathScreen5({required this.actividadId});

  @override
  State<MathScreen5> createState() => _MathScreen5State();
}

class _MathScreen5State extends State<MathScreen5> {
  bool _isCorrect = false;
  bool _showResult = false;
  int leftCount = 0;
  int rightCount = 0;
  String leftImage = '';
  String rightImage = '';

  final List<String> _images = [
    'assets/estrella.png',
    'assets/luna.png',
    'assets/sol.png',
    'assets/nube.png',
  ];

  @override
  void initState() {
    super.initState();
    _generateRound();
  }

  void _generateRound() {
    final random = Random();
    setState(() {
      leftCount = random.nextInt(5) + 1; // 1 a 5
      rightCount = random.nextInt(5) + 1; // 1 a 5
      leftImage = _images[random.nextInt(_images.length)];
      rightImage = _images[random.nextInt(_images.length)];
      _showResult = false;
    });
  }

  void _handleTap(bool isLeft) async {
    final correct = (isLeft && leftCount > rightCount) ||
        (!isLeft && rightCount > leftCount);

    setState(() {
      _isCorrect = correct;
      _showResult = true;
    });

    if (correct) {
      await PostRegistrarActividad.submitData(actividad: widget.actividadId);
    }

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
      //_generateRound(); // Si luego quieres que repita el juego, descomenta esta línea
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFFEFF8F9),
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            if (_showResult)
              Center(
                child: Lottie.asset(
                  _isCorrect
                      ? 'assets/correct.json'
                      : 'assets/incorrect.json',
                  width: 250,
                  height: 250,
                  repeat: false,
                ),
              ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const TitleText(text:
                  'Toca el grupo con más objetos'
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: _showResult ? null : () => _handleTap(true),
                      child: _buildGroup(leftImage, leftCount),
                    ),
                    GestureDetector(
                      onTap: _showResult ? null : () => _handleTap(false),
                      child: _buildGroup(rightImage, rightCount),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroup(String imagePath, int count) {
    return Container(
      padding: const EdgeInsets.all(20),
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF6BACB4),
          width: 4,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Center(
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: List.generate(
            count,
                (index) => Image.asset(
              imagePath,
              width: 60,
              height: 60,
            ),
          ),
        ),
      ),
    );
  }
}
