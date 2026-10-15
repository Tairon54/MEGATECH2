import 'dart:convert';
import 'package:fronted/model/user.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'apiuser.dart';

/// Peticiones del admin sobre /usuario (el backend exige token de Admin).
class UsuariosAdminService {
  Future<String> _token() async =>
      (await SharedPreferences.getInstance()).getString('token') ?? '';

  Future<Map<String, String>> _headers() async => {
    ...ApiConfig.headers,
    'Authorization': 'Bearer ${await _token()}',
  };

  /// Id del usuario con sesión iniciada (viene dentro del token JWT).
  /// Sirve para no dejar que el admin se elimine ni se quite el rol a sí mismo.
  Future<String?> idActual() async {
    final partes = (await _token()).split('.');
    if (partes.length != 3) return null;
    try {
      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(partes[1])),
      );
      return (jsonDecode(payload) as Map<String, dynamic>)['id']?.toString();
    } catch (_) {
      return null;
    }
  }

  /// Convierte una respuesta fallida en una Exception con mensaje legible.
  Never _fallo(http.Response r, String porDefecto) {
    if (r.statusCode == 401 || r.statusCode == 403) {
      throw Exception('Su sesión expiró o no tiene permisos de administrador');
    }
    try {
      final body = jsonDecode(r.body);
      if (body is Map && body['error'] != null) {
        throw Exception(body['error'].toString());
      }
    } on FormatException {
      // el cuerpo no era JSON: usamos el mensaje por defecto
    }
    throw Exception(porDefecto);
  }

  /// GET /usuario → todos los usuarios, ordenados por nombre.
  Future<List<usermodel>> obtenerTodos() async {
    final r = await http
        .get(
          Uri.parse('${ApiConfig.rootUrl}/usuario'),
          headers: await _headers(),
        )
        .timeout(const Duration(seconds: 20));
    if (r.statusCode != 200) _fallo(r, 'Error al obtener los usuarios');

    final List<dynamic> data = (jsonDecode(r.body)['usuarios'] as List?) ?? [];
    final lista = data.map((e) {
      final j = Map<String, dynamic>.from(e as Map);
      // cédula y teléfono pueden venir como número desde la base de datos
      return usermodel.fromJson({
        ...j,
        'cedula': j['cedula']?.toString(),
        'telefono': j['telefono']?.toString(),
      });
    }).toList();
    lista.sort(
      (a, b) => (a.nombre ?? '').toLowerCase().compareTo(
        (b.nombre ?? '').toLowerCase(),
      ),
    );
    return lista;
  }

  /// PUT /usuario/actualizar/:id (no toca la contraseña).
  Future<void> actualizar(
    String id, {
    required String nombre,
    required String apellido,
    required String telefono,
    required String correo,
    required String rol,
  }) async {
    final r = await http
        .put(
          Uri.parse('${ApiConfig.rootUrl}/usuario/actualizar/$id'),
          headers: await _headers(),
          body: jsonEncode({
            'nombre': nombre,
            'apellido': apellido,
            'telefono': telefono,
            'correo': correo,
            'rol': rol,
          }),
        )
        .timeout(const Duration(seconds: 20));
    if (r.statusCode != 200) _fallo(r, 'No se pudo actualizar el usuario');
  }

  /// Desactiva o reactiva una cuenta (PUT /usuario/actualizar/:id con `activo`).
  /// Una cuenta desactivada no puede iniciar sesión, pero conserva sus ventas
  /// y pedidos.
  Future<void> cambiarActivo(String id, {required bool activo}) async {
    final r = await http
        .put(
          Uri.parse('${ApiConfig.rootUrl}/usuario/actualizar/$id'),
          headers: await _headers(),
          body: jsonEncode({'activo': activo}),
        )
        .timeout(const Duration(seconds: 20));
    if (r.statusCode != 200) {
      _fallo(
        r,
        activo
            ? 'No se pudo reactivar el usuario'
            : 'No se pudo desactivar el usuario',
      );
    }
  }
}
