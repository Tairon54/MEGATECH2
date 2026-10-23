import 'package:flutter/material.dart';
import 'package:fronted/paginas/cliente/components/pantallaproductos.dart';

class EquiposDeSonido extends StatelessWidget {
  const EquiposDeSonido({super.key});

  @override
  Widget build(BuildContext context) {
    return const PantallaProductos(
      titulo: 'Equipos de sonido',
      subcategoria: 'Equipos de sonido',
    );
  }
}