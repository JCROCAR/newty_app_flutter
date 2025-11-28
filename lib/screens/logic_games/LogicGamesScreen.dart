import 'package:educapp_demo/screens/logic_games/logic_screen_4.dart';
import 'package:educapp_demo/screens/logic_games/logic_screen_7.dart';
import 'package:educapp_demo/screens/logic_games/logic_screen_8.dart';
import 'package:flutter/material.dart';
import 'package:educapp_demo/screens/logic_games/logic_screen_1.dart';
import 'package:educapp_demo/screens/logic_games/logic_screen_2.dart';
import 'package:educapp_demo/screens/logic_games/logic_screen_3.dart';
import 'package:educapp_demo/screens/logic_games/logic_screen_5.dart';
import '../../services/actividad_service.dart';
import 'logic_screen_6.dart';




// Clase principal para la sección de juegos de lógica
class LogicGamesSection extends StatefulWidget {
  const LogicGamesSection({super.key});

  @override
  _LogicGamesSectionState createState() => _LogicGamesSectionState();
}

class _LogicGamesSectionState extends State<LogicGamesSection> {
  final ActividadService _actividadService = ActividadService();
  Widget? currentGame;
  bool isLoading = true;


  final Map<String, Widget Function(int)> actividadWidgets = {
    'selecciona_transporte': (id) => LogicScreen1(actividadId: id),
    'arrastra_silueta': (id) => LogicScreen2(actividadId: id),
    'selecciona_color': (id) => LogicScreen3(actividadId: id),
    'completa_laberinto': (id) => LogicScreen4(actividadId: id),
    'arrastra_frutas': (id) => LogicScreen5(actividadId: id),
    'completa_rompecabezas': (id) => LogicScreen6(actividadId: id),
    'ordena_menor_mayor': (id) => LogicScreen7(actividadId: id),
    'direccion_flechas': (id) => LogicScreen8(actividadId: id),
  };

  @override
  void initState() {
    super.initState();
    _loadActividadNoJugada();
  }

  Future<void> _loadActividadNoJugada() async {
    const int categoriaId = 3;
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
