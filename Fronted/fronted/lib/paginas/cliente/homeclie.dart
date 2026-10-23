import 'package:flutter/material.dart';
import 'package:fronted/components/login/fondo.dart';
import 'package:fronted/paginas/admin/perfil.dart';
import 'package:fronted/paginas/admin/widets.dart/barranavega.dart';
import 'package:fronted/paginas/cliente/carrito.dart';
import 'package:fronted/paginas/cliente/components/barradebusqueda.dart';
import 'package:fronted/paginas/cliente/components/carrusel.dart';
import 'package:fronted/paginas/cliente/components/categorias.dart';
import 'package:fronted/paginas/cliente/components/encabesadosinico.dart';
import 'package:fronted/paginas/cliente/components/encabezadoscroll.dart';
import 'package:fronted/paginas/cliente/components/inisiarsesion.dart';
import 'package:fronted/paginas/cliente/components/menu.dart';
import 'package:fronted/paginas/cliente/components/piedepantalla.dart';
import 'package:fronted/paginas/cliente/iacliente.dart';
import 'package:fronted/paginas/login.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fronted/paginas/cliente/components/masvendidos.dart';
import 'package:fronted/paginas/cliente/components/resultadosbusquedas.dart';

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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _busquedaCtrl = TextEditingController();
  // Controla el scroll para animar el encabezado mientras se baja
  final ScrollController _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _busquedaCtrl.dispose();
    super.dispose();
  }

  void _buscar([String? texto]) {
    final consulta = (texto ?? _busquedaCtrl.text).trim();
    if (consulta.isEmpty) return;
    FocusScope.of(context).unfocus();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ResultadosBusqueda(consulta: consulta)),
    );
    _busquedaCtrl.clear();
  }

  void _irALogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Login()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const Menu(),
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
          BotonNav(
            icon: Icons.menu,
            size: 26,
            onTap: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          // Con sesión: perfil. Sin sesión: botón para ir a login
          if (widget.esInvitado)
            BotonNav(icon: Icons.person, size: 26, onTap: _irALogin)
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
              controller: _scrollCtrl,
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // Parte de arriba: se desvanece y desaparece al bajar
                  EncabezadoAnimado(
                    controller: _scrollCtrl,
                    child: Column(
                      children: [
                        if (widget.esInvitado) ...[
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
                          BotonIniciarSesion(onTap: _irALogin),
                        ] else
                          // Con sesión: "Hola, nombre"
                          SaludoCliente(nombre: widget.nombre),
                      ],
                    ),
                  ),
                  BarraBusqueda(
                    controller: _busquedaCtrl,
                    textInputAction: TextInputAction.search,
                    onSubmitted: _buscar,
                    suffixIcon: IconButton(
                      icon: const Icon(
                        Icons.arrow_forward_rounded,
                        color: Color(0xFF20BFFF),
                      ),
                      onPressed: _buscar,
                    ),
                  ),
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
                  const PiePantalla(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}