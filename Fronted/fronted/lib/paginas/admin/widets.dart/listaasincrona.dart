import 'package:flutter/material.dart';
import 'package:fronted/colores/stilocolores.dart';
import 'package:google_fonts/google_fonts.dart';

// ESTA PANTALLA ES LA QUE DA EL ERROR Y NO SE PUEDN CARGAR

/// Mensaje centrado con icono (vacío / error) y botón "Reintentar" opcional.
class MensajeEstado extends StatelessWidget {
  final IconData icono;
  final String texto;
  final VoidCallback? onReintentar;

  const MensajeEstado({
    super.key,
    required this.icono,
    required this.texto,
    this.onReintentar,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, color: Colors.white54, size: 56),
            const SizedBox(height: 12),
            Text(
              texto,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 15),
            ),
            if (onReintentar != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onReintentar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3FA9F5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  'Reintentar',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// FutureBuilder + estados (cargando / error / vacío) + lista con pull-to-refresh.
/// [filtrar] es opcional: recibe todos los datos y devuelve los que se muestran.
class ListaAsincrona<T> extends StatelessWidget {
  final Future<List<T>> futuro;
  final Future<void> Function() onRecargar;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final String textoError;
  final String textoVacio;
  final IconData iconoVacio;
  final List<T> Function(List<T> items)? filtrar;

  const ListaAsincrona({
    super.key,
    required this.futuro,
    required this.onRecargar,
    required this.itemBuilder,
    required this.textoError,
    required this.textoVacio,
    this.iconoVacio = Icons.inbox_outlined,
    this.filtrar,
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
            onReintentar: onRecargar,
          );
        }

        final datos = snapshot.data ?? <T>[];
        final items = filtrar == null ? datos : filtrar!(datos);

        if (items.isEmpty) {
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(
                height: 320,
                child: MensajeEstado(icono: iconoVacio, texto: textoVacio),
              ),
            ],
          );
        }

        return ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (context, i) => itemBuilder(context, items[i]),
        );
      },
    );
  }
}
