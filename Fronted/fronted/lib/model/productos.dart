/// Producto tal como lo devuelve el backend (tabla "productos" de Supabase).
class Producto {
  final int id;
  final String nombre;
  final String descripcion;
  final double precio;
  final int stock;
  final String? foto;
  final String? subcategoria;
  final String? categoria; // NUEVO

  const Producto({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.stock,
    this.foto,
    this.subcategoria,
    this.categoria, // NUEVO
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    final sub = json['subcategorias'];
    return Producto(
      id: int.tryParse(json['id'].toString()) ?? 0,
      nombre: (json['nombre'] ?? '').toString(),
      descripcion: (json['descripcion'] ?? '').toString(),
      precio: double.tryParse(json['precio'].toString()) ?? 0,
      stock: int.tryParse(json['stock'].toString()) ?? 0,
      foto: (json['foto'] == null || json['foto'].toString().isEmpty)
          ? null
          : json['foto'].toString(),
      subcategoria: sub is Map ? sub['nombre']?.toString() : null,
      categoria: (sub is Map && sub['categorias'] is Map)
          ? sub['categorias']['nombre_categoria']?.toString()
          : null,
    );
  }
}
