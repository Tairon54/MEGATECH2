import 'package:flutter/material.dart';
import 'package:fronted/colores/stilocolores.dart';
import 'package:fronted/components/login/fondo.dart';
import 'package:fronted/paginas/admin/widets.dart/barranavega.dart';
import 'package:fronted/paginas/admin/widets.dart/targetas.dart';
import 'package:fronted/paginas/admin/widets.dart/targetasesta.dart';
import 'package:fronted/service/desboard.dart';
import 'package:google_fonts/google_fonts.dart';

// ESTRUCTURA COMPARTIDA DEL HOME (admin y empleado)

/// Abre una pantalla encima de la actual.
void irA(BuildContext context, Widget pagina) =>
    Navigator.push(context, MaterialPageRoute(builder: (_) => pagina));

/// Una tarjeta del home: título, descripción, texto del botón y la pantalla
/// a la que lleva.
class OpcionHome {
  final String titulo;
  final String descripcion;
  final String textoBoton;
  final Widget pagina;

  const OpcionHome(this.titulo, this.descripcion, this.textoBoton, this.pagina);
}

/// Home con fondo, "Megatech 2", saludo, las dos estadísticas del dashboard
/// (pedidos por entregar y bajo stock), las [opciones] en filas de dos y la
/// barra inferior con [botones].
class PantallaHome extends StatefulWidget {
  final String nombre;
  final List<OpcionHome> opciones;
  final List<BotonNav> botones;

  const PantallaHome({
    super.key,
    required this.nombre,
    required this.opciones,
    required this.botones,
  });

  @override
  State<PantallaHome> createState() => _PantallaHomeState();
}

class _PantallaHomeState extends State<PantallaHome> {
  final _servicio = DashboardService();

  // null = todavía cargando
  int? _pedidos;
  int? _bajoStock;

  @override
  void initState() {
    super.initState();
    _cargar(_servicio.obtenerPedidosPorEntregar, (v) => _pedidos = v);
    _cargar(_servicio.obtenerProductosBajoStock, (v) => _bajoStock = v);
  }

  /// Consulta un total; si falla muestra 0 en vez de quedarse en "...".
  Future<void> _cargar(Future<int> Function() consulta, void Function(int) guardar) async {
    var total = 0;
    try {
      total = await consulta();
    } catch (_) {}
    if (mounted) setState(() => guardar(total));
  }

  TextStyle _estilo(Color color) => GoogleFonts.poppins(
        color: color,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      );

  Widget _estadistica(int? valor, String etiqueta, Color color) =>
      Tarjetaestadistica(
        valor: valor?.toString() ?? '...',
        etiqueta: etiqueta,
        colorValor: color,
        colorBorde: AppColors.bordeTarjeta,
      );

  Widget _tarjeta(OpcionHome o) => Targetas(
        titulo: o.titulo,
        descripcion: o.descripcion,
        colorTitulo: AppColors.azulClaro,
        colorBorde: AppColors.bordeTarjeta,
        textoBoton: o.textoBoton,
        onPressed: () => irA(context, o.pagina),
      );

  /// Dos tarjetas de la misma altura; si [b] es null, [a] ocupa todo el ancho.
  Widget _fila(Widget a, [Widget? b]) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: b == null
            ? a
            : IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: a),
                    const SizedBox(width: 10),
                    Expanded(child: b),
                  ],
                ),
              ),
      );

  @override
  Widget build(BuildContext context) {
    final o = widget.opciones;

    return Scaffold(
      bottomNavigationBar: Barranavegacioninferior(botones: widget.botones),
      body: Fondo(
        child: RefreshIndicator(
        onRefresh: () async {
          setState(() {});

          // Espera un momento para mostrar el efecto de recarga.
          await Future.delayed(const Duration(milliseconds: 500));
        },
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 20),
                    child: Text('Megatech 2', style: _estilo(Colors.white)),
                  ),
                  const Divider(color: Colors.white, thickness: 1, height: 20),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Hola, ${widget.nombre}',
                            style: _estilo(const Color(0xFF1BC2F0)),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _fila(
                          _estadistica(_pedidos, 'Pedidos por entregar', const Color(0xFF1BC2F0)),
                          _estadistica(_bajoStock, 'Productos en bajo stock', const Color(0xFFEC0404)),
                        ),
                        for (var i = 0; i < o.length; i += 2)
                          _fila(_tarjeta(o[i]), i + 1 < o.length ? _tarjeta(o[i + 1]) : null),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}