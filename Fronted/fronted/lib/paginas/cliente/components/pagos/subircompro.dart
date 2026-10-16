import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:fronted/colores/stilocolores.dart';
import 'package:fronted/paginas/cliente/components/pagos/targetapagos.dart';
import 'package:google_fonts/google_fonts.dart';

/// Zona para subir el comprobante: muestra la vista previa si ya hay [bytes]
/// o la invitación a seleccionar una imagen.
class SubirComprobante extends StatelessWidget {
  final Uint8List? bytes;
  final VoidCallback onTap;

  const SubirComprobante({super.key, required this.bytes, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'COMPROBANTE DE PAGO NEQUI',
          style: GoogleFonts.poppins(
            color: Colors.white70,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: onTap,
          child: TarjetaPago(
            height: 190,
            child: bytes != null ? _vistaPrevia() : _invitacion(),
          ),
        ),
      ],
    );
  }

  Widget _vistaPrevia() => Stack(
    fit: StackFit.expand,
    children: [
      Image.memory(bytes!, fit: BoxFit.cover),
      Positioned(
        right: 10,
        bottom: 10,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Toca para cambiar',
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 11),
          ),
        ),
      ),
    ],
  );

  Widget _invitacion() => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppColors.gradienteBoton,
        ),
        child: const Icon(Icons.upload_rounded, color: Colors.white),
      ),
      const SizedBox(height: 12),
      Text(
        'Sube tu pantallazo o foto',
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        'Toca aquí para seleccionar',
        style: GoogleFonts.poppins(
          color: AppColors.azulEnlace,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}
