import 'package:flutter/material.dart';
import 'package:fronted/model/pedidos.dart';
import 'package:fronted/paginas/admin/widets.dart/pedido/dialogospedido.dart';
import 'package:fronted/paginas/admin/widets.dart/ventas/mensajesnack.dart';
import 'package:fronted/paginas/admin/widets.dart/pedido/panelestadopedido.dart';
import 'package:fronted/paginas/admin/widets.dart/pantallaadmin.dart';
import 'package:fronted/paginas/admin/widets.dart/pedido/targetaarticulopedido.dart';
import 'package:fronted/paginas/admin/widets.dart/pedido/tragetaclientepedido.dart';
import 'package:fronted/service/pedidos.dart';
import 'package:google_fonts/google_fonts.dart';

/// Detalle de un pedido: cliente, artículos, total y cambio de estado
/// (guarda en la base de datos).
class DetallePedido extends StatefulWidget {
  final Pedido pedido;

  /// false para el empleado: ve el estado pero no puede cambiarlo.
  final bool puedeCambiarEstado;

  const DetallePedido({
    super.key,
    required this.pedido,
    this.puedeCambiarEstado = true,
  });

  @override
  State<DetallePedido> createState() => _DetallePedidoState();
}

class _DetallePedidoState extends State<DetallePedido> {
  final PedidosService _service = PedidosService();
  late Pedido _pedido;
  bool _cambiando = false;

  @override
  void initState() {
    super.initState();
    _pedido = widget.pedido;
  }

  Future<void> _cambiarEstado() async {
    if (!widget.puedeCambiarEstado) return; // seguridad extra
    final elegido = await elegirNuevoEstado(context, _pedido);
    if (elegido == null || !mounted) return;

    final confirmado = await confirmarCambioEstado(context, _pedido, elegido);
    if (confirmado && mounted) _aplicarCambio(elegido);
  }

  /// Llama al backend (PUT /pedidos/actualizar/:id). Solo si responde bien
  /// (o si el estado quedó guardado pero falló algo después, como el correo)
  /// se actualiza lo que se ve en pantalla.
  Future<void> _aplicarCambio(String nuevoEstado) async {
    setState(() => _cambiando = true);
    try {
      await _service.cambiarEstado(_pedido.id, nuevoEstado);
      if (!mounted) return;
      setState(() => _pedido = _pedido.copyWith(estado: nuevoEstado));
      mostrarSnack(
        context,
        'Pedido actualizado a "$nuevoEstado"',
        color: EstadoPedido.color(nuevoEstado),
        icono: Icons.check_circle_outline_rounded,
      );
    } on PedidoException catch (e) {
      if (!mounted) return;
      if (e.aplicado) {
        setState(() => _pedido = _pedido.copyWith(estado: nuevoEstado));
      }
      mostrarSnack(
        context,
        e.mensaje,
        color: e.aplicado ? const Color(0xFFFFA726) : const Color(0xFFFF5252),
        icono: e.aplicado
            ? Icons.warning_amber_rounded
            : Icons.error_outline_rounded,
      );
    } catch (_) {
      mostrarSnack(
        context,
        'No se pudo conectar con el servidor',
        color: const Color(0xFFFF5252),
        icono: Icons.wifi_off_rounded,
      );
    } finally {
      if (mounted) setState(() => _cambiando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PantallaAdmin(
      titulo: 'Pedido #${_pedido.id}',
      onVolver: () => Navigator.pop(context),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              children: [
                TarjetaClientePedido(pedido: _pedido),
                const SizedBox(height: 18),
                Padding(
                  padding: const EdgeInsets.only(left: 6, bottom: 10),
                  child: Text(
                    'Artículos (${_pedido.articulos.length})',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (_pedido.articulos.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        'Este pedido no tiene artículos',
                        style: GoogleFonts.poppins(color: Colors.white70),
                      ),
                    ),
                  ),
                for (final articulo in _pedido.articulos)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TarjetaArticuloPedido(articulo: articulo),
                  ),
              ],
            ),
          ),
          PanelEstadoPedido(
            pedido: _pedido,
            cambiando: _cambiando,
            soloLectura: !widget.puedeCambiarEstado,
            onCambiar: _cambiarEstado,
          ),
        ],
      ),
    );
  }
}