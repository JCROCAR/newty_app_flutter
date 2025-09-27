import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomChildSkipButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;

  CustomChildSkipButton({required this.onPressed, required this.text});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Text(
        text,
        style: GoogleFonts.openSans(
          textStyle: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFFEF898F), // Color del texto
            decoration: TextDecoration.underline,
            decorationColor: Color(0xFFEF898F)// Opcional, para indicar que es clickeable
          ),
        )
      ),
    );
  }
}
