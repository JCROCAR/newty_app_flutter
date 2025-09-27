import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '/config.dart';

class NiniosService {
  static Future<Map<String, dynamic>?> getNinio(int ninioId) async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'access_token');

    final response = await http.get(
      Uri.parse('${Config.baseUrl}/ninios/$ninioId/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['ninios'];
    } else {
      print('Error obteniendo niño: ${response.body}');
      return null;
    }
  }
}
