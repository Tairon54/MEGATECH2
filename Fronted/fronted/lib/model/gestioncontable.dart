// Modelos de la pantalla de Gestión contable.

double _num(dynamic v) => double.tryParse(v?.toString() ?? '') ?? 0;
int _int(dynamic v) => int.tryParse(v?.toString() ?? '') ?? 0;
Map<String, dynamic>? _map(dynamic v) =>
    v is Map ? Map<String, dynamic>.from(v) : null;

/// "$ 1.250.000"
String moneda(double v) {
  final s = v.round().abs().toString();
  final b = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
    b.write(s[i]);
  }
  return '${v < 0 ? '-' : ''}\$ $b';
}

/// "2026-10-08T14:30:00..." -> "2026-10-08 14:30"
String fechaCorta(String f) {
  final t = f.replaceAll('T', ' ');
  return t.length >= 16 ? t.substring(0, 16) : t;
}

/// DateTime -> "2026-10-08" (formato que espera el backend)
String fechaIso(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// Opción de un dropdown (vendedor, categoría o subcategoría).
class OpcionFiltro {
  final String id;
  final String nombre;
  final String? idPadre; // para subcategorías: id de su categoría
  const OpcionFiltro({required this.id, required this.nombre, this.idPadre});
}

/// Filtros del reporte -> query string de GET /ventas/reporte
class FiltrosReporte {
  String periodo; // hoy | semana | mes | rango
  DateTime? inicio;
  DateTime? fin;
  String? idVendedor;
  String? idCategoria;
  String? idSubcategoria;

  FiltrosReporte({
    this.periodo = 'hoy',
    this.inicio,
    this.fin,
    this.idVendedor,
    this.idCategoria,
    this.idSubcategoria,
  });

  Map<String, String> toQuery() {
    final q = <String, String>{};
    if (periodo == 'rango') {
      q['fecha_inicio'] = fechaIso(inicio!);
      q['fecha_fin'] = fechaIso(fin!);
    } else {
      q['periodo'] = periodo;
    }
    if (idVendedor != null) q['id_vendedor'] = idVendedor!;
    if (idCategoria != null) q['id_categoria'] = idCategoria!;
    if (idSubcategoria != null) q['id_subcategoria'] = idSubcategoria!;
    return q;
  }
}

class ResumenReporte {
  final int cantidadVentas;
  final int cantidadDetalles;
  final int unidadesVendidas;
  final double totalVendido;

  const ResumenReporte({
    required this.cantidadVentas,
    required this.cantidadDetalles,
    required this.unidadesVendidas,
    required this.totalVendido,
  });

  factory ResumenReporte.fromJson(Map<String, dynamic> j) => ResumenReporte(
    cantidadVentas: _int(j['cantidad_ventas']),
    cantidadDetalles: _int(j['cantidad_detalles']),
    unidadesVendidas: _int(j['unidades_vendidas']),
    totalVendido: _num(j['total_vendido']),
  );
}

/// Una línea de una venta (un producto).
class DetalleContable {
  final String producto;
  final String categoria;
  final String subcategoria;
  final int cantidad;
  final double precioUnitario;
  final double subtotal;

  const DetalleContable({
    required this.producto,
    required this.categoria,
    required this.subcategoria,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
  });

  factory DetalleContable.fromJson(Map<String, dynamic> j) {
    final prod = _map(j['productos']);
    final sub = _map(prod?['subcategorias']);
    final cat = _map(sub?['categorias']);
    return DetalleContable(
      producto: (prod?['nombre'] ?? 'Producto ${j['id_producto']}').toString(),
      categoria: (cat?['nombre_categoria'] ?? '').toString(),
      subcategoria: (sub?['nombre'] ?? '').toString(),
      cantidad: _int(j['cantidad']),
      precioUnitario: _num(j['precio_unitario']),
      subtotal: _num(j['subtotal']),
    );
  }
}

/// Datos de una persona de la venta (el comprador o el vendedor).
class PersonaVenta {
  final String id;
  final String cedula;
  final String nombre;
  final String rol;

  const PersonaVenta({
    this.id = '',
    this.cedula = '',
    this.nombre = '',
    this.rol = '',
  });

  /// [datos] es el objeto que manda el backend (puede venir null);
  /// [idRespaldo] es el id de la venta por si no llegan los datos.
  factory PersonaVenta.desde(dynamic datos, dynamic idRespaldo) {
    final m = _map(datos);
    if (m == null) return PersonaVenta(id: (idRespaldo ?? '').toString());
    return PersonaVenta(
      id: (m['id'] ?? idRespaldo ?? '').toString(),
      cedula: (m['cedula'] ?? '').toString(),
      nombre: '${m['nombre'] ?? ''} ${m['apellido'] ?? ''}'.trim(),
      rol: (m['rol'] ?? '').toString(),
    );
  }
}

/// Una venta (sirve para el reporte y para los listados de ventas).
class VentaContable {
  final int id;
  final String fecha;
  final double total;
  final String idCliente;
  final String idVendedor;
  final PersonaVenta vendedor;
  final PersonaVenta cliente; // el comprador
  final List<DetalleContable> detalles;

  const VentaContable({
    required this.id,
    required this.fecha,
    required this.total,
    required this.idCliente,
    required this.idVendedor,
    required this.vendedor,
    required this.cliente,
    required this.detalles,
  });

  factory VentaContable.fromJson(Map<String, dynamic> j) {
    final det = j['detalle_venta'];
    return VentaContable(
      id: _int(j['id']),
      fecha: (j['fecha'] ?? '').toString(),
      total: _num(j['total']),
      idCliente: (j['id_cliente'] ?? '').toString(),
      idVendedor: (j['id_vendedor'] ?? '').toString(),
      // 'usuarios' es el vendedor del reporte (por si el backend viejo aún responde así)
      vendedor: PersonaVenta.desde(
        j['vendedor'] ?? j['usuarios'],
        j['id_vendedor'],
      ),
      cliente: PersonaVenta.desde(j['cliente'], j['id_cliente']),
      detalles: det is List
          ? det
                .map(
                  (e) => DetalleContable.fromJson(Map<String, dynamic>.from(e)),
                )
                .toList()
          : <DetalleContable>[],
    );
  }
}

class ReporteVentas {
  final String periodo;
  final ResumenReporte resumen;
  final List<VentaContable> ventas;

  const ReporteVentas({
    required this.periodo,
    required this.resumen,
    required this.ventas,
  });

  factory ReporteVentas.fromJson(Map<String, dynamic> j) => ReporteVentas(
    periodo: (j['periodo'] ?? '').toString(),
    resumen: ResumenReporte.fromJson(
      Map<String, dynamic>.from(j['resumen'] ?? {}),
    ),
    ventas: (j['ventas'] as List? ?? [])
        .map((e) => VentaContable.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
  );
}

/// Resultado de buscar ventas por cédula (cliente o vendedor).
class BusquedaVentas {
  final String titulo; // ej: "Compras de Ana Pérez"
  final List<VentaContable> ventas;
  const BusquedaVentas({required this.titulo, required this.ventas});
}
