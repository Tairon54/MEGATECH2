import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'apiuser.dart';

class CuentaService {
  Future<void> eliminarMiCuenta() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    if (token.isEmpty) {
      throw Exception('Tu sesión ha expirado. Inicia sesión nuevamente.');
    }

    final url = Uri.parse('${ApiConfig.rootUrl}/usuario/mi-cuenta');

    final response = await http
        .delete(
          url,
          headers: {...ApiConfig.headers, 'Authorization': 'Bearer $token'},
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      return;
    }

    try {
      final data = jsonDecode(response.body);

      throw Exception(
        data['error'] ?? data['mensaje'] ?? 'No se pudo eliminar la cuenta.',
      );
    } catch (e) {
      if (e is Exception && !e.toString().contains('FormatException')) {
        rethrow;
      }

      throw Exception('Error del servidor: ${response.statusCode}');
    }
  }
}
