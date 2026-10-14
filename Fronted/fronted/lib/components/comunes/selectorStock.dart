import 'package:flutter/material.dart';
import 'package:fronted/components/comunes/botonCircular.dart';
import 'package:fronted/components/comunes/campoFormulario.dart';

/// Campo numérico de stock con botones – y + a los lados.
class SelectorStock extends StatelessWidget {
  final TextEditingController controller;

  const SelectorStock({super.key, required this.controller});

  void _cambiar(int delta) {
    final actual = int.tryParse(controller.text.trim()) ?? 0;
    controller.text = (actual + delta).clamp(0, 999999).toString();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        BotonCircularDegradado(icono: Icons.remove, onTap: () => _cambiar(-1)),
        const SizedBox(width: 10),
        Expanded(
          child: CampoFormulario(
            controller: controller,
            etiqueta: 'Stock (unidades)',
            alineacion: TextAlign.center,
            teclado: TextInputType.number,
            validator: (v) {
              final n = int.tryParse((v ?? '').trim());
              return (n == null || n < 0) ? 'Stock inválido' : null;
            },
          ),
        ),
        const SizedBox(width: 10),
        BotonCircularDegradado(icono: Icons.add, onTap: () => _cambiar(1)),
      ],
    );
  }
}
