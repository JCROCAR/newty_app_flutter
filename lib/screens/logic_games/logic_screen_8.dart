import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:educapp_demo/widgets/instructions_text.dart';
import '../../services/actividad_registrada_service.dart';

class LogicScreen8 extends StatefulWidget {
  final int actividadId;

  const LogicScreen8({super.key, required this.actividadId});

  @override
  State<LogicScreen8> createState() => _LogicScreen8State();
}

class _LogicScreen8State extends State<LogicScreen8> {
  String mensaje = ""; // Mensaje mostrado al presionar una flecha
  Map<String, bool> completado = {
    "arriba": false,
    "abajo": false,
    "izquierda": false,
    "derecha": false,
  };

  Future<void> _verificarCompletado() async {
    if (!completado.containsValue(false)) {
      // Mostrar animación correcta
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Center(
          child: SizedBox(
            width: 200,
            height: 200,
            child: Lottie.asset(
              "assets/correct.json",
              repeat: false,
            ),
          ),
        ),
      );

      await PostRegistrarActividad.submitData(actividad: widget.actividadId);
      await Future.delayed(const Duration(seconds: 2));

      Navigator.pop(context);
      Navigator.pop(context);
    }
  }

  void _presionarFlecha(String direccion) {
    setState(() {
      switch (direccion) {
        case "arriba":
          mensaje = "Arriba";
          break;
        case "abajo":
          mensaje = "Abajo";
          break;
        case "izquierda":
          mensaje = "Izquierda";
          break;
        case "derecha":
          mensaje = "Derecha";
          break;
      }

      completado[direccion] = true;
    });

    _verificarCompletado();
  }

  Widget _buildArrowButton(String direccion, IconData icono) {
    return ElevatedButton(
      onPressed: () => _presionarFlecha(direccion),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF6BACB4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        padding: const EdgeInsets.all(18),
      ),
      child: Icon(
        icono,
        color: Colors.white,
        size: 42,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2FBFC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 📌 IZQUIERDA: Instrucción + texto mostrado
              Expanded(
                flex: 4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const TitleText(
                      text: "Presiona las flechas para conocer las direcciones",
                    ),
                    const SizedBox(height: 40),
                    Text(
                      mensaje,
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6BACB4),
                      ),
                    ),
                  ],
                ),
              ),

              // 📌 DERECHA: Flechas acomodadas correctamente
              Expanded(
                flex: 4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 🔼 Flecha arriba
                    _buildArrowButton("arriba", Icons.arrow_upward),
                    const SizedBox(height: 30),

                    // ⬅️  ➡️ Flechas izquierda y derecha
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildArrowButton("izquierda", Icons.arrow_back),
                        _buildArrowButton("derecha", Icons.arrow_forward),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // 🔽 Flecha abajo
                    _buildArrowButton("abajo", Icons.arrow_downward),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
