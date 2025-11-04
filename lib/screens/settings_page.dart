// lib/screens/settings_page.dart
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'Esta es la pantalla de Configuración.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}