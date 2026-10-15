import 'package:flutter/material.dart';
import 'package:fronted/colores/stilocolores.dart';
import 'package:fronted/components/comunes/botonDegradado.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tarjeta que se muestra cuando el carrito no tiene productos.
/// [onExplorar] se ejecuta al tocar "Explorar producto".
class CarritoVacio extends StatelessWidget {
  final VoidCallback onExplorar;

  const CarritoVacio({super.key, required this.onExplorar});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        color: AppColors.fondoTarjeta,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.bordeTarjeta, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.shopping_cart_rounded, color: Colors.white, size: 70),
          const SizedBox(height: 14),
          Text(
            'Tu carrito está vacío',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              decorationThickness: 3,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            '¡Descubre productos increíbles y comienza tu compra!',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: 210,
            child: BotonDegradado(
              texto: 'Explorar producto',
              icono: Icons.search,
              height: 48,
              borderRadius: 20,
              onTap: onExplorar,
            ),
          ),
        ],
      ),
    );
  }
}