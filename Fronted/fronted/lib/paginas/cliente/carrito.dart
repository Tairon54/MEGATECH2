import 'package:flutter/material.dart';
import 'package:fronted/paginas/admin/widets.dart/pantallaadmin.dart';
import 'package:fronted/paginas/cliente/components/subtitulo.dart';

class Carrito extends StatefulWidget {
  final VoidCallback? onVolver;

  const Carrito({super.key, this.onVolver});

  @override
  State<Carrito> createState() => _CarritoState();
}

class _CarritoState extends State<Carrito> {
  @override
  Widget build(BuildContext context) {
    return PantallaAdmin(
      titulo: 'Tu carrito de compras',
      child: TextoInformativo(
        texto: 'Revisa bien tus productos antes de finalizar la compra',
      ),
    );
  }
}
