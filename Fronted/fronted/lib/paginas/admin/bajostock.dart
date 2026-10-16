import 'package:flutter/material.dart';
import 'package:fronted/model/productos.dart';
import 'package:fronted/paginas/admin/widets.dart/listaasincrona.dart';
import 'package:fronted/paginas/admin/widets.dart/pantallaadmin.dart';
import 'package:fronted/paginas/admin/widets.dart/targetaproducto.dart';
import 'package:fronted/service/productoservice.dart';

class Bajostock extends StatefulWidget {
  const Bajostock({super.key});

  @override
  State<Bajostock> createState() => _BajostockState();
}

class _BajostockState extends State<Bajostock> {
  final ProductosService _service = ProductosService();
  late Future<List<Producto>> _futuroProductos;

  @override
  void initState() {
    super.initState();
    _futuroProductos = _service.obtenerListaBajoStock();
  }

  Future<void> _recargar() async {
    setState(() => _futuroProductos = _service.obtenerListaBajoStock());
    await _futuroProductos.catchError((_) => <Producto>[]);
  }

  @override
  Widget build(BuildContext context) {
    return PantallaAdmin(
      titulo: 'Productos en bajo stock',
      child: RefreshIndicator(
        onRefresh: () async {
          setState(() {});

          // Espera un momento para mostrar el efecto de recarga.
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: ListaAsincrona<Producto>(
          futuro: _futuroProductos,
          onRecargar: _recargar,
          textoError: 'No se pudieron cargar los productos',
          textoVacio: '¡Todo en orden! No hay productos en bajo stock',
          iconoVacio: Icons.check_circle_outline_rounded,
          itemBuilder: (_, p) => TarjetaProductoAdmin(producto: p),
        ),
      ),
    );
  }
}
