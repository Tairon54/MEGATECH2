import 'package:flutter/material.dart';
import 'package:fronted/colores/stilocolores.dart';
import 'package:fronted/components/Bienvenida/boton_degradado.dart';
import 'package:fronted/components/comunes/aviso.dart' show textoError;
import 'package:fronted/components/comunes/campoFormulario.dart';
import 'package:fronted/components/comunes/selectorFoto.dart';
import 'package:fronted/components/comunes/selectorStock.dart';
import 'package:fronted/model/productos.dart';
import 'package:fronted/model/subcategoria.dart';
import 'package:fronted/service/productoservice.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

/// Formulario que se abre desde abajo para crear (producto == null) o editar
/// un producto. Se cierra con `true` si se guardó.
class HojaProducto extends StatefulWidget {
  final Producto? producto;
  final ProductosService service;

  const HojaProducto({
    super.key,
    required this.producto,
    required this.service,
  });

  @override
  State<HojaProducto> createState() => _HojaProductoState();
}

class _HojaProductoState extends State<HojaProducto> {
  final _formKey = GlobalKey<FormState>();
  late final _nombre = TextEditingController(text: widget.producto?.nombre);
  late final _descripcion = TextEditingController(
    text: widget.producto?.descripcion,
  );
  late final _precio = TextEditingController(
    text: widget.producto == null ? '' : _textoPrecio(widget.producto!.precio),
  );
  late final _stock = TextEditingController(
    text: (widget.producto?.stock ?? 0).toString(),
  );

  XFile? _foto; // null = se conserva la foto actual
  int? _idSubcategoria; // solo al crear
  bool _guardando = false;
  String? _error;

  bool get _esNuevo => widget.producto == null;

  static String _textoPrecio(num p) =>
      p % 1 == 0 ? p.toInt().toString() : p.toString();

  @override
  void dispose() {
    for (final c in [_nombre, _descripcion, _precio, _stock]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _guardando = true;
      _error = null;
    });

    try {
      final nombre = _nombre.text.trim();
      final descripcion = _descripcion.text.trim();
      final precio = double.parse(_precio.text.trim().replaceAll(',', '.'));
      final stock = int.parse(_stock.text.trim());

      if (_esNuevo) {
        await widget.service.crearProducto(
          nombre: nombre,
          descripcion: descripcion,
          precio: precio,
          stock: stock,
          idSubcategoria: _idSubcategoria!,
          foto: _foto,
        );
      } else {
        await widget.service.actualizarProducto(
          widget.producto!.id,
          nombre: nombre,
          descripcion: descripcion,
          precio: precio,
          stock: stock,
          foto: _foto,
        );
      }
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
                _esNuevo
                    ? 'Añadir producto'
                    : 'Editar producto #${widget.producto!.id}',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: AppColors.azulClaro,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),
              Center(
                child: SelectorFoto(
                  urlActual: widget.producto?.foto,
                  esNuevo: _esNuevo,
                  deshabilitado: _guardando,
                  onCambio: (f) => setState(() {
                    _foto = f;
                    _error = null;
                  }),
                  onError: (m) => setState(() => _error = m),
                ),
              ),
              const SizedBox(height: 10),
              CampoFormulario(
                controller: _nombre,
                etiqueta: 'Nombre',
                capitalizar: TextCapitalization.sentences,
                validator: (v) =>
                    (v ?? '').trim().isEmpty ? 'Escriba el nombre' : null,
              ),
              sep,
              if (_esNuevo) ...[
                _SelectorSubcategoria(
                  service: widget.service,
                  valor: _idSubcategoria,
                  habilitado: !_guardando,
                  onChanged: (v) => setState(() => _idSubcategoria = v),
                ),
                sep,
              ],
              CampoFormulario(
                controller: _descripcion,
                etiqueta: 'Descripción',
                maxLines: 3,
                minLines: 2,
                capitalizar: TextCapitalization.sentences,
              ),
              sep,
              CampoFormulario(
                controller: _precio,
                etiqueta: 'Precio',
                prefijo: '\$ ',
                teclado: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  final n = double.tryParse(
                    (v ?? '').trim().replaceAll(',', '.'),
                  );
                  return (n == null || n <= 0) ? 'Precio inválido' : null;
                },
              ),
              sep,
              SelectorStock(controller: _stock),
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
                      texto: _esNuevo ? 'Añadir' : 'Guardar',
                      height: 48,
                      borderRadius: 25,
                      cargando: _guardando,
                      onTap: _guardar,
                      icono: Icons.save,
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

/// Lista desplegable de subcategorías cargada desde el backend.
class _SelectorSubcategoria extends StatefulWidget {
  final ProductosService service;
  final int? valor;
  final bool habilitado;
  final ValueChanged<int?> onChanged;

  const _SelectorSubcategoria({
    required this.service,
    required this.valor,
    required this.habilitado,
    required this.onChanged,
  });

  @override
  State<_SelectorSubcategoria> createState() => _SelectorSubcategoriaState();
}

class _SelectorSubcategoriaState extends State<_SelectorSubcategoria> {
  late Future<List<Subcategoria>> _futuro = widget.service
      .obtenerSubcategorias();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Subcategoria>>(
      future: _futuro,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.azulClaro,
                ),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Row(
            children: [
              Expanded(
                child: Text(
                  'No se pudieron cargar las subcategorías',
                  style: GoogleFonts.poppins(
                    color: AppColors.rojo,
                    fontSize: 13,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => setState(
                  () => _futuro = widget.service.obtenerSubcategorias(),
                ),
                child: Text(
                  'Reintentar',
                  style: GoogleFonts.poppins(color: AppColors.azulClaro),
                ),
              ),
            ],
          );
        }

        return DropdownButtonFormField<int>(
          value: widget.valor,
          isExpanded: true,
          dropdownColor: AppColors.fondoOscuro2,
          iconEnabledColor: Colors.white70,
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
          decoration: CampoFormulario.decoracion('Subcategoría'),
          items: [
            for (final s in snapshot.data ?? <Subcategoria>[])
              DropdownMenuItem<int>(
                value: s.id,
                child: Text(s.nombre, overflow: TextOverflow.ellipsis),
              ),
          ],
          onChanged: widget.habilitado ? widget.onChanged : null,
          validator: (v) => v == null ? 'Elija una subcategoría' : null,
        );
      },
    );
  }
}
