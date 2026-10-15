import 'package:flutter/material.dart';
import 'package:fronted/colores/stilocolores.dart';
import 'package:fronted/model/pedidos.dart' show formatearPesos;
import 'package:fronted/paginas/admin/widets.dart/pedido/targetapedido.dart'
    show FotoCuadrada;
import 'package:fronted/service/carrito.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tarjeta de un producto dentro del carrito: foto, nombre, precio,
/// selector de cantidad (– y +), botón para quitarlo y subtotal.
///
/// [onMas] / [onMenos] pueden ser null para dejar el botón desactivado
/// (por ejemplo, "+" cuando ya se alcanzó el stock disponible).
class TarjetaItemCarrito extends StatelessWidget {
  final ItemCarrito item;
  final VoidCallback? onMas;
  final VoidCallback? onMenos;
  final VoidCallback onEliminar;

  const TarjetaItemCarrito({
    super.key,
    required this.item,
    required this.onMas,
    required this.onMenos,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    final p = item.producto;

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
          FotoCuadrada(url: p.foto, tam: 90),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        p.nombre,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: onEliminar,
                      borderRadius: BorderRadius.circular(20),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.delete_outline_rounded,
                          color: AppColors.rojo,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  '${formatearPesos(p.precio)} c/u',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _stepper(),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            formatearPesos(item.subtotal),
                            style: GoogleFonts.poppins(
                              color: AppColors.azulClaro,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (onMas == null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Máximo disponible (${p.stock})',
                    style: GoogleFonts.poppins(
                      color: Colors.white54,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepper() {
    Widget boton(IconData icono, VoidCallback? onTap) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: onTap == null ? null : AppColors.gradienteBoton,
            color: onTap == null ? Colors.white12 : null,
          ),
          child: Icon(
            icono,
            color: onTap == null ? Colors.white30 : Colors.black,
            size: 18,
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        boton(Icons.remove, onMenos),
        SizedBox(
          width: 34,
          child: Text(
            '${item.cantidad}',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        boton(Icons.add, onMas),
      ],
    );
  }
}