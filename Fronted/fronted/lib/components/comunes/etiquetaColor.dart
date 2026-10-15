import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Etiqueta redondeada de un color con icono opcional (rol, estado, etc.).
class EtiquetaColor extends StatelessWidget {
  final String texto;
  final Color color;
  final IconData? icono;
  final double fontSize;

  const EtiquetaColor({
    super.key,
    required this.texto,
    required this.color,
    this.icono,
    this.fontSize = 11,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icono != null) ...[
            Icon(icono, color: color, size: fontSize + 3),
            const SizedBox(width: 4),
          ],
          Text(
            texto,
            style: GoogleFonts.poppins(
              color: color,
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
