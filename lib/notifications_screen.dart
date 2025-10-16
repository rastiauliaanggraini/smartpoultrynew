
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications', style: GoogleFonts.montserrat()),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Center(
        child: Text(
          'Notifications Screen',
          style: GoogleFonts.montserrat(fontSize: 20),
        ),
      ),
    );
  }
}
