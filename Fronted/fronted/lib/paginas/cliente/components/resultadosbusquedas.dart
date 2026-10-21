import 'package:flutter/material.dart';
import 'package:fronted/colores/stilocolores.dart';
import 'package:fronted/components/login/fondo.dart';
import 'package:fronted/model/productos.dart';
import 'package:fronted/paginas/admin/widets.dart/targetaproducto.dart';
import 'package:fronted/paginas/cliente/components/barradebusqueda.dart';
import 'package:fronted/paginas/cliente/components/targetasproductos.dart';
import 'package:fronted/service/productoservice.dart';
import 'package:google_fonts/google_fonts.dart';

/// Pantalla de resultados de búsqueda. Carga los productos una sola vez y
/// filtra en el teléfono mientras el usuario escribe.
/// Igual que PantallaProductos: el cliente solo ve productos con stock y
/// el personal (admin/empleado) ve todos.
class ResultadosBusqueda extends StatefulWidget {
  /// Texto que venía escrito en la barra del home.
  final String consulta;

  const ResultadosBusqueda({super.key, this.consulta = ''});

  @override
  State<ResultadosBusqueda> createState() => _ResultadosBusquedaState();
}

class _ResultadosBusquedaState extends State<ResultadosBusqueda> {
  final ProductosService _service = ProductosService();
  late final TextEditingController _controller;
  late Future<_Datos> _futuro;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.consulta);
    _controller.addListener(() => setState(() {}));
    _futuro = _cargar();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<_Datos> _cargar() async {
    final rol = await _service.rolActual();
    final esPersonal = rol == 'Admin' || rol == 'Empleado';
    final sesionIniciada = rol != null;
    var productos = await _service.obtenerTodos();
    if (!esPersonal) {
      productos = productos.where((p) => p.stock > 0).toList();
    }
    return _Datos(productos, esPersonal, sesionIniciada);
  }

  Future<void> _recargar() async {
    setState(() {
      _futuro = _cargar();
    });
    await _futuro.catchError((_) => const _Datos([], false, false));
  }

  @override
  Widget build(BuildContext context) {
    final consulta = _controller.text.trim();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Fondo(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: kToolbarHeight),
              Text(
                'Buscar productos',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF1BC2F0),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: BarraBusqueda(
                  controller: _controller,
                  textInputAction: TextInputAction.search,
                  suffixIcon: consulta.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close, color: Colors.white70),
                          onPressed: _controller.clear,
                        ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: FutureBuilder<_Datos>(
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

                    final datos = snapshot.data!;

                    if (consulta.isEmpty) {
                      return _mensaje(
                        icono: Icons.search_rounded,
                        texto: 'Escribe el nombre de un producto, marca o categoría',
                      );
                    }

                    final resultados = ProductosService.filtrar(
                      datos.productos,
                      consulta,
                    );

                    if (resultados.isEmpty) {
                      return _mensaje(
                        icono: Icons.search_off_rounded,
                        texto: 'No encontramos productos para "$consulta"',
                      );
                    }

                    return RefreshIndicator(
                      color: AppColors.azulClaro,
                      onRefresh: _recargar,
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                        itemCount: resultados.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (context, i) => datos.esPersonal
                            ? TarjetaProductoAdmin(producto: resultados[i])
                            : TarjetaProductoCliente(
                                producto: resultados[i],
                                mostrarCarrito: datos.sesionIniciada,
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

class _Datos {
  final List<Producto> productos;
  final bool esPersonal;
  final bool sesionIniciada;

  const _Datos(this.productos, this.esPersonal, this.sesionIniciada);
}