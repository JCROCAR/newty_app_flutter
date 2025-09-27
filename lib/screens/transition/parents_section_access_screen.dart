import 'dart:math';
import 'package:educapp_demo/screens/transition/parents_section_screen.dart';
import 'package:educapp_demo/widgets/next_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class ParentSectionAccess extends StatefulWidget {
  @override
  _ParentSectionAccessState createState() => _ParentSectionAccessState();
}

class _ParentSectionAccessState extends State<ParentSectionAccess> {
  int num1 = 0;
  int num2 = 0;
  final TextEditingController _controller = TextEditingController();
  String message = '';

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    super.initState();
    _generateNewSum();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void _generateNewSum() {
    final random = Random();
    setState(() {
      num1 = random.nextInt(10) + 1; // Número entre 1 y 30
      num2 = random.nextInt(10) + 1;
      _controller.clear();
      message = '';
    });
  }

  void _checkAnswer() {
    if (int.tryParse(_controller.text) == num1 + num2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ParentsSectionScreen()),
      );
    } else {
      setState(() {
        message = 'Respuesta incorrecta. Inténtalo de nuevo.';
      });
    }
  }

  void _onNumberPressed(String number) {
    setState(() {
      _controller.text += number;
    });
  }

  void _onDelete() {
    setState(() {
      if (_controller.text.isNotEmpty) {
        _controller.text = _controller.text.substring(0, _controller.text.length - 1);
      }
    });
  }

  void _onClear() {
    setState(() {
      _controller.clear();
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF87C5C4),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: AppBar(
          backgroundColor: Color(0xFF87C5C4),
        ),
      ),
      body: Stack(
        children: [
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Sección izquierda: Texto y operación matemática
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Resuelve la operación para continuar',
                      style: GoogleFonts.openSans(
                        textStyle: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    Text(
                      '$num1 + $num2 = ?',
                      style: GoogleFonts.openSans(
                        textStyle: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      )
                    ),
                    SizedBox(height: 20),
                    Container(
                      width: 180,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        controller: _controller,
                        keyboardType: TextInputType.none, // Evita que aparezca el teclado
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 25,
                          fontFamily: 'Comic Sans MS',
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    CustomChildButton(onPressed: _checkAnswer, text: 'Ingresar'),
                    if (message.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          message,
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 18,
                            fontFamily: 'Comic Sans MS',
                          ),
                        ),
                      ),
                  ],
                ),

                SizedBox(width: 20), // Espaciado mínimo entre el texto y los botones

                // Sección derecha: Botones numéricos más pegados
                _buildNumberPad(),
              ],
            ),
          ),
        ],
      ),
    );
  }

// Método para construir el panel numérico con botones más pequeños y pegados
  Widget _buildNumberPad() {
    return Container(
      width: 230, // Ancho más compacto para pegar los botones al texto
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4, // Espaciado mínimo
          mainAxisSpacing: 4, // Espaciado mínimo
          childAspectRatio: 1.5, // Hace los botones más pequeños
        ),
        itemCount: 12,
        itemBuilder: (context, index) {
          List<String> buttons = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '⌫', '0', 'C'];

          return ElevatedButton(
            onPressed: () {
              if (buttons[index] == '⌫') {
                _onDelete();
              } else if (buttons[index] == 'C') {
                _onClear();
              } else {
                _onNumberPressed(buttons[index]);
              }
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.all(15), // Botones más pequeños
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              backgroundColor: Color(0xFF7C3AC8).withOpacity(0.6),
            ),
            child: Text(
              buttons[index],
              style: TextStyle(
                fontSize: 18, // Texto más compacto
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          );
        },
      ),
    );
  }


}
