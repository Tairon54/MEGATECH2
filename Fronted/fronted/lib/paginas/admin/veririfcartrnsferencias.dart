import 'package:flutter/material.dart';
import 'package:fronted/colores/stilocolores.dart';
import 'package:fronted/components/comunes/aviso.dart';
import 'package:fronted/components/comunes/campoBusqueda.dart';
import 'package:fronted/model/comprobante.dart';
import 'package:fronted/paginas/admin/widets.dart/listaasincrona.dart';
import 'package:fronted/paginas/admin/widets.dart/pantallaadmin.dart';
import 'package:fronted/paginas/admin/widets.dart/pedido/filtrochips.dart';
import 'package:fronted/paginas/admin/widets.dart/comprobante/hojacomprobante.dart';
import 'package:fronted/paginas/admin/widets.dart/comprobante/targetacomprobante.dart';
import 'package:fronted/service/comprobantes.dart';

/// Pantalla del admin para verificar las transferencias de los pedidos:
/// lista los comprobantes que subieron los clientes, permite buscar por
/// nombre / cédula / # de pedido, filtrar por verificadas o pendientes y
/// aprobar el pago (el pedido pasa de "Por pagar" a "Por entregar").
class Veririfcartrnsferencias extends StatefulWidget {
  const Veririfcartrnsferencias({super.key});

  @override
  State<Veririfcartrnsferencias> createState() =>
      _VeririfcartrnsferenciasState();
}

class _VeririfcartrnsferenciasState extends State<Veririfcartrnsferencias> {
  static const String _porVerificar = 'Por verificar';
  static const String _verificadas = 'Verificadas';

  final _service = ComprobantesService();
  final _buscador = TextEditingController();
  late Future<List<Comprobante>> _futuro = _service.obtenerTodos();

  /// null = "Todos" | [_porVerificar] | [_verificadas]
  String? _filtro;
  String _busqueda = '';

  @override
  void dispose() {
    _buscador.dispose();
    super.dispose();
  }

  Future<void> _recargar() async {
    final nuevaConsulta = _service.obtenerTodos();

    if (mounted) {
      setState(() {
        _futuro = nuevaConsulta;
      });
      try {
        await nuevaConsulta;
      } catch (_) {
        if (mounted) {
          mostrarAviso(
            context,
            'No se pudieron cargar los comprobantes',
            error: true,
          );
        }
      }
    }

    await nuevaConsulta;
  }

  List<Comprobante> _filtrar(List<Comprobante> todos) {
    final q = _busqueda.trim().toLowerCase();
    return todos.where((c) {
      if (_filtro == _porVerificar && !c.porVerificar) return false;
      if (_filtro == _verificadas && c.porVerificar) return false;
      if (q.isEmpty) return true;
      final texto = '${c.nombreCliente} ${c.cedula} ${c.idPedido}'
          .toLowerCase();
      return texto.contains(q);
    }).toList();
  }

  String get _textoVacio => _busqueda.isNotEmpty
      ? 'No se encontraron comprobantes'
      : _filtro == _porVerificar
      ? 'No hay transferencias por verificar'
      : _filtro == _verificadas
      ? 'Todavía no hay transferencias verificadas'
      : 'Todavía no hay comprobantes';

  Future<void> _abrir(Comprobante c) async {
    final resultado = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.fondoTarjeta,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => HojaComprobante(comprobante: c, service: _service),
    );
    if (resultado == null || !mounted) return;

    if (resultado == transferenciaAprobadaSinCorreo) {
      mostrarAviso(
        context,
        'Transferencia aprobada, pero no se pudo enviar el correo al cliente',
        error: true,
      );
    } else {
      mostrarAviso(context, 'Transferencia aprobada: pedido por entregar');
    }
    _recargar();
  }

  @override
  Widget build(BuildContext context) {
    return PantallaAdmin(
      titulo: 'Verificar transferencias',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: CampoBusqueda(
                  controller: _buscador,
                  hint: 'Buscar por nombre, cédula o # de pedido',
                  onChanged: (v) => setState(() => _busqueda = v),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _recargar,
                tooltip: 'Actualizar transferencias',
                icon: const Icon(
                  Icons.refresh_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FiltroChips(
            opciones: const <String?>[null, _porVerificar, _verificadas],
            seleccionado: _filtro,
            onSeleccionar: (f) => setState(() => _filtro = f),
            colorDe: (f) => f == null
                ? AppColors.azulClaro
                : colorVerificacion(f == _porVerificar),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListaAsincrona<Comprobante>(
              futuro: _futuro,
              onRecargar: _recargar,
              textoError: 'No se pudieron cargar los comprobantes',
              textoVacio: _textoVacio,
              iconoVacio: Icons.receipt_long_outlined,
              filtrar: _filtrar,
              itemBuilder: (_, c) =>
                  TarjetaComprobante(comprobante: c, onTap: () => _abrir(c)),
            ),
          ),
        ],
      ),
    );
  }
}
