import 'dart:convert';
import 'package:http/http.dart' as http;
import '/config.dart';

class NotificationService {
  Future<bool> saveSettings({
    required String correo,
    required List<String> dias,
    required String hora,
  }) async {
    final url = Uri.parse('${Config.baseUrl}/notificacion/notificaciones/');

    final Map<String, dynamic> payload = {
      'correo': correo,
      'dias': dias,      // lista de días seleccionados
      'hora': hora,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        print('Error: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error de red: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getSettings(String correo) async {
    final url = Uri.parse('${Config.baseUrl}/notificacion/notificaciones/?correo=$correo');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Suponiendo que el backend devuelve un JSON con estructura:
        // { "dias": ["Lunes", "Martes"], "hora": "14:30" }
        return data;
      } else {
        print('Error al obtener configuración: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error de red al obtener configuración: $e');
      return null;
    }
  }
}
