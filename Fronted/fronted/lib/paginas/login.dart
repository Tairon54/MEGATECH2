import 'package:flutter/material.dart';
import 'package:fronted/components/login/botonaaccionprincipal.dart';
import 'package:fronted/components/login/botondevolver.dart';
import 'package:fronted/components/login/contenedorformulario.dart';
import 'package:fronted/components/login/datosprotejidos.dart';
import 'package:fronted/components/login/encabesado.dart';
import 'package:fronted/components/login/fondo.dart';
import 'package:fronted/components/login/leertexto.dart';
import 'package:fronted/components/login/notienesregister.dart';
import 'package:fronted/components/login/recorolvi.dart';
import '../service/confiuser.dart';
import '../paginas/admin/homeadmin.dart';
import '../paginas/cliente/homeclie.dart';
import '../paginas/empleado/homeemple.dart';
import '../model/user.dart';
import '../paginas/recuperapass.dart';
import '../paginas/registro.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController correoController = TextEditingController();
  final TextEditingController contrasenaController = TextEditingController();

  final Userservice _userService = Userservice();

  bool recordarme = false;
  bool ocultarContrasena = true;

  Future<void> iniciarSesion() async {
    try {
      final respuesta = await _userService.loginUsuario(
        correoController.text.trim(),
        contrasenaController.text,
      );

      final usuario = usermodel.fromJson(respuesta['usuario']);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', respuesta['token']);

      if (!mounted) return;

      if (usuario.rol == 'Cliente') {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => Homeclie(
              cedula: usuario.cedula ?? '',
              nombre: usuario.nombre ?? '',
              apellido: usuario.apellido ?? '',
              telefono: usuario.telefono ?? '',
              correo: usuario.correo ?? '',
            ),
          ),
          (route) => false,
        );
      } else if (usuario.rol == 'Empleado') {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => Homeemple(
              cedula: usuario.cedula ?? '',
              nombre: usuario.nombre ?? '',
              apellido: usuario.apellido ?? '',
              telefono: usuario.telefono ?? '',
              correo: usuario.correo ?? '',
            ),
          ),
          (route) => false,
        );
      } else if (usuario.rol == 'Admin') {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => Homeadmin(
              cedula: usuario.cedula ?? '',
              nombre: usuario.nombre ?? '',
              apellido: usuario.apellido ?? '',
              telefono: usuario.telefono ?? '',
              correo: usuario.correo ?? '',
            ),
          ),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Rol no reconocido')));
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  void dispose() {
    correoController.dispose();
    contrasenaController.dispose();
    super.dispose();
  }

  void _irARecuperarContrasena() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Recuperapass()),
    );
  }

  void _irARegistro() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Registro()),
    );
  }

  void _alternarVisibilidadContrasena() {
    setState(() => ocultarContrasena = !ocultarContrasena);
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
                        title: 'Bienvenido',
                        subtitle: 'Inicia sesion en tu cuenta de megatech 2',
                      ),
                      const SizedBox(height: 28),

                      Leertexto(
                        label: 'Correo electronico',
                        controller: correoController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 18),

                      Leertexto(
                        label: 'Contraseña',
                        controller: contrasenaController,
                        obscureText: ocultarContrasena,
                        suffixIcon: IconButton(
                          onPressed: _alternarVisibilidadContrasena,
                          icon: Icon(
                            ocultarContrasena
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      Recorolvi(
                        value: recordarme,
                        onChanged: (value) =>
                            setState(() => recordarme = value),
                        onForgotPassword: _irARecuperarContrasena,
                      ),
                      const SizedBox(height: 8),

                      Botonaaccionprincipal(
                        text: 'Iniciar sesion',
                        onTap: iniciarSesion,
                      ),
                      const SizedBox(height: 25),

                      Notienesregister(
                        question: '¿No tienes cuenta?',
                        actionText: 'Registrate aqui',
                        onTap: _irARegistro,
                      ),
                      const SizedBox(height: 17),

                      const Datosprotejidos(),
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
