import 'package:flutter/material.dart';
import 'package:fronted/colores/stilocolores.dart';
import 'package:fronted/paginas/cliente/acsesorios/auriculares.dart';
import 'package:fronted/paginas/cliente/acsesorios/cabezotes_tc.dart';
import 'package:fronted/paginas/cliente/acsesorios/cabezotes_usb.dart';
import 'package:fronted/paginas/cliente/acsesorios/cablesusbtc.dart';
import 'package:fronted/paginas/cliente/acsesorios/cablesusbv8.dart';
import 'package:fronted/paginas/cliente/acsesorios/cargadores_tc.dart';
import 'package:fronted/paginas/cliente/acsesorios/cargadores_v8.dart';
import 'package:fronted/paginas/cliente/acsesorios/forros.dart';
import 'package:fronted/paginas/cliente/acsesorios/vidrios.dart';
import 'package:fronted/paginas/cliente/celulares/celulares_redmi.dart';
import 'package:fronted/paginas/cliente/celulares/infinix.dart';
import 'package:fronted/paginas/cliente/celulares/sansumg.dart';
import 'package:fronted/paginas/cliente/celulares/tecno.dart';
import 'package:fronted/paginas/cliente/celulares/zte.dart';
import 'package:fronted/paginas/cliente/electrodomesticos/Licuadoras.dart';
import 'package:fronted/paginas/cliente/electrodomesticos/arrozeras.dart';
import 'package:fronted/paginas/cliente/electrodomesticos/cafeteras.dart';
import 'package:fronted/paginas/cliente/electrodomesticos/freidoras.dart';
import 'package:fronted/paginas/cliente/electrodomesticos/ollaspresion.dart';
import 'package:fronted/paginas/cliente/electrodomesticos/planchas.dart';
import 'package:fronted/paginas/cliente/electrodomesticos/sanduicheras.dart';
import 'package:fronted/paginas/cliente/otros/bolsos.dart';
import 'package:fronted/paginas/cliente/otros/equiposdesonido.dart';
import 'package:fronted/paginas/cliente/otros/memorias_sd.dart';
import 'package:fronted/paginas/cliente/otros/memorias_usb.dart';
import 'package:fronted/paginas/cliente/otros/mouse.dart';
import 'package:fronted/paginas/cliente/otros/sim.dart';
import 'package:google_fonts/google_fonts.dart';

class Menu extends StatelessWidget {
  const Menu({super.key});

  // Colores por categoría (todos salen de tu paleta azul)
  static const Color _colorCelulares = AppColors.azulClaro;
  static const Color _colorAccesorios = AppColors.azulEnlace;
  static const Color _colorElectro = Color(0xFF4DD0E1); // cian suave
  static const Color _colorOtros = Color(0xFF90CAF9); // azul pastel

  void _ir(BuildContext context, Widget pantalla) {
    // 1. Cierra el menú primero
    Navigator.pop(context);

    // 2. Si estamos en el Home (no hay nada debajo), SE AGREGA encima.
    //    Si ya estamos en una pantalla de productos, se REEMPLAZA
    //    para que la pila no crezca con cada categoría.
    final navigator = Navigator.of(context);
    final route = MaterialPageRoute<void>(builder: (_) => pantalla);

    if (navigator.canPop()) {
      navigator.pushReplacement(route);
    } else {
      navigator.push(route);
    }
  }

