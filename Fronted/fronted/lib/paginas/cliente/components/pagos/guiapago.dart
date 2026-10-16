import 'package:flutter/material.dart';
import 'package:fronted/colores/stilocolores.dart';
import 'package:fronted/paginas/cliente/components/pagos/targetapagos.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tarjeta "¿Cómo pagar?" con los pasos para transferir y subir el comprobante.
class GuiaPago extends StatelessWidget {
  final String numero;

  const GuiaPago({super.key, required this.numero});

  @override
  Widget build(BuildContext context) {
    final pasos = [
      'Abre tu app Nequi y transfiere al número +57 $numero.',
      'Toma un pantallazo del comprobante de pago.',
      'Súbelo aquí y confirma.',
    ];

    return TarjetaPago(
      radio: 26,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¿CÓMO PAGAR?',
            style: GoogleFonts.poppins(
              color: AppColors.azulClaro,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          for (var i = 0; i < pasos.length; i++) _paso(i + 1, pasos[i]),
        ],
      ),
    );
  }

  Widget _paso(int n, String texto) {
    final estilo = GoogleFonts.poppins(color: Colors.white, fontSize: 12);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$n. ', style: estilo),
          Expanded(child: Text(texto, style: estilo)),
        ],
      ),
    );
  }
}
