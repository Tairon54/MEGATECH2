import 'dart:convert';
import 'package:fronted/model/productos.dart';
import 'package:fronted/model/subcategoria.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' show MediaType;
import 'package:image_picker/image_picker.dart' show XFile;
import 'package:shared_preferences/shared_preferences.dart';
import 'apiuser.dart';

class ProductosService {
  Future<Map<String, String>> _headersConToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    return {...ApiConfig.headers, 'Authorization': 'Bearer $token'};
  }

  /// Rol del usuario ('Admin', 'Empleado', 'Cliente') leído del token JWT que
  /// guardó el login. Si no hay sesión (invitado) devuelve null.
  Future<String?> rolActual() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final partes = token.split('.');
    if (partes.length != 3) return null;
    try {
      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(partes[1])),
      );
      return (jsonDecode(payload) as Map<String, dynamic>)['rol']?.toString();
    } catch (_) {
      return null;
    }
  }

  /// Trae la lista de productos con bajo stock desde el backend.
  Future<List<Producto>> obtenerListaBajoStock() async {
    final url = Uri.parse('${ApiConfig.rootUrl}/productos/bajo-stock/lista');
    final response = await http.get(url, headers: await _headersConToken());

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((e) => Producto.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Error al obtener productos con bajo stock');
    }
  }

  /// GET /productos (ruta pública): todos los productos, ordenados por nombre.
  Future<List<Producto>> obtenerTodos() async {
    final url = Uri.parse('${ApiConfig.rootUrl}/productos');
    final response = await http
        .get(url, headers: ApiConfig.headers)
        .timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      throw Exception('Error al obtener los productos');
    }

    final List<dynamic> data = jsonDecode(response.body);
    final lista = data
        .map((e) => Producto.fromJson(e as Map<String, dynamic>))
        .toList();
    lista.sort(
      (a, b) => a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase()),
    );
    return lista;
  }

  /// PUT /productos/actualizar/:id (solo Admin).
  /// El backend usa multer (`upload.single("file")`), por eso se envía como
  /// multipart/form-data y no como JSON. Solo se mandan los campos recibidos;
  /// si [foto] es null, el backend conserva la imagen actual.
  Future<void> actualizarProducto(
    int id, {
    String? nombre,
    String? descripcion,
    double? precio,
    int? stock,
    XFile? foto,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final url = Uri.parse('${ApiConfig.rootUrl}/productos/actualizar/$id');
    final request = http.MultipartRequest('PUT', url)
      ..headers['Authorization'] = 'Bearer $token'
      ..headers['Accept'] = 'application/json';

    if (nombre != null) request.fields['nombre'] = nombre;
    if (descripcion != null) request.fields['descripcion'] = descripcion;
    if (precio != null) request.fields['precio'] = precio.toString();
    if (stock != null) request.fields['stock'] = stock.toString();

    // La foto va en el campo "file" (el que espera upload.single("file")).
    if (foto != null) {
      final bytes = await foto.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: foto.name,
          contentType: _tipoImagen(foto.name),
        ),
      );
    }

    final streamed = await request.send().timeout(const Duration(seconds: 30));
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 200) return;

    if (response.statusCode == 401 || response.statusCode == 403) {
      throw Exception('Su sesión expiró o no tiene permisos de administrador');
    }

    String mensaje = 'No se pudo actualizar el producto';
    try {
      final body = jsonDecode(response.body);
      if (body is Map && body['error'] != null) {
        mensaje = body['error'].toString();
      }
    } catch (_) {}
    throw Exception(mensaje);
  }

  /// GET /subcategorias (ruta pública): para elegir la subcategoría al crear.
  Future<List<Subcategoria>> obtenerSubcategorias() async {
    final url = Uri.parse('${ApiConfig.rootUrl}/subcategorias');
    final response = await http
        .get(url, headers: ApiConfig.headers)
        .timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      throw Exception('No se pudieron cargar las subcategorías');
    }

    final List<dynamic> data = jsonDecode(response.body);
    final lista = data
        .map((e) => Subcategoria.fromJson(e as Map<String, dynamic>))
        .toList();
    lista.sort(
      (a, b) => a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase()),
    );
    return lista;
  }

  /// POST /productos/crear (solo Admin). Igual que actualizar, va como
  /// multipart/form-data porque el backend usa `upload.single("file")`.
  Future<void> crearProducto({
    required String nombre,
    required String descripcion,
    required double precio,
    required int stock,
    required int idSubcategoria,
    XFile? foto,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final url = Uri.parse('${ApiConfig.rootUrl}/productos/crear');
    final request = http.MultipartRequest('POST', url)
      ..headers['Authorization'] = 'Bearer $token'
      ..headers['Accept'] = 'application/json';

    request.fields['nombre'] = nombre;
    request.fields['descripcion'] = descripcion;
    request.fields['precio'] = precio.toString();
    request.fields['stock'] = stock.toString();
    request.fields['id_subcategoria'] = idSubcategoria.toString();

    if (foto != null) {
      final bytes = await foto.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: foto.name,
          contentType: _tipoImagen(foto.name),
        ),
      );
    }

    final streamed = await request.send().timeout(const Duration(seconds: 30));
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 200 || response.statusCode == 201) return;

    if (response.statusCode == 401 || response.statusCode == 403) {
      throw Exception('Su sesión expiró o no tiene permisos de administrador');
    }

    String mensaje = 'No se pudo crear el producto';
    try {
      final body = jsonDecode(response.body);
      if (body is Map && body['error'] != null) {
        mensaje = body['error'].toString();
      }
    } catch (_) {}
    throw Exception(mensaje);
  }

  /// DELETE /productos/eliminar/:id (solo Admin).
  Future<void> eliminarProducto(int id) async {
    final url = Uri.parse('${ApiConfig.rootUrl}/productos/eliminar/$id');
    final response = await http
        .delete(url, headers: await _headersConToken())
        .timeout(const Duration(seconds: 20));

    if (response.statusCode == 200) return;

    if (response.statusCode == 401 || response.statusCode == 403) {
      throw Exception('Su sesión expiró o no tiene permisos de administrador');
    }

    String mensaje = 'No se pudo eliminar el producto';
    try {
      final body = jsonDecode(response.body);
      if (body is Map && body['error'] != null) {
        final detalle = body['error'].toString();
        // Postgres rechaza borrar un producto que ya aparece en ventas/pedidos.
        mensaje = detalle.toLowerCase().contains('foreign key')
            ? 'No se puede eliminar: el producto ya tiene ventas o pedidos registrados'
            : detalle;
      }
    } catch (_) {}
    throw Exception(mensaje);
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

  /// "Cabezotes TC" -> "cabezotestc" (sin tildes, mayúsculas ni símbolos).
  static String _normalizar(String texto) {
    const conTilde = 'áàäâéèëêíìïîóòöôúùüûñ';
    const sinTilde = 'aaaaeeeeiiiioooouuuun';
    var t = texto.toLowerCase();
    for (var i = 0; i < conTilde.length; i++) {
      t = t.replaceAll(conTilde[i], sinTilde[i]);
    }
    return t.replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  static bool _coincide(String deProducto, String buscada) {
    final a = _normalizar(deProducto);
    final b = _normalizar(buscada);
    if (a.isEmpty || b.isEmpty) return false;
    if (a == b) return true;
    return a.length >= 4 && b.length >= 4 && (a.contains(b) || b.contains(a));
  }

  /// GET /productos (ruta pública) y se queda con los de una subcategoría.
  /// [soloDisponibles] oculta los productos sin stock.
  Future<List<Producto>> obtenerPorSubcategoria(
    String subcategoria, {
    bool soloDisponibles = true,
  }) async {
    final url = Uri.parse('${ApiConfig.rootUrl}/productos');
    final response = await http
        .get(url, headers: ApiConfig.headers)
        .timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      throw Exception('Error al obtener los productos');
    }

    final List<dynamic> data = jsonDecode(response.body);
    return data
        .map((e) => Producto.fromJson(e as Map<String, dynamic>))
        .where((p) => _coincide(p.subcategoria ?? '', subcategoria))
        .where((p) => !soloDisponibles || p.stock > 0)
        .toList();
  }
}
