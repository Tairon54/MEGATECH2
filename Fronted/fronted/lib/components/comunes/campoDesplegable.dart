import 'package:flutter/material.dart';
import 'package:fronted/colores/stilocolores.dart';
import 'package:fronted/components/comunes/campoFormulario.dart';
import 'package:google_fonts/google_fonts.dart';

/// Lista desplegable con el mismo estilo oscuro de [CampoFormulario].
/// Con [onChanged] null queda deshabilitada.
class CampoDesplegable<T> extends StatelessWidget {
  final String etiqueta;
  final T? valor;
  final List<T> opciones;
  final String Function(T) textoDe;
  final ValueChanged<T?>? onChanged;
  final String? Function(T?)? validator;

  const CampoDesplegable({
    super.key,
    required this.etiqueta,
    required this.valor,
    required this.opciones,
    required this.textoDe,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: valor,
      isExpanded: true,
      dropdownColor: AppColors.fondoOscuro2,
      iconEnabledColor: Colors.white70,
      iconDisabledColor: Colors.white24,
      style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
      decoration: CampoFormulario.decoracion(etiqueta),
      items: [
        for (final o in opciones)
          DropdownMenuItem<T>(
            value: o,
            child: Text(textoDe(o), overflow: TextOverflow.ellipsis),
          ),
      ],
      onChanged: onChanged,
      validator: validator,
    );
  }
}
