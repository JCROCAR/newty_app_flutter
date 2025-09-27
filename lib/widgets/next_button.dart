import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomChildButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;

  CustomChildButton({required this.onPressed, required this.text});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFFEF898F),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        elevation: 0,
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.openSans(
              textStyle: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            )
          ),
        ],
      ),
    );
  }
}