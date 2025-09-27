import 'package:educapp_demo/screens/login/email_screen.dart';
import 'package:educapp_demo/screens/transition/parents_birthday_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/configuracion_service.dart';
import '../../services/padres_service.dart';
import '../../services/post_ninios_api.dart';
import '../../services/post_perfil_api.dart';
import '../../widgets/next_button.dart';
import '../../widgets/skip_button.dart';
import 'package:flutter/services.dart';
import '../principal_screen.dart';
import 'package:flutter/services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';




class BirthdayScreen extends StatefulWidget {
  final String name;
  final String gender;
  final bool correObtenido;
  final String correo;
  final int padresID;

  BirthdayScreen({required this.name, required this.gender, required this.correObtenido, required this.correo, required this.padresID});

  @override
  _BirthdayScreenState createState() => _BirthdayScreenState();
}

class _BirthdayScreenState extends State<BirthdayScreen> {
  final _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String age = '';
  bool isLoading = false;
  String? _fcmToken;

  void _submitAge() async {
    if (_controller.text.isNotEmpty) {
      setState(() {
        age = _controller.text; // Guarda el valor ingresado
      });
      //widget.onNext(age);

      if (widget.correObtenido)
        {
          final success = await _submitData();
          if (success) {
            await SystemChrome.setPreferredOrientations([
              DeviceOrientation.landscapeLeft,
              DeviceOrientation.landscapeRight,
            ]);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreen(userName: widget.name),
              ),
            );
          }
        } else
          {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EmailScreen(name: widget.name, gender: widget.gender, age:age), // Navega a la nueva pantalla
              ),
            );
          }

    }else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, ingresa la edad')),
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
        age: age,
      );

      if (ninioId != null) {
        // Crear perfil y obtener su ID
        final perfilId = await PostPerfil.submitData(
          ninio: ninioId,
          padres: widget.padresID,
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
          SnackBar(content: Text('Error al enviar datos del niño')),
        );

        return false;
      }
    }

    return false;
  }

  Future<void> _getFCMToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    setState(() {
      _fcmToken = token;
    });
    print('FCM Token: $_fcmToken');
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
        preferredSize: Size.fromHeight(60.0),
        child: AppBar(
          centerTitle: true,
          backgroundColor: Colors.white,

        ),
      ),
      body:
      Column(
       children: [
         Expanded(
           child: Center(
             child: SingleChildScrollView(
               padding: const EdgeInsets.all(16.0),
               child: Column(
                 mainAxisSize: MainAxisSize.min,
                 children: [
                   Text(
                     'Ingresa la edad de tu hijo/a',
                     style: GoogleFonts.openSans(
                       textStyle: TextStyle(
                         fontSize: 30,
                         fontWeight: FontWeight.bold,
                         color: Color(0xFFF2A452),
                       ),
                     ),
                     textAlign: TextAlign.center,
                   ),
                   SizedBox(height: 20),
                   Container(
                     decoration: BoxDecoration(
                       color: Colors.white.withOpacity(0.2),
                       borderRadius: BorderRadius.circular(10),
                     ),
                     child: TextField(
                       controller: _controller,
                       focusNode: _focusNode,
                       keyboardType: TextInputType.number,
                       inputFormatters: [FilteringTextInputFormatter.digitsOnly], // Restringe a solo números enteros
                       textAlign: TextAlign.center,
                       style: TextStyle(
                         fontSize: 25,
                         fontFamily: 'Arial',
                       ),
                       decoration: InputDecoration(
                         border: InputBorder.none,
                         contentPadding: EdgeInsets.all(12),
                       ),
                     ),
                   ),
                   SizedBox(height: 20),
                   isLoading
                       ? CircularProgressIndicator()
                       : CustomChildButton(
                     onPressed: _submitAge,
                     text: 'Siguiente',
                   ),
                   SizedBox(height: 45),
                   CustomChildSkipButton(
                     onPressed: () {
                       // Lógica para omitir
                     },
                     text: 'Omitir',
                   ),
                 ],
               ),
             ),
           ),
         ),
         Padding(
           padding: const EdgeInsets.only(bottom: 25.0),
           child: Text(
             'Newty',
             style:  TextStyle(
                 fontSize: 30,
                 fontWeight: FontWeight.normal,
                 color: Color(0xFF6BACB4),
                 fontFamily: 'kbdarkhour'
             ),
           ),
         ),
       ],
      )
    );
  }
}
