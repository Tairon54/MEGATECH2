import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fronted/colores/stilocolores.dart';
import 'package:fronted/components/login/fondo.dart';

class PantallaTerminosCondiciones extends StatelessWidget {
  const PantallaTerminosCondiciones({super.key});

  Widget _seccion({
    required IconData icono,
    required String titulo,
    required String contenido,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF293545),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.bordeTarjeta.withOpacity(0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icono, color: AppColors.cian, size: 23),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  titulo,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            contenido,
            textAlign: TextAlign.justify,
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 12,
              height: 1.65,
            ),
          ),
        ],
      ),
    );
  }

  Widget _contenidoTerminos() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        _seccion(
          icono: Icons.info_outline,
          titulo: '1. Aceptación de los términos',
          contenido:
              'Al registrarse y utilizar MEGATECH 2, el usuario '
              'declara que ha leído y acepta estos términos y condiciones. '
              'Si no está de acuerdo, debe abstenerse de utilizar la aplicación.',
        ),
        _seccion(
          icono: Icons.person_outline,
          titulo: '2. Registro de usuarios',
          contenido:
              'Para utilizar las funciones de MEGATECH 2, el usuario '
              'debe proporcionar información verdadera, completa y actualizada. '
              'Es responsable de mantener la confidencialidad de sus credenciales '
              'y del uso de su cuenta.',
        ),
        _seccion(
          icono: Icons.shopping_cart_outlined,
          titulo: '3. Productos y compras',
          contenido:
              'MEGATECH 2 permite consultar productos, precios, disponibilidad '
              'y realizar pedidos. Los precios y las existencias pueden cambiar. '
              'La disponibilidad de un producto estará sujeta a la confirmación '
              'del inventario.',
        ),
        _seccion(
          icono: Icons.payment_outlined,
          titulo: '4. Pagos y comprobantes',
          contenido:
              'El usuario debe proporcionar información correcta al realizar '
              'sus compras y enviar comprobantes de pago legítimos cuando '
              'corresponda. Los pagos estarán sujetos a los procesos de '
              'verificación establecidos por MEGATECH 2.',
        ),
        _seccion(
          icono: Icons.security_outlined,
          titulo: '5. Seguridad de la cuenta',
          contenido:
              'El usuario no debe compartir sus contraseñas ni permitir que '
              'terceras personas utilicen su cuenta de manera no autorizada. '
              'Cualquier actividad sospechosa debe ser comunicada al responsable '
              'de la aplicación.',
        ),
        _seccion(
          icono: Icons.block_outlined,
          titulo: '6. Uso adecuado',
          contenido:
              'Está prohibido utilizar la aplicación para actividades '
              'fraudulentas, introducir información falsa, afectar el '
              'funcionamiento del sistema o intentar acceder a funciones '
              'sin autorización.',
        ),
        _seccion(
          icono: Icons.update,
          titulo: '7. Modificaciones',
          contenido:
              'MEGATECH 2 podrá actualizar estos términos cuando sea necesario. '
              'Los cambios deberán ser comunicados a los usuarios mediante '
              'los medios disponibles en la aplicación.',
        ),
        _seccion(
          icono: Icons.gavel_outlined,
          titulo: '8. Legislación aplicable',
          contenido:
              'Estos términos se interpretarán de acuerdo con las normas '
              'vigentes en la República de Colombia.',
        ),
        const SizedBox(height: 10),
        _avisoFinal(),
      ],
    );
  }

  Widget _contenidoPrivacidad() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        _seccion(
          icono: Icons.privacy_tip_outlined,
          titulo: '1. Responsable del tratamiento',
          contenido:
              'Aplicación: MEGATECH 2.\n'
              'Responsable: Jhon Jaider Cerquera].\n'
              'Correo de contacto: tairondark15@gmail.com.\n'
              'Dirección: Centro, Agrado Huila.\n',
        ),
        _seccion(
          icono: Icons.badge_outlined,
          titulo: '2. Datos personales recopilados',
          contenido:
              'Durante el registro podemos solicitar los siguientes datos:\n\n'
              '• Número de cédula.\n'
              '• Nombres y apellidos.\n'
              '• Número de teléfono.\n'
              '• Correo electrónico.\n'
              '• Contraseña de acceso.\n\n'
              'También se pueden procesar datos relacionados con pedidos, '
              'compras y comprobantes de pago.',
        ),
        _seccion(
          icono: Icons.track_changes_outlined,
          titulo: '3. Finalidad del tratamiento',
          contenido:
              'Los datos se utilizan para crear y administrar cuentas, '
              'verificar la identidad mediante correo electrónico, gestionar '
              'pedidos y compras, verificar pagos, ofrecer atención al cliente '
              'y mantener la seguridad de la plataforma.',
        ),
        _seccion(
          icono: Icons.cloud_outlined,
          titulo: '4. Almacenamiento y proveedores',
          contenido:
              'MEGATECH 2 utiliza servicios tecnológicos para el funcionamiento '
              'de la aplicación, entre ellos Supabase para la gestión de datos, '
              'Brevo para el envío de correos electrónicos y Cloudinary para '
              'el almacenamiento de imágenes y comprobantes.\n\n'
              'El chatbot utiliza servicios de inteligencia artificial. '
              'No se deben introducir contraseñas, números de cédula u otros '
              'datos sensibles en sus conversaciones.',
        ),
        _seccion(
          icono: Icons.lock_outline,
          titulo: '5. Protección de la información',
          contenido:
              'Se deben aplicar medidas técnicas y administrativas para '
              'proteger la información contra accesos no autorizados, pérdida, '
              'alteración o divulgación. Las contraseñas de las cuentas se '
              'almacenan mediante un proceso de hash.',
        ),
        _seccion(
          icono: Icons.people_outline,
          titulo: '6. Derechos de los usuarios',
          contenido:
              'De acuerdo con la Ley 1581 de 2012, los titulares pueden solicitar '
              'conocer, actualizar y rectificar sus datos, conocer el uso que '
              'se les ha dado, solicitar prueba de su autorización y ejercer '
              'los demás derechos previstos en la legislación aplicable.',
        ),
        _seccion(
          icono: Icons.delete_outline,
          titulo: '7. Conservación y eliminación',
          contenido:
              'Los datos se conservarán durante el tiempo necesario para '
              'cumplir las finalidades informadas y las obligaciones legales '
              'aplicables. El usuario podrá solicitar la eliminación de su '
              'cuenta y de los datos asociados mediante el procedimiento '
              'oficial que debe habilitar el responsable.\n\n'
              '[COMPLETAR PLAZOS, EXCEPCIONES LEGALES Y PROCEDIMIENTO REAL '
              'DE ELIMINACIÓN ANTES DE PUBLICAR].',
        ),
        _seccion(
          icono: Icons.mail_outline,
          titulo: '8. Consultas y reclamaciones',
          contenido:
              'Para consultas, solicitudes de actualización, rectificación '
              'o supresión de datos personales, el usuario podrá comunicarse '
              'con el responsable a través de su correo oficial:\n'
              '[CORREO OFICIAL DEL RESPONSABLE].',
        ),
        _seccion(
          icono: Icons.verified_user_outlined,
          titulo: '9. Autorización',
          contenido:
              'Al aceptar esta política, el usuario manifiesta haber recibido '
              'información sobre el tratamiento de sus datos personales y '
              'autoriza su tratamiento para las finalidades aquí descritas, '
              'conforme a la legislación colombiana.',
        ),
        const SizedBox(height: 10),
        _avisoFinal(),
      ],
    );
  }

  Widget _avisoFinal() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.azulOscuro.withOpacity(0.25),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.verified_user, color: AppColors.cian, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'MEGATECH 2 promueve el uso responsable y la protección '
              'de la información personal de sus usuarios.',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 11,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.fondoOscuro3,
        body: Fondo(
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 12, 15, 15),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Información legal',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 45),
                    ],
                  ),
                ),
                const Icon(
                  Icons.gpp_good_outlined,
                  color: AppColors.cian,
                  size: 55,
                ),
                const SizedBox(height: 8),
                Text(
                  'MEGATECH 2',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 8,
                  ),
                  child: Text(
                    'Conoce las condiciones de uso y cómo protegemos '
                    'tu información personal.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 18),
                  decoration: BoxDecoration(
                    color: AppColors.fondoTarjeta,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.bordeTarjeta),
                  ),
                  child: TabBar(
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: BoxDecoration(
                      gradient: AppColors.gradienteBoton,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.white70,
                    labelStyle: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                    tabs: const [
                      Tab(text: 'Términos'),
                      Tab(text: 'Privacidad'),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: TabBarView(
                    children: [_contenidoTerminos(), _contenidoPrivacidad()],
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
