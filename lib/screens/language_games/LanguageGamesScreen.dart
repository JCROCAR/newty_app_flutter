import 'package:educapp_demo/screens/language_games/LanguageScreen1.dart';
import 'package:educapp_demo/screens/language_games/LanguageScreen2.dart';
import 'package:educapp_demo/screens/language_games/LanguageScreen3.dart';
import 'package:flutter/material.dart';
import '/../services/actividad_service.dart';




// Clase principal para la sección de juegos de lógica
class LanguageGamesSection extends StatefulWidget {
  const LanguageGamesSection({super.key});

  @override
  _LanguageGamesSectionState createState() => _LanguageGamesSectionState();
}

class _LanguageGamesSectionState extends State<LanguageGamesSection> {
  final ActividadService _actividadService = ActividadService();
  Widget? currentGame;
  bool isLoading = true;


  final Map<String, Widget Function(int)> actividadWidgets = {
    'sonido_animal': (id) => LanguageScreen1(actividadId: id),
    'completa_palabra': (id) => LanguageScreen2(actividadId: id),
    'colorea_palabra': (id) => LanguageScreen3(actividadId: id),
  };


  @override
  void initState() {
    super.initState();
    // Seleccionar un juego aleatorio al iniciar
    _loadActividadNoJugada();
    //currentGame = _getRandomGame();
  }

  Future<void> _loadActividadNoJugada() async {
    const int categoriaId = 4;
    final result = await _actividadService.fetchActividadNoJugada(categoriaId);

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