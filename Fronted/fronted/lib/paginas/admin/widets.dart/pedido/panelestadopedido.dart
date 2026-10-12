import 'package:flutter/material.dart';
import 'package:fronted/colores/stilocolores.dart';
import 'package:fronted/model/pedidos.dart';
import 'package:google_fonts/google_fonts.dart';


// ESTE ES EL PANEL DE ESTADO DE PEDIDO


/// Total final + botón para cambiar el estado, siempre visibles al final.
class PanelEstadoPedido extends StatelessWidget {
  final Pedido pedido;
  final bool cambiando;
  final VoidCallback onCambiar;

  /// true = solo muestra el estado (sin botón). Se usa con el empleado.
  final bool soloLectura;

  const PanelEstadoPedido({
    super.key,
    required this.pedido,
    required this.cambiando,
    required this.onCambiar,
    this.soloLectura = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = EstadoPedido.color(pedido.estado);
    final puedeCambiar = EstadoPedido.siguiente(pedido.estado) != null;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      decoration: const BoxDecoration(
        color: Color(0xFF0B202E),
        border: Border(top: BorderSide(color: Color(0xFF1BC2F0), width: 1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                'Total del pedido',
                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
              ),
              const Spacer(),
              Text(
                formatearPesos(pedido.total),
                style: GoogleFonts.poppins(
                  color: AppColors.azulClaro,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (soloLectura)
            _EstadoSoloLectura(estado: pedido.estado)
          else
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: (cambiando || !puedeCambiar) ? null : onCambiar,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.black,
                disabledBackgroundColor: color.withOpacity(0.75),
                disabledForegroundColor: Colors.black87,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
              ),
              child: cambiando
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.black,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(EstadoPedido.icono(pedido.estado), size: 22),
                        const SizedBox(width: 8),
                        Text(
                          pedido.estado,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          puedeCambiar
                              ? Icons.swap_horiz_rounded
                              : Icons.lock_outline_rounded,
                          size: 22,
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Muestra el estado del pedido como etiqueta (sin ser un botón).
class _EstadoSoloLectura extends StatelessWidget {
  final String estado;

  const _EstadoSoloLectura({required this.estado});

  @override
  Widget build(BuildContext context) {
    final color = EstadoPedido.color(estado);

    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        border: Border.all(color: color, width: 1.5),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(EstadoPedido.icono(estado), color: color, size: 22),
          const SizedBox(width: 8),
          Text(
            'Estado: $estado',
            style: GoogleFonts.poppins(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}