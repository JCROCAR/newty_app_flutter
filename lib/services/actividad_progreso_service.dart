import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../models/categoria_progreso_model.dart';

class ActividadProgresoService {
  Future<List<CategoriaProgreso>> fetchProgresoCategorias(String correoUsuario) async {
    final url = Uri.parse(
      '${Config.baseUrl}/detalle_actividad_duracion/progreso-categorias/?correo=$correoUsuario',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(data);
      if (data['progreso'] != null) {
        List<dynamic> lista = data['progreso'];
        return lista.map((e) => CategoriaProgreso.fromJson(e)).toList();
      } else {
        throw Exception('Respuesta inesperada del servidor');
      }
    } else {
      throw Exception('Error al obtener progreso: ${response.statusCode}');
    }
  }
}
