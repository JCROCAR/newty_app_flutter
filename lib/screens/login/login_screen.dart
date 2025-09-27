import 'package:educapp_demo/screens/principal_screen.dart';
import 'package:educapp_demo/screens/login/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/google_sign_in.dart';
import '../../services/perfil_service.dart';
import '../../services/ninios_service.dart';
import '../name_screen.dart';
import 'package:flutter/services.dart';


class LoginScreen extends StatefulWidget {
  const  LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  void initState() {
    super.initState();

    // UI inmersiva (oculta barra de estado y navegación)
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    // Forzar orientación vertical al entrar
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }


  @override
  void dispose() {
    // Restaurar orientaciones permitidas al salir del login
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'NEWTY',
                style: TextStyle(
                  fontSize: 45,
                  fontWeight: FontWeight.normal,
                  color: Color(0xFF6BACB4),
                  fontFamily: 'kbdarkhour',
                ),
              ),
              const SizedBox(height: 60),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignInScreen()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFFF2A452),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide.none,
                  ),
                  child: Text(
                    'Iniciar sesión',
                    style: GoogleFonts.openSans(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NameScreen(
                          onNext: (name) => print('Nombre recibido: $name'), correoObtenido: false, correo: '', padresID: 0,
                        ),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFFF2A452),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide.none,
                  ),
                  child: Text(
                    'Crear cuenta',
                    style: GoogleFonts.openSans(fontWeight: FontWeight.bold),
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


