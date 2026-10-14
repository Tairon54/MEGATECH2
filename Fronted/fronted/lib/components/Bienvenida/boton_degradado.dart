import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BotonDegradado extends StatefulWidget {
  final String texto;
  final VoidCallback onTap;
  final double height;
  final double borderRadius;
  final List<Color> colores;
  final Color colorTexto;
  final bool cargando;
  final IconData? icono;

  const BotonDegradado({
    super.key,
    required this.texto,
    required this.onTap,
    this.height = 52,
    this.borderRadius = 30,
    this.colores = const [Color(0xFF29B6F6), Color(0xFF0288D1)],
    this.colorTexto = Colors.white,
    this.cargando = false,
    this.icono,
  });

  @override
  State<BotonDegradado> createState() => _BotonDegradadoState();
}

class _BotonDegradadoState extends State<BotonDegradado> {
  bool _presionado = false;

  void _cambiarPresionado(bool valor) {
    if (widget.cargando) return;

    setState(() {
      _presionado = valor;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _cambiarPresionado(true),
      onTapUp: (_) => _cambiarPresionado(false),
      onTapCancel: () => _cambiarPresionado(false),
      onTap: widget.cargando ? null : widget.onTap,
      child: AnimatedOpacity(
        opacity: _presionado ? 0.7 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          width: double.infinity,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(colors: widget.colores),
          ),
          child: Center(
            child: widget.cargando
                ? SizedBox(
                    width: 25,
                    height: 25,
                    child: CircularProgressIndicator(
                      color: widget.colorTexto,
                      strokeWidth: 2,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.icono != null) ...[
                        Icon(widget.icono, color: widget.colorTexto, size: 20),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        widget.texto,
                        style: GoogleFonts.acme(
                          color: widget.colorTexto,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
