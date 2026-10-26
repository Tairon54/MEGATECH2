import 'package:flutter/material.dart';
import 'package:fronted/colores/stilocolores.dart';
import 'package:fronted/model/pedidos.dart' show formatearPesos;
import 'package:fronted/model/productos.dart';
import 'package:google_fonts/google_fonts.dart';

// LOS PRODUCTOS QUE APARECEN EN EL SELECTOR PARA SELECCIONARLOS EN LA VENTA
// Ahora vienen agrupados: CATEGORÍA > SUBCATEGORÍA > productos,
// con chips para filtrar por categoría y subcategoría.

/// Miniatura de un producto (con placeholder si no hay foto o falla).
class FotoProducto extends StatelessWidget {
  final String? url;
  final double tam;

  const FotoProducto({super.key, required this.url, this.tam = 56});

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: tam,
      height: tam,
      color: AppColors.fondoOscuro2,
      child: Icon(
        Icons.image_not_supported_outlined,
        color: Colors.white38,
        size: tam * 0.4,
      ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: url == null
          ? placeholder
          : Image.network(
              url!,
              width: tam,
              height: tam,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => placeholder,
            ),
    );
  }
}

/// Abre el buscador de productos y devuelve el elegido (o null si cierra).
/// [bloqueados] = ids que ya están en otra tarjeta de la venta.
Future<Producto?> mostrarSelectorProducto(
  BuildContext context, {
  required List<Producto> productos,
  required Set<int> bloqueados,
}) {
  return showModalBottomSheet<Producto>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) =>
        _SelectorProducto(productos: productos, bloqueados: bloqueados),
  );
}

// Encabezados que se mezclan con los productos en la lista.
class _EncCategoria {
  final String nombre;
  const _EncCategoria(this.nombre);
}

class _EncSubcategoria {
  final String nombre;
  const _EncSubcategoria(this.nombre);
}

class _SelectorProducto extends StatefulWidget {
  final List<Producto> productos;
  final Set<int> bloqueados;

  const _SelectorProducto({required this.productos, required this.bloqueados});

  @override
  State<_SelectorProducto> createState() => _SelectorProductoState();
}

class _SelectorProductoState extends State<_SelectorProducto> {
  static const String _sinCategoria = 'Sin categoría';
  static const String _sinSubcategoria = 'Sin subcategoría';

  final TextEditingController _busqueda = TextEditingController();
  String _texto = '';
  String? _categoria; // null = todas
  String? _subcategoria; // null = todas

  @override
  void dispose() {
    _busqueda.dispose();
    super.dispose();
  }

  // ---------- Helpers de categoría ----------
  String _cat(Producto p) {
    final c = p.categoria?.trim() ?? '';
    return c.isEmpty ? _sinCategoria : c;
  }

  String _sub(Producto p) {
    final s = p.subcategoria?.trim() ?? '';
    return s.isEmpty ? _sinSubcategoria : s;
  }

  // Los "Sin ..." van al final al ordenar.
  String _clave(String v) => (v == _sinCategoria || v == _sinSubcategoria)
      ? '\uffff'
      : v.toLowerCase();

  int _comparar(String a, String b) => _clave(a).compareTo(_clave(b));

  List<String> get _categorias {
    final set = widget.productos.map(_cat).toSet().toList();
    set.sort(_comparar);
    return set;
  }

  List<String> get _subcategorias {
    if (_categoria == null) return [];
    final set = widget.productos
        .where((p) => _cat(p) == _categoria)
        .map(_sub)
        .toSet()
        .toList();
    set.sort(_comparar);
    return set;
  }

  // ---------- Filtro + agrupación ----------
  List<Producto> get _filtrados {
    final q = _texto.trim().toLowerCase();
    return widget.productos.where((p) {
      if (_categoria != null && _cat(p) != _categoria) return false;
      if (_subcategoria != null && _sub(p) != _subcategoria) return false;
      if (q.isEmpty) return true;
      return p.nombre.toLowerCase().contains(q) ||
          p.id.toString() == q ||
          _cat(p).toLowerCase().contains(q) ||
          _sub(p).toLowerCase().contains(q);
    }).toList();
  }

  /// Lista plana: [Categoría, Subcategoría, producto, producto, Subcategoría, ...]
  List<Object> _construirItems(List<Producto> lista) {
    final orden = [...lista]
      ..sort((a, b) {
        final c = _comparar(_cat(a), _cat(b));
        if (c != 0) return c;
        final s = _comparar(_sub(a), _sub(b));
        if (s != 0) return s;
        return a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase());
      });

