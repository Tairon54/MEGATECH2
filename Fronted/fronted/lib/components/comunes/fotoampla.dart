import 'package:flutter/material.dart';
import 'package:fronted/colores/stilocolores.dart';
import 'package:fronted/paginas/admin/widets.dart/pedido/targetapedido.dart'
    show FotoCuadrada;

/// Foto cuadrada (igual que [FotoCuadrada]) que al tocarla se abre en
/// grande. Si el producto no tiene foto, no hace nada al tocarla.
class FotoAmpliable extends StatelessWidget {
  final String? url;
  final double tam;
  final double radio;

  const FotoAmpliable({
    super.key,
    required this.url,
    this.tam = 105,
    this.radio = 18,
  });

  @override
  Widget build(BuildContext context) {
    final foto = FotoCuadrada(url: url, tam: tam, radio: radio);
    if (url == null) return foto;

    return GestureDetector(
      onTap: () => mostrarFotoGrande(context, url!),
      child: foto,
    );
  }
}

/// Abre la foto a pantalla completa. Se puede ampliar con los dedos y se
/// cierra tocando fuera de la foto o con la X.
Future<void> mostrarFotoGrande(BuildContext context, String url) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Cerrar foto',
    barrierColor: Colors.black87,
    transitionDuration: const Duration(milliseconds: 180),
    pageBuilder: (_, __, ___) => _VisorFoto(url: url),
    transitionBuilder: (_, animacion, __, hijo) =>
        FadeTransition(opacity: animacion, child: hijo),
  );
}

class _VisorFoto extends StatelessWidget {
  final String url;

  const _VisorFoto({required this.url});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Tocar el fondo cierra el visor.
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.pop(context),
            ),
          ),
          Center(
            child: InteractiveViewer(
              minScale: 1,
              maxScale: 5,
              child: Image.network(
                url,
                width: double.infinity,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, progreso) {
                  if (progreso == null) return child;
                  return const SizedBox(
                    height: 240,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.azulClaro,
                      ),
                    ),
                  );
                },
                errorBuilder: (_, __, ___) => const SizedBox(
                  height: 240,
                  child: Center(
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: Colors.white54,
                      size: 64,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: IconButton(
                  tooltip: 'Cerrar',
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
