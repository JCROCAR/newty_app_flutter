import 'dart:math';
import 'package:educapp_demo/widgets/instructions_text.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../services/actividad_registrada_service.dart';

class LogicScreen7 extends StatefulWidget {
  final int actividadId;

  const LogicScreen7({required this.actividadId, Key? key}) : super(key: key);

  @override
  State<LogicScreen7> createState() => _LogicScreen7State();
}

class _LogicScreen7State extends State<LogicScreen7> {
  List<Map<String, dynamic>> _objects = [];
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _generateObjects();
  }

  void _generateObjects() {
    final random = Random();
    final sizes = [60.0, 100.0, 140.0, 180.0, 220.0];
    sizes.shuffle(random);

    setState(() {
      _objects = sizes.map((s) {
        return {'size': s, 'id': UniqueKey()};
      }).toList();
      _isCompleted = false;
    });
  }

  Future<void> _checkOrder() async {
    final sizes = _objects.map((o) => o['size'] as double).toList();
    final sorted = List<double>.from(sizes)..sort();

    if (sizes.toString() == sorted.toString()) {
      setState(() => _isCompleted = true);

      await PostRegistrarActividad.submitData(actividad: widget.actividadId);

      // Animación de éxito centrada
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Center(
          child: SizedBox(
            width: 200,
            height: 200,
            child: Lottie.asset('assets/correct.json', repeat: false),
          ),
        ),
      );

      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pop(context);
        Navigator.pop(context);
      });
    }
  }

  Widget _buildTree(double size, double width) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color(0xFF6BACB4).withOpacity(0.5),
              width: size / 45, // borde dinámico
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.white24,
                blurRadius: size / 18,  // sombra dinámica
                spreadRadius: size / 80,
              ),
            ],
          ),
          child: Image.asset(
            'assets/arbol.png',
            height: size,
            width: width * 0.8,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 6)
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF8F9),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 16),
              const TitleText(text:
                'Ordena de menor a mayor tamaño',
              ),
              const SizedBox(height: 24),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final spacing = 12.0;
                    final maxWidth = constraints.maxWidth;

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(_objects.length, (index) {
                        final obj = _objects[index];
                        final imageWidth =
                            (maxWidth / _objects.length) - (spacing * 0.5);

                        return Expanded(
                          child: DragTarget<int>(
                            onWillAccept: (_) => true,
                            onAccept: (fromIndex) {
                              setState(() {
                                final item = _objects.removeAt(fromIndex);
                                _objects.insert(index, item);
                              });
                              _checkOrder();
                            },
                            builder: (context, candidateData, rejectedData) {
                              return Container(
                                height: constraints.maxHeight,
                                alignment: Alignment.bottomCenter,
                                child: Draggable<int>(
                                  data: index,
                                  feedback: Material(
                                    color: Colors.transparent,
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: _buildTree(obj['size'], imageWidth),
                                    ),
                                  ),
                                  childWhenDragging: Opacity(
                                    opacity: 0.3,
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: _buildTree(obj['size'], imageWidth),
                                    ),
                                  ),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: _buildTree(obj['size'], imageWidth),
                                  ),
                                ),
                              );
                            },
                          ),
                        );

                      }),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
