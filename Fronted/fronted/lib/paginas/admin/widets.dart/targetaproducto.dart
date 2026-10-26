import 'package:flutter/material.dart';
import 'package:fronted/colores/stilocolores.dart';
import 'package:fronted/model/pedidos.dart' show formatearPesos;
import 'package:fronted/model/productos.dart';
import 'package:fronted/paginas/admin/widets.dart/comprobante/visorcomprobante.dart';
import 'package:fronted/paginas/admin/widets.dart/pedido/targetapedido.dart'
    show FotoCuadrada;
import 'package:google_fonts/google_fonts.dart';

// ESTA ES LA TAREGTA DE RODUCTOS DE ADMIN

/// Tarjeta de producto para admin/empleado: foto, ID, stock, nombre,
/// descripción y precio. El borde y la etiqueta de stock cambian de color
/// cuando queda poco (<= 5) o está agotado.
class TarjetaProductoAdmin extends StatelessWidget {
  final Producto producto;

  const TarjetaProductoAdmin({super.key, required this.producto});

  static const Color _rojo = Color(0xFFFF5252);
  static const Color _naranja = Color(0xFFFFA726);
  static const int _umbralBajoStock = 5; // el mismo que usa el backend

  bool get _agotado => producto.stock <= 0;
  bool get _bajo => !_agotado && producto.stock <= _umbralBajoStock;

  Color get _colorStock => _agotado
      ? _rojo
      : _bajo
      ? _naranja
      : AppColors.azulClaro;

  Color get _colorBorde =>
      (_agotado || _bajo) ? _colorStock : AppColors.bordeTarjeta;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: _colorBorde, width: 1.5),
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
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    _chip('ID ${producto.id}', AppColors.azulClaro),
                    _chip(_textoStock(), _colorStock),
                  ],
                ),
                const SizedBox(height: 6),
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
                  maxLines: 2,
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
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _textoStock() {
    if (_agotado) return 'Agotado';
    if (producto.stock == 1) return '1 unidad';
    return '${producto.stock} unidades';
  }

  Widget _chip(String texto, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        texto,
        style: GoogleFonts.poppins(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
