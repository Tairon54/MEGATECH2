import 'package:flutter/material.dart';
import 'package:fronted/colores/stilocolores.dart';
import 'package:fronted/components/comunes/aviso.dart';
import 'package:fronted/components/comunes/campoBusqueda.dart';
import 'package:fronted/model/rolusuario.dart';
import 'package:fronted/model/user.dart';
import 'package:fronted/paginas/admin/hojaUsuario.dart';
import 'package:fronted/paginas/admin/widets.dart/listaasincrona.dart';
import 'package:fronted/paginas/admin/widets.dart/pantallaadmin.dart';
import 'package:fronted/paginas/admin/widets.dart/pedido/filtrochips.dart';
import 'package:fronted/paginas/admin/widets.dart/usuario/targetausuario.dart';
import 'package:fronted/service/usuariosservice.dart';

/// Pantalla del admin para gestionar usuarios: lista todos, busca por nombre,
/// cédula o correo, filtra por rol o por inactivos, edita (tocando la tarjeta)
/// y desactiva / reactiva cuentas (sin borrar su historial de ventas).
class Gestiondeusuarios extends StatefulWidget {
  const Gestiondeusuarios({super.key});

  @override
  State<Gestiondeusuarios> createState() => _GestiondeusuariosState();
}

class _GestiondeusuariosState extends State<Gestiondeusuarios> {
  static const String _inactivos = 'Inactivos';

  final _service = UsuariosAdminService();
  final _buscador = TextEditingController();
  late Future<List<usermodel>> _futuro = _service.obtenerTodos();

  /// null = "Todos" | un rol | [_inactivos]
  String? _filtro;
  String _busqueda = '';
  String? _idActual;

  @override
  void initState() {
    super.initState();
    _service.idActual().then((id) {
      if (mounted) setState(() => _idActual = id);
    });
  }

  @override
  void dispose() {
    _buscador.dispose();
    super.dispose();
  }

  Future<void> _recargar() async {
    setState(() => _futuro = _service.obtenerTodos());
    await _futuro.catchError((_) => <usermodel>[]);
  }

  /// Filtra por rol / inactivos y por nombre, apellido, cédula o correo.
  List<usermodel> _filtrar(List<usermodel> todos) {
    final q = _busqueda.trim().toLowerCase();
    return todos.where((u) {
      if (_filtro == _inactivos) {
        if (u.activo) return false;
      } else if (_filtro != null && u.rol != _filtro) {
        return false;
      }
      if (q.isEmpty) return true;
      final texto = [
        u.nombre,
        u.apellido,
        u.cedula,
        u.correo,
      ].whereType<String>().join(' ').toLowerCase();
      return texto.contains(q);
    }).toList();
  }

  String get _textoVacio => _busqueda.isNotEmpty
      ? 'No se encontraron usuarios'
      : _filtro == _inactivos
      ? 'No hay usuarios desactivados'
      : _filtro != null
      ? 'No hay usuarios con rol $_filtro'
      : 'Todavía no hay usuarios registrados';

  Future<void> _editar(usermodel u) async {
    final guardado = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.fondoTarjeta,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) =>
          HojaUsuario(usuario: u, service: _service, esYo: u.id == _idActual),
    );
    if (guardado != true || !mounted) return;
    mostrarAviso(context, 'Usuario actualizado correctamente');
    _recargar();
  }

  /// Desactiva (pide confirmación) o reactiva (directo) la cuenta.
  Future<void> _cambiarEstado(usermodel u) async {
    final activar = !u.activo;

    if (!activar) {
      final ok = await confirmar(
        context,
        titulo: 'Desactivar usuario',
        mensaje:
            '¿Desactivar a "${u.nombre} ${u.apellido}"? No podrá iniciar '
            'sesión, pero se conservan sus ventas y pedidos. Puede '
            'reactivarlo cuando quiera.',
        textoConfirmar: 'Desactivar',
      );
      if (!ok || !mounted) return;
    }

    try {
      await _service.cambiarActivo(u.id!, activo: activar);
      if (!mounted) return;
      mostrarAviso(
        context,
        activar
            ? 'Usuario reactivado correctamente'
            : 'Usuario desactivado correctamente',
      );
      _recargar();
    } catch (e) {
      if (mounted) mostrarAviso(context, textoError(e), error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PantallaAdmin(
      titulo: 'Gestión de usuarios',
      child: RefreshIndicator(
        onRefresh: () async {
          setState(() {});

          // Espera un momento para mostrar el efecto de recarga.
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: Column(
          children: [
            CampoBusqueda(
              controller: _buscador,
              hint: 'Buscar por nombre, cédula o correo',
              onChanged: (v) => setState(() => _busqueda = v),
            ),
            const SizedBox(height: 12),
            FiltroChips(
              opciones: <String?>[null, ...RolUsuario.todos, _inactivos],
              seleccionado: _filtro,
              onSeleccionar: (f) => setState(() => _filtro = f),
              colorDe: (f) => f == null
                  ? AppColors.azulClaro
                  : f == _inactivos
                  ? AppColors.rojo
                  : RolUsuario.color(f),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListaAsincrona<usermodel>(
                futuro: _futuro,
                onRecargar: _recargar,
                textoError: 'No se pudieron cargar los usuarios',
                textoVacio: _textoVacio,
                iconoVacio: Icons.person_search_outlined,
                filtrar: _filtrar,
                itemBuilder: (_, u) {
                  final esYo = u.id == _idActual;
                  return TarjetaUsuario(
                    usuario: u,
                    esYo: esYo,
                    onEditar: () => _editar(u),
                    onCambiarEstado: esYo ? null : () => _cambiarEstado(u),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
