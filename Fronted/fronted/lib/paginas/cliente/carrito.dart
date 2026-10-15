import 'package:flutter/material.dart';
import 'package:fronted/colores/stilocolores.dart';
import 'package:fronted/components/comunes/aviso.dart';
import 'package:fronted/components/comunes/botonDegradado.dart';
import 'package:fronted/paginas/admin/widets.dart/pantallaadmin.dart';
import 'package:fronted/paginas/cliente/components/carritovacio.dart';
import 'package:fronted/paginas/cliente/components/resumenpedido.dart';
import 'package:fronted/paginas/cliente/components/subtitulo.dart';
import 'package:fronted/paginas/cliente/components/itemcarrito.dart';
import 'package:fronted/service/carrito.dart';
import 'package:fronted/service/pedidos.dart';
import 'package:google_fonts/google_fonts.dart';

/// Pantalla del carrito de compras (solo para clientes con sesión iniciada).
/// - Sin productos: muestra la tarjeta de carrito vacío.
/// - Con productos: lista cada uno con su cantidad y subtotal.
/// - "Pagar ahora" crea el pedido en el backend (POST /pedidos/crear).
class Carrito extends StatefulWidget {
  final VoidCallback? onVolver;

  const Carrito({super.key, this.onVolver});

  @override
  State<Carrito> createState() => _CarritoState();
}

class _CarritoState extends State<Carrito> {
  final CarritoService _carrito = CarritoService.instance;
  final PedidosService _pedidos = PedidosService();
  bool _procesando = false;

  /// Regresa a la pantalla anterior (el home del cliente).
  void _volver() {
    if (widget.onVolver != null) {
      widget.onVolver!();
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _quitarProducto(ItemCarrito item) async {
    final ok = await confirmar(
      context,
      titulo: 'Quitar producto',
      mensaje: '¿Quieres quitar "${item.producto.nombre}" del carrito?',
      textoConfirmar: 'Quitar',
    );
    if (ok) _carrito.eliminar(item.producto.id);
  }

  Future<void> _pagar() async {
    if (_procesando) return;

    if (_carrito.estaVacio) {
      mostrarAviso(context, 'Tu carrito está vacío', error: true);
      return;
    }

    setState(() => _procesando = true);
    try {
      final idPedido = await _pedidos.crearPedido(_carrito.items);
      _carrito.vaciar();
      if (!mounted) return;
      await _mostrarExito(idPedido);
      if (mounted) _volver();
    } on PedidoException catch (e) {
      mostrarAviso(context, e.mensaje, error: true);
    } catch (_) {
      mostrarAviso(
        context,
        'No se pudo conectar con el servidor. Intenta de nuevo.',
        error: true,
      );
    } finally {
      if (mounted) setState(() => _procesando = false);
    }
  }

  Future<void> _mostrarExito(int? idPedido) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.fondoTarjeta,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF2ECC71),
              size: 28,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '¡Pedido realizado!',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          idPedido == null
              ? 'Tu pedido fue registrado con estado "Por pagar".'
              : 'Tu pedido #$idPedido fue registrado con estado "Por pagar".',
          style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.azulClaro,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              'Seguir comprando',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PantallaAdmin(
      titulo: 'Tu carrito de compras',
      // Desde el carrito la flecha regresa al home (no a la primera ruta).
      onVolver: _volver,
      child: ListenableBuilder(
        listenable: _carrito,
        builder: (context, _) {
          final items = _carrito.items;

          return ListView(
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
            children: [
              const TextoInformativo(
                texto: 'Revisa bien tus productos antes de finalizar la compra',
              ),
              const SizedBox(height: 20),

              if (items.isEmpty)
                CarritoVacio(onExplorar: _volver)
              else
                for (final item in items)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: TarjetaItemCarrito(
                      key: ValueKey(item.producto.id),
                      item: item,
                      // "–" solo si hay más de una unidad (para quitar todo
                      // se usa el icono de la papelera).
                      onMenos: item.cantidad > 1
                          ? () => _carrito.quitarUna(item.producto.id)
                          : null,
                      // "+" se desactiva al llegar al stock disponible.
                      onMas: item.cantidad < item.producto.stock
                          ? () => _carrito.agregar(item.producto)
                          : null,
                      onEliminar: () => _quitarProducto(item),
                    ),
                  ),

              const SizedBox(height: 14),
              ResumenPedido(items: items, total: _carrito.total),
              const SizedBox(height: 28),
              Center(
                child: SizedBox(
                  width: 200,
                  child: BotonDegradado(
                    texto: 'Pagar ahora',
                    cargando: _procesando,
                    height: 48,
                    borderRadius: 20,
                    onTap: _pagar,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}