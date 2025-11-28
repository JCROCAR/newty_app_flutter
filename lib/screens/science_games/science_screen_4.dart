import 'dart:math';
import 'package:educapp_demo/widgets/instructions_text.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../services/actividad_registrada_service.dart';

class ScienceScreen4 extends StatefulWidget {
  final int actividadId;

  const ScienceScreen4({super.key, required this.actividadId});

  @override
  State<ScienceScreen4> createState() => _ScienceScreen4State();
}

class _ScienceScreen4State extends State<ScienceScreen4> {
  late List<Map<String, dynamic>> items; // frutas para arrastrar
  late int _totalFruits;

  Map<String, List<Map<String, dynamic>>> buckets = {
    "Rojo": [],
    "Verde": [],
    "Amarillo": [],
  };

  @override
  void initState() {
    super.initState();
    generateFruits();
  }

  void generateFruits() {
    final random = Random();
    final fruitOptions = [
      {"color": "Rojo", "asset": "assets/fresa.png"},
      {"color": "Rojo", "asset": "assets/manzana.png"},
      {"color": "Verde", "asset": "assets/manzana_verde.png"},
      {"color": "Amarillo", "asset": "assets/banana.png"},
      {"color": "Amarillo", "asset": "assets/piña.png"},
    ];

    items = List.generate(
      6,
          (_) => {
        "id": UniqueKey(),
        ...fruitOptions[random.nextInt(fruitOptions.length)]
      },
    );

    _totalFruits = items.length;
  }

  Future<void> checkCompletion() async {
    final totalPlaced = buckets.values.fold(0, (sum, list) => sum + list.length);
    if (totalPlaced != _totalFruits) return;

    for (var bucketName in buckets.keys) {
      for (var fruit in buckets[bucketName]!) {
        if (fruit["color"] != bucketName) return;
      }
    }

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

    await PostRegistrarActividad.submitData(actividad: widget.actividadId);

    await Future.delayed(const Duration(seconds: 2));
    Navigator.pop(context);
    Navigator.pop(context);
  }

  Widget buildFruit(Map<String, dynamic> fruit, int index) {
    return Draggable<Map<String, dynamic>>(
      data: fruit,
      feedback: Material(
        color: Colors.transparent,
        child: Image.asset(fruit["asset"], height: 80),
      ),
      childWhenDragging: const SizedBox.shrink(),
      child: Image.asset(fruit["asset"], height: 80),
    );
  }

  Widget buildBucket(String label, Color color) {
    return DragTarget<Map<String, dynamic>>(
      onWillAccept: (fruit) => fruit != null && fruit["color"] == label,
      onAccept: (fruit) {
        setState(() {
          buckets[label]!.add(fruit);
          items.removeWhere((f) => f["id"] == fruit["id"]);
        });
        checkCompletion();
      },
      builder: (context, candidate, rejected) {
        final isHighlighted = candidate.isNotEmpty;
        return Container(
          width: 125,
          height: 140,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isHighlighted ? Colors.black : color,
              width: isHighlighted ? 4 : 3,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontFamily: 'Arial',
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Image.asset(
                label == "Rojo"
                    ? "assets/cesto_rojo.png"
                    : label == "Verde"
                    ? "assets/cesto_verde.png"
                    : "assets/cesto_amarillo.png",
                height: 90,
                fit: BoxFit.contain,
              ),
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
              const TitleText(text: "Agrupa los colores naturales"),
              const SizedBox(height: 22),

              Expanded(
                child: Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  alignment: WrapAlignment.center,
                  children: [
                    for (var i = 0; i < items.length; i++) buildFruit(items[i], i),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildBucket("Rojo", Colors.red),
                  buildBucket("Verde", Colors.green),
                  buildBucket("Amarillo", Colors.yellow),
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