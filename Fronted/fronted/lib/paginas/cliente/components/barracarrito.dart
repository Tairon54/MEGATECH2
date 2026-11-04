import 'package:flutter/material.dart';
import 'package:fronted/colores/stilocolores.dart';
import 'package:fronted/model/pedidos.dart' show formatearPesos;
import 'package:fronted/paginas/cliente/carrito.dart';
import 'package:fronted/service/carrito.dart';
import 'package:google_fonts/google_fonts.dart';

/// Barra inferior que aparece cuando hay productos en el carrito.
/// Muestra unidades y total; al tocarla abre el carrito.
class BarraCarrito extends StatelessWidget {
  const BarraCarrito({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: CarritoService.instance,
      builder: (context, _) {
        final c = CarritoService.instance;

        return AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          child: c.estaVacio
              ? const SizedBox(width: double.infinity) // altura 0
              : Container(
                  color: AppColors.fondoOscuro3, // mismo tono del fondo
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(25),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const Carrito()),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            gradient: AppColors.gradienteBoton,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.azulClaro.withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Badge(
                                label: Text('${c.totalUnidades}'),
                                backgroundColor: Colors.white,
                                textColor: Colors.black,
                                child: const Icon(
                                  Icons.shopping_cart_rounded,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Text(
                                'Ver carrito',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                formatearPesos(c.total),
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: Colors.white,
                                size: 14,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }
}
