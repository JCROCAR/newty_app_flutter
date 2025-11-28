import 'dart:math';
import 'package:educapp_demo/widgets/instructions_text.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../services/actividad_registrada_service.dart';

class MathScreen6 extends StatefulWidget {
  final int actividadId;

  const MathScreen6({super.key, required this.actividadId});

  @override
  State<MathScreen6> createState() => _MathScreen6State();
}

class _MathScreen6State extends State<MathScreen6> {
  // 🔥 Rango dinámico
  final int minValor = 3;
  final int maxValor = 10;

  late int objetivo;
  int contador = 0;

  @override
  void initState() {
    super.initState();
    _generarNumero();
  }

  void _generarNumero() {
    objetivo = Random().nextInt(maxValor - minValor + 1) + minValor;
  }

  Future<void> _verificarCompletado() async {
    if (contador == objetivo) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Center(
          child: SizedBox(
            width: 220,
            height: 220,
            child: Lottie.asset("assets/correct.json", repeat: false),
          ),
        ),
      );

      await PostRegistrarActividad.submitData(actividad: widget.actividadId);

      await Future.delayed(const Duration(seconds: 2));
      Navigator.pop(context);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF9FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 📌 Panel izquierdo: instrucción + contador
              Expanded(
                flex: 4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TitleText(
                      text: "Presiona el botón $objetivo veces",
                    ),

                    const SizedBox(height: 40),

                    Text(
                      "$contador",
                      style: const TextStyle(
                        fontSize: 110,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6BACB4),
                      ),
                    ),
                  ],
                ),
              ),

              // 📌 Panel derecho: botón grande
              Expanded(
                flex: 3,
                child: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (contador < objetivo) {
                        setState(() {
                          contador++;
                        });
                        _verificarCompletado();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6BACB4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 50,
                        vertical: 35,
                      ),
                    ),
                    child: const Text(
                      "Presionar",
                      style: TextStyle(
                        fontSize: 32,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
