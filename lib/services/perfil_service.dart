import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '/config.dart';

class PerfilService {
  static Future<Map<String, dynamic>?> getPerfil() async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'access_token');
    final correo = await storage.read(key: 'user_email');

    if (correo == null) return null;

    final response = await http.get(
      Uri.parse('${Config.baseUrl}/perfil/by-correo/$correo'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        'has_perfil': true,
        'perfil': data['perfil'],
      };
    } else {
      return {'has_perfil': false};
    }
  }
}

