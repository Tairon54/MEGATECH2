import 'package:flutter/material.dart';
import 'package:fronted/colores/stilocolores.dart';
import 'package:fronted/components/login/fondo.dart';
import 'package:fronted/model/productos.dart';
import 'package:fronted/paginas/admin/widets.dart/targetaproducto.dart';
import 'package:fronted/paginas/cliente/components/menu.dart';
import 'package:fronted/paginas/cliente/components/targetasproductos.dart';
import 'package:fronted/service/productoservice.dart';
import 'package:google_fonts/google_fonts.dart';

/// Pantalla reutilizable que lista los productos de UNA subcategoría.
/// Sirve para cliente y para personal: según el rol del usuario que inició
/// sesión muestra la tarjeta de cliente (foto, nombre, descripción, precio)
/// o la de admin (con ID y stock, y también los productos agotados).
class PantallaProductos extends StatefulWidget {
  /// Texto que se ve como título de la pantalla.
  final String titulo;

  /// Nombre de la subcategoría en la base de datos (tabla "subcategorias").
  final String subcategoria;

  const PantallaProductos({
    super.key,
    required this.titulo,
    required this.subcategoria,
  });

  @override
  State<PantallaProductos> createState() => _PantallaProductosState();
}

class _PantallaProductosState extends State<PantallaProductos> {
  final ProductosService _service = ProductosService();
  late Future<_Resultado> _futuro;

  @override
  void initState() {
    super.initState();
    _futuro = _cargar();
  }

  /// Primero averigua el rol y luego pide los productos: el cliente solo ve
  /// los que tienen stock; admin y empleado ven todos.
  Future<_Resultado> _cargar() async {
    final rol = await _service.rolActual();
    final esPersonal = rol == 'Admin' || rol == 'Empleado';
    // Sin token válido (invitado) rol es null: no puede usar el carrito.
    final sesionIniciada = rol != null;
    final productos = await _service.obtenerPorSubcategoria(
      widget.subcategoria,
      soloDisponibles: !esPersonal,
    );
    return _Resultado(productos, esPersonal, sesionIniciada);
  }

  Future<void> _recargar() async {
    setState(() {
      _futuro = _cargar();
    });
    await _futuro.catchError((_) => const _Resultado([], false, false));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const Menu(),
      body: Fondo(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: kToolbarHeight),
              Text(
                'Megatech 2',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.titulo,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: const Color(0xFF1BC2F0),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: FutureBuilder<_Resultado>(
                  future: _futuro,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.azulClaro,
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return _mensaje(
                        icono: Icons.wifi_off_rounded,
                        texto: 'No se pudieron cargar los productos',
                        conBoton: true,
                      );
                    }

                    final resultado = snapshot.data!;
                    final productos = resultado.productos;
                    if (productos.isEmpty) {
                      return _mensaje(
                        icono: Icons.inventory_2_outlined,
                        texto: 'Por ahora no hay productos en ${widget.titulo}',
                      );
                    }

                    return RefreshIndicator(
                      color: AppColors.azulClaro,
                      onRefresh: _recargar,
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                        itemCount: productos.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (context, i) => resultado.esPersonal
                            ? TarjetaProductoAdmin(producto: productos[i])
                            : TarjetaProductoCliente(
                                producto: productos[i],
                                mostrarCarrito: resultado.sesionIniciada,
                              ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mensaje({
    required IconData icono,
    required String texto,
    bool conBoton = false,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, color: Colors.white54, size: 56),
            const SizedBox(height: 12),
            Text(
              texto,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 15),
            ),
            if (conBoton) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _recargar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3FA9F5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  'Reintentar',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Productos ya filtrados + si quien mira es personal (admin/empleado)
/// + si hay una sesión iniciada.
class _Resultado {
  final List<Producto> productos;
  final bool esPersonal;
  final bool sesionIniciada;

  const _Resultado(this.productos, this.esPersonal, this.sesionIniciada);
}
