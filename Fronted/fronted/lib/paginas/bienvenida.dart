import 'package:flutter/material.dart';
import 'package:fronted/paginas/cliente/components/carrusel.dart';
import 'package:fronted/paginas/cliente/homeclie.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fronted/components/Bienvenida/fondo.dart';
import 'package:fronted/components/Bienvenida/texto_degradado.dart';
import 'package:fronted/components/Bienvenida/boton_degradado.dart';

class Bienvenida extends StatefulWidget {
  const Bienvenida({super.key});

  @override
  State<Bienvenida> createState() => _BienvenidaState();
}

class _BienvenidaState extends State<Bienvenida> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FondoDegradado(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (context, valor, child) => Opacity(
                opacity: valor,
                child: Transform.translate(
                  offset: Offset(0, 30 * (1 - valor)),
                  child: child,
                ),
              ),
              child: Column(
                children: [
                  // Logo en la esquina superior izquierda + nombre al lado
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/logo_megatech2.png',
                          width: 70,
                        ),
                        const SizedBox(width: 12),
                        const Flexible(
                          child: TextoDegradado(
                            texto: 'Megatech 2',
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(flex: 3),
                  const Carrusel(),

                  Text(
                    'Bienvenido a',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 1),

                  const TextoDegradado(texto: 'Megatech', fontSize: 34),

                  const SizedBox(height: 3),

                  const TextoDegradado(texto: '2', fontSize: 32),

                  const SizedBox(height: 5),

                  Text(
                    'En Megatech 2 te ofrecemos lo mejor en tecnología '
                    'con una experiencia rápida, segura y confiable para '
                    'que compres sin complicaciones.',
                    textAlign: TextAlign.justify,
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),

                  const Spacer(flex: 20),

                  BotonDegradado(
                    texto: 'Explorar tienda',
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => Homeclie()),
                      );
                    },
                    icono: Icons.shopping_cart,
                  ),

                  const SizedBox(height: 25),
                  Text(
                    'Agrado - Huila',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                  SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
