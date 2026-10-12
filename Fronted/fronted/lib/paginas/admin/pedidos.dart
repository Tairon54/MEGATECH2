import 'package:flutter/material.dart';
import 'package:fronted/colores/stilocolores.dart';
import 'package:fronted/model/pedidos.dart';
import 'package:fronted/paginas/admin/detallepedido.dart';
import 'package:fronted/paginas/admin/widets.dart/pedido/buscarpedido.dart';
import 'package:fronted/paginas/admin/widets.dart/pedido/filtrochips.dart';
import 'package:fronted/paginas/admin/widets.dart/listaasincrona.dart';
import 'package:fronted/paginas/admin/widets.dart/pantallaadmin.dart';
import 'package:fronted/paginas/admin/widets.dart/pedido/targetapedido.dart';
import 'package:fronted/service/pedidos.dart';

class Pedidos extends StatefulWidget {
  /// Solo el admin puede cambiar el estado de un pedido.
  /// El empleado ve lo mismo, pero en modo solo lectura.
  final bool puedeCambiarEstado;

  const Pedidos({super.key, this.puedeCambiarEstado = true});

  @override
  State<Pedidos> createState() => _PedidosState();
}

class _PedidosState extends State<Pedidos> {
  final PedidosService _service = PedidosService();
  final TextEditingController _cedulaCtrl = TextEditingController();
  late Future<List<Pedido>> _futuroPedidos;

  /// null = "Todos"
  String? _filtro;

  /// null = sin búsqueda (se muestran todos los pedidos)
  String? _cedulaBuscada;

  Future<List<Pedido>> _cargar() => _cedulaBuscada == null
      ? _service.obtenerPedidos()
      : _service.obtenerPedidosPorCedula(_cedulaBuscada!);

  @override
  void initState() {
    super.initState();
    _futuroPedidos = _cargar();
  }

  @override
  void dispose() {
    _cedulaCtrl.dispose();
    super.dispose();
  }

  void _buscarPorCedula() {
    FocusScope.of(context).unfocus();
    final cedula = _cedulaCtrl.text.trim();
    if (cedula.isEmpty) return _limpiarBusqueda();
    setState(() {
      _cedulaBuscada = cedula;
      _futuroPedidos = _cargar();
    });
  }

  void _limpiarBusqueda() {
    _cedulaCtrl.clear();
    setState(() {
      _cedulaBuscada = null;
      _futuroPedidos = _cargar();
    });
  }

  Future<void> _recargar() async {
    setState(() => _futuroPedidos = _cargar());
    await _futuroPedidos.catchError((_) => <Pedido>[]);
  }

  Future<void> _abrirDetalle(Pedido pedido) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetallePedido(
          pedido: pedido,
          puedeCambiarEstado: widget.puedeCambiarEstado,
        ),
      ),
    );
    if (mounted) _recargar();
  }

  String get _textoVacio => _cedulaBuscada != null
      ? 'No hay pedidos para la cédula $_cedulaBuscada'
      : _filtro == null
          ? 'Todavía no hay pedidos'
          : 'No hay pedidos "$_filtro"';

  @override
  Widget build(BuildContext context) {
    return PantallaAdmin(
      titulo: 'Pedidos',
      child: Column(
        children: [
          BarraBusquedaCedula(
            controller: _cedulaCtrl,
            hayBusqueda: _cedulaBuscada != null,
            onBuscar: _buscarPorCedula,
            onLimpiar: _limpiarBusqueda,
          ),
          const SizedBox(height: 14),
          FiltroChips(
            opciones: <String?>[null, ...EstadoPedido.todos],
            seleccionado: _filtro,
            onSeleccionar: (estado) => setState(() => _filtro = estado),
            colorDe: (estado) =>
                estado == null ? AppColors.azulClaro : EstadoPedido.color(estado),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListaAsincrona<Pedido>(
              futuro: _futuroPedidos,
              onRecargar: _recargar,
              textoError: 'No se pudieron cargar los pedidos',
              textoVacio: _textoVacio,
              filtrar: (todos) => _filtro == null
                  ? todos
                  : todos.where((p) => p.estado == _filtro).toList(),
              itemBuilder: (_, p) =>
                  TarjetaPedido(pedido: p, onTap: () => _abrirDetalle(p)),
            ),
          ),
        ],
      ),
    );
  }
}