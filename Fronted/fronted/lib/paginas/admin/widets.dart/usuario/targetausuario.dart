import 'package:flutter/material.dart';
import 'package:fronted/colores/stilocolores.dart';
import 'package:fronted/components/comunes/etiquetaColor.dart';
import 'package:fronted/components/comunes/filaDato.dart';
import 'package:fronted/model/rolusuario.dart';
import 'package:fronted/model/user.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tarjeta de un usuario en la lista de gestión: iniciales, nombre, rol,
/// cédula, teléfono y correo. Tocarla = editar. El botón de la derecha
/// desactiva (o reactiva) la cuenta; si [onCambiarEstado] es null no se
/// muestra (es el propio admin). Las cuentas desactivadas se ven atenuadas.
class TarjetaUsuario extends StatelessWidget {
  static const Color _verde = Color(0xFF2ECC71);

  final usermodel usuario;
  final bool esYo;
  final VoidCallback onEditar;
  final VoidCallback? onCambiarEstado;

  const TarjetaUsuario({
    super.key,
    required this.usuario,
    required this.onEditar,
    this.esYo = false,
    this.onCambiarEstado,
  });

  String get _nombreCompleto =>
      '${usuario.nombre ?? ''} ${usuario.apellido ?? ''}'.trim();

  String get _iniciales {
    final n = (usuario.nombre ?? '').trim();
    final a = (usuario.apellido ?? '').trim();
    return ((n.isEmpty ? '' : n[0]) + (a.isEmpty ? '' : a[0])).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final colorRol = RolUsuario.color(usuario.rol);
    // Cuenta desactivada: borde y avatar en gris.
    final color = usuario.activo ? colorRol : Colors.white38;

    return Opacity(
      opacity: usuario.activo ? 1 : 0.6,
      child: GestureDetector(
        onTap: onEditar,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF1F2937),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: color, width: 1.5),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: color.withOpacity(0.18),
                child: Text(
                  _iniciales,
                  style: GoogleFonts.poppins(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _nombreCompleto.isEmpty ? 'Sin nombre' : _nombreCompleto,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        EtiquetaColor(
                          texto: usuario.rol ?? RolUsuario.cliente,
                          color: colorRol,
                          icono: RolUsuario.icono(usuario.rol),
                        ),
                        if (!usuario.activo)
                          const EtiquetaColor(
                            texto: 'Inactivo',
                            color: AppColors.rojo,
                            icono: Icons.block_rounded,
                          ),
                        if (esYo)
                          const EtiquetaColor(
                            texto: 'Tú',
                            color: AppColors.azulClaro,
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    FilaDato(Icons.badge_outlined, usuario.cedula ?? ''),
                    const SizedBox(height: 4),
                    FilaDato(Icons.phone_outlined, usuario.telefono ?? ''),
                    const SizedBox(height: 4),
                    FilaDato(Icons.email_outlined, usuario.correo ?? ''),
                  ],
                ),
              ),
              Column(
                children: [
                  const Icon(
                    Icons.edit_rounded,
                    color: AppColors.azulClaro,
                    size: 20,
                  ),
                  if (onCambiarEstado != null) ...[
                    const SizedBox(height: 10),
                    IconButton(
                      tooltip: usuario.activo
                          ? 'Desactivar usuario'
                          : 'Reactivar usuario',
                      onPressed: onCambiarEstado,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(
                        usuario.activo
                            ? Icons.person_off_outlined
                            : Icons.how_to_reg_outlined,
                        color: usuario.activo ? AppColors.rojo : _verde,
                        size: 24,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
