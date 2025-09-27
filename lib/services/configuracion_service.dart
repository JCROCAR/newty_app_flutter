import 'dart:convert';
import 'package:http/http.dart' as http;
import '/config.dart'; // Importa tu archivo de configuración

class PostConfiguracion {
  static Future<bool> submitData({
    required int perfil,
    required String? token_fcm
  }) async {
    final String endpoint = '${Config.baseUrl}/configuracion/configuracion/';

    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'lenguaje': 'es',
          'tarjeta': '1521',
          'tipo_membresia':'abc',
          'perfil': perfil,
          'token_fcm': token_fcm
        }),
      );


      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print('Error al enviar los datos: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }
}