import 'package:educapp_demo/screens/login/email_login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/config.dart'; // Importa tu archivo de configuración
import '../name_screen.dart';
import 'package:educapp_demo/screens/principal_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart' as localAuth;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';





class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  @override
  void initState() {
    super.initState();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  Future<void> _handleGoogleLoginWithFirebase(BuildContext context) async {
    try {
      // Paso 1: Inicia sesión con Google
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        print('Login cancelado por el usuario');
        return;
      }

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      // Paso 2: Crea credenciales para Firebase
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Paso 3: Autentica con Firebase
      final UserCredential userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user == null) {
        print('No se pudo autenticar con Firebase');
        return;
      }

      print('Usuario autenticado con Firebase: ${user.email}');

      // Paso 4: Obtén el token de Firebase
      final String? firebaseIdToken = await user.getIdToken();

      if (firebaseIdToken == null) {
        print('No se pudo obtener el token de Firebase');
        return;
      }

      // Paso 5: Usa AuthProvider para manejar la sesión
      final data = await Provider.of<localAuth.AuthProvider>(context, listen: false)
          .loginWithFirebaseIdToken(firebaseIdToken, user.email!);

      if (data != null) {
        final bool isNew = data['is_new'] ?? false;
        final Map<String, dynamic> userMap = data['user'];
        final int padresID = userMap['id'];
        final String email = userMap['email'];

        final storage = FlutterSecureStorage();
        await storage.write(key: 'padresID', value: padresID.toString());

        if (isNew) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => NameScreen(
                onNext: (name) => print('Nombre recibido: $name'),
                correoObtenido: true,
                correo: email,
                padresID: padresID,
              ),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen(userName: '')),
          );
        }
      }
      else {
        print('Error en el servidor o en AuthProvider');
      }
    } catch (e) {
      print('Error durante el login con Firebase: $e');
    }
  }

  Future<void> handleAppleLogin(BuildContext context) async {
    try {
      // 1️⃣ Solicitar credenciales de Apple
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // 2️⃣ Crear credenciales para Firebase
      final oAuthProvider = OAuthProvider("apple.com");
      final credential = oAuthProvider.credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // 3️⃣ Login en Firebase
      final UserCredential userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);

      final user = userCredential.user;

      if (user == null) {
        print("No se pudo autenticar con Firebase (Apple)");
        return;
      }

      print("Usuario Apple en Firebase: ${user.email}");

      final String? firebaseIdToken = await user.getIdToken();

      if (firebaseIdToken == null) {
        print("❌ No se pudo obtener el token de Firebase");
        return;
      }

      // 5️⃣ Enviar a tu API de Django (exactamente igual a Google)
      final data = await Provider.of<localAuth.AuthProvider>(context, listen: false)
          .loginWithFirebaseIdToken(firebaseIdToken, user.email!);

      if (data != null) {
        final bool isNew = data['is_new'] ?? false;
        final Map<String, dynamic> userMap = data['user'];
        final int padresID = userMap['id'];
        final String email = userMap['email'];

        final storage = FlutterSecureStorage();
        await storage.write(key: 'padresID', value: padresID.toString());

        if (isNew) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => NameScreen(
                onNext: (name) => print('Nombre recibido: $name'),
                correoObtenido: true,
                correo: email,
                padresID: padresID,
              ),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen(userName: '')),
          );
        }
      }
    } catch (e) {
      print("Error en Apple Sign-In: $e");
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF6BACB4)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Iniciar sesión',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.normal,
                  color: Color(0xFF6BACB4),
                  fontFamily: 'kbdarkhour',
                ),
              ),
              const SizedBox(height: 60),

              // Botón de correo electrónico
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const EmailLoginScreen()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFFF2A452),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide.none,
                  ),
                  child: Text(
                    'Correo electrónico',
                    style: GoogleFonts.openSans(
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Botón de Google con ícono
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _handleGoogleLoginWithFirebase(context),
                  icon: Image.asset(
                    'assets/google-logo.png',
                    height: 20,
                  ),
                  label: Text(
                    'Continuar con Google',
                    style: GoogleFonts.openSans(
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFFF2A452),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => handleAppleLogin(context),
                  icon: Image.asset(
                    'assets/apple-icon.jpg',
                    height: 30,
                  ),
                  label: Text(
                    'Continuar con Apple',
                    style: GoogleFonts.openSans(
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFFF2A452),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
