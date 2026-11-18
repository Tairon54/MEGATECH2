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

import 'package:fronted/service/cuenta.dart';
import 'package:flutter/material.dart';

class Perfil extends StatefulWidget {
  final String cedula;
  final String nombre;
  final String apellido;
  final String telefono;
  final String correo;

  final bool puedeEliminarCuenta;

  const Perfil({
    super.key,
    required this.cedula,
    required this.nombre,
    required this.apellido,
    required this.telefono,
    required this.correo,
    this.puedeEliminarCuenta = false,
  });

  @override
  State<Perfil> createState() => _PerfilState();
}

class _PerfilState extends State<Perfil> {
  bool eliminandoCuenta = false;

  Future<void> _eliminarCuenta() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF10243F),
        title: const Text(
          '¿Eliminar tu cuenta?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Esta acción es permanente. Se eliminará tu cuenta '
          'de MEGATECH 2 y no podrás volver a iniciar sesión '
          'con ella.\n\n¿Estás seguro de continuar?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Eliminar definitivamente',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;

    setState(() => eliminandoCuenta = true);

    try {
      await CuentaService().eliminarMiCuenta();

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');

      CarritoService.instance.vaciar();

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const Login()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => eliminandoCuenta = false);
      }
    }
  }

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

                      if (widget.puedeEliminarCuenta) ...[
                        const SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: eliminandoCuenta
                                ? null
                                : _eliminarCuenta,
                            icon: eliminandoCuenta
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.redAccent,
                                    ),
                                  )
                                : const Icon(
                                    Icons.delete_forever_outlined,
                                    color: Colors.redAccent,
                                  ),
                            label: Text(
                              eliminandoCuenta
                                  ? 'Eliminando cuenta...'
                                  : 'Eliminar mi cuenta',
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.redAccent),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                          ),
                        ),
                      ],
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
