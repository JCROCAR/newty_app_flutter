import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '/config.dart'; // Configuración con baseUrl

class PostRegistrarActividad {
  static final _storage = FlutterSecureStorage();

  static Future<bool> submitData({
    required int actividad,
  }) async {
    final String endpoint = '${Config.baseUrl}/detalle_actividad_duracion/registrar_actividad_jugada/';

    // Leer el token desde el storage
    final token = await _storage.read(key: 'access_token');

    if (token == null) {
      print('❌ No se encontró el token');
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Usa Bearer porque estás con JWT
        },
        body: jsonEncode({
          'actividad': actividad,
          'tiempo_uso': 60.0,
          'completada': 1,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print('❌ Error al enviar los datos: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Excepción al registrar actividad: $e');
      return false;
    }
  }
}
