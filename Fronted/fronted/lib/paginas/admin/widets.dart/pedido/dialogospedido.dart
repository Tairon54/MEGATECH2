import 'package:flutter/material.dart';
import 'package:fronted/colores/stilocolores.dart';
import 'package:fronted/model/pedidos.dart';
import 'package:google_fonts/google_fonts.dart';

// ESTA ES PRACTICAMENTE TODA LA PANTALLA DE CAMBIAR EL ESTADO DEL PEDIDO

/// Hoja con los estados. Solo los estados permitidos quedan habilitados.
/// Devuelve el estado elegido, o null si se cierra sin elegir.
Future<String?> elegirNuevoEstado(BuildContext context, Pedido pedido) {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      decoration: const BoxDecoration(
        color: Color(0xFF1F2937),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: AppColors.bordeTarjeta, width: 1.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Cambiar estado del pedido',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            for (final estado in EstadoPedido.todos)
              _OpcionEstado(
                estado: estado,
                esActual: estado == pedido.estado,
                habilitado: EstadoPedido.puedeCambiar(pedido.estado, estado),
              ),
          ],
        ),
      ),
    ),
  );
}

/// Diálogo "Confirmar cambio". Devuelve true si el admin confirma.
Future<bool> confirmarCambioEstado(
  BuildContext context,
  Pedido pedido,
  String nuevoEstado,
) async {
  final color = EstadoPedido.color(nuevoEstado);
  final esCancelacion = nuevoEstado == EstadoPedido.cancelado;

  final aviso = nuevoEstado == EstadoPedido.porEntregar
      ? '\n\nSe le enviará un correo de confirmación al cliente.'
      : esCancelacion
      ? '\n\nLos productos volverán al stock. Esta acción no se puede deshacer.'
      : '';

  final confirmado = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF1F2937),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
        side: BorderSide(color: color, width: 1.5),
      ),
      title: Text(
        'Confirmar cambio',
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Text(
        'El pedido #${pedido.id} pasará de "${pedido.estado}" '
        'a "$nuevoEstado".$aviso',
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
            backgroundColor: color,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Text(
            esCancelacion ? 'Sí, cancelar' : 'Confirmar',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ),
  );

  return confirmado == true;
}

class _OpcionEstado extends StatelessWidget {
  final String estado;
  final bool esActual;
  final bool habilitado;

  const _OpcionEstado({
    required this.estado,
    required this.esActual,
    required this.habilitado,
  });

  @override
  Widget build(BuildContext context) {
    final color = EstadoPedido.color(estado);
    final trailing = esActual
        ? 'Actual'
        : habilitado
        ? 'Disponible'
        : 'No disponible';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Opacity(
        opacity: (esActual || habilitado) ? 1 : 0.4,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: habilitado ? () => Navigator.pop(context, estado) : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: color.withOpacity(esActual ? 0.18 : 0.08),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: color, width: esActual ? 2 : 1),
              ),
              child: Row(
                children: [
                  Icon(EstadoPedido.icono(estado), color: color),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      estado,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    trailing,
                    style: GoogleFonts.poppins(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
