import 'package:flutter/material.dart';
import 'package:fronted/colores/stilocolores.dart';
import 'package:fronted/components/login/fondo.dart';
import 'package:fronted/model/productos.dart';
import 'package:fronted/paginas/admin/widets.dart/targetaproducto.dart';
import 'package:fronted/paginas/cliente/components/menu.dart';
import 'package:fronted/paginas/cliente/components/targetasproductos.dart';
import 'package:fronted/service/productoservice.dart';
import 'package:google_fonts/google_fonts.dart';

/// Pantalla reutilizable que lista los productos de UNA subcategoría.
/// Sirve para cliente y para personal: según el rol del usuario que inició
/// sesión muestra la tarjeta de cliente (foto, nombre, descripción, precio)
/// o la de admin (con ID y stock, y también los productos agotados).
class PantallaProductos extends StatefulWidget {
  /// Texto que se ve como título de la pantalla.
  final String titulo;

  /// Nombre de la subcategoría en la base de datos (tabla "subcategorias").
  final String subcategoria;

  /// Descripción elegante que se ve bajo el título. Si no se pasa, se usa la
  /// de [_descripciones] según la subcategoría (así no hay que tocar las
  /// 23 pantallas pequeñas).
  final String? descripcion;

  const PantallaProductos({
    super.key,
    required this.titulo,
    required this.subcategoria,
    this.descripcion,
  });

  @override
  State<PantallaProductos> createState() => _PantallaProductosState();
}

/// Texto de presentación de cada subcategoría. La clave es EXACTAMENTE el
/// mismo texto que se manda en `subcategoria:` de cada pantalla.
const Map<String, String> _descripciones = {
  // Celulares
  'Redmi':
      'Rendimiento y diseño moderno a un precio que sorprende. '
      'Celulares pensados para acompañarte todos los días.',
  'Infinix':
      'Pantallas amplias y baterías de larga duración para quienes '
      'no quieren desconectarse.',
  'Samsung':
      'Calidad reconocida, pantallas brillantes y cámaras que '
      'capturan cada momento con detalle.',
  'Tecno':
      'Estilo y tecnología al alcance de todos, con cámaras y batería '
      'listas para el uso diario.',
  'ZTE':
      'Equipos prácticos y confiables para mantenerte siempre '
      'comunicado.',
  // Accesorios
  'Cabezotes TC':
      'Cabezotes con entrada tipo C para cargar tu equipo de '
      'forma segura y eficiente.',
  'Cabezotes USB':
      'Cabezotes con entrada USB, ideales para cargar en casa, '
      'en el trabajo o de viaje.',
  'Cables USB TC':
      'Cables con conector tipo C para cargar y transferir datos '
      'sin complicaciones.',
  'Cables USB V8':
      'Cables con conector V8 resistentes, ideales para cargar y '
      'transferir datos.',
  'Cargadores TC':
      'Cargadores completos con conector tipo C, listos para '
      'usar desde el primer momento.',
  'Cargadores V8':
      'Cargadores completos con conector V8 para los equipos '
      'que siguen dando guerra.',
  'Forros':
      'Protege tu celular sin perder estilo: forros para cada gusto '
      'y cada modelo.',
  'Vidrios':
      'Vidrios protectores que cuidan tu pantalla de golpes y '
      'rayones.',
  'Auriculares':
      'Sonido nítido y comodidad para tu música, tus llamadas y '
      'tus videos, estés donde estés.',
  // Electrodomésticos
  'Arrozeras':
      'El arroz perfecto sin estar pendiente de la estufa, '
      'siempre en su punto.',
  'Cafeteras':
      'Un buen café cada mañana, preparado con facilidad en la '
      'comodidad de tu hogar.',
  'Freidoras de aire':
      'Cocina con menos aceite y más sabor: rápida, '
      'práctica y fácil de limpiar.',
  'Licuadoras':
      'Jugos, batidos y salsas en segundos con la potencia que '
      'tu cocina necesita.',
  'Ollas a presión':
      'Prepara tus comidas en menos tiempo y conserva todo '
      'su sabor.',
  'Planchas':
      'Ropa impecable con menos esfuerzo: planchas para dejar cada '
      'prenda lista.',
  'Sandwichera':
      'Desayunos y meriendas calientes y crocantes en pocos '
      'minutos.',
  // Otros
  'Bolsos':
      'Practicidad y buen gusto para llevar todo lo que necesitas '
      'contigo.',
  'Equipos de sonido':
      'Potencia y calidad de audio para llenar de música tu casa, '
      'tus reuniones y tus fiestas.',
  'Mouse':
      'Mouse cómodos y precisos para trabajar, estudiar o jugar '
      'con total control.',
  'Memorias SD':
      'Más espacio para tus fotos, videos y archivos, siempre a '
      'la mano.',
  'Memorias USB':
      'Lleva y respalda tu información de forma sencilla y '
      'segura.',
  'Sim': 'Mantente conectado con la línea que mejor se adapte a ti.',
};

