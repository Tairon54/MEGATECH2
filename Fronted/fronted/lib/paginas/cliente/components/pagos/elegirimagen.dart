import 'package:flutter/material.dart';
import 'package:fronted/colores/stilocolores.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

/// Hoja inferior para elegir de dónde sale la imagen (galería o cámara).
/// Devuelve null si el usuario la cierra sin elegir.
Future<ImageSource?> elegirOrigenImagen(BuildContext context) {
  Widget opcion(IconData icono, String texto, ImageSource origen) => ListTile(
    leading: Icon(icono, color: Colors.white),
    title: Text(texto, style: GoogleFonts.poppins(color: Colors.white)),
    onTap: () => Navigator.pop(context, origen),
  );

  return showModalBottomSheet<ImageSource>(
    context: context,
    backgroundColor: AppColors.fondoOscuro2,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          opcion(
            Icons.photo_library_rounded,
            'Elegir de la galería',
            ImageSource.gallery,
          ),
          opcion(
            Icons.photo_camera_rounded,
            'Tomar una foto',
            ImageSource.camera,
          ),
        ],
      ),
    ),
  );
}
