import 'package:flutter/material.dart';
import 'package:fronted/colores/stilocolores.dart';
import 'package:fronted/paginas/ayuda/manual_usuario.dart';

class AyudaFlotante extends StatelessWidget {
  const AyudaFlotante({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      heroTag: 'botonAyuda',
      backgroundColor: AppColors.azulOscuro,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.menu_book_rounded),
      label: const Text('Ayuda'),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ManualUsuario()),
        );
      },
    );
  }
}
