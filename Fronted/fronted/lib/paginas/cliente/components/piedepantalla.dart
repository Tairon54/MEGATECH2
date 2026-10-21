import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fronted/colores/stilocolores.dart';

/// Pie de pantalla reutilizable con teléfono, horario de atención y dirección.
///
/// Uso (al final de cualquier pantalla):
///   const PiePantalla()
///
/// Para cambiar la dirección cuando la tengas, edita [PiePantalla.direccionPorDefecto]
/// o pásala al usarlo:
///   const PiePantalla(direccion: 'Cra 5 # 10-20, Garzón, Huila')
class PiePantalla extends StatelessWidget {
  // ====== DATOS EDITABLES ======
  static const String telefonoPorDefecto = '3123917934';

  // TODO: cambiar por la dirección real cuando la tengas.
  static const String direccionPorDefecto = 'Calle 5 #4-67 Barrio centro';

  static const String horarioSemana =
      '7:00 a. m. a 1:00 p. m.\n2:00 p. m. a 8:00 p. m.';
  static const String horarioFinSemana = '7:00 a. m. a 8:00 p. m.';
  // =============================

  final String telefono;
  final String direccion;

  const PiePantalla({
    super.key,
    this.telefono = telefonoPorDefecto,
    this.direccion = direccionPorDefecto,
  });

  void _copiarTelefono(BuildContext context) {
    Clipboard.setData(ClipboardData(text: telefono));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.fondoTarjeta,
        content: Text(
          'Teléfono copiado',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      decoration: const BoxDecoration(
        color: AppColors.fondoOscuro3,
        border: Border(
          top: BorderSide(color: AppColors.bordeTarjeta, width: 1.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'Contáctanos',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 18),
          _Fila(
            icono: Icons.phone_rounded,
            titulo: 'Teléfono',
            onTap: () => _copiarTelefono(context),
            child: Text(
              telefono,
              style: GoogleFonts.poppins(
                color: AppColors.azulClaro,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const _Separador(),
          _Fila(
            icono: Icons.access_time_rounded,
            titulo: 'Horario de atención',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _TextoHorario(dia: 'Lunes a viernes', horas: horarioSemana),
                SizedBox(height: 8),
                _TextoHorario(
                  dia: 'Sábados y domingos',
                  horas: horarioFinSemana,
                ),
              ],
            ),
          ),
          const _Separador(),
          _Fila(
            icono: Icons.location_on_rounded,
            titulo: 'Dirección',
            child: Text(
              direccion,
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class _Fila extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final Widget child;
  final VoidCallback? onTap;

  const _Fila({
    required this.icono,
    required this.titulo,
    required this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.gradienteBoton,
            ),
            child: Icon(icono, color: Colors.black, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                child,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TextoHorario extends StatelessWidget {
  final String dia;
  final String horas;

  const _TextoHorario({required this.dia, required this.horas});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          dia,
          style: GoogleFonts.poppins(
            color: AppColors.cian,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          horas,
          style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13),
        ),
      ],
    );
  }
}

class _Separador extends StatelessWidget {
  const _Separador();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Divider(color: Colors.white12, height: 1),
    );
  }
}
