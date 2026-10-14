import 'package:flutter/material.dart';
import 'package:fronted/colores/stilocolores.dart';

/// Botón redondo con degradado azul (stock +/-, insignia de editar foto...).
class BotonCircularDegradado extends StatelessWidget {
  final IconData icono;
  final VoidCallback? onTap;
  final double tam;
  final double tamIcono;

  const BotonCircularDegradado({
    super.key,
    required this.icono,
    this.onTap,
    this.tam = 46,
    this.tamIcono = 24,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: tam,
        height: tam,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppColors.gradienteBoton,
        ),
        child: Icon(icono, color: Colors.white, size: tamIcono),
      ),
    );
  }
}
