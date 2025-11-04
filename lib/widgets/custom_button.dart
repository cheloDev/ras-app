// lib/widgets/custom_button.dart
import 'package:flutter/material.dart';

// 1. Define el widget como StatelessWidget (o StatefulWidget)
class CustomButton extends StatelessWidget {
  // 2. Define las propiedades que el widget necesita (parámetros del constructor)
  final String text;
  final VoidCallback onPressed; // VoidCallback es un alias para void Function()

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  // 3. Sobrescribe el método build()
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.pink, // Personalización del diseño
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 18),
      ),
    );
  }
}