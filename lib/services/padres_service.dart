import 'dart:convert';
import 'package:http/http.dart' as http;
import '/config.dart'; // Importa tu archivo de configuración

  class PostPadres {
  static Future<int?> submitData({
    required String email,
    required String password
  }) async {
    final String endpoint = '${Config.baseUrl}/padres/padres/';

    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'correo': email,
          'password': password
        }),
      );


      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final padreID = data['padres']['id']; // ← accede al ID correctamente
        return padreID;
      } else {
        print('Error al enviar los datos: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }
}