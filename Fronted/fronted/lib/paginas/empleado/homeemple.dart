import 'package:flutter/material.dart';
import 'package:fronted/paginas/admin/bajostock.dart';
import 'package:fronted/paginas/admin/pedidos.dart';
import 'package:fronted/paginas/admin/perfil.dart';
import 'package:fronted/paginas/admin/registarventas.dart';
import 'package:fronted/paginas/admin/widets.dart/barranavega.dart';
import 'package:fronted/paginas/admin/widets.dart/pantallahome.dart';

class Homeemple extends StatelessWidget {
  final String cedula, nombre, apellido, telefono, correo;

  const Homeemple({
    super.key,
    required this.cedula,
    required this.nombre,
    required this.apellido,
    required this.telefono,
    required this.correo,
  });

  @override
  Widget build(BuildContext context) {
    return PantallaHome(
      nombre: nombre,
      botones: [
        BotonNav(
          icon: Icons.person,
          onTap: () => irA(
            context,
            Perfil(
              cedula: cedula,
              nombre: nombre,
              apellido: apellido,
              telefono: telefono,
              correo: correo,
            ),
          ),
        ),
      ],
      opciones: const [
        OpcionHome('Bajo stok', 'productos que estan en unidades criticas', 'Revisar', Bajostock()),
        // El empleado ve los pedidos, pero no puede cambiar su estado.
        OpcionHome('Pedidos', 'Pedidos echos por la app que deben de ser entregados', 'Colsultar', Pedidos(puedeCambiarEstado: false)),
        OpcionHome('Registrar ventas', 'Registrar ventas fisicas', 'Registrar', Registarventas()),
      ],
    );
  }
}