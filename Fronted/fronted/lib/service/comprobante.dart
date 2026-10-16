import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' show MediaType;
import 'package:image_picker/image_picker.dart' show XFile;
import 'package:shared_preferences/shared_preferences.dart';
import 'apiuser.dart';

/// Error al enviar el comprobante de pago.
class ComprobanteException implements Exception {
  final String mensaje;
  const ComprobanteException(this.mensaje);

  @override
  String toString() => mensaje;
}

class ComprobanteService {
  /// POST /compro (solo Cliente). Va como multipart/form-data:
  ///  - campo "id_pedido"
  ///  - archivo "foto"  (el backend usa upload.single("foto"))
  /// El backend busca el pedido, sube la imagen a Cloudinary y guarda el
  /// comprobante con el id_cliente del pedido. Por eso aquí NO hace falta
  /// enviar celular ni correo.
  Future<void> enviarComprobante({
    required int idPedido,
    required XFile foto,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final url = Uri.parse('${ApiConfig.rootUrl}/compro');
    final request = http.MultipartRequest('POST', url)
      ..headers['Authorization'] = 'Bearer $token'
      ..headers['Accept'] = 'application/json';

    request.fields['id_pedido'] = idPedido.toString();

    final bytes = await foto.readAsBytes();
    request.files.add(
      http.MultipartFile.fromBytes(
        'foto',
        bytes,
        filename: foto.name,
        contentType: _tipoImagen(foto.name),
      ),
    );

    final streamed = await request.send().timeout(const Duration(seconds: 40));
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 200 || response.statusCode == 201) return;

    if (response.statusCode == 401 || response.statusCode == 403) {
      throw const ComprobanteException(
        'Tu sesión expiró. Inicia sesión de nuevo para enviar el comprobante.',
      );
    }

    var mensaje = 'No se pudo enviar el comprobante';
    try {
      final body = jsonDecode(response.body);
      if (body is Map && body['error'] != null) {
        mensaje = body['error'].toString();
      }
    } catch (_) {}
    throw ComprobanteException(mensaje);
  }

  static MediaType _tipoImagen(String nombreArchivo) {
    final ext = nombreArchivo.split('.').last.toLowerCase();
    switch (ext) {
      case 'png':
        return MediaType('image', 'png');
      case 'webp':
        return MediaType('image', 'webp');
      case 'gif':
        return MediaType('image', 'gif');
      default:
        return MediaType('image', 'jpeg');
    }
  }
}
