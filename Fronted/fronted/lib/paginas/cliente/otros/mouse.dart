import 'package:flutter/material.dart';
import 'package:fronted/paginas/cliente/components/pantallaproductos.dart';

class Mouse extends StatelessWidget {
  const Mouse({super.key});

  @override
  Widget build(BuildContext context) {
    return const PantallaProductos(
      titulo: 'Mouse',
      subcategoria: 'Mouse',
    );
  }
}