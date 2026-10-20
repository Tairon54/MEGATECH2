import 'package:fronted/model/pedidos.dart';

int _aInt(dynamic v) => int.tryParse(v?.toString() ?? '') ?? 0;
double _aDouble(dynamic v) => double.tryParse(v?.toString() ?? '') ?? 0;

/// "2026-10-16T14:05:00" -> "16/10/2026 09:05 a. m." (hora local del teléfono).
/// Supabase manda la fecha en UTC; si no trae zona horaria se la agregamos.
String _formatearFecha(dynamic v) {
  var crudo = (v?.toString() ?? '').trim().replaceFirst(' ', 'T');
  if (crudo.isEmpty) return '';
  final hora = crudo.contains('T') ? crudo.split('T').last : '';
  final tieneZona =
      hora.endsWith('Z') || hora.contains('+') || hora.contains('-');
  final fecha = DateTime.tryParse(tieneZona ? crudo : '${crudo}Z');
  if (fecha == null) return crudo;

  final l = fecha.toLocal();
  String dos(int n) => n.toString().padLeft(2, '0');
  final h12 = l.hour % 12 == 0 ? 12 : l.hour % 12;
  final sufijo = l.hour < 12 ? 'a. m.' : 'p. m.';
  return '${dos(l.day)}/${dos(l.month)}/${l.year} ${dos(h12)}:${dos(l.minute)} $sufijo';
}

/// Comprobante de pago tal como lo devuelve GET /compro
/// (con el cliente y el pedido incluidos).
class Comprobante {
  final int id;
  final int idPedido;
  final String? foto;
  final String fecha;
  final String nombreCliente;
  final String cedula;
  final String estadoPedido;
  final double total;

  const Comprobante({
    required this.id,
    required this.idPedido,
    required this.fecha,
    required this.nombreCliente,
    required this.cedula,
    required this.estadoPedido,
    required this.total,
    this.foto,
  });

  /// true = el pedido sigue "Por pagar": falta que el admin verifique la transferencia.
  bool get porVerificar => estadoPedido == EstadoPedido.porPagar;

  factory Comprobante.fromJson(Map<String, dynamic> json) {
    final u = json['usuarios'] is Map<String, dynamic>
        ? json['usuarios'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final p = json['pedidos'] is Map<String, dynamic>
        ? json['pedidos'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final foto = json['foto']?.toString().trim();

    return Comprobante(
      id: _aInt(json['id']),
      idPedido: _aInt(json['id_pedido']),
      foto: (foto == null || foto.isEmpty) ? null : foto,
      fecha: _formatearFecha(json['fecha']),
      nombreCliente: '${u['nombre'] ?? ''} ${u['apellido'] ?? ''}'.trim(),
      cedula: (u['cedula'] ?? '').toString(),
      estadoPedido: (p['estado'] ?? '').toString(),
      total: _aDouble(p['total']),
    );
  }
}
