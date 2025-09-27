import 'package:educapp_demo/screens/transition/parents_birthday_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/configuracion_service.dart';
import '../../services/post_ninios_api.dart';
import '../../services/padres_service.dart';
import '../../services/post_perfil_api.dart';
import '../../widgets/next_button.dart';
import '../../widgets/skip_button.dart';
import 'package:flutter/services.dart';
import '../principal_screen.dart';
import 'package:flutter/services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';




class EmailScreen extends StatefulWidget {
  final String name;
  final String gender;
  final String age;



  EmailScreen({required this.name, required this.gender, required this.age});

  @override
  _EmailScreenState createState() => _EmailScreenState();
}

class _EmailScreenState extends State<EmailScreen> {
  final _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _passwordController = TextEditingController();
  String email = '';
  String password = '';
  bool isLoading = false;
  String? _fcmToken;


  void _submitEmail() async {
    if (_controller.text.isNotEmpty && _passwordController.text.isNotEmpty) {
      setState(() {
        email = _controller.text.trim();
        password = _passwordController.text;
      });

      // Llamamos a _submitData y esperamos el resultado
      final success = await _submitData();

      if (success) {
        // Aquí logueamos al usuario en el AuthProvider
        final loginSuccess = await Provider.of<AuthProvider>(context, listen: false)
            .loginWithEmail(email, password);

        if (loginSuccess) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(userName: widget.name),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al iniciar sesión automáticamente')),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, ingresa tu correo')),
      );
    }
  }



  Future<bool> _submitData() async {
    if (_controller.text.isNotEmpty) {
      setState(() {
        isLoading = true;
      });

      final ninioId = await PostNinios.submitData(
        name: widget.name,
        gender: widget.gender,
        age: widget.age,
      );

      if (ninioId != null) {
        final padreId = await PostPadres.submitData(
          email: email,
          password: password,
        );

        if (padreId != null) {
          // Crear perfil y obtener su ID
          final perfilId = await PostPerfil.submitData(
            ninio: ninioId,
            padres: padreId,
          );

          if (perfilId != null) {
            // Crear configuración usando el perfilId
            final successConfiguracion = await PostConfiguracion.submitData(
              perfil: perfilId,
              token_fcm: _fcmToken
            );

            setState(() {
              isLoading = false;
            });

            if (!successConfiguracion) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error al crear la configuración')),
              );
            }

            return successConfiguracion;
          } else {
            setState(() {
              isLoading = false;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error al crear el perfil')),
            );

            return false;
          }
        } else {
          setState(() {
            isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al enviar datos del padre')),
          );

          return false;
        }
      } else {
        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al enviar datos del niño')),
        );

        return false;
      }
    }

    return false;
  }





  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    // Forzar orientación vertical
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    WidgetsBinding.instance.addPostFrameCallback((_){
      _focusNode.requestFocus();
    });

    _getFCMToken();
  }

  Future<void> _getFCMToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    setState(() {
      _fcmToken = token;
    });
    print('FCM Token: $_fcmToken');
  }

  @override
  void dispose() {
    // Restaurar orientación al salir
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: AppBar(
          centerTitle: true,
          backgroundColor: Colors.white,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Ingresa tu correo electrónico y una contraseña',
                      style: GoogleFonts.openSans(
                        textStyle: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF2A452),
                        ),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        keyboardType: TextInputType.emailAddress,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 15,
                          fontFamily: 'Arial',
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Correo',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        controller: _passwordController, // ✅ nuevo
                        obscureText: true,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 15,
                          fontFamily: 'Arial',
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Contraseña',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    isLoading
                        ? const CircularProgressIndicator()
                        : CustomChildButton(
                      onPressed: _submitEmail,
                      text: 'Siguiente',
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 25.0),
            child: Text(
              'Newty',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.normal,
                color: Color(0xFF6BACB4),
                fontFamily: 'kbdarkhour',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
