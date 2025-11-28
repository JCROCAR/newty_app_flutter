import 'dart:convert';
import 'package:educapp_demo/screens/math_games/math_screen_4.dart';
import 'package:educapp_demo/screens/math_games/math_screen_5.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:educapp_demo/screens/math_games/math_screen_1.dart';
import 'package:educapp_demo/screens/math_games/math_screen_2.dart';
import 'package:educapp_demo/screens/math_games/math_screen_3.dart';
import '../../config.dart';
import '../../services/actividad_service.dart';
import 'math_screen_6.dart';


// Clase principal para la sección de juegos de matemática
class MathGamesSection extends StatefulWidget {
  const MathGamesSection({super.key});

  @override
  _MathGamesSectionState createState() => _MathGamesSectionState();
}

class _MathGamesSectionState extends State<MathGamesSection> {
  final ActividadService _actividadService = ActividadService();
  Widget? currentGame;
  bool isLoading = true;


  final Map<String, Widget Function(int)> actividadWidgets = {
    'contador_frutas': (id) => MathScreen1(actividadId: id),
    'indica_numero': (id) => MathScreen2(actividadId: id),
    'completa_secuencia': (id) => MathScreen3(actividadId: id),
    'cantidad_objetos': (id) => MathScreen4(actividadId: id),
    'grupo_mas_grande': (id) => MathScreen5(actividadId: id),
    'contador': (id) => MathScreen6(actividadId: id),
  };

  @override
  void initState() {
    super.initState();
    _loadActividadNoJugada();
  }

  Future<void> _loadActividadNoJugada() async {
    const int categoriaId = 1;
    final result = await _actividadService.fetchActividadNoJugada(context, categoriaId);

    if (result['error']) {
      setState(() {
        currentGame = _buildErrorWidget(result['message']);
        isLoading = false;
      });
      return;
    }

    final data = result['data'];
    final actividades = List<Map<String, dynamic>>.from(data['actividades']);

    if (actividades.isEmpty) {
      setState(() {
        currentGame = _buildAllCompletedWidget();
        isLoading = false;
      });
      return;
    }

    final randomActividad = (actividades..shuffle()).first;
    final String nombreActividad = randomActividad['nombre'];
    final int actividadId = randomActividad['id'];

    final constructor = actividadWidgets[nombreActividad];

    if (constructor != null) {
      setState(() {
        currentGame = constructor(actividadId);
        isLoading = false;
      });
    } else {
      setState(() {
        currentGame = _buildErrorWidget("No hay widget para '$nombreActividad'");
        isLoading = false;
      });
    }
  }

  Widget _buildAllCompletedWidget() {
    return Scaffold(
      body: Center(
        child: Text('🎉 ¡Ya completaste todos los juegos de esta categoría!'),
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Scaffold(
      body: Center(child: Text(message)),
    );
  }



  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return currentGame!;
  }
}