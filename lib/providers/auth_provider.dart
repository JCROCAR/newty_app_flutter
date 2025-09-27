import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import '/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  final _storage = FlutterSecureStorage();
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  String? _accessToken;
  String? get accessToken => _accessToken;

  String? _userEmail;
  String? get userEmail => _userEmail;

  Future<void> checkLoginStatus() async {
    _accessToken = await _storage.read(key: 'access_token');
    final refreshToken = await _storage.read(key: 'refresh_token');

    if (_accessToken == null || refreshToken == null) {
      _isAuthenticated = false;
      notifyListeners();
      return;
    }

    final test = await http.get(
      Uri.parse('${Config.baseUrl}/padres/padres/'),
      headers: {'Authorization': 'Bearer $_accessToken'},
    );

    if (test.statusCode == 200) {
      _isAuthenticated = true;
      // Cargar correo guardado
      final prefs = await SharedPreferences.getInstance();
      _userEmail = prefs.getString('userEmail');
    } else if (test.statusCode == 401) {
      final response = await http.post(
        Uri.parse('${Config.baseUrl}/api/token/refresh/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': refreshToken}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _accessToken = data['access'];
        await _storage.write(key: 'access_token', value: _accessToken);
        _isAuthenticated = true;
        final prefs = await SharedPreferences.getInstance();
        _userEmail = prefs.getString('userEmail');
      } else {
        await logout();
      }
    }

    notifyListeners();
  }

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final auth = await googleUser.authentication;
      final idToken = auth.idToken;

      final response = await http.post(
        Uri.parse('${Config.baseUrl}/padres/google-login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': idToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _accessToken = data['access'];
        final refreshToken = data['refresh'];

        await _storage.write(key: 'access_token', value: _accessToken);
        await _storage.write(key: 'refresh_token', value: refreshToken);

        // Guardar correo del usuario Google
        _userEmail = googleUser.email;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userEmail', _userEmail!);

        _isAuthenticated = true;
        notifyListeners();
      }
    } catch (e) {
      print('Error en login: $e');
    }
  }

  Future<Map<String, dynamic>?> loginWithFirebaseIdToken(String idToken, String email) async {
    try {
      final response = await http.post(
        Uri.parse('${Config.baseUrl}/padres/padres/google-login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id_token': idToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _accessToken = data['access'];
        final refreshToken = data['refresh'];

        await _storage.write(key: 'access_token', value: _accessToken);
        await _storage.write(key: 'refresh_token', value: refreshToken);

        // Guardar correo del usuario
        _userEmail = email;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userEmail', _userEmail!);

        _isAuthenticated = true;
        notifyListeners();

        return data;
      } else {
        print('Error en servidor: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error en loginWithFirebaseIdToken: $e');
      return null;
    }
  }

  Future<bool> loginWithEmail(String correo, String password) async {
    final url = Uri.parse('${Config.baseUrl}/padres/padres/email-login/');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'correo': correo, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _accessToken = data['access'];
        final refreshToken = data['refresh'];

        await _storage.write(key: 'access_token', value: _accessToken);
        await _storage.write(key: 'refresh_token', value: refreshToken);

        // Guardar correo del usuario
        _userEmail = correo;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userEmail', correo);

        _isAuthenticated = true;
        notifyListeners();
        return true;
      } else {
        print('Login error: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error en loginWithEmail: $e');
      return false;
    }
  }

  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    _isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
    _userEmail = prefs.getString('userEmail');
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
    _isAuthenticated = false;
    _userEmail = null;
    notifyListeners();
  }

  Future<String?> getValidAccessToken() async {
    if (_accessToken == null) return null;

    // Probar si aún sirve
    final test = await http.get(
      Uri.parse('${Config.baseUrl}/padres/padres/'),
      headers: {'Authorization': 'Bearer $_accessToken'},
    );

    if (test.statusCode == 401) {
      // Access expirado → refrescarlo
      final refreshToken = await _storage.read(key: 'refresh_token');
      if (refreshToken == null) {
        await logout();
        return null;
      }

      final response = await http.post(
        Uri.parse('${Config.baseUrl}/padres/padres/token/refresh/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _accessToken = data['access'];
        await _storage.write(key: 'access_token', value: _accessToken);
        return _accessToken;
      } else {
        await logout();
        return null;
      }
    }

    // Si sigue válido, lo devolvemos
    return _accessToken;
  }

}
