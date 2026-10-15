import 'package:flutter/material.dart';

/// Roles de usuario (los mismos textos que guarda el backend).
class RolUsuario {
  RolUsuario._();

  static const String admin = 'Admin';
  static const String empleado = 'Empleado';
  static const String cliente = 'Cliente';

  static const List<String> todos = [admin, empleado, cliente];

  static Color color(String? rol) {
    switch (rol) {
      case admin:
        return const Color(0xFFAB47BC); // morado
      case empleado:
        return const Color(0xFF29B6F6); // azul de la app
      case cliente:
        return const Color(0xFF2ECC71); // verde
      default:
        return Colors.white54;
    }
  }

  static IconData icono(String? rol) {
    switch (rol) {
      case admin:
        return Icons.admin_panel_settings_outlined;
      case empleado:
        return Icons.badge_outlined;
      default:
        return Icons.person_outline_rounded;
    }
  }
}
