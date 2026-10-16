import 'package:flutter/material.dart';
import 'package:fronted/components/login/fondo.dart';
import 'package:fronted/paginas/admin/widets.dart/barranavega.dart';
import 'package:google_fonts/google_fonts.dart';

// ESTA ES LA ESTRUCTURA BASICA DE LAS PNATALLAS DE ADMIN

/// Estructura común de las pantallas del admin:
/// fondo + barra inferior (volver) + "Megatech 2" + título + contenido.
/// [onVolver] es opcional; por defecto regresa al inicio (primera ruta).
class PantallaAdmin extends StatelessWidget {
  final String titulo;
  final Widget child;
  final VoidCallback? onVolver;
  final bool mostrarBarra; // NUEVO

  const PantallaAdmin({
    super.key,
    required this.titulo,
    required this.child,
    this.onVolver,
    this.mostrarBarra = true, // NUEVO
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: mostrarBarra
          ? Barranavegacioninferior(
              botones: [
                BotonNav(
                  icon: Icons.arrow_back,
                  size: 26,
                  onTap: () async {
                    if (onVolver != null) {
                      onVolver!();
                    } else {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    }
                  },
                ),
              ],
            )
          : null,
      body: Fondo(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 36,
                  vertical: 20,
                ),
                child: Text(
                  'Megatech 2',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                titulo,
                style: GoogleFonts.poppins(
                  color: const Color(0xFF1BC2F0),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }
}
