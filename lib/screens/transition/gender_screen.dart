import 'package:educapp_demo/screens/transition/birthday_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/next_button.dart';
import '../../widgets/skip_button.dart';
import 'package:flutter/services.dart';


class GenderScreen extends StatefulWidget {
  final String name;
  final bool correObtenido;
  final String correo;
  final int padresID;

  GenderScreen({required this.name, required this.correObtenido, required this.correo, required this.padresID});

  @override
  _GenderScreenState createState() => _GenderScreenState();
}

class _GenderScreenState extends State<GenderScreen> {
  String selectedGender = ''; // Variable para almacenar el género seleccionado

  void _submitGender() {
    if (selectedGender.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BirthdayScreen(name: widget.name, gender: selectedGender, correObtenido: widget.correObtenido, correo: widget.correo, padresID: widget.padresID), // Navega a la nueva pantalla
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, selecciona un género')),
      );
    }
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
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
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
                      'Selecciona el género de tu hijo/a',
                      style: GoogleFonts.openSans(
                        textStyle: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFF2A452),
                        ),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildGenderButton(
                          label: 'M',
                          isSelected: selectedGender == 'M',
                          onTap: () => setState(() {
                            selectedGender = 'M';
                          }),
                        ),
                        SizedBox(width: 20),
                        _buildGenderButton(
                          label: 'F',
                          isSelected: selectedGender == 'F',
                          onTap: () => setState(() {
                            selectedGender = 'F';
                          }),
                        ),
                      ],
                    ),
                    SizedBox(height: 40),
                    CustomChildButton(
                      onPressed: _submitGender,
                      text: 'Siguiente',
                    ),
                    SizedBox(height: 45),
                    CustomChildSkipButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BirthdayScreen(name: '', gender: '', correObtenido: false, correo: '', padresID: 0),
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

  Widget _buildGenderButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 60, // Define un ancho fijo para todos los botones
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isSelected ? Color(0xFF87C5C4) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.black),
          ),
          child: Center( // Asegura que el texto esté centrado
            child: Text(
              label,
              style: GoogleFonts.openSans(
                textStyle: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.black,
                ),
              )
            ),
          ),
        ),
      ),
    );

  }
}
