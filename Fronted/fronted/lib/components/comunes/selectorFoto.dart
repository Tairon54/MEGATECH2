import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:fronted/colores/stilocolores.dart';
import 'package:fronted/components/comunes/botonCircular.dart';
import 'package:fronted/paginas/admin/widets.dart/targetapedido.dart'
    show FotoCuadrada;
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

/// Foto cuadrada editable: toca para elegir de galería o cámara.
/// Muestra [urlActual] hasta que se elige una nueva; avisa con [onCambio]
/// (null = se descartó la foto nueva).
class SelectorFoto extends StatefulWidget {
  final String? urlActual;
  final bool esNuevo;
  final bool deshabilitado;
  final ValueChanged<XFile?> onCambio;
  final ValueChanged<String> onError;

  const SelectorFoto({
    super.key,
    required this.urlActual,
    required this.onCambio,
    required this.onError,
    this.esNuevo = false,
    this.deshabilitado = false,
  });

  @override
  State<SelectorFoto> createState() => _SelectorFotoState();
}

class _SelectorFotoState extends State<SelectorFoto> {
  final ImagePicker _picker = ImagePicker();
  XFile? _foto;
  Uint8List? _bytes;

  Widget _opcion(IconData icono, String texto, ImageSource origen) => ListTile(
    leading: Icon(icono, color: Colors.white),
    title: Text(texto, style: GoogleFonts.poppins(color: Colors.white)),
    onTap: () => Navigator.pop(context, origen),
  );

  Future<void> _elegir() async {
    final origen = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.fondoOscuro2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _opcion(
              Icons.photo_library_rounded,
              'Elegir de la galería',
              ImageSource.gallery,
            ),
            _opcion(
              Icons.photo_camera_rounded,
              'Tomar una foto',
              ImageSource.camera,
            ),
          ],
        ),
      ),
    );
    if (origen == null) return;

    try {
      final foto = await _picker.pickImage(
        source: origen,
        maxWidth: 1200, // reduce el peso antes de subirla
        imageQuality: 85,
      );
      if (foto == null) return;
      final bytes = await foto.readAsBytes();
      if (!mounted) return;
      setState(() {
        _foto = foto;
        _bytes = bytes;
      });
      widget.onCambio(foto);
    } catch (_) {
      if (mounted) widget.onError('No se pudo abrir la cámara o la galería');
    }
  }

  void _descartar() {
    setState(() {
      _foto = null;
      _bytes = null;
    });
    widget.onCambio(null);
  }

  @override
  Widget build(BuildContext context) {
    const tam = 130.0;
    final bloqueado = widget.deshabilitado;

    return Column(
      children: [
        GestureDetector(
          onTap: bloqueado ? null : _elegir,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _foto != null
                        ? AppColors.azulClaro
                        : AppColors.bordeTarjeta,
                    width: 1.5,
                  ),
                ),
                child: _bytes != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.memory(
                          _bytes!,
                          width: tam,
                          height: tam,
                          fit: BoxFit.cover,
                        ),
                      )
                    : FotoCuadrada(url: widget.urlActual, tam: tam),
              ),
              const Positioned(
                right: 6,
                bottom: 6,
                child: BotonCircularDegradado(
                  icono: Icons.edit,
                  tam: 28,
                  tamIcono: 16,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        TextButton(
          onPressed: bloqueado ? null : (_foto == null ? _elegir : _descartar),
          child: Text(
            _foto != null
                ? 'Descartar foto nueva'
                : (widget.esNuevo ? 'Elegir foto' : 'Cambiar foto'),
            style: GoogleFonts.poppins(
              color: _foto != null ? Colors.white70 : AppColors.azulClaro,
              fontWeight: _foto != null ? FontWeight.normal : FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
