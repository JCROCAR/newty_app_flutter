import 'package:educapp_demo/widgets/instructions_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:educapp_demo/services/actividad_registrada_service.dart';

class LogicScreen6 extends StatefulWidget {
  final int actividadId;

  const LogicScreen6({required this.actividadId, super.key});

  @override
  State<LogicScreen6> createState() => _LogicScreen6State();
}

class _LogicScreen6State extends State<LogicScreen6> {
  final List<String> _positions = ['1', '2', '3', '4'];
  late List<String> _availablePieces;
  final Map<String, String?> _placedPieces = {};

  @override
  void initState() {
    super.initState();
    _availablePieces = List.from(_positions)..shuffle();
    for (var p in _positions) {
      _placedPieces[p] = null;
    }
  }

  void _checkIfCompleted() async {
    if (_placedPieces.entries.every((e) => e.key == e.value)) {
      await PostRegistrarActividad.submitData(actividad: widget.actividadId);

      showDialog(
        context: context,
        barrierDismissible: false, // evita cerrar tocando fuera
        barrierColor: Colors.black.withOpacity(0.5), // fondo semitransparente
        builder: (_) => Center(
          child: SizedBox(
            width: 200,
            height: 200,
            child: Lottie.asset(
              'assets/correct.json',
              repeat: false,
              onLoaded: (composition) {
                // Cierra automáticamente al terminar la animación
                Future.delayed(
                  composition.duration + const Duration(seconds: 2),
                      () {
                    Navigator.pop(context); // cierra el diálogo
                    Navigator.pop(context); // vuelve a la pantalla anterior
                  },
                );
              },
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2FBFC),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Center(
                    child: TitleText(text: 'Arma el rompecabezas'),
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
            const SizedBox(height: 24),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // 🔹 Lado izquierdo: piezas disponibles
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _availablePieces.map((piece) {
                      return Draggable<String>(
                        data: piece,
                        feedback: Material(
                          color: Colors.transparent,
                          child: Image.asset(
                            'assets/pieza_$piece.png',
                            width: 150,
                            fit: BoxFit.contain,
                          ),
                        ),
                        childWhenDragging: Opacity(
                          opacity: 0.3,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Image.asset(
                              'assets/pieza_$piece.png',
                              width: 150,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Image.asset(
                            'assets/pieza_$piece.png',
                            width: 150,
                            fit: BoxFit.contain,
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  // 🔹 Lado derecho: slots vacíos
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: _positions.map((pos) {
                          return DragTarget<String>(
                            builder: (context, candidateData, rejectedData) {
                              final placedPiece = _placedPieces[pos];
                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 2), // menos espacio
                                width: 140, // antes 180
                                height: 50, // antes 90
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: candidateData.isNotEmpty
                                        ? Colors.orange
                                        : const Color(0xFF6BACB4),
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: placedPiece != null
                                    ? Image.asset(
                                  'assets/pieza_$placedPiece.png',
                                  fit: BoxFit.cover,
                                )
                                    : const SizedBox.shrink(),
                              );
                            },
                            onWillAccept: (data) => data == pos,
                            onAccept: (data) {
                              setState(() {
                                _placedPieces[pos] = data;
                                _availablePieces.remove(data);
                              });
                              Future.delayed(const Duration(seconds: 1), () {
                                _checkIfCompleted();
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
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
