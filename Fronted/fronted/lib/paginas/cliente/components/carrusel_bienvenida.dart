import 'dart:async';
import 'package:flutter/material.dart';

/// Carrusel de imágenes con avance automático.
/// Uso:  const CarruselBienvenida()
class CarruselBienvenida extends StatefulWidget {
  const CarruselBienvenida({super.key});

  @override
  State<CarruselBienvenida> createState() => _CarruselBienvenidaState();
}

class _CarruselBienvenidaState extends State<CarruselBienvenida> {
  // Controla las páginas del PageView
  final PageController _controller = PageController();

  // Temporizador del avance automático
  Timer? _timer;

  // Tiempo que se muestra cada imagen
  static const Duration _intervalo = Duration(seconds: 3);

  // Índice de la imagen visible
  int paginaActual = 0;

  // Imágenes del carrusel (cámbialas por las tuyas)
  final List<String> imagenes = [
    'assets/images/local1.jpeg',
    'assets/images/local2.jpeg',
    'assets/images/licuadora.jpg',
    'assets/images/local3.jpeg',
    'assets/images/local4.jpeg',
    'assets/images/local5.jpeg',
    'assets/images/local6.jpeg',
    'assets/images/local7.jpeg',
  ];

  @override
  void initState() {
    super.initState();
    _iniciarAutoavance();
  }

  void _iniciarAutoavance() {
    _timer?.cancel();
    _timer = Timer.periodic(_intervalo, (_) {
      if (!_controller.hasClients) return;

      // Al llegar a la última vuelve a la primera
      final siguiente = (paginaActual + 1) % imagenes.length;

      _controller.animateToPage(
        siguiente,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 20),

        // Carrusel
        SizedBox(
          height: 250,
          child: PageView.builder(
            controller: _controller,
            itemCount: imagenes.length,
            onPageChanged: (index) {
              setState(() {
                paginaActual = index;
              });
              // Si el usuario desliza a mano, se reinicia la cuenta
              // para que no cambie justo después de su gesto
              _iniciarAutoavance();
            },
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(blurRadius: 8, offset: Offset(0, 4)),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    imagenes[index],
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 10),

        // Indicadores
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(imagenes.length, (index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 5),
              width: paginaActual == index ? 20 : 10,
              height: 10,
              decoration: BoxDecoration(
                color: paginaActual == index ? Colors.blue : Colors.grey,
                borderRadius: BorderRadius.circular(10),
              ),
            );
          }),
        ),

        const SizedBox(height: 30),
      ],
    );
  }

  @override
  void dispose() {
    _timer?.cancel(); // Importante: detener el timer al salir
    _controller.dispose();
    super.dispose();
  }
}