    final items = <Object>[];
    String? catActual;
    String? subActual;
    for (final p in orden) {
      final c = _cat(p);
      final s = _sub(p);
      if (c != catActual) {
        items.add(_EncCategoria(c));
        catActual = c;
        subActual = null;
      }
      if (s != subActual) {
        items.add(_EncSubcategoria(s));
        subActual = s;
      }
      items.add(p);
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final alto = MediaQuery.of(context).size.height * 0.85;
    final lista = _filtrados;
    final items = _construirItems(lista);
    final subs = _subcategorias;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        height: alto,
        decoration: BoxDecoration(
          color: AppColors.fondoOscuro2,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          border: Border.all(color: AppColors.bordeTarjeta, width: 1),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Elegir producto',
              style: GoogleFonts.poppins(
                color: AppColors.azulClaro,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: TextField(
                controller: _busqueda,
                onChanged: (v) => setState(() => _texto = v),
                decoration: InputDecoration(
                  hintText: 'Buscar por nombre, ID o categoría',
                  hintStyle: GoogleFonts.poppins(fontSize: 14),
                  filled: true,
                  fillColor: AppColors.fondoCampo,
                  prefixIcon: const Icon(Icons.search, color: Colors.black),
                  suffixIcon: _texto.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close, color: Colors.black),
                          onPressed: () {
                            _busqueda.clear();
                            setState(() => _texto = '');
                          },
                        ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // Chips de categorías
            _filaChips(
              opciones: _categorias,
              seleccionada: _categoria,
              onElegir: (v) => setState(() {
                _categoria = v;
                _subcategoria = null; // al cambiar de categoría, se reinicia
              }),
            ),

            // Chips de subcategorías (solo si hay una categoría elegida)
            if (_categoria != null && subs.length > 1)
              _filaChips(
                opciones: subs,
                seleccionada: _subcategoria,
                onElegir: (v) => setState(() => _subcategoria = v),
                pequena: true,
              ),

            const SizedBox(height: 4),
            Expanded(
              child: lista.isEmpty
                  ? Center(
                      child: Text(
                        'No hay productos con esa búsqueda',
                        style: GoogleFonts.poppins(color: Colors.white70),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                      itemCount: items.length,
                      itemBuilder: (context, i) {
                        final it = items[i];
                        if (it is _EncCategoria)
                          return _encabezadoCat(it.nombre);
                        if (it is _EncSubcategoria) {
                          return _encabezadoSub(it.nombre);
                        }
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _fila(it as Producto),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Widgets ----------
  Widget _filaChips({
    required List<String> opciones,
    required String? seleccionada,
    required ValueChanged<String?> onElegir,
    bool pequena = false,
  }) {
    Widget chip(String label, bool activo, VoidCallback onTap) {
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Text(
            label,
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
          visualDensity: pequena
              ? VisualDensity.compact
              : VisualDensity.standard,
          onSelected: (_) => onTap(),
        ),
      );
    }

    return SizedBox(
      height: pequena ? 40 : 46,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          chip('Todas', seleccionada == null, () => onElegir(null)),
          for (final o in opciones)
            chip(o, seleccionada == o, () => onElegir(o)),
        ],
      ),
    );
  }

  Widget _encabezadoCat(String nombre) {
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

  Widget _encabezadoSub(String nombre) {
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

  Widget _fila(Producto p) {
    final agotado = p.stock <= 0;
    final yaAgregado = widget.bloqueados.contains(p.id);
    final deshabilitado = agotado || yaAgregado;
    final etiqueta = agotado
        ? 'Agotado'
        : yaAgregado
        ? 'Ya agregado'
        : null;

    return Opacity(
      opacity: deshabilitado ? 0.45 : 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: deshabilitado ? null : () => Navigator.pop(context, p),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF1F2937),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              FotoProducto(url: p.foto),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.nombre,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      etiqueta ?? 'ID ${p.id}  ·  Stock ${p.stock}',
                      style: GoogleFonts.poppins(
                        color: etiqueta != null
                            ? const Color(0xFFFFA726)
                            : Colors.white60,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                formatearPesos(p.precio),
                style: GoogleFonts.poppins(
                  color: AppColors.azulClaro,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
