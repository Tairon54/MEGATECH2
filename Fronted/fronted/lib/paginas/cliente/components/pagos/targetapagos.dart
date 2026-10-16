import 'package:flutter/material.dart';
import 'package:fronted/colores/stilocolores.dart';

/// Contenedor translúcido con borde azul que usan las tarjetas del pago.
class TarjetaPago extends StatelessWidget {
  final Widget child;
  final double radio;
  final double? height;
  final EdgeInsetsGeometry? padding;

  const TarjetaPago({
    super.key,
    required this.child,
    this.radio = 30,
    this.height,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      padding: padding,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.fondoTarjeta.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(radio),
        border: Border.all(color: AppColors.bordeTarjeta, width: 1),
      ),
      child: child,
    );
  }
}
