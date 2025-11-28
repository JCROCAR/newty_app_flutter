import 'dart:math';
import 'package:educapp_demo/widgets/instructions_text.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../services/actividad_registrada_service.dart';

class ScienceScreen5 extends StatefulWidget {
  final int actividadId;

  const ScienceScreen5({super.key, required this.actividadId});

  @override
  State<ScienceScreen5> createState() => _ScienceScreen5State();
}

class _ScienceScreen5State extends State<ScienceScreen5> {
  late List<Map<String, dynamic>> animales;
  late int _totalAnimals;

  // Ambientes: cada uno guarda la lista de animales que se colocaron ahí
  Map<String, List<Map<String, dynamic>>> ambientes = {
    "Aire": [],
    "Agua": [],
    "Tierra": [],
  };

  @override
  void initState() {
    super.initState();
    generarAnimales();
  }

  void generarAnimales() {
    final opciones = [
      {"ambiente": "Aire", "asset": "assets/ave.png", "name": "ave"},
      {"ambiente": "Aire", "asset": "assets/mariposa.png", "name": "mariposa"},
      {"ambiente": "Agua", "asset": "assets/pez.png", "name": "pez"},
      {"ambiente": "Agua", "asset": "assets/tortuga.png", "name": "tortuga"},
      {"ambiente": "Tierra", "asset": "assets/leon.png", "name": "leon"},
      {"ambiente": "Tierra", "asset": "assets/elefante.png", "name": "elefante"},
    ];

    // Tomar animales únicos (sin repetición) — aquí tomamos 3 como antes
    opciones.shuffle();
    animales = opciones.take(3).map((a) => Map<String, dynamic>.from(a)).toList();

    // Guarda el total inicial para la validación
    _totalAnimals = animales.length;
  }

  Future<void> checkCompletion() async {
    // Cuántos animales han sido colocados en total
    final totalPlaced = ambientes.values.fold(0, (sum, list) => sum + list.length);

    // Si no se han colocado todos, salir
    if (totalPlaced != _totalAnimals) return;

    // Verificar si TODOS están en el ambiente correcto
    bool allCorrect = true;
    for (var ambiente in ambientes.keys) {
      for (var animal in ambientes[ambiente]!) {
        if (animal["ambiente"] != ambiente) {
          allCorrect = false;
          break;
        }
      }
      if (!allCorrect) break;
    }

    // Mostrar animación según corresponda
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: SizedBox(
          width: 200,
          height: 200,
          child: Lottie.asset(
            allCorrect
                ? "assets/correct.json"
                : "assets/incorrect.json",
            repeat: false,
          ),
        ),
      ),
    );

    // Si todo correcto, registrar actividad
    if (allCorrect) {
      await PostRegistrarActividad.submitData(actividad: widget.actividadId);
    }

    // Esperar a que termine la animación
    await Future.delayed(const Duration(seconds: 2));

    // Cerrar el popup
    Navigator.pop(context);

    // Si todo correcto, también cerrar la pantalla (como antes)
    if (allCorrect) {
      Navigator.pop(context);
    }
    // Si fue incorrecto, mantenemos la pantalla abierta para que el usuario vea el resultado.
  }

  Widget buildAnimal(Map<String, dynamic> animal) {
    return Draggable<Map<String, dynamic>>(
      data: animal,
      feedback: Material(
        color: Colors.transparent,
        child: Image.asset(animal["asset"], height: 90),
      ),
      childWhenDragging: const SizedBox(height: 80),
      child: Image.asset(animal["asset"], height: 80),
    );
  }

  Widget buildAmbiente(String label, String asset) {
    return DragTarget<Map<String, dynamic>>(
      // Aceptamos cualquier animal (para permitir equivocaciones)
      onWillAccept: (data) => data != null,

      // Al aceptar, colocamos el animal en el ambiente seleccionado y lo eliminamos del área superior
      onAccept: (data) {
        setState(() {
          ambientes[label]!.add(data);
          animales.removeWhere((a) =>
          a["asset"] == data["asset"] && a["ambiente"] == data["ambiente"] && a["name"] == data["name"]);
        });
        checkCompletion();
      },

      builder: (_, candidate, __) {
        final highlight = candidate.isNotEmpty;
        return Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: highlight ? Colors.black54 : Colors.black12, width: highlight ? 3 : 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(asset, height: 70),
              const SizedBox(height: 6),
              Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2FBFC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 12),
              const TitleText(text: "Clasifica los animales por su ecosistema"),
              const SizedBox(height: 20),

              // Animales (únicos)
              Expanded(
                child: Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  alignment: WrapAlignment.center,
                  children: animales.map(buildAnimal).toList(),
                ),
              ),

              const SizedBox(height: 20),

              // Ambientes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildAmbiente("Aire", "assets/aire.png"),
                  buildAmbiente("Agua", "assets/agua.png"),
                  buildAmbiente("Tierra", "assets/tierra.png"),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
