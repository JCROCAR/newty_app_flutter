import 'dart:convert';
import 'package:educapp_demo/screens/science_games/science_screen_1.dart';
import 'package:educapp_demo/screens/science_games/science_screen_2.dart';
import 'package:educapp_demo/screens/science_games/science_screen_3.dart';
import 'package:educapp_demo/screens/science_games/science_screen_4.dart';
import 'package:educapp_demo/screens/science_games/science_screen_5.dart';
import 'package:educapp_demo/screens/science_games/science_screen_6.dart';
import 'package:educapp_demo/screens/science_games/science_screen_7.dart';
import 'package:educapp_demo/screens/science_games/science_screen_8.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../../config.dart';




// Clase principal para la sección de juegos de matemática
class ScienceGamesSection extends StatefulWidget {
  const ScienceGamesSection({super.key});

  @override
  _ScienceGamesSectionState createState() => _ScienceGamesSectionState();
}

class _ScienceGamesSectionState extends State<ScienceGamesSection> {

  Widget? currentGame;
  bool isLoading = true;


  final Map<String, Widget Function(int)> actividadWidgets = {
    'animal_sonido': (id) => ScienceScreen1(actividadId: id),
    'animal_dondevive': (id) => ScienceScreen2(actividadId: id),
    'nombre_imagen': (id) => ScienceScreen3(actividadId: id),
    'colores_cubos': (id) => ScienceScreen4(actividadId: id),
    'ambientes': (id) => ScienceScreen5(actividadId: id),
    'une_parejas': (id) => ScienceScreen6(actividadId: id),
    'une_especies': (id) => ScienceScreen7(actividadId: id),
    'circula_grupo': (id) => ScienceScreen8(actividadId: id),
  };

  @override
  void initState() {
    super.initState();
    _loadActividadNoJugada();
  }

  Future<void> _loadActividadNoJugada() async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'access_token'); // lee el token guardado
    final categoriaId = 2;

    if (token == null) {
      setState(() {
        currentGame = _buildErrorWidget('Token no disponible');
        isLoading = false;
      });
      return;
    }

    try {
      /**/
      final response = await http.get(
        Uri.parse('${Config.baseUrl}/detalle_actividad_duracion/actividades_no_jugadas/$categoriaId/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Asegúrate de usar "Bearer" si estás usando JWT
        },
      );

      /*
      final response = await http.get(
        Uri.parse('${Config.baseUrl}/detalle_actividad_duracion/actividades_no_jugadas/$categoriaId/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Asegúrate de usar "Bearer" si estás usando JWT
        },
      ); */

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
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
      } else {
        setState(() {
          currentGame = _buildErrorWidget('Error al cargar actividades');
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        currentGame = _buildErrorWidget('Excepción: $e');
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