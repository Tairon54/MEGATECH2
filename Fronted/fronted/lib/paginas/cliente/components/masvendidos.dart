import 'package:flutter/material.dart';
import 'package:fronted/colores/stilocolores.dart';
import 'package:fronted/model/productos.dart';
import 'package:fronted/paginas/cliente/components/targetasproductos.dart';
import 'package:fronted/service/productoservice.dart';
import 'package:google_fonts/google_fonts.dart';

/// Muestra los 3 productos más vendidos (según la tabla de ventas).
/// Usa la misma tarjeta que el resto de la app del cliente.
///
/// [mostrarCarrito] debe ser true solo si hay sesión iniciada.
/// Uso:  MasVendidos(mostrarCarrito: !widget.esInvitado)
class MasVendidos extends StatefulWidget {
  final bool mostrarCarrito;

  const MasVendidos({super.key, this.mostrarCarrito = false});

  @override
  State<MasVendidos> createState() => _MasVendidosState();
}

class _MasVendidosState extends State<MasVendidos> {
  final ProductosService _service = ProductosService();
  late Future<List<Producto>> _futuro;

  @override
  void initState() {
    super.initState();
    _futuro = _service.obtenerMasVendidos();
  }

  void _recargar() {
    setState(() {
      _futuro = _service.obtenerMasVendidos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Producto>>(
      future: _futuro,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 30),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.azulClaro),
            ),
          );
        }

        if (snapshot.hasError) {
          return _mensaje(
            'No se pudieron cargar los más vendidos',
            conBoton: true,
          );
        }

        final productos = snapshot.data ?? [];
        if (productos.isEmpty) {
          return _mensaje('Aún no hay productos más vendidos');
        }

        // Column (no ListView) porque el home ya tiene su propio scroll.
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              for (final p in productos)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: TarjetaProductoCliente(
                    producto: p,
                    mostrarCarrito: widget.mostrarCarrito,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _mensaje(String texto, {bool conBoton = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 20),
      child: Column(
        children: [
          Text(
            texto,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
          ),
          if (conBoton)
            TextButton(
              onPressed: _recargar,
              child: Text(
                'Reintentar',
                style: GoogleFonts.poppins(
                  color: AppColors.azulClaro,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
