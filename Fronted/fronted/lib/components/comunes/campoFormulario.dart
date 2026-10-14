import 'package:flutter/material.dart';
import 'package:fronted/colores/stilocolores.dart';
import 'package:google_fonts/google_fonts.dart';

/// Campo de formulario oscuro con borde azul (para hojas y diálogos).
/// [decoracion] es estático para reutilizarlo en Dropdowns.
class CampoFormulario extends StatelessWidget {
  final TextEditingController controller;
  final String etiqueta;
  final String? prefijo;
  final String? Function(String?)? validator;
  final TextInputType? teclado;
  final int maxLines;
  final int? minLines;
  final TextAlign alineacion;
  final TextCapitalization capitalizar;

  const CampoFormulario({
    super.key,
    required this.controller,
    required this.etiqueta,
    this.prefijo,
    this.validator,
    this.teclado,
    this.maxLines = 1,
    this.minLines,
    this.alineacion = TextAlign.start,
    this.capitalizar = TextCapitalization.none,
  });

  static InputDecoration decoracion(String etiqueta, {String? prefijo}) {
    OutlineInputBorder borde(Color c, [double ancho = 1]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(color: c, width: ancho),
    );
    return InputDecoration(
      labelText: etiqueta,
      prefixText: prefijo,
      prefixStyle: GoogleFonts.poppins(color: Colors.white),
      labelStyle: GoogleFonts.poppins(color: Colors.white70, fontSize: 13),
      filled: true,
      fillColor: AppColors.fondoOscuro2,
      enabledBorder: borde(AppColors.bordeTarjeta),
      focusedBorder: borde(AppColors.azulClaro, 2),
      errorBorder: borde(AppColors.rojo),
      focusedErrorBorder: borde(AppColors.rojo, 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
      keyboardType: teclado,
      maxLines: maxLines,
      minLines: minLines,
      textAlign: alineacion,
      textCapitalization: capitalizar,
      decoration: decoracion(etiqueta, prefijo: prefijo),
      validator: validator,
    );
  }
}
