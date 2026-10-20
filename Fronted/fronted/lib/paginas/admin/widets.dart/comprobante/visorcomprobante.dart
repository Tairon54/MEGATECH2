import 'package:flutter/material.dart';
import 'package:fronted/colores/stilocolores.dart';

/// Comprobante a pantalla completa, con zoom (pellizcar) para leer bien
/// el monto, la fecha y la referencia de la transferencia.
class VisorComprobante extends StatelessWidget {
  final String url;

  const VisorComprobante({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 1,
          maxScale: 5,
          child: Image.network(
            url,
            fit: BoxFit.contain,
            loadingBuilder: (_, child, progreso) => progreso == null
                ? child
                : const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.azulClaro,
                    ),
                  ),
            errorBuilder: (_, __, ___) => const Icon(
              Icons.broken_image_outlined,
              color: Colors.white54,
              size: 64,
            ),
          ),
        ),
      ),
    );
  }
}
