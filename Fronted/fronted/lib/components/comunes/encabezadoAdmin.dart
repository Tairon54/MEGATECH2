import 'package:flutter/material.dart';
import 'package:fronted/colores/stilocolores.dart';
import 'package:google_fonts/google_fonts.dart';

/// Encabezado de las pantallas del admin: "Megatech 2" + título de la pantalla.
class EncabezadoAdmin extends StatelessWidget {
  final String subtitulo;

  const EncabezadoAdmin({super.key, required this.subtitulo});

  @override
  Widget build(BuildContext context) {
    final estilo = GoogleFonts.poppins(
      fontSize: 24,
      fontWeight: FontWeight.bold,
    );
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 20),
          child: Text(
            'Megatech 2',
            style: estilo.copyWith(color: Colors.white),
          ),
        ),
        Text(subtitulo, style: estilo.copyWith(color: AppColors.cian)),
      ],
    );
  }
}
