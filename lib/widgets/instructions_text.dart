import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TitleText extends StatelessWidget {
  final String text;
  final Color color;
  final double fontSize;

  const TitleText({
    super.key,
    required this.text,
    this.color = const Color(0xFFFF9800), // Naranja más intenso por defecto
    this.fontSize = 28,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: GoogleFonts.openSans(
        textStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
