import 'package:flutter/material.dart';
import 'package:fronted/paginas/Terminoscondiciones.dart';
import 'package:fronted/paginas/login.dart';
import 'package:fronted/model/user.dart';
import 'package:fronted/paginas/verificarcuentas.dart';
import 'package:fronted/service/confiuser.dart';
import 'package:fronted/components/login/botondevolver.dart';
import 'package:fronted/components/login/botonaaccionprincipal.dart';
import 'package:fronted/components/login/contenedorformulario.dart';
import 'package:fronted/components/login/encabesado.dart';
import 'package:fronted/components/login/fondo.dart';
import 'package:fronted/components/login/leertexto.dart';
import 'package:fronted/components/login/notienesregister.dart';

class Registro extends StatefulWidget {
  const Registro({super.key});

  @override
  State<Registro> createState() => _RegistroState();
}

class _RegistroState extends State<Registro> {
  final cedulaController = TextEditingController();
  final nombreController = TextEditingController();
  final apellidoController = TextEditingController();
  final telefonoController = TextEditingController();
  final correoController = TextEditingController();
  final contrasenaController = TextEditingController();
  final confirmarController = TextEditingController();
  bool aceptar = false;
  bool ocultarContrasena = true;
  bool ocultarConfirmacion = true;

  Future<void> registrarUsuario() async {
    // 1. Verificar que todos los campos estén llenos
    if (cedulaController.text.trim().isEmpty ||
        nombreController.text.trim().isEmpty ||
        apellidoController.text.trim().isEmpty ||
        telefonoController.text.trim().isEmpty ||
        correoController.text.trim().isEmpty ||
        contrasenaController.text.isEmpty ||
        confirmarController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos')),
      );
      return;
    }

    // 2. Verificar seguridad de la contraseña
    // Mínimo 8 caracteres, al menos una mayúscula, una minúscula y un carácter especial
    final regexPassword = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*[\W_]).{8,}$');
    if (!regexPassword.hasMatch(contrasenaController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'La contraseña debe tener al menos 8 caracteres, incluir una mayúscula, una minúscula y un carácter especial.',
          ),
        ),
      );
      return;
    }

    // 3. Verificar que aceptó términos y condiciones
    if (!aceptar) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Debes aceptar los términos y condiciones para registrarte',
          ),
        ),
      );
      return;
    }

    // 4. Verificar que las contraseñas sean iguales
    if (contrasenaController.text != confirmarController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Las contraseñas no coinciden')),
      );
      return;
    }

    // 5. Crear el usuario
    final correo = correoController.text.trim();
    final usuario = usermodel(
      cedula: cedulaController.text.trim(),
      nombre: nombreController.text.trim(),
      apellido: apellidoController.text.trim(),
      telefono: telefonoController.text.trim(),
      correo: correo,
      contrasena: contrasenaController.text,
      rol: 'Cliente',
    );

    // 6. Enviar al backend
    try {
      final respuesta = await Userservice().registrar(usuario);

      if (!mounted) return;

      final bool emailEnviado = respuesta['emailEnviado'] ?? false;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            emailEnviado
                ? 'Usuario registrado. Revisa tu correo para el código de verificación'
                : 'Usuario registrado, pero no se pudo enviar el correo. Puedes reenviar el código',
          ),
        ),
      );

      // 7. Ir a pedir el código de verificación
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => VerificarCuenta(correo: correo),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  void _irALogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Login()),
    );
  }

  @override
  void dispose() {
    cedulaController.dispose();
    nombreController.dispose();
    apellidoController.dispose();
    telefonoController.dispose();
    correoController.dispose();
    contrasenaController.dispose();
    confirmarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Fondo(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 20),
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Botondevolver()],
                ),
                const SizedBox(height: 20),

                Contenedorformulario(
                  child: Column(
                    children: [
                      const Encabesado(
                        icon: Icons.person_add,
                        title: 'Únete a megatech 2',
                        subtitle:
                            'Crea tu cuenta de megatech 2 y disfruta de la mejor tecnología',
                      ),
                      const SizedBox(height: 28),

                      Leertexto(
                        label: 'Número de cédula',
                        controller: cedulaController,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 18),

                      Leertexto(
                        label: 'Nombre',
                        controller: nombreController,
                        keyboardType: TextInputType.name,
                      ),
                      const SizedBox(height: 18),

                      Leertexto(
                        label: 'Apellido',
                        controller: apellidoController,
                        keyboardType: TextInputType.name,
                      ),
                      const SizedBox(height: 18),

                      Leertexto(
                        label: 'Número de teléfono',
                        controller: telefonoController,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 18),

                      Leertexto(
                        label: 'Correo electrónico',
                        controller: correoController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 18),

                      Leertexto(
                        label: 'Contraseña',
                        controller: contrasenaController,
                        obscureText: ocultarContrasena,
                        suffixIcon: IconButton(
                          onPressed: () => setState(
                            () => ocultarContrasena = !ocultarContrasena,
                          ),
                          icon: Icon(
                            ocultarContrasena
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      Leertexto(
                        label: 'Confirmación de contraseña',
                        controller: confirmarController,
                        obscureText: ocultarConfirmacion,
                        suffixIcon: IconButton(
                          onPressed: () => setState(
                            () => ocultarConfirmacion = !ocultarConfirmacion,
                          ),
                          icon: Icon(
                            ocultarConfirmacion
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      Terminoscondiciones(
                        value: aceptar,
                        onChanged: (value) => setState(() => aceptar = value),
                      ),
                      const SizedBox(height: 8),

                      Botonaaccionprincipal(
                        text: 'Registrarse',
                        onTap: registrarUsuario,
                        width: 250,
                      ),
                      const SizedBox(height: 25),

                      Notienesregister(
                        question: '¿Ya tienes cuenta?',
                        actionText: 'Inicia sesión aquí',
                        onTap: _irALogin,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
