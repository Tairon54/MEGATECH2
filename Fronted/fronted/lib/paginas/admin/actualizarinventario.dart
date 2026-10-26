import 'package:flutter/material.dart';
import 'package:fronted/colores/stilocolores.dart';
import 'package:fronted/components/Bienvenida/boton_degradado.dart';
import 'package:fronted/components/comunes/aviso.dart';
import 'package:fronted/components/comunes/campoBusqueda.dart';
import 'package:fronted/components/comunes/encabezadoAdmin.dart';
import 'package:fronted/components/comunes/listaasinc.dart';
import 'package:fronted/components/comunes/productosAgrupados.dart';
import 'package:fronted/components/login/fondo.dart';
import 'package:fronted/model/productos.dart';
import 'package:fronted/paginas/admin/hojaProducto.dart';
import 'package:fronted/paginas/admin/widets.dart/barranavega.dart';
import 'package:fronted/paginas/admin/widets.dart/targetaproducto.dart';
import 'package:fronted/service/productoservice.dart';

/// Pantalla del admin para modificar el inventario: lista los productos
/// ordenados por categoría y subcategoría, permite buscar, filtrar con chips,
/// añadir uno nuevo, editar (tocando la tarjeta) y eliminar.
class Actualizarinventario extends StatefulWidget {
  const Actualizarinventario({super.key});

  @override
  State<Actualizarinventario> createState() => _ActualizarinventarioState();
}

class _ActualizarinventarioState extends State<Actualizarinventario> {
  final _service = ProductosService();
  final _buscador = TextEditingController();
  late Future<List<Producto>> _futuro = _service.obtenerTodos();
  String _busqueda = '';
  String? _categoria; // null = todas
  String? _subcategoria; // null = todas

  @override
  void dispose() {
    _buscador.dispose();
    super.dispose();
  }

  Future<void> _recargar() async {
    setState(() => _futuro = _service.obtenerTodos());
    await _futuro.catchError((_) => <Producto>[]);
  }

  /// Filtra por nombre, ID, categoría o subcategoría.
  List<Producto> _filtrar(List<Producto> productos) {
    final q = _busqueda.trim().toLowerCase();
    if (q.isEmpty) return productos;
    return productos
        .where(
          (p) =>
              p.nombre.toLowerCase().contains(q) ||
              p.id.toString() == q ||
              (p.categoria ?? '').toLowerCase().contains(q) ||
              (p.subcategoria ?? '').toLowerCase().contains(q),
        )
        .toList();
  }

  /// Con [producto] edita; sin producto crea uno nuevo.
  Future<void> _abrirFormulario({Producto? producto}) async {
    final guardado = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.fondoTarjeta,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => HojaProducto(producto: producto, service: _service),
    );
    if (guardado != true || !mounted) return;
    mostrarAviso(
      context,
      producto == null
          ? 'Producto añadido correctamente'
          : 'Producto actualizado correctamente',
    );
    _recargar();
  }

  Future<void> _eliminar(Producto p) async {
    final ok = await confirmar(
      context,
      titulo: 'Eliminar producto',
      mensaje:
          '¿Seguro que desea eliminar "${p.nombre}" (ID ${p.id})? '
          'Esta acción no se puede deshacer.',
    );
    if (!ok || !mounted) return;

    try {
      await _service.eliminarProducto(p.id);
      if (!mounted) return;
      mostrarAviso(context, 'Producto eliminado correctamente');
      _recargar();
    } catch (e) {
      if (mounted) mostrarAviso(context, textoError(e), error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Barranavegacioninferior(
        botones: [
          BotonNav(icon: Icons.arrow_back, onTap: () => Navigator.pop(context)),
        ],
      ),
      body: Fondo(
        child: RefreshIndicator(
          onRefresh: _recargar,
          child: SafeArea(
            child: Column(
              children: [
                const EncabezadoAdmin(subtitulo: 'Actualizar inventario'),
                const SizedBox(height: 12),
                CampoBusqueda(
                  controller: _buscador,
                  hint: 'Buscar por nombre, ID o categoría',
                  onChanged: (v) => setState(() => _busqueda = v),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: BotonDegradado(
                    texto: 'Añadir producto',
                    icono: Icons.add_circle_outline,
                    height: 46,
                    borderRadius: 25,
                    onTap: _abrirFormulario,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListaAsincrona<Producto>(
                    futuro: _futuro,
                    onReintentar: _recargar,
                    textoError: 'No se pudieron cargar los productos',
                    textoVacio: _busqueda.isEmpty
                        ? 'Todavía no hay productos registrados'
                        : 'No se encontraron productos',
                    filtro: _filtrar,
                    builder: (context, productos) => ProductosAgrupados(
                      productos: productos,
                      categoria: _categoria,
                      subcategoria: _subcategoria,
                      onCategoria: (v) => setState(() {
                        _categoria = v;
                        _subcategoria = null;
                      }),
                      onSubcategoria: (v) => setState(() => _subcategoria = v),
                      itemBuilder: (_, p) => _TarjetaEditable(
                        producto: p,
                        onEditar: () => _abrirFormulario(producto: p),
                        onEliminar: () => _eliminar(p),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Tarjeta de producto con lápiz (tocar = editar) y papelera (eliminar).
class _TarjetaEditable extends StatelessWidget {
  final Producto producto;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  const _TarjetaEditable({
    required this.producto,
    required this.onEditar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onEditar,
      child: Stack(
        children: [
          TarjetaProductoAdmin(producto: producto),
          const Positioned(
            top: 10,
            right: 14,
            child: Icon(
              Icons.edit_rounded,
              color: AppColors.azulClaro,
              size: 20,
            ),
          ),
          Positioned(
            bottom: 6,
            right: 8,
            child: IconButton(
              tooltip: 'Eliminar producto',
              onPressed: onEliminar,
              icon: const Icon(
                Icons.delete_rounded,
                color: AppColors.rojo,
                size: 24,
              ),
            ),
          ),
        ], 
      ),
    );
  }
}
