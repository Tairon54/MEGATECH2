import 'package:flutter/material.dart';
import 'package:fronted/components/login/fondo.dart';
import 'package:fronted/paginas/admin/perfil.dart';
import 'package:fronted/paginas/admin/widets.dart/barranavega.dart';
import 'package:fronted/paginas/cliente/carrito.dart';
import 'package:fronted/paginas/cliente/components/barradebusqueda.dart';
import 'package:fronted/paginas/cliente/components/carrusel.dart';
import 'package:fronted/paginas/cliente/components/categorias.dart';
import 'package:fronted/paginas/cliente/components/encabesadosinico.dart';
import 'package:fronted/paginas/cliente/components/inisiarsesion.dart';
import 'package:fronted/paginas/cliente/iacliente.dart';
import 'package:fronted/paginas/login.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fronted/paginas/cliente/components/masvendidos.dart';

class Homeclie extends StatefulWidget {
  final String cedula;
  final String nombre;
  final String apellido;
  final String telefono;
  final String correo;

  const Homeclie({
    super.key,
    this.cedula = '',
    this.nombre = '',
    this.apellido = '',
    this.telefono = '',
    this.correo = '',
  });

  // Si no hay cédula, no hay sesión de cliente
  bool get esInvitado => cedula.isEmpty;

  @override
  State<Homeclie> createState() => _HomeclieState();
}

class _HomeclieState extends State<Homeclie> {
  void _irALogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Login()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Barranavegacioninferior(
        botones: [
          // La IA se conserva siempre
          BotonNav(
            icon: Icons.smart_toy,
            size: 26,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Iacliente()),
              );
            },
          ),
          // Con sesión: perfil. Sin sesión: botón para ir a login
          if (widget.esInvitado)
            BotonNav(icon: Icons.login, size: 26, onTap: _irALogin)
          else
            BotonNav(
              icon: Icons.person,
              size: 28,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Perfil(
                      cedula: widget.cedula,
                      nombre: widget.nombre,
                      apellido: widget.apellido,
                      telefono: widget.telefono,
                      correo: widget.correo,
                    ),
                  ),
                );
              },
            ),
          // El carrito solo existe con sesión iniciada (no para invitados)
          if (!widget.esInvitado)
            BotonNav(
              icon: Icons.shopping_cart,
              size: 26,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Carrito()),
                );
              },
            ),
        ],
      ),
      body: Fondo(
        child: RefreshIndicator(
          onRefresh: () async {
            setState(() {});

            // Espera un momento para mostrar el efecto de recarga.
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 36,
                      vertical: 20,
                    ),
                    child: Center(
                      child: Text(
                        'Megatech 2',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  // Mensaje solo para invitados
                  if (widget.esInvitado)
                    BotonIniciarSesion(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Login()),
                        );
                      },
                    ),
                  BarraBusqueda(),
                  const Carrusel(),
                  const Padding(
                    padding: EdgeInsets.only(left: 15, right: 15, bottom: 15),
                    child: EncabesadoSinIcono(
                      title: 'Nuestros productos mas comprados',
                      subtitle:
                          'Aqui encontraras nuestros productos mas comprados',
                    ),
                  ),
                  MasVendidos(mostrarCarrito: !widget.esInvitado),
                  const SizedBox(height: 20),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: EncabesadoSinIcono(
                        title: 'Nuestros productos',
                        subtitle:
                            'Revisa nuesras diferentes categorias para encontras lo que neseseitas',
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  CategoriasProductos(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