class _PantallaProductosState extends State<PantallaProductos> {
  final ProductosService _service = ProductosService();
  late Future<_Resultado> _futuro;

  @override
  void initState() {
    super.initState();
    _futuro = _cargar();
  }

  /// Primero averigua el rol y luego pide los productos: el cliente solo ve
  /// los que tienen stock; admin y empleado ven todos.
  Future<_Resultado> _cargar() async {
    final rol = await _service.rolActual();
    final esPersonal = rol == 'Admin' || rol == 'Empleado';
    // Sin token válido (invitado) rol es null: no puede usar el carrito.
    final sesionIniciada = rol != null;
    final productos = await _service.obtenerPorSubcategoria(
      widget.subcategoria,
      soloDisponibles: !esPersonal,
    );
    return _Resultado(productos, esPersonal, sesionIniciada);
  }

  Future<void> _recargar() async {
    setState(() {
      _futuro = _cargar();
    });
    await _futuro.catchError((_) => const _Resultado([], false, false));
  }

  /// Descripción elegante bajo el título, con una línea fina de adorno.
  Widget _descripcion() {
    final texto = widget.descripcion ?? _descripciones[widget.subcategoria];
    if (texto == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          // Línea fina con degradado: da un toque de elegancia
          Container(
            width: 60,
            height: 2,
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              gradient: AppColors.gradienteBoton,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(
            texto,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 13,
              height: 1.5,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  /// Aviso que le indica al usuario que el resto de productos está en el
  /// menú de las tres líneas. Al tocarlo abre el menú.
  Widget _avisoMenu() {
    return Builder(
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () => Scaffold.of(context).openDrawer(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: const Color(0xFF1BC2F0).withOpacity(0.5),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.menu_rounded,
                  color: Color(0xFF1BC2F0),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Más productos',
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const Menu(),
      body: Fondo(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: kToolbarHeight),
              Text(
                'Megatech 2',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.titulo,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: const Color(0xFF1BC2F0),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _descripcion(),
              const SizedBox(height: 12),
              _avisoMenu(),
              const SizedBox(height: 12),
              Expanded(
                child: FutureBuilder<_Resultado>(
                  future: _futuro,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.azulClaro,
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return _mensaje(
                        icono: Icons.wifi_off_rounded,
                        texto: 'No se pudieron cargar los productos',
                        conBoton: true,
                      );
                    }

                    final resultado = snapshot.data!;
                    final productos = resultado.productos;
                    if (productos.isEmpty) {
                      return _mensaje(
                        icono: Icons.inventory_2_outlined,
                        texto: 'Por ahora no hay productos en ${widget.titulo}',
                      );
                    }

                    return RefreshIndicator(
                      color: AppColors.azulClaro,
                      onRefresh: _recargar,
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                        itemCount: productos.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (context, i) => resultado.esPersonal
                            ? TarjetaProductoAdmin(producto: productos[i])
                            : TarjetaProductoCliente(
                                producto: productos[i],
                                mostrarCarrito: resultado.sesionIniciada,
                              ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mensaje({
    required IconData icono,
    required String texto,
    bool conBoton = false,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, color: Colors.white54, size: 56),
            const SizedBox(height: 12),
            Text(
              texto,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 15),
            ),
            if (conBoton) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _recargar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3FA9F5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  'Reintentar',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Productos ya filtrados + si quien mira es personal (admin/empleado)
/// + si hay una sesión iniciada.
class _Resultado {
  final List<Producto> productos;
  final bool esPersonal;
  final bool sesionIniciada;

  const _Resultado(this.productos, this.esPersonal, this.sesionIniciada);
}
