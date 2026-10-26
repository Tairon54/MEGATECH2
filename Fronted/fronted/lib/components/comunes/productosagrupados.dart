import 'package:flutter/material.dart';
import 'package:fronted/colores/stilocolores.dart';
import 'package:fronted/model/productos.dart';
import 'package:google_fonts/google_fonts.dart';

/// Reglas para agrupar y ordenar productos por categoría y subcategoría.
class OrdenProductos {
  OrdenProductos._();

  static const String sinCategoria = 'Sin categoría';
  static const String sinSubcategoria = 'Sin subcategoría';

  static String categoriaDe(Producto p) {
    final c = p.categoria?.trim() ?? '';
    return c.isEmpty ? sinCategoria : c;
  }

  static String subcategoriaDe(Producto p) {
    final s = p.subcategoria?.trim() ?? '';
    return s.isEmpty ? sinSubcategoria : s;
  }

  // Los "Sin ..." van siempre al final.
  static String _clave(String v) =>
      (v == sinCategoria || v == sinSubcategoria) ? '\uffff' : v.toLowerCase();

  static int comparar(String a, String b) => _clave(a).compareTo(_clave(b));

  static List<String> categorias(List<Producto> productos) {
    return productos.map(categoriaDe).toSet().toList()..sort(comparar);
  }

  static List<String> subcategorias(
    List<Producto> productos,
    String categoria,
  ) {
    return productos
        .where((p) => categoriaDe(p) == categoria)
        .map(subcategoriaDe)
        .toSet()
        .toList()
      ..sort(comparar);
  }

  /// Ordena por categoría, luego subcategoría y luego nombre.
  static List<Producto> ordenar(List<Producto> productos) {
    return [...productos]..sort((a, b) {
      final c = comparar(categoriaDe(a), categoriaDe(b));
      if (c != 0) return c;
      final s = comparar(subcategoriaDe(a), subcategoriaDe(b));
      if (s != 0) return s;
      return a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase());
    });
  }
}

/// Fila horizontal de chips con la opción "Todas" al inicio.
class ChipsDesplazables extends StatelessWidget {
  final List<String> opciones;
  final String? seleccionada; // null = Todas
  final ValueChanged<String?> onElegir;
  final bool pequena;

  const ChipsDesplazables({
    super.key,
    required this.opciones,
    required this.seleccionada,
    required this.onElegir,
    this.pequena = false,
  });

  Widget _chip(String texto, bool activo, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(
          texto,
          style: GoogleFonts.poppins(
            fontSize: pequena ? 12 : 13,
            fontWeight: FontWeight.w600,
            color: activo ? Colors.black : Colors.white70,
          ),
        ),
        selected: activo,
        showCheckmark: false,
        selectedColor: AppColors.azulClaro,
        backgroundColor: const Color(0xFF1F2937),
        side: BorderSide.none,
        visualDensity: pequena ? VisualDensity.compact : VisualDensity.standard,
        onSelected: (_) => onTap(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: pequena ? 40 : 46,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _chip('Todas', seleccionada == null, () => onElegir(null)),
          for (final o in opciones)
            _chip(o, seleccionada == o, () => onElegir(o)),
        ],
      ),
    );
  }
}

/// Título de una categoría dentro de la lista.
class EncabezadoCategoria extends StatelessWidget {
  final String nombre;

  const EncabezadoCategoria(this.nombre, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 4),
      child: Row(
        children: [
          const Icon(
            Icons.category_outlined,
            color: AppColors.azulClaro,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              nombre.toUpperCase(),
              style: GoogleFonts.poppins(
                color: AppColors.azulClaro,
                fontSize: 15,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Título de una subcategoría dentro de la lista.
class EncabezadoSubcategoria extends StatelessWidget {
  final String nombre;

  const EncabezadoSubcategoria(this.nombre, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 8, left: 4),
      child: Text(
        nombre,
        style: GoogleFonts.poppins(
          color: Colors.white70,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// Marcadores internos para mezclar encabezados con productos.
class _EncCat {
  final String nombre;
  const _EncCat(this.nombre);
}

class _EncSub {
  final String nombre;
  const _EncSub(this.nombre);
}

/// Lista de productos ordenada por CATEGORÍA > SUBCATEGORÍA, con chips para
/// filtrar. No guarda estado: quien la usa guarda la categoría y subcategoría
/// elegidas y las recibe aquí. Cada producto se dibuja con [itemBuilder].
/// Debe ir dentro de un espacio con alto definido (por ejemplo un Expanded).
class ProductosAgrupados extends StatelessWidget {
  final List<Producto> productos;
  final String? categoria;
  final String? subcategoria;
  final ValueChanged<String?> onCategoria;
  final ValueChanged<String?> onSubcategoria;
  final Widget Function(BuildContext context, Producto producto) itemBuilder;
  final EdgeInsets padding;

  const ProductosAgrupados({
    super.key,
    required this.productos,
    required this.categoria,
    required this.subcategoria,
    required this.onCategoria,
    required this.onSubcategoria,
    required this.itemBuilder,
    this.padding = const EdgeInsets.fromLTRB(20, 4, 20, 20),
  });

  List<Object> _construirItems(List<Producto> lista) {
    final items = <Object>[];
    String? catActual;
    String? subActual;
    for (final p in OrdenProductos.ordenar(lista)) {
      final c = OrdenProductos.categoriaDe(p);
      final s = OrdenProductos.subcategoriaDe(p);
      if (c != catActual) {
        items.add(_EncCat(c));
        catActual = c;
        subActual = null;
      }
      if (s != subActual) {
        items.add(_EncSub(s));
        subActual = s;
      }
      items.add(p);
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final cats = OrdenProductos.categorias(productos);
    // Si la categoría elegida ya no tiene productos (por la búsqueda), se
    // muestra como "Todas".
    final cat = cats.contains(categoria) ? categoria : null;
    final subs = cat == null
        ? <String>[]
        : OrdenProductos.subcategorias(productos, cat);
    final sub = subs.contains(subcategoria) ? subcategoria : null;

    final visibles = productos.where((p) {
      if (cat != null && OrdenProductos.categoriaDe(p) != cat) return false;
      if (sub != null && OrdenProductos.subcategoriaDe(p) != sub) return false;
      return true;
    }).toList();
    final items = _construirItems(visibles);

    return Column(
      children: [
        ChipsDesplazables(
          opciones: cats,
          seleccionada: cat,
          onElegir: onCategoria,
        ),
        if (cat != null && subs.length > 1)
          ChipsDesplazables(
            opciones: subs,
            seleccionada: sub,
            onElegir: onSubcategoria,
            pequena: true,
          ),
        const SizedBox(height: 4),
        Expanded(
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: padding,
            itemCount: items.length,
            itemBuilder: (context, i) {
              final it = items[i];
              if (it is _EncCat) return EncabezadoCategoria(it.nombre);
              if (it is _EncSub) return EncabezadoSubcategoria(it.nombre);
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: itemBuilder(context, it as Producto),
              );
            },
          ),
        ),
      ],
    );
  }
}
