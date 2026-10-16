import 'package:flutter/material.dart';
import 'package:fronted/colores/stilocolores.dart';
import 'package:fronted/paginas/cliente/components/pagos/targetapagos.dart';
import 'package:google_fonts/google_fonts.dart';

/// Número Nequi al que se transfiere (toca el número para copiarlo).
class DatosNequi extends StatelessWidget {
  final String numero;
  final String titular;
  final VoidCallback onCopiar;

  const DatosNequi({
    super.key,
    required this.numero,
    required this.titular,
    required this.onCopiar,
  });

  @override
  Widget build(BuildContext context) {
    return TarjetaPago(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.phone_in_talk, color: Colors.white70, size: 16),
              const SizedBox(width: 8),
              Text(
                'Consigna a este número Nequi',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: onCopiar,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '+57 $numero',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.copy_rounded, color: AppColors.cian, size: 18),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Titular: $titular',
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
