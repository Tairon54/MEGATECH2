/// Subcategoría tal como la devuelve GET /subcategorias.
class Subcategoria {
  final int id;
  final String nombre;
  final int? idCategoria;

  const Subcategoria({
    required this.id,
    required this.nombre,
    this.idCategoria,
  });

  factory Subcategoria.fromJson(Map<String, dynamic> json) {
    return Subcategoria(
      id: int.tryParse(json['id'].toString()) ?? 0,
      nombre: (json['nombre'] ?? '').toString(),
      idCategoria: int.tryParse((json['id_categoria'] ?? '').toString()),
    );
  }
}
