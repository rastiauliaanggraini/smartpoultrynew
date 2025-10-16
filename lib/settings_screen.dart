
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: GoogleFonts.montserrat()),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Center(
        child: Text(
          'Settings Screen',
          style: GoogleFonts.montserrat(fontSize: 20),
        ),
      ),
    );
  }
}
