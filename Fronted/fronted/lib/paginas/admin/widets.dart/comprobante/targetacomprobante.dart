import 'package:flutter/material.dart';
import 'package:fronted/colores/stilocolores.dart';
import 'package:fronted/components/comunes/etiquetaColor.dart';
import 'package:fronted/components/comunes/filaDato.dart';
import 'package:fronted/model/comprobante.dart';
import 'package:fronted/model/pedidos.dart';
import 'package:fronted/paginas/admin/widets.dart/pedido/targetapedido.dart';
import 'package:google_fonts/google_fonts.dart';

/// Color y texto de la etiqueta según si la transferencia ya fue verificada.
Color colorVerificacion(bool porVerificar) =>
    porVerificar ? const Color(0xFFFFA726) : const Color(0xFF2ECC71);

/// Tarjeta de un comprobante en la lista: foto, cliente, cédula, pedido,
/// fecha, total y si está "Por verificar" o "Verificada".
class TarjetaComprobante extends StatelessWidget {
  final Comprobante comprobante;
  final VoidCallback onTap;

  const TarjetaComprobante({
    super.key,
    required this.comprobante,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = comprobante;
    final color = colorVerificacion(c.porVerificar);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(25),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1F2937),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: color, width: 1.5),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FotoCuadrada(url: c.foto, tam: 95),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FilaDato(
                      Icons.person_outline,
                      c.nombreCliente,
                      fuerte: true,
                    ),
                    const SizedBox(height: 4),
                    FilaDato(Icons.badge_outlined, c.cedula),
                    const SizedBox(height: 4),
                    FilaDato(
                      Icons.receipt_long_outlined,
                      'Pedido #${c.idPedido}',
                    ),
                    const SizedBox(height: 4),
                    FilaDato(Icons.event_outlined, c.fecha),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          formatearPesos(c.total),
                          style: GoogleFonts.poppins(
                            color: AppColors.azulClaro,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        EtiquetaColor(
                          texto: c.porVerificar
                              ? 'Por verificar'
                              : 'Verificada',
                          color: color,
                          icono: c.porVerificar
                              ? Icons.hourglass_top_rounded
                              : Icons.verified_outlined,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
