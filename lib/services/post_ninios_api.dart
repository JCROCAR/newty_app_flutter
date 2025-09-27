import 'dart:convert';
import 'package:http/http.dart' as http;
import '/config.dart'; // Importa tu archivo de configuración

class PostNinios {
  static Future<int?> submitData({
    required String name,
    required String gender,
    required String age,
  }) async {
    final String endpoint = '${Config.baseUrl}/ninios/ninios/';

    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nombre': name,
          'edad': age,
          'genero': gender,
          'on_boarding_completed': 1,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final ninioId = data['ninios']['id']; // ← accede al ID correctamente
        return ninioId;
      } else {
        print('Error al enviar los datos: ${response.body}');
        return null; // Error en la respuesta
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }
}