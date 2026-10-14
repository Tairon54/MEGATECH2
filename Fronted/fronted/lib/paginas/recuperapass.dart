import 'package:flutter/material.dart';
import '../model/recuperapass.dart';
import '../service/recuperapass.dart';
import 'screen/codigoenviado.dart';
import 'package:fronted/components/Bienvenida/fondo.dart';
import 'package:fronted/components/Bienvenida/boton_degradado.dart';
import 'package:fronted/components/rescuperar_contra/BotonRegresarDegradado.dart';
import 'package:fronted/components/rescuperar_contra/TarjetaFormulario.dart';
import 'package:fronted/components/rescuperar_contra/CampoTexto.dart';

class Recuperapass extends StatefulWidget {
  const Recuperapass({super.key});

  @override
  State<Recuperapass> createState() => _RecuperapassState();
}

class _RecuperapassState extends State<Recuperapass> {
  final TextEditingController emailController = TextEditingController();
  final RecuperarService recuperarService = RecuperarService();

  Future<void> enviarCodigo() async {
    final correo = emailController.text.trim();

    if (correo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingrese su correo electrónico'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final recuperar = RecuperarModel(correo: correo);

      await recuperarService.enviarCodigo(recuperar);

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CodigoEnviado(correo: correo)),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FondoDegradado(
        colores: const [
          Color(0xFF0F2B48),
          Color(0xFF0B1928),
          Color(0xFF050B12),
        ],
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                BotonRegresarDegradado(
                  onPressed: () => Navigator.of(context).pop(),
                ),

                const Spacer(),

                TarjetaFormulario(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Recupera tu contraseña',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      const Text(
                        'Por favor digite el correo electrónico que está ligado a su cuenta de Megatech 2.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          height: 1.3,
                        ),
                      ),

                      const SizedBox(height: 28),

                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Correo electrónico',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      CampoTexto(
                        controller: emailController,
                        label: 'Correo electrónico',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),

                      const SizedBox(height: 32),

                      BotonDegradado(
                        texto: 'Enviar',
                        onTap: enviarCodigo,
                        height: 48,
                        borderRadius: 24,
                        colores: const [Color(0xFF00C6FF), Color(0xFF0072FF)],
                        colorTexto: Colors.black,
                        icono: Icons.send,
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }
}
