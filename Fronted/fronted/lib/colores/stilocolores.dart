import 'package:flutter/material.dart';

/// Paleta de colores de MEGATECH 2.
class AppColors {
  AppColors._();

  // Fondo general
  static const Color fondoOscuro1 = Color(0xFF173A55);
  static const Color fondoOscuro2 = Color(0xFF0B202E);
  static const Color fondoOscuro3 = Color(0xFF06141D);

  // Tarjeta contenedor principal
  static const Color fondoTarjeta = Color(0xFF202A39);
  static const Color bordeTarjeta = Color(0xFF20BFFF);

  // Botones
  static const Color azulClaro = Color(0xFF29B6F6);
  static const Color azulOscuro = Color(0xFF0288D1);
  static const Color azulEnlace = Color(0xFF2196F3);

  // Campos de texto
  static const Color fondoCampo = Colors.white;
  static const Color iconoCampo = Colors.black;

  // Textos
  static const Color textoPrincipal = Colors.white;
  static const Color textoBoton = Colors.black;

  // Estados
  static const Color rojo = Color(0xFFFF5252);
  static const Color rojoOscuro = Color(0xFFB71C1C);
  static const Color cian = Color(0xFF1BC2F0);

  // Gradientes reutilizables
  static const LinearGradient gradienteFondo = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [fondoOscuro1, Color.fromARGB(255, 11, 32, 46), fondoOscuro3],
  );

  static const LinearGradient gradienteBoton = LinearGradient(
    colors: [azulClaro, azulOscuro],
  );
}
