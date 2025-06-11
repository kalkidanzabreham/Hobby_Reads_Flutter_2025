import 'package:flutter/material.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        '© ${DateTime.now().year} HobbyReads. All rights reserved.',
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
} 