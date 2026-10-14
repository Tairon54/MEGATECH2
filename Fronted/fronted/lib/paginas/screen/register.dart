import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fronted/components/Bienvenida/boton_degradado.dart';
import 'package:fronted/components/Bienvenida/fondo.dart';
import 'package:fronted/components/codigo_verifi/iconocirculodegradado.dart';
import 'package:fronted/paginas/login.dart';

class Register extends StatelessWidget {
  const Register({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FondoDegradado(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const Spacer(),
                const IconoCirculoDegradado(
                  icono: Icons.check,
                  tamano: 90,
                  tamanoIcono: 50,
                ),
                const SizedBox(height: 24),
                Text(
                  'Felicidades',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Tu cuenta fue creada correctamente',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 18,
                  ),
                ),
                const Spacer(),
                BotonDegradado(
                  texto: 'Siguiente',
                  height: 56,
                  icono: Icons.arrow_forward,
                  onTap: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const Login()),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
