import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../name_screen.dart';
import '../login/login_screen.dart'; // Tu pantalla de login
import '../../utils/test_file.dart';
import '../principal_screen.dart';
import 'package:educapp_demo/services/push_notifications_service.dart';



class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    FirebasePushService.init(); // 👈 activa las notificaciones
    _navigateAfterDelay();
  }

  void _navigateAfterDelay() async {
    await Future.delayed(const Duration(seconds: 4));

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Cargar sesión desde almacenamiento local
    await authProvider.loadSession();

    // 🔁 Intentar obtener un token válido (refresca si expiró)
    final validToken = await authProvider.getValidAccessToken();

    if (validToken != null) {
      // Token válido, puede ingresar
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen(userName: '')),
      );
    } else {
      // No hay token válido, ir al login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/newty_1440x2560.png',
              width: 800,
              height: 600,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(
              color: Color(0xFF6BACB4),
            ),
          ],
        ),
      ),
    );
  }
}
