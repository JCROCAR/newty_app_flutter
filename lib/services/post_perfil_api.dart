import 'dart:convert';
import 'package:http/http.dart' as http;
import '/config.dart'; // Importa tu archivo de configuración

class PostPerfil {
  static Future<int?> submitData({
    required int ninio,
    required int padres,
  }) async {
    final String endpoint = '${Config.baseUrl}/perfil/perfil/';

    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'ninios': ninio,
          'padres': padres,
        }),
      );

      print(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final perfilID = data['perfil']['id']; // ← accede al ID correctamente
        return perfilID;
      } else {
        print('Error al enviar los datos: ${response.body}');
        return null; // Error en la respuesta
      }
    } catch (e) {
      print('Error: $e');
      return null; // Error en la solicitud
    }
  }
}