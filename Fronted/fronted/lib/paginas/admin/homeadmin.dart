import 'package:flutter/material.dart';
import 'package:fronted/paginas/admin/actualizarinventario.dart';
import 'package:fronted/paginas/admin/bajostock.dart';
import 'package:fronted/paginas/admin/gestioncontable.dart';
import 'package:fronted/paginas/admin/gestiondeusuarios.dart';
import 'package:fronted/paginas/admin/pedidos.dart';
import 'package:fronted/paginas/admin/perfil.dart';
import 'package:fronted/paginas/admin/registarventas.dart';
import 'package:fronted/paginas/admin/veririfcartrnsferencias.dart';
import 'package:fronted/paginas/admin/widets.dart/barranavega.dart';
import 'package:fronted/paginas/admin/widets.dart/pantallahome.dart';
import 'package:fronted/paginas/cliente/celulares/celulares_redmi.dart';
import 'package:fronted/paginas/cliente/iacliente.dart';

class Homeadmin extends StatelessWidget {
  final String cedula, nombre, apellido, telefono, correo;

  const Homeadmin({
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
          icon: Icons.smart_toy,
          onTap: () => irA(context, const Iacliente()),
        ),
        BotonNav(
          icon: Icons.person,
          size: 28,
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
        OpcionHome(
          'Bajo stok',
          'productos que estan en unidades criticas',
          'Revisar',
          Bajostock(),
        ),
        OpcionHome(
          'Pedidos',
          'Pedidos echos por la app que deben de ser entregados',
          'Colsultar',
          Pedidos(),
        ),
        OpcionHome(
          'Registrar ventas',
          'Registrar ventas fisicas',
          'Registrar',
          Registarventas(),
        ),
        OpcionHome(
          'Inventario',
          'Revisar inventario',
          'Colsultar',
          Celularesredmi(),
        ),
        OpcionHome(
          'Gestion contable',
          'Revisar gestion contable',
          'Consultar',
          Gestioncontable(),
        ),
        OpcionHome(
          'Actualizar inventario',
          'Modificar inventario',
          'Ingresar',
          Actualizarinventario(),
        ),
        OpcionHome(
          'Gestion de usuarios',
          'Modificar informacion de los usuarios',
          'Modificar',
          Gestiondeusuarios(),
        ),
        OpcionHome(
          'verificar transferencias',
          'Verificar las transferencias de los pagos de los pedidos',
          'Consultar',
          Veririfcartrnsferencias(),
        ),
      ],
    );
  }
}
