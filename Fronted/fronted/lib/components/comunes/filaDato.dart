import 'package:flutter/material.dart';
import 'package:fronted/colores/stilocolores.dart';
import 'package:google_fonts/google_fonts.dart';

/// Fila "icono azul + texto" para mostrar datos en tarjetas
/// (teléfono, correo, fecha...). [fuerte] la resalta (nombre, título).
class FilaDato extends StatelessWidget {
  final IconData icono;
  final String texto;
  final bool fuerte;

  const FilaDato(this.icono, this.texto, {super.key, this.fuerte = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icono, color: AppColors.azulClaro, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            texto,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              color: fuerte ? Colors.white : Colors.white70,
              fontSize: fuerte ? 16 : 13,
              fontWeight: fuerte ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}
