import 'package:flutter/material.dart';
import 'package:fronted/colores/stilocolores.dart';
import 'package:google_fonts/google_fonts.dart';

/// Envuelve cualquier widget de la parte de arriba del home y le aplica una
/// transición mientras el usuario baja: se desvanece, se achica un poco y se
/// mueve más lento que el resto del contenido (efecto parallax) hasta
/// desaparecer.
///
/// Uso:
///   EncabezadoAnimado(controller: _scrollCtrl, child: Text('Megatech 2'))
class EncabezadoAnimado extends StatelessWidget {
  final ScrollController controller;
  final Widget child;

  /// Cuántos píxeles hay que bajar para que desaparezca por completo.
  final double distancia;

  const EncabezadoAnimado({
    super.key,
    required this.controller,
    required this.child,
    this.distancia = 140,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      child: child,
      builder: (context, child) {
        final offset = controller.hasClients
            ? controller.offset.clamp(0.0, distancia).toDouble()
            : 0.0;
        final t = Curves.easeOut.transform(offset / distancia);

        return IgnorePointer(
          ignoring: t > 0.9,
          child: Opacity(
            opacity: 1 - t,
            child: Transform.translate(
              offset: Offset(0, offset * 0.4),
              child: Transform.scale(
                scale: 1 - (0.12 * t),
                alignment: Alignment.topCenter,
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Saludo que aparece arriba cuando el cliente ya inició sesión.
/// Entra con una pequeña animación (fade + deslizamiento) al abrir el home.
class SaludoCliente extends StatelessWidget {
  final String nombre;

  const SaludoCliente({super.key, required this.nombre});

  @override
  Widget build(BuildContext context) {
    // Solo el primer nombre: "Juan Carlos" -> "Juan"
    final partes = nombre.trim().split(RegExp(r'\s+'));
    final primerNombre = partes.first;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (context, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(offset: Offset(0, (1 - v) * -16), child: child),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 20),
        child: Column(
          children: [
            Text(
              primerNombre.isEmpty ? 'Hola ' : 'Hola, $primerNombre ',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                color: AppColors.azulEnlace,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Bienvenido a Megatech 2',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}