import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fronted/components/comunes/aviso.dart';
import 'package:fronted/components/comunes/botonDegradado.dart';
import 'package:fronted/paginas/admin/widets.dart/pantallaadmin.dart';
import 'package:fronted/paginas/cliente/components/pagos/datosnequi.dart';
import 'package:fronted/paginas/cliente/components/pagos/elegirimagen.dart';
import 'package:fronted/paginas/cliente/components/pagos/guiapago.dart';
import 'package:fronted/paginas/cliente/components/pagos/subircompro.dart';
import 'package:fronted/paginas/cliente/components/pagos/totalpago.dart';
import 'package:fronted/paginas/cliente/pagoexitoso.dart';
import 'package:fronted/service/comprobante.dart';
import 'package:image_picker/image_picker.dart';

/// Proceso de pago por Nequi.
/// Recibe el [idPedido] (ya creado en el backend con estado "Por pagar") y el
/// [total] a transferir. El cliente transfiere, sube la foto del comprobante
/// y esta pantalla la envía a POST /compro junto con el id del pedido.
class Pagosuno extends StatefulWidget {
  final int idPedido;
  final double total;

  const Pagosuno({super.key, required this.idPedido, required this.total});

  @override
  State<Pagosuno> createState() => _PagosunoState();
}

class _PagosunoState extends State<Pagosuno> {
  static const String _numeroNequi = '3123917934';
  static const String _titular = 'Jose Yecid Cerquera';

  final ImagePicker _picker = ImagePicker();
  final ComprobanteService _servicio = ComprobanteService();

  XFile? _foto;
  Uint8List? _bytes;
  bool _enviando = false;

  Future<void> _elegirFoto() async {
    if (_enviando) return;
    final origen = await elegirOrigenImagen(context);
    if (origen == null) return;

    try {
      final foto = await _picker.pickImage(
        source: origen,
        maxWidth: 1600,
        imageQuality: 85,
      );
      if (foto == null) return;
      final bytes = await foto.readAsBytes();
      if (!mounted) return;
      setState(() {
        _foto = foto;
        _bytes = bytes;
      });
    } catch (_) {
      mostrarAviso(
        context,
        'No se pudo abrir la cámara o la galería',
        error: true,
      );
    }
  }

  Future<void> _enviar() async {
    if (_enviando) return;
    if (_foto == null) {
      mostrarAviso(context, 'Sube primero el comprobante de pago', error: true);
      return;
    }

    setState(() => _enviando = true);
    try {
      await _servicio.enviarComprobante(
        idPedido: widget.idPedido,
        foto: _foto!,
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PagoExitoso()),
      );
    } on ComprobanteException catch (e) {
      mostrarAviso(context, e.mensaje, error: true);
    } catch (_) {
      mostrarAviso(
        context,
        'No se pudo conectar con el servidor. Intenta de nuevo.',
        error: true,
      );
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  void _copiarNumero() {
    Clipboard.setData(const ClipboardData(text: _numeroNequi));
    mostrarAviso(context, 'Número copiado');
  }

  @override
  Widget build(BuildContext context) {
    return PantallaAdmin(
      titulo: 'Proceso de pago',
      mostrarBarra: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
        children: [
          DatosNequi(
            numero: _numeroNequi,
            titular: _titular,
            onCopiar: _copiarNumero,
          ),
          const SizedBox(height: 22),
          SubirComprobante(bytes: _bytes, onTap: _elegirFoto),
          const SizedBox(height: 22),
          const GuiaPago(numero: _numeroNequi),
          const SizedBox(height: 18),
          TotalPago(idPedido: widget.idPedido, total: widget.total),
          const SizedBox(height: 24),
          BotonDegradado(
            texto: 'ENVIAR COMPROBANTE',
            icono: Icons.verified_user_outlined,
            cargando: _enviando,
            height: 54,
            borderRadius: 30,
            onTap: _enviar,
          ),
        ],
      ),
    );
  }
}