  // Encabezado de cada sección
  Widget _seccion(String titulo, IconData icono, Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 6),
      child: Row(
        children: [
          Icon(icono, color: color, size: 18),
          const SizedBox(width: 8),
          Text(
            titulo.toUpperCase(),
            style: GoogleFonts.poppins(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Divider(color: color.withOpacity(0.35), height: 1)),
        ],
      ),
    );
  }

  // Cada opción del menú
  Widget _item(
    BuildContext context,
    IconData icono,
    String texto,
    Widget pantalla,
    Color color,
  ) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icono, color: color, size: 20),
      ),
      title: Text(
        texto,
        style: GoogleFonts.poppins(
          color: AppColors.textoPrincipal,
          fontSize: 14,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: Colors.white30,
        size: 20,
      ),
      onTap: () => _ir(context, pantalla),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.fondoOscuro2,
      child: Column(
        children: [
          // ── Cabecera ──
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
              20,
              MediaQuery.of(context).padding.top + 24,
              20,
              24,
            ),
            decoration: const BoxDecoration(gradient: AppColors.gradienteBoton),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.storefront,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Megatech 2',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Tecnología para ti',
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Opciones ──
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 20),
              children: [
                // Inicio destacado
                Container(
                  margin: const EdgeInsets.fromLTRB(14, 14, 14, 0),
                  decoration: BoxDecoration(
                    gradient: AppColors.gradienteBoton,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Icons.home_rounded,
                      color: Colors.white,
                    ),
                    title: Text(
                      'Inicio',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    // Vuelve al home sin perder la sesión
                    onTap: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                  ),
                ),

                // Celulares
                _seccion('Celulares', Icons.smartphone, _colorCelulares),
                _item(
                  context,
                  Icons.phone_android,
                  'Redmi',
                  const Celularesredmi(),
                  _colorCelulares,
                ),
                _item(
                  context,
                  Icons.smartphone,
                  'Samsung',
                  const Sansumg(),
                  _colorCelulares,
                ),
                _item(
                  context,
                  Icons.stay_current_portrait,
                  'Tecno',
                  const Tecno(),
                  _colorCelulares,
                ),
                _item(
                  context,
                  Icons.tablet_android,
                  'Infinix',
                  const Infinix(),
                  _colorCelulares,
                ),
                _item(
                  context,
                  Icons.settings_cell,
                  'ZTE',
                  const Zte(),
                  _colorCelulares,
                ),

                // Accesorios
                _seccion('Accesorios', Icons.bolt, _colorAccesorios),
                _item(
                  context,
                  Icons.headphones,
                  'Auriculares',
                  const Auriculares(),
                  _colorAccesorios,
                ),
                _item(
                  context,
                  Icons.power,
                  'Cabezotes USB',
                  const CabezotesUsb(),
                  _colorAccesorios,
                ),
                _item(
                  context,
                  Icons.electrical_services,
                  'Cabezotes TC',
                  const CabezotesTc(),
                  _colorAccesorios,
                ),
                _item(
                  context,
                  Icons.cable,
                  'Cables USB TC',
                  const CablesUsbTc(),
                  _colorAccesorios,
                ),
                _item(
                  context,
                  Icons.cable,
                  'Cables USB V8',
                  const CablesUsbV8(),
                  _colorAccesorios,
                ),
                _item(
                  context,
                  Icons.bolt,
                  'Cargadores TC',
                  const CargadoresTc(),
                  _colorAccesorios,
                ),
                _item(
                  context,
                  Icons.battery_charging_full,
                  'Cargadores V8',
                  const CargadoresV8(),
                  _colorAccesorios,
                ),
                _item(
                  context,
                  Icons.shield,
                  'Forros',
                  const Forros(),
                  _colorAccesorios,
                ),
                _item(
                  context,
                  Icons.screen_lock_portrait,
                  'Vidrios',
                  const Vidrios(),
                  _colorAccesorios,
                ),

                // Electrodomésticos
                _seccion('Electrodomésticos', Icons.kitchen, _colorElectro),
                _item(
                  context,
                  Icons.rice_bowl,
                  'Arroceras',
                  const Arrozeras(),
                  _colorElectro,
                ),
                _item(
                  context,
                  Icons.coffee_maker,
                  'Cafeteras',
                  const Cafeteras(),
                  _colorElectro,
                ),
                _item(
                  context,
                  Icons.air,
                  'Freidoras de aire',
                  const Freidoras(),
                  _colorElectro,
                ),
                _item(
                  context,
                  Icons.blender,
                  'Licuadoras',
                  const Licuadoras(),
                  _colorElectro,
                ),
                _item(
                  context,
                  Icons.soup_kitchen,
                  'Ollas a presión',
                  const Ollaspresion(),
                  _colorElectro,
                ),
                _item(
                  context,
                  Icons.iron,
                  'Planchas',
                  const Planchas(),
                  _colorElectro,
                ),
                _item(
                  context,
                  Icons.lunch_dining,
                  'sandwichera',
                  const Sanduicheras(),
                  _colorElectro,
                ),

                // Otros
                _seccion('Otros', Icons.category, _colorOtros),
                _item(
                  context,
                  Icons.shopping_bag,
                  'Bolsos',
                  const Bolsos(),
                  _colorOtros,
                ),
                _item(
                  context,
                  Icons.speaker,
                  'Equipos de sonido',
                  const EquiposDeSonido(),
                  _colorOtros,
                ),
                _item(
                  context,
                  Icons.usb,
                  'Memorias USB',
                  const MemoriasUsb(),
                  _colorOtros,
                ),
                _item(
                  context,
                  Icons.sd_card,
                  'Memorias SD',
                  const MemoriasSd(),
                  _colorOtros,
                ),
                _item(
                  context,
                  Icons.mouse,
                  'Mouse',
                  const Mouse(),
                  _colorOtros,
                ),
                _item(context, Icons.sim_card, 'Sim', const Sim(), _colorOtros),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
