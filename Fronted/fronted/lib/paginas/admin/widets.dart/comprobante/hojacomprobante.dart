import 'package:flutter/material.dart';
import 'package:fronted/colores/stilocolores.dart';
import 'package:fronted/components/comunes/aviso.dart';
import 'package:fronted/components/comunes/botonDegradado.dart';
import 'package:fronted/components/comunes/etiquetaColor.dart';
import 'package:fronted/components/comunes/filaDato.dart';
import 'package:fronted/model/comprobante.dart';
import 'package:fronted/model/pedidos.dart';
import 'package:fronted/paginas/admin/widets.dart/comprobante/targetacomprobante.dart';
import 'package:fronted/paginas/admin/widets.dart/comprobante/visorcomprobante.dart';
import 'package:fronted/service/comprobantes.dart';
import 'package:fronted/service/pedidos.dart' show PedidoException;
import 'package:google_fonts/google_fonts.dart';

/// Resultados con los que se cierra la hoja.
const String transferenciaAprobada = 'aprobada';
const String transferenciaAprobadaSinCorreo = 'aprobada_sin_correo';

/// Hoja inferior para verificar un comprobante: foto grande (toca para zoom),
/// datos del pedido y botón "Aprobar transferencia".
class HojaComprobante extends StatefulWidget {
  final Comprobante comprobante;
  final ComprobantesService service;

  const HojaComprobante({
    super.key,
    required this.comprobante,
    required this.service,
  });

  @override
  State<HojaComprobante> createState() => _HojaComprobanteState();
}

class _HojaComprobanteState extends State<HojaComprobante> {
  bool _aprobando = false;

  Comprobante get _c => widget.comprobante;

  void _verCompleto() {
    final foto = _c.foto;
    if (foto == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => VisorComprobante(url: foto)),
    );
  }

  Future<void> _aprobar() async {
    final ok = await confirmar(
      context,
      titulo: 'Aprobar transferencia',
      mensaje:
          '¿Confirmas que recibiste ${formatearPesos(_c.total)} del pedido '
          '#${_c.idPedido}? Pasará a "Por entregar" y se enviará un correo '
          'al cliente.',
      textoConfirmar: 'Aprobar',
      colorConfirmar: AppColors.azulOscuro,
    );
    if (!ok || !mounted) return;

    setState(() => _aprobando = true);
    try {
      await widget.service.aprobar(_c.idPedido);
      if (mounted) Navigator.pop(context, transferenciaAprobada);
    } on PedidoException catch (e) {
      if (!mounted) return;
      // El estado sí quedó guardado; solo falló el correo al cliente.
      if (e.aplicado) {
        Navigator.pop(context, transferenciaAprobadaSinCorreo);
      } else {
        setState(() => _aprobando = false);
        mostrarAviso(context, e.mensaje, error: true);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _aprobando = false);
      mostrarAviso(context, textoError(e), error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = colorVerificacion(_c.porVerificar);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Pedido #${_c.idPedido}',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                EtiquetaColor(
                  texto: _c.porVerificar ? 'Por verificar' : 'Verificada',
                  color: color,
                  icono: _c.porVerificar
                      ? Icons.hourglass_top_rounded
                      : Icons.verified_outlined,
                ),
              ],
            ),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: _verCompleto,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  height: 300,
                  width: double.infinity,
                  color: AppColors.fondoOscuro2,
                  child: _c.foto == null
                      ? const Icon(
                          Icons.image_not_supported_outlined,
                          color: Colors.white38,
                          size: 56,
                        )
                      : Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              _c.foto!,
                              fit: BoxFit.contain,
                              loadingBuilder: (_, child, progreso) =>
                                  progreso == null
                                  ? child
                                  : const Center(
                                      child: CircularProgressIndicator(
                                        color: AppColors.azulClaro,
                                      ),
                                    ),
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.broken_image_outlined,
                                color: Colors.white38,
                                size: 56,
                              ),
                            ),
                            const Positioned(
                              right: 8,
                              bottom: 8,
                              child: Icon(
                                Icons.zoom_out_map_rounded,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilaDato(Icons.person_outline, _c.nombreCliente, fuerte: true),
            const SizedBox(height: 6),
            FilaDato(Icons.badge_outlined, _c.cedula),
            const SizedBox(height: 6),
            FilaDato(Icons.event_outlined, _c.fecha),
            const SizedBox(height: 14),
            Row(
              children: [
                Text(
                  'Total a recibir',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                Text(
                  formatearPesos(_c.total),
                  style: GoogleFonts.poppins(
                    color: AppColors.azulClaro,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_c.porVerificar)
              BotonDegradado(
                texto: 'Aprobar transferencia',
                icono: Icons.check_circle_outline_rounded,
                cargando: _aprobando,
                onTap: _aprobar,
              )
            else
              Container(
                width: double.infinity,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  border: Border.all(color: color, width: 1.5),
                  borderRadius: BorderRadius.circular(26),
                ),
                child: Text(
                  'Pedido ${_c.estadoPedido}',
                  style: GoogleFonts.poppins(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
