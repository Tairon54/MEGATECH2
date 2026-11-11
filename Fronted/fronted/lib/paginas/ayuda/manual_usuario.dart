import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:fronted/colores/stilocolores.dart';

class ManualUsuario extends StatelessWidget {
  const ManualUsuario({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.azulOscuro,
      appBar: AppBar(
        backgroundColor: AppColors.azulOscuro,
        foregroundColor: Colors.white,
        title: const Text('Manual de usuario'),
        elevation: 0,
      ),
      body: SfPdfViewer.asset('assets/pdf/manual_usuario.pdf'),
    );
  }
}
