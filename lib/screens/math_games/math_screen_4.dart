import 'package:educapp_demo/widgets/instructions_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'dart:math';
import '../../services/actividad_registrada_service.dart';

class MathScreen4 extends StatefulWidget {
  final int actividadId;

  MathScreen4({required this.actividadId});

  @override
  State<MathScreen4> createState() => _MathScreen4State();
}

class _MathScreen4State extends State<MathScreen4> {
  int _targetNumber = 1;
  int _objectsInBox = 0;
  bool _isCompleted = false;

  // 🔹 Lista de objetos disponibles
  final List<String> _items = [
    'manzana',
    'pelota',
    'fresa',
    'orange',
    'banana'
  ];

  late List<String> _availableItems;

  @override
  void initState() {
    super.initState();
    _generateNewChallenge();
  }

  void _generateNewChallenge() {
    final random = Random();
    setState(() {
      _targetNumber = random.nextInt(5) + 1; // número entre 1 y 5
      _availableItems = List.from(_items);
      _objectsInBox = 0;
      _isCompleted = false;
    });
  }

  Future<void> _checkCompletion() async {
    if (_objectsInBox == _targetNumber) {
      setState(() => _isCompleted = true);
      await PostRegistrarActividad.submitData(actividad: widget.actividadId);

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Dialog(
          backgroundColor: Colors.transparent,
          child: Center(
            child: Lottie.asset(
              'assets/correct.json',
              width: 200,
              height: 200,
              repeat: false,
            ),
          ),
        ),
      );

      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pop(context);
        Navigator.pop(context);
        //_generateNewChallenge();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2FBFC),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final objectSize = constraints.maxHeight * 0.15;

            return Column(
              children: [
                // 🔹 Texto superior centrado
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: TitleText(
                      text:
                      'Arrastra $_targetNumber ${_targetNumber == 1 ? "objeto" : "objetos"} a la caja',
                    ),
                  ),
                ),

                // 🔸 Área de juego horizontal
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 🔹 Objetos disponibles (lado izquierdo)
                      Container(
                        width: constraints.maxWidth * 0.35,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 15,
                          runSpacing: 15,
                          children: _availableItems.map((item) {
                            return Draggable<String>(
                              data: item,
                              feedback: Material(
                                color: Colors.transparent,
                                child: Image.asset(
                                  'assets/$item.png',
                                  width: objectSize,
                                  height: objectSize,
                                ),
                              ),
                              childWhenDragging: const SizedBox(), // 🔹 Desaparece al arrastrar
                              onDragCompleted: () {
                                setState(() {
                                  _availableItems.remove(item);
                                });
                              },
                              child: Image.asset(
                                'assets/$item.png',
                                width: objectSize,
                                height: objectSize,
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      // 🔸 Caja o vagón (lado derecho)
                      Expanded(
                        child: DragTarget<String>(
                          builder: (context, candidateData, rejectedData) {
                            return Container(
                              width: constraints.maxWidth * 0.45,
                              height: constraints.maxHeight * 0.7,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Image.asset(
                                    'assets/caja.png',
                                    fit: BoxFit.contain,
                                    width: constraints.maxWidth * 0.5,
                                  ),
                                  // 🔹 Indicador visual si hay objetos sobre el vagón
                                  if (candidateData.isNotEmpty)
                                    Container(
                                      width: constraints.maxWidth * 0.5,
                                      height: constraints.maxHeight * 0.7,
                                      decoration: BoxDecoration(
                                        color: Colors.orange.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                          onAccept: (data) {
                            setState(() {
                              _objectsInBox++;
                            });
                            _checkCompletion();
                          },
                        ),
                      ),
                    ],
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
