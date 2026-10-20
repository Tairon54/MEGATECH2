import 'dart:convert';
import 'package:fronted/model/comprobante.dart';
import 'package:fronted/model/pedidos.dart';
import 'package:fronted/service/apiuser.dart';
import 'package:fronted/service/pedidos.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ComprobantesService {
  final PedidosService _pedidos = PedidosService();

  Future<Map<String, String>> _headersConToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    return {...ApiConfig.headers, 'Authorization': 'Bearer $token'};
  }

  /// GET /compro -> todos los comprobantes (el más reciente primero).
  Future<List<Comprobante>> obtenerTodos() async {
    final url = Uri.parse('${ApiConfig.rootUrl}/compro');
    final response = await http
        .get(url, headers: await _headersConToken())
        .timeout(const Duration(seconds: 20));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final lista = data is Map ? data['comprobantes'] : data;
      if (lista is List) {
        return lista
            .map((e) => Comprobante.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return <Comprobante>[];
    }
    throw Exception('Error al obtener los comprobantes');
  }

  /// Aprueba la transferencia: el pedido pasa de "Por pagar" a "Por entregar"
  /// (el backend además le envía el correo de confirmación al cliente).
  /// Puede lanzar [PedidoException].
  Future<void> aprobar(int idPedido) =>
      _pedidos.cambiarEstado(idPedido, EstadoPedido.porEntregar);
}
