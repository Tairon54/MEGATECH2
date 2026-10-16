import 'package:flutter/material.dart';
import 'package:fronted/colores/stilocolores.dart';
import 'package:fronted/model/pedidos.dart' show formatearPesos;
import 'package:google_fonts/google_fonts.dart';

/// Barra oscura con el número del pedido y el total a pagar.
class TotalPago extends StatelessWidget {
  final int idPedido;
  final double total;

  const TotalPago({super.key, required this.idPedido, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.fondoOscuro3,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total a pagar',
                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 11),
              ),
              Text(
                'Pedido #$idPedido',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Text(
            formatearPesos(total),
            style: GoogleFonts.poppins(
              color: AppColors.cian,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
