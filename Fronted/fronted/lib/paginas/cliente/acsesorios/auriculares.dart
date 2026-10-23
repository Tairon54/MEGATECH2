import 'package:flutter/material.dart';
import 'package:fronted/paginas/cliente/components/pantallaproductos.dart';

class Auriculares extends StatelessWidget {
  const Auriculares({super.key});

  @override
  Widget build(BuildContext context) {
    return const PantallaProductos(
      titulo: 'Auriculares',
      subcategoria: 'Auriculares',
    );
  }
}