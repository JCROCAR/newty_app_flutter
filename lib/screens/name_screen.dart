import 'package:educapp_demo/screens/transition/gender_screen.dart';
import 'package:flutter/material.dart';
import '../widgets/next_button.dart';
import '../widgets/skip_button.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';



class NameScreen extends StatefulWidget {
  final Function(String) onNext;
  final bool correoObtenido ;
  final String correo;
  final int padresID;


  NameScreen({required this.onNext, required this.correoObtenido, required this.correo, required this.padresID});

  @override
  _NameScreenState createState() => _NameScreenState();
}

class _NameScreenState extends State<NameScreen> {
  final FocusNode _focusNode = FocusNode();
  final _controller = TextEditingController();
  late String enteredName = ''; // Variable para almacenar el nombre ingresado

  void _submitName() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        enteredName = _controller.text; // Guarda el valor ingresado
      });
      widget.onNext(enteredName); // Llama a la función de callback
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GenderScreen(name: enteredName, correObtenido: widget.correoObtenido, correo: widget.correo, padresID: widget.padresID), // Navega a la nueva pantalla
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, ingresa un nombre')),
      );
    }
  }

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    super.initState();
    // Forzar orientación vertical
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    WidgetsBinding.instance.addPostFrameCallback((_){
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    // Restaurar orientación al salir
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
      backgroundColor: Colors.white, // Fondo sólido
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
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
                      'Ingresa el nombre de tu hijo/a',
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
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 25,
                          fontFamily: 'Arial',
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    CustomChildButton(
                      onPressed: _submitName,
                      text: 'Siguiente',
                    ),
                    SizedBox(height: 45),
                    CustomChildSkipButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GenderScreen(name: enteredName, correObtenido: false, correo: '', padresID: 0),
                          ),
                        );
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
      ),
    );
  }

}

