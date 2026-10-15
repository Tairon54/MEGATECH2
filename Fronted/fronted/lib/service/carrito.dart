import 'package:flutter/foundation.dart';
import 'package:fronted/model/productos.dart';

/// Un producto dentro del carrito con su cantidad.
class ItemCarrito {
  final Producto producto;
  int cantidad;

  ItemCarrito({required this.producto, this.cantidad = 1});

  double get subtotal => producto.precio * cantidad;
}

/// Carrito de compras en memoria (se vacía al cerrar la app).
/// Es un singleton: se usa con `CarritoService.instance` desde cualquier
/// pantalla y avisa a quien lo escuche cuando cambia.
class CarritoService extends ChangeNotifier {
  CarritoService._();
  static final CarritoService instance = CarritoService._();

  final Map<int, ItemCarrito> _items = {};

  List<ItemCarrito> get items => _items.values.toList();

  /// Total de unidades (útil para un globito en el icono del carrito).
  int get totalUnidades =>
      _items.values.fold(0, (suma, item) => suma + item.cantidad);

  double get total =>
      _items.values.fold(0.0, (suma, item) => suma + item.subtotal);

  bool get estaVacio => _items.isEmpty;

  /// Cuántas unidades de este producto hay en el carrito.
  int cantidadDe(int idProducto) => _items[idProducto]?.cantidad ?? 0;

  /// Agrega una unidad. Devuelve false si ya se alcanzó el stock disponible.
  bool agregar(Producto producto) {
    final actual = _items[producto.id];
    if (actual == null) {
      if (producto.stock < 1) return false;
      _items[producto.id] = ItemCarrito(producto: producto);
    } else {
      if (actual.cantidad >= producto.stock) return false;
      actual.cantidad++;
    }
    notifyListeners();
    return true;
  }

  /// Quita una unidad; si llega a cero, elimina el producto del carrito.
  void quitarUna(int idProducto) {
    final actual = _items[idProducto];
    if (actual == null) return;
    actual.cantidad--;
    if (actual.cantidad <= 0) _items.remove(idProducto);
    notifyListeners();
  }

  void eliminar(int idProducto) {
    if (_items.remove(idProducto) != null) notifyListeners();
  }

  void vaciar() {
    if (_items.isEmpty) return;
    _items.clear();
    notifyListeners();
  }
}
