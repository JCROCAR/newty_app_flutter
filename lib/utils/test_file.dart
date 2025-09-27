import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: ['email'],
  serverClientId: '897182599759-g60juut3ehrtpn5n86f1gvffa1pi661q.apps.googleusercontent.com',
);

class GoogleTestLogin extends StatelessWidget {
  const GoogleTestLogin({super.key});

  void _testGoogleSignIn(BuildContext context) async {
    try {
      await _googleSignIn.signOut(); // asegurarse de limpiar
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🚫 Login cancelado por el usuario')),
        );
        return;
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      print('🟢 idToken: $idToken');
      print('🟢 accessToken: $accessToken');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Login exitoso: ${googleUser.email}')),
      );
    } catch (e, st) {
      print('❌ Error en Google Sign-Inn: $e');
      print('📌 StackTracee: $st');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Error en Google Sign-In')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.login),
          label: const Text('Probar Google Login'),
          onPressed: () => _testGoogleSignIn(context),
        ),
      ),
    );
  }
}
