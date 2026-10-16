import 'package:flutter/material.dart';
import 'package:fronted/colores/stilocolores.dart';
import 'package:fronted/components/comunes/botonDegradado.dart';
import 'package:fronted/paginas/admin/widets.dart/pantallaadmin.dart';
import 'package:google_fonts/google_fonts.dart';

/// Confirmación que ve el cliente después de enviar el comprobante.
class PagoExitoso extends StatelessWidget {
  const PagoExitoso({super.key});

  void _regresar(BuildContext context) =>
      Navigator.popUntil(context, (route) => route.isFirst);

  @override
  Widget build(BuildContext context) {
    return PantallaAdmin(
      titulo: 'Proceso de pago',
      mostrarBarra: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(28, 10, 28, 24),
        children: [
          const SizedBox(height: 10),
          Text(
            'Comprobante enviado correctamente',
            textAlign: TextAlign.center,
            style: GoogleFonts.acme(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(26),
            decoration: BoxDecoration(
              color: AppColors.fondoTarjeta.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: AppColors.bordeTarjeta, width: 1),
            ),
            child: Text(
              'Tu comprobante ha sido enviado exitosamente. El pago será '
              'verificado por los administradores y se te enviará un correo '
              'confirmando que la transferencia fue exitosa. En consecuencia '
              'tendrás que pasar por el almacén a recoger tu pedido.',
              textAlign: TextAlign.center,
              style: GoogleFonts.acme(
                color: Colors.white,
                fontSize: 18,
                height: 1.35,
              ),
            ),
          ),
          const SizedBox(height: 36),
          Center(
            child: SizedBox(
              width: 170,
              child: BotonDegradado(
                texto: 'Regresar',
                height: 44,
                borderRadius: 22,
                onTap: () => _regresar(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
