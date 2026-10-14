import 'package:flutter/material.dart';
import 'package:fronted/colores/stilocolores.dart';
import 'package:google_fonts/google_fonts.dart';

/// Quita el prefijo "Exception: " de un error para mostrarlo al usuario.
String textoError(Object e) => e.toString().replaceFirst('Exception: ', '');

/// SnackBar estándar de la app (azul = éxito, rojo = error).
void mostrarAviso(BuildContext context, String texto, {bool error = false}) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: error ? AppColors.rojoOscuro : AppColors.azulOscuro,
      content: Text(texto, style: GoogleFonts.poppins(color: Colors.white)),
    ),
  );
}

/// Diálogo de confirmación (por defecto para eliminar). Devuelve true si acepta.
Future<bool> confirmar(
  BuildContext context, {
  required String titulo,
  required String mensaje,
  String textoConfirmar = 'Eliminar',
}) async {
  final r = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.fondoTarjeta,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      title: Text(
        titulo,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Text(
        mensaje,
        style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(
            'Cancelar',
            style: GoogleFonts.poppins(color: Colors.white70),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.rojo,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Text(
            textoConfirmar,
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ),
  );
  return r == true;
}
