import 'package:flutter/material.dart';
import 'package:fronted/colores/stilocolores.dart';
import 'package:fronted/components/comunes/mensajeEstado.dart';

/// Resuelve los 4 estados de una lista que viene del backend:
/// cargando, error (con "Reintentar"), vacía y con datos (con pull-to-refresh).
/// Solo hay que decir cómo se dibujan los datos en [builder].
class ListaAsincrona<T> extends StatelessWidget {
  final Future<List<T>> futuro;
  final Future<void> Function() onReintentar;
  final String textoVacio;
  final String textoError;
  final List<T> Function(List<T>)? filtro;
  final Widget Function(BuildContext, List<T>) builder;

  const ListaAsincrona({
    super.key,
    required this.futuro,
    required this.onReintentar,
    required this.textoVacio,
    required this.builder,
    this.filtro,
    this.textoError = 'No se pudieron cargar los datos',
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<T>>(
      future: futuro,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.azulClaro),
          );
        }
        if (snapshot.hasError) {
          return MensajeEstado(
            icono: Icons.wifi_off_rounded,
            texto: textoError,
            onReintentar: onReintentar,
          );
        }
        final lista = snapshot.data ?? <T>[];
        final datos = filtro?.call(lista) ?? lista;
        if (datos.isEmpty) {
          return MensajeEstado(
            icono: Icons.search_off_rounded,
            texto: textoVacio,
          );
        }
        return builder(context, datos);
      },
    );
  }
}
