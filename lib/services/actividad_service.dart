import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '/config.dart';

class ActividadService {
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  Future<Map<String, dynamic>> fetchActividadNoJugada(int categoriaId) async {
    final token = await _storage.read(key: 'access_token');
    final selectedLevel = await _storage.read(key: 'selectedLevel');

    if (token == null) {
      return {
        'error': true,
        'message': 'Token no disponible',
      };
    }

    // Mapear "Nivel X" a número
    int? nivelInt;
    if (selectedLevel != null) {
      switch (selectedLevel) {
        case 'Nivel 1':
          nivelInt = 1;
          break;
        case 'Nivel 2':
          nivelInt = 2;
          break;
        case 'Nivel 3':
          nivelInt = 3;
          break;
      }
    }

    try {
      final response = await http.get(
        Uri.parse(
          '${Config.baseUrl}/detalle_actividad_duracion/actividades_no_jugadas/$categoriaId/'
              '?nivel=${nivelInt ?? ''}',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'error': false,
          'data': data,
        };
      } else {
        return {
          'error': true,
          'message': 'Error al cargar actividades',
        };
      }
    } catch (e) {
      return {
        'error': true,
        'message': 'Excepción: $e',
      };
    }
  }

}

