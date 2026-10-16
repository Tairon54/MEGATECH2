import 'package:flutter/material.dart';
import 'package:fronted/components/comunes/aviso.dart';
import 'package:fronted/components/comunes/botonDegradado.dart';
import 'package:fronted/paginas/admin/widets.dart/pantallaadmin.dart';
import 'package:fronted/paginas/cliente/components/carritovacio.dart';
import 'package:fronted/paginas/cliente/pagosuno.dart';
import 'package:fronted/paginas/cliente/components/resumenpedido.dart';
import 'package:fronted/paginas/cliente/components/subtitulo.dart';
import 'package:fronted/paginas/cliente/components/itemcarrito.dart';
import 'package:fronted/service/carrito.dart';
import 'package:fronted/service/pedidos.dart';

/// Pantalla del carrito de compras (solo para clientes con sesión iniciada).
/// - Sin productos: muestra la tarjeta de carrito vacío.
/// - Con productos: lista cada uno con su cantidad y subtotal.
/// - "Pagar ahora" crea el pedido en el backend (POST /pedidos/crear) y
///   abre el proceso de pago (Pagosuno) para subir el comprobante.
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
      // Guardamos el total antes de vaciar el carrito.
      final total = _carrito.total;
      final idPedido = await _pedidos.crearPedido(_carrito.items);
      _carrito.vaciar();
      if (!mounted) return;

      if (idPedido == null) {
        // El pedido se creó pero no pudimos leer su número.
        mostrarAviso(
          context,
          'Tu pedido fue creado. Revisa "Mis pedidos" para pagarlo.',
        );
        _volver();
        return;
      }

      // Pasa al proceso de pago para enviar el comprobante de la transferencia.
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => Pagosuno(idPedido: idPedido, total: total),
        ),
      );
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
          // coso para que se refresque la pantalla

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {});

              // Espera un momento para mostrar el efecto de recarga.
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
              children: [
                const TextoInformativo(
                  texto:
                      'Revisa bien tus productos antes de finalizar la compra',
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
            ),
          );
        },
      ),
    );
  }
}
