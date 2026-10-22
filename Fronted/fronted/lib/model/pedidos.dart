import 'package:flutter/material.dart';

double _aDouble(dynamic v) => double.tryParse(v?.toString() ?? '') ?? 0;
int _aInt(dynamic v) => int.tryParse(v?.toString() ?? '') ?? 0;

String? _aTextoOpcional(dynamic v) {
  if (v == null) return null;
  final t = v.toString().trim();
  return t.isEmpty ? null : t;
}

/// 1500000 -> $1.500.000
String formatearPesos(double valor) {
  final entero = valor.round().toString();
  final conPuntos = entero.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (m) => '.',
  );
  return '\$$conPuntos';
}

/// Estados que maneja el backend y su flujo permitido:
/// Por pagar -> Por entregar -> Entregado
class EstadoPedido {
  EstadoPedido._();

  static const String porPagar = 'Por pagar';
  static const String porEntregar = 'Por entregar';
  static const String entregado = 'Entregado';
  static const String cancelado = 'Cancelado';

  static const List<String> todos = [
    porPagar,
    porEntregar,
    entregado,
    cancelado,
  ];

  /// Siguiente estado "normal" (null si ya no puede cambiar).
  static String? siguiente(String actual) {
    switch (actual) {
      case porPagar:
        return porEntregar;
      case porEntregar:
        return entregado;
      default:
        return null;
    }
  }

  /// true si el backend permite pasar de [actual] a [nuevo].
  static bool puedeCambiar(String actual, String nuevo) {
    if (actual == porPagar) return nuevo == porEntregar || nuevo == cancelado;
    if (actual == porEntregar) return nuevo == entregado;
    return false; // Entregado y Cancelado son finales
  }

  static Color color(String estado) {
    switch (estado) {
      case porPagar:
        return const Color(0xFFFFA726); // naranja
      case porEntregar:
        return const Color(0xFF29B6F6); // azul de la app
      case entregado:
        return const Color(0xFF2ECC71); // verde
      case cancelado:
        return const Color(0xFFFF5252); // rojo
      default:
        return Colors.white54;
    }
  }

  static IconData icono(String estado) {
    switch (estado) {
      case porPagar:
        return Icons.payments_outlined;
      case porEntregar:
        return Icons.local_shipping_outlined;
      case entregado:
        return Icons.check_circle_outline_rounded;
      case cancelado:
        return Icons.cancel_outlined;
      default:
        return Icons.help_outline_rounded;
    }
  }
}

/// Datos del cliente que hizo el pedido.
class ClientePedido {
  final int id;
  final String nombre;
  final String apellido;
  final String? telefono;
  final String? correo;

  const ClientePedido({
    required this.id,
    required this.nombre,
    required this.apellido,
    this.telefono,
    this.correo,
  });

  String get nombreCompleto => '$nombre $apellido'.trim();

  factory ClientePedido.fromJson(Map<String, dynamic> json) {
    return ClientePedido(
      id: _aInt(json['id']),
      nombre: (json['nombre'] ?? '').toString(),
      apellido: (json['apellido'] ?? '').toString(),
      telefono: _aTextoOpcional(json['telefono']),
      correo: _aTextoOpcional(json['correo']),
    );
  }
}

/// Un artículo (fila de detalle_pedido) dentro de un pedido.
class ArticuloPedido {
  final int id;
  final String nombre;
  final String descripcion;
  final String? foto;
  final int cantidad;
  final double precioUnitario;
  final double subtotal;

  const ArticuloPedido({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
    this.foto,
  });

  factory ArticuloPedido.fromJson(Map<String, dynamic> json) {
    return ArticuloPedido(
      id: _aInt(json['id']),
      nombre: (json['nombre'] ?? '').toString(),
      descripcion: (json['descripcion'] ?? '').toString(),
      foto: _aTextoOpcional(json['foto']),
      cantidad: _aInt(json['cantidad']),
      precioUnitario: _aDouble(json['precio_unitario']),
      subtotal: _aDouble(json['subtotal']),
    );
  }
}

/// Pedido tal como lo devuelve GET /pedidos/resumen
class Pedido {
  final int id;
  final String estado;
  final double total;
  final String fecha;
  final ClientePedido? cliente;
  final String? fotoPrincipal;
  final List<ArticuloPedido> articulos;

  const Pedido({
    required this.id,
    required this.estado,
    required this.total,
    required this.fecha,
    required this.articulos,
    this.cliente,
    this.fotoPrincipal,
  });

  Pedido copyWith({String? estado}) {
    return Pedido(
      id: id,
      estado: estado ?? this.estado,
      total: total,
      fecha: fecha,
      cliente: cliente,
      fotoPrincipal: fotoPrincipal,
      articulos: articulos,
    );
  }

  factory Pedido.fromJson(Map<String, dynamic> json) {
    final detalle = json['detalle'];
    return Pedido(
      id: _aInt(json['id']),
      estado: (json['estado'] ?? '').toString(),
      total: _aDouble(json['total']),
      fecha: (json['fecha_formateada'] ?? '').toString(),
      cliente: json['cliente'] is Map<String, dynamic>
          ? ClientePedido.fromJson(json['cliente'] as Map<String, dynamic>)
          : null,
      fotoPrincipal: _aTextoOpcional(json['foto_principal']),
      articulos: detalle is List
          ? detalle
                .map((e) => ArticuloPedido.fromJson(e as Map<String, dynamic>))
                .toList()
          : <ArticuloPedido>[],
    );
  }
}
