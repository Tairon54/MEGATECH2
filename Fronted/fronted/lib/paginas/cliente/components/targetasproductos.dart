import 'package:flutter/material.dart';
import 'package:fronted/colores/stilocolores.dart';
import 'package:fronted/model/pedidos.dart' show formatearPesos;
import 'package:fronted/model/productos.dart';
import 'package:fronted/paginas/admin/widets.dart/comprobante/visorcomprobante.dart';
import 'package:fronted/paginas/admin/widets.dart/pedido/targetapedido.dart'
    show FotoCuadrada;
import 'package:fronted/service/carrito.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tarjeta de producto para el cliente: foto, nombre, descripción, precio
/// y, solo si hay sesión iniciada, un botón para añadir al carrito.
class TarjetaProductoCliente extends StatelessWidget {
  final Producto producto;

  /// true únicamente cuando el usuario inició sesión.
  final bool mostrarCarrito;

  const TarjetaProductoCliente({
    super.key,
    required this.producto,
    this.mostrarCarrito = false,
  });

  void _agregar(BuildContext context) {
    final ok = CarritoService.instance.agregar(producto);
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        backgroundColor: ok ? AppColors.azulOscuro : AppColors.rojoOscuro,
        content: Text(
          ok
              ? '${producto.nombre} añadido al carrito'
              : 'Ya tienes todas las unidades disponibles en el carrito',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.fondoTarjeta,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: AppColors.bordeTarjeta, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              final foto = producto.foto;
              if (foto == null) return;

              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => VisorComprobante(url: foto)),
              );
            },
            child: FotoCuadrada(url: producto.foto),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  producto.nombre,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  producto.descripcion,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  formatearPesos(producto.precio),
                  style: GoogleFonts.poppins(
                    color: AppColors.azulClaro,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (mostrarCarrito) ...[
                  const SizedBox(height: 10),
                  _BotonAgregarCarrito(
                    producto: producto,
                    onPressed: () => _agregar(context),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Botón "Añadir al carrito". Se actualiza solo cuando cambia el carrito:
/// muestra cuántas unidades lleva y se desactiva al llegar al stock.
class _BotonAgregarCarrito extends StatelessWidget {
  final Producto producto;
  final VoidCallback onPressed;

  const _BotonAgregarCarrito({required this.producto, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: CarritoService.instance,
      builder: (context, _) {
        final enCarrito = CarritoService.instance.cantidadDe(producto.id);
        final agotado = producto.stock < 1 || enCarrito >= producto.stock;

        return SizedBox(
          width: double.infinity,
          height: 38,
          child: ElevatedButton.icon(
            onPressed: agotado ? null : onPressed,
            icon: const Icon(Icons.add_shopping_cart_rounded, size: 18),
            label: Text(
              enCarrito == 0
                  ? 'Añadir al carrito'
                  : 'Añadir más ($enCarrito en el carrito)',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.azulClaro,
              foregroundColor: Colors.black,
              disabledBackgroundColor: Colors.white24,
              disabledForegroundColor: Colors.white54,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        );
      },
    );
  }
}
