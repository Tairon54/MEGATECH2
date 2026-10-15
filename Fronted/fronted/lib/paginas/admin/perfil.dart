import 'package:flutter/material.dart';
import 'package:fronted/components/login/botonaaccionprincipal.dart';
import 'package:fronted/components/login/botondevolver.dart';
import 'package:fronted/components/login/contenedorformulario.dart';
import 'package:fronted/components/login/encabesado.dart';
import 'package:fronted/components/login/fondo.dart';
import 'package:fronted/paginas/admin/widets.dart/datoperfil.dart';
import 'package:fronted/paginas/login.dart';
import 'package:fronted/service/carrito.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Perfil extends StatefulWidget {
  final String cedula;
  final String nombre;
  final String apellido;
  final String telefono;
  final String correo;

  const Perfil({
    super.key,
    required this.cedula,
    required this.nombre,
    required this.apellido,
    required this.telefono,
    required this.correo,
  });

  @override
  State<Perfil> createState() => _PerfilState();
}

class _PerfilState extends State<Perfil> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Fondo(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Botondevolver()],
                ),

                const SizedBox(height: 20),

                Contenedorformulario(
                  child: Column(
                    children: [
                      Encabesado(title: 'Perfil', subtitle: widget.nombre),

                      const SizedBox(height: 30),

                      Datoperfil(
                        etiqueta: 'Número de cédula',
                        valor: widget.cedula,
                      ),

                      const SizedBox(height: 18),

                      Datoperfil(etiqueta: 'Nombre', valor: widget.nombre),

                      const SizedBox(height: 18),

                      Datoperfil(etiqueta: 'Apellido', valor: widget.apellido),

                      const SizedBox(height: 18),

                      Datoperfil(
                        etiqueta: 'Número de teléfono',
                        valor: widget.telefono,
                      ),

                      const SizedBox(height: 18),

                      Datoperfil(
                        etiqueta: 'Correo electrónico',
                        valor: widget.correo,
                      ),
                      const SizedBox(height: 20),
                      Botonaaccionprincipal(
                        text: 'Cerrar sesion',
                        onTap: () async {
                          final prefs = await SharedPreferences.getInstance();

                          // Eliminar el token de la sesión
                          await prefs.remove('token');

                          // El carrito es de la sesión: se vacía al salir
                          CarritoService.instance.vaciar();

                          if (!context.mounted) return;

                          // Ir al Login y eliminar todas las pantallas anteriores
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Login(),
                            ),
                            (route) => false,
                          );
                        },
                      ),
                    ],
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