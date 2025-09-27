import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import '/config.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: ['email'],
  serverClientId: '897182599759-g60juut3ehrtpn5n86f1gvffa1pi661q.apps.googleusercontent.com',
);

final storage = FlutterSecureStorage();

Future<Map<String, dynamic>?> signInWithGoogle() async {
  try {
    await _googleSignIn.signOut(); // ← AGREGA ESTO
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

    print("🟠 Resultado googleUser: $googleUser");
    final googleAuth = await googleUser.authentication;
    final idToken = googleAuth.idToken;
    print('🟢 Token generado por Google: $idToken'); // <--- AGREGA ESTO

    final response = await http.post(
      Uri.parse('${Config.baseUrl}/padres/padres/google-login/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'token': idToken}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await storage.write(key: 'access_token', value: data['access']);
      await storage.write(key: 'refresh_token', value: data['refresh']);
      await storage.write(key: 'user_email', value: data['user']['email']);

      return data['user']; // retorna email y name
    } else {
      print('Error de backend: ${response.body}');
      return null;
    }
  } catch (e, stackTrace) {
    print('❌ Error en Google Sign-In: $e');
    print('📌 StackTrace: $stackTrace');
    return null;
  }

}
