import 'package:flutter/material.dart';
import 'package:fronted/colores/stilocolores.dart';
import 'package:fronted/components/comunes/aviso.dart' show textoError;
import 'package:fronted/components/comunes/botonDegradado.dart';
import 'package:fronted/components/comunes/campoDesplegable.dart';
import 'package:fronted/components/comunes/campoFormulario.dart';
import 'package:fronted/model/rolUsuario.dart';
import 'package:fronted/model/user.dart';
import 'package:fronted/service/usuariosservice.dart';
import 'package:google_fonts/google_fonts.dart';

/// Formulario que se abre desde abajo para editar un usuario.
/// Se cierra con `true` si se guardó. La cédula solo se muestra (no se edita)
/// y, si [esYo], el rol queda bloqueado para no quitarse el acceso de admin.
class HojaUsuario extends StatefulWidget {
  final usermodel usuario;
  final UsuariosAdminService service;
  final bool esYo;

  const HojaUsuario({
    super.key,
    required this.usuario,
    required this.service,
    this.esYo = false,
  });

  @override
  State<HojaUsuario> createState() => _HojaUsuarioState();
}

class _HojaUsuarioState extends State<HojaUsuario> {
  static final _regCorreo = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');
  static final _regTelefono = RegExp(r'^\+?[0-9\s-]{7,15}$');

  final _formKey = GlobalKey<FormState>();
  late final _nombre = TextEditingController(text: widget.usuario.nombre);
  late final _apellido = TextEditingController(text: widget.usuario.apellido);
  late final _telefono = TextEditingController(text: widget.usuario.telefono);
  late final _correo = TextEditingController(text: widget.usuario.correo);
  late String _rol = RolUsuario.todos.contains(widget.usuario.rol)
      ? widget.usuario.rol!
      : RolUsuario.cliente;

  bool _guardando = false;
  String? _error;

  @override
  void dispose() {
    for (final c in [_nombre, _apellido, _telefono, _correo]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _obligatorio(String? v, String mensaje) =>
      (v ?? '').trim().isEmpty ? mensaje : null;

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _guardando = true;
      _error = null;
    });

    try {
      await widget.service.actualizar(
        widget.usuario.id!,
        nombre: _nombre.text.trim(),
        apellido: _apellido.text.trim(),
        telefono: _telefono.text.trim(),
        correo: _correo.text.trim(),
        rol: _rol,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _guardando = false;
        _error = textoError(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const sep = SizedBox(height: 12);

    return Padding(
      // Sube el formulario cuando aparece el teclado
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Editar usuario',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: AppColors.azulClaro,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Cédula ${widget.usuario.cedula ?? ''}',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 16),
              CampoFormulario(
                controller: _nombre,
                etiqueta: 'Nombre',
                capitalizar: TextCapitalization.words,
                validator: (v) => _obligatorio(v, 'Escriba el nombre'),
              ),
              sep,
              CampoFormulario(
                controller: _apellido,
                etiqueta: 'Apellido',
                capitalizar: TextCapitalization.words,
                validator: (v) => _obligatorio(v, 'Escriba el apellido'),
              ),
              sep,
              CampoFormulario(
                controller: _telefono,
                etiqueta: 'Teléfono',
                teclado: TextInputType.phone,
                validator: (v) => _regTelefono.hasMatch((v ?? '').trim())
                    ? null
                    : 'Teléfono inválido',
              ),
              sep,
              CampoFormulario(
                controller: _correo,
                etiqueta: 'Correo electrónico',
                teclado: TextInputType.emailAddress,
                validator: (v) => _regCorreo.hasMatch((v ?? '').trim())
                    ? null
                    : 'Correo inválido',
              ),
              sep,
              CampoDesplegable<String>(
                etiqueta: 'Rol',
                valor: _rol,
                opciones: RolUsuario.todos,
                textoDe: (r) => r,
                onChanged: (widget.esYo || _guardando)
                    ? null
                    : (v) => setState(() => _rol = v ?? _rol),
              ),
              if (widget.esYo) ...[
                const SizedBox(height: 6),
                Text(
                  'No puedes cambiar tu propio rol.',
                  style: GoogleFonts.poppins(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
              if (_error != null) ...[
                sep,
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: AppColors.rojo,
                    fontSize: 13,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _guardando
                          ? null
                          : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white38),
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Text(
                        'Cancelar',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: BotonDegradado(
                      texto: 'Guardar',
                      height: 48,
                      borderRadius: 25,
                      cargando: _guardando,
                      onTap: _guardar,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
