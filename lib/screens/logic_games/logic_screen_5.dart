import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:educapp_demo/services/actividad_registrada_service.dart';

import '../../widgets/instructions_text.dart';

class LogicScreen5 extends StatefulWidget {
  final int actividadId;

  const LogicScreen5({required this.actividadId, super.key});

  @override
  State<LogicScreen5> createState() => _LogicScreen5State();
}

class _LogicScreen5State extends State<LogicScreen5> {
  final List<String> fruits = ['manzana', 'banana', 'naranja'];
  final Map<String, bool> collected = {};
  bool _showSuccess = false;

  @override
  void initState() {
    super.initState();
    for (var f in fruits) collected[f] = false;
  }

  void _checkCompletion() {
    if (collected.values.every((v) => v)) {
      setState(() => _showSuccess = true);
      _showSuccessAnimation();
    }
  }

  Future<void> _playAudio(String fileName) async {
    final player = AudioPlayer();
    await player.play(AssetSource('selecciona$fileName.wav'));
  }

  void _showSuccessAnimation() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        Future.delayed(const Duration(seconds: 2), () async {
          await PostRegistrarActividad.submitData(actividad: widget.actividadId);
          Navigator.of(dialogContext).pop(); // cierra el diálogo
          Navigator.of(context).pop();       // vuelve a la pantalla anterior
        });

        return Center(
          child: SizedBox(
            width: 200,
            height: 200,
            child: Lottie.asset('assets/correct.json', repeat: false),
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF6F6),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),

            // 🟣 Encabezado con texto e ícono
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Center(
                    child: TitleText(text: 'Lleva las frutas al cesto'),
                  ),
                  Positioned(
                    right: 125,
                    child: IconButton(
                      icon:  Icon(Icons.volume_up,
                          size: 40, color: Color(0xFFFF9800).withOpacity(0.8)),
                      onPressed: () {}, // 🔈 Aquí irá la función para reproducir audio
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 🍎 Cuerpo principal
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Frutas para arrastrar
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: fruits.map((fruit) {
                      if (collected[fruit]!) {
                        return const SizedBox(height: 80);
                      }
                      return Draggable<String>(
                        data: fruit,
                        feedback: Image.asset('assets/$fruit.png',
                            width: 80, height: 80),
                        childWhenDragging: Opacity(
                          opacity: 0.5,
                          child: Image.asset('assets/$fruit.png',
                              width: 80, height: 80),
                        ),
                        child: Image.asset('assets/$fruit.png',
                            width: 80, height: 80),
                      );
                    }).toList(),
                  ),

                  // 🧺 Cesto
                  DragTarget<String>(
                    builder: (context, candidateData, rejectedData) => Image.asset(
                      'assets/cesto.png',
                      width: 135,
                      height: 135,
                    ),
                    onWillAccept: (data) => fruits.contains(data),
                    onAccept: (data) {
                      setState(() {
                        collected[data] = true;
                      });
                      _checkCompletion();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
