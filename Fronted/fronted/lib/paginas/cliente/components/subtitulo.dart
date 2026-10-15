import 'package:flutter/material.dart';

class TextoInformativo extends StatelessWidget {
  final String texto;

  const TextoInformativo({super.key, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 15,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
