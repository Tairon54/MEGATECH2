import {
  crearVenta,
  crearDetalleVenta,
  obtenerProducto,
  actualizarStock,
  obtenerUsuarioporid,
  obtenerComprasPorCliente,
  obtenerUsuarioPorCedula,
  obtenerVentas,
  obtenerVentasPorVendedor,
  obtenerVentaPorId,
  obtenerDetallesVenta,
  eliminarDetallesVenta,
  eliminarVenta,
  obtenerReporteVentas,
} from "../model/ventas.js";

// registar una venta
export const registrarVenta = async (req, res) => {
  try {
    console.log("BODY RECIBIDO:", req.body);

    const { cedula_cliente, id_vendedor, productos } = req.body;

    // Validar datos
    if (
      !cedula_cliente ||
      !id_vendedor ||
      !productos ||
      productos.length === 0
    ) {
      return res.status(400).json({
        error: "Faltan datos para registrar la venta.",
      });
    }

    // Verificar cliente
    const { data: cliente, error: errorCliente } =
      await obtenerUsuarioPorCedula(cedula_cliente);

    if (errorCliente || !cliente) {
      return res.status(404).json({
        error: "Cliente no encontrado.",
      });
    }

    // Verificar vendedor
    const { data: vendedor, error: errorVendedor } =
      await obtenerUsuarioporid(id_vendedor);

    if (errorVendedor || !vendedor) {
      return res.status(404).json({
        error: "Vendedor no encontrado.",
      });
    }

    let total = 0;
    const detalles = [];

    // Revisar productos
    for (const item of productos) {
      const { data: producto, error } = await obtenerProducto(item.id_producto);

      if (error || !producto) {
        return res.status(404).json({
          error: `Producto ${item.id_producto} no encontrado.`,
        });
      }
      // AGREGAR
      if (producto.activo === false) {
        return res.status(400).json({
          error: `El producto "${producto.nombre}" ya no está disponible.`,
        });
      }

      if (producto.stock < item.cantidad) {
        return res.status(400).json({
          error: `Stock insuficiente para ${producto.nombre}`,
        });
      }

      const subtotal = Number(producto.precio) * Number(item.cantidad);

      total += subtotal;

      detalles.push({
        id_producto: producto.id,
        cantidad: item.cantidad,
        precio_unitario: producto.precio,
        subtotal,
      });
    }

    // Crear venta
    const { data: venta, error: errorVenta } = await crearVenta({
      fecha: new Date(Date.now() - 5 * 60 * 60 * 1000),
      total,
      id_cliente: cliente.id,
      id_vendedor,
    });

    if (errorVenta) {
      return res.status(500).json(errorVenta);
    }

    // Agregar id de venta a cada detalle
    const detalleFinal = detalles.map((detalle) => ({
      ...detalle,
      id_venta: venta.id,
    }));

    // Guardar detalles
    const { error: errorDetalle } = await crearDetalleVenta(detalleFinal);

    if (errorDetalle) {
      return res.status(500).json(errorDetalle);
    }

    // Actualizar stock
    for (const item of productos) {
      const { data: producto } = await obtenerProducto(item.id_producto);

      await actualizarStock(producto.id, producto.stock - item.cantidad);
    }

    const fechaFormateada = new Date(venta.fecha).toLocaleString("es-CO", {
      timeZone: "America/Bogota",
      year: "numeric",
      month: "2-digit",
      day: "2-digit",
      hour: "2-digit",
      minute: "2-digit",
      second: "2-digit",
      hour12: true,
    });

    res.status(201).json({
      mensaje: "Venta registrada correctamente.",
      venta: {
        ...venta,
        fecha: fechaFormateada,
      },
      detalles: detalleFinal,
    });
  } catch (error) {
    console.error(error);

    res.status(500).json({
      error: error.message,
    });
  }
};

export const comprasPorCliente = async (req, res) => {
  try {
    const { id_cliente } = req.params;

    const { data, error } = await obtenerComprasPorCliente(id_cliente);

    if (error) {
      return res.status(500).json({
        error: error.message,
      });
    }

    if (!data || data.length === 0) {
      return res.status(404).json({
        mensaje: "El cliente no tiene compras registradas.",
      });
    }

    res.status(200).json({
      id_cliente,
      compras: data,
    });
  } catch (error) {
    res.status(500).json({
      error: error.message,
    });
  }
};

export const comprasPorCedula = async (req, res) => {
  try {
    const { cedula } = req.params;

    // Buscar primero al usuario
    const { data: usuario, error: errorUsuario } =
      await obtenerUsuarioPorCedula(cedula);

    if (errorUsuario || !usuario) {
      return res.status(404).json({
        error: "No se encontró un usuario con esa cédula.",
      });
    }

    // Buscar sus compras
    const { data: compras, error: errorCompras } =
      await obtenerComprasPorCliente(usuario.id);

    if (errorCompras) {
      return res.status(500).json({
        error: errorCompras.message,
      });
    }

    res.status(200).json({
      cliente: {
        id: usuario.id,
        cedula: usuario.cedula,
        nombre: usuario.nombre,
        apellido: usuario.apellido,
      },
      compras: compras || [],
    });
  } catch (error) {
    res.status(500).json({
      error: error.message,
    });
  }
};

// ver todas las ventas
export const listarVentas = async (req, res) => {
  try {
    const { data, error } = await obtenerVentas();

    if (error) {
      return res.status(500).json({
        error: error.message,
      });
    }

    res.status(200).json({
      ventas: data,
    });
  } catch (error) {
    res.status(500).json({
      error: error.message,
    });
  }
};

// ver ventas de cada vendedor
export const ventasPorVendedor = async (req, res) => {
  try {
    const { id_vendedor } = req.params;

    const { data, error } = await obtenerVentasPorVendedor(id_vendedor);

    if (error) {
      return res.status(500).json({
        error: error.message,
      });
    }

    res.status(200).json({
      id_vendedor,
      ventas: data,
    });
  } catch (error) {
    res.status(500).json({
      error: error.message,
    });
  }
};

// ver ventas por id
export const ventaPorId = async (req, res) => {
  try {
    const { id } = req.params;

    const { data, error } = await obtenerVentaPorId(id);

    if (error || !data) {
      return res.status(404).json({
        error: "Venta no encontrada.",
      });
    }

    res.status(200).json(data);
  } catch (error) {
    res.status(500).json({
      error: error.message,
    });
  }
};

// Ver ventas de un vendedor por cédula
export const ventasPorCedula = async (req, res) => {
  try {
    const { cedula } = req.params;

    // Buscar usuario por cédula
    const { data: vendedor, error: errorVendedor } =
      await obtenerUsuarioPorCedula(cedula);

    if (errorVendedor || !vendedor) {
      return res.status(404).json({
        error: "No se encontró un usuario con esa cédula.",
      });
    }

    // Verificar que sea Admin o Empleado
    if (vendedor.rol !== "Admin" && vendedor.rol !== "Empleado") {
      return res.status(400).json({
        error: "El usuario no es un vendedor.",
      });
    }

    // Buscar las ventas del vendedor
    const { data: ventas, error: errorVentas } = await obtenerVentasPorVendedor(
      vendedor.id,
    );

    if (errorVentas) {
      return res.status(500).json({
        error: errorVentas.message,
      });
    }

    res.status(200).json({
      vendedor: {
        id: vendedor.id,
        cedula: vendedor.cedula,
        nombre: vendedor.nombre,
        apellido: vendedor.apellido,
        rol: vendedor.rol,
      },
      ventas: ventas || [],
    });
  } catch (error) {
    console.error(error);

    res.status(500).json({
      error: error.message,
    });
  }
};

// Eliminar una venta
export const borrarVenta = async (req, res) => {
  try {
    const { id } = req.params;

    // Buscar la venta
    const { data: venta, error: errorVenta } = await obtenerVentaPorId(id);

    if (errorVenta || !venta) {
      return res.status(404).json({
        error: "Venta no encontrada.",
      });
    }

    // Buscar los detalles de la venta
    const { data: detalles, error: errorDetalles } =
      await obtenerDetallesVenta(id);

    if (errorDetalles) {
      return res.status(500).json({
        error: errorDetalles.message,
      });
    }

    // Devolver el stock de cada producto
    for (const detalle of detalles) {
      const { data: producto, error: errorProducto } = await obtenerProducto(
        detalle.id_producto,
      );

      if (errorProducto || !producto) {
        return res.status(404).json({
          error: `No se encontró el producto ${detalle.id_producto}.`,
        });
      }

      const nuevoStock = Number(producto.stock) + Number(detalle.cantidad);

      const { error: errorStock } = await actualizarStock(
        producto.id,
        nuevoStock,
      );

      if (errorStock) {
        return res.status(500).json({
          error: errorStock.message,
        });
      }
    }

    // Eliminar detalles
    const { error: errorEliminarDetalles } = await eliminarDetallesVenta(id);

    if (errorEliminarDetalles) {
      return res.status(500).json({
        error: errorEliminarDetalles.message,
      });
    }

    // Eliminar venta
    const { error: errorEliminarVenta } = await eliminarVenta(id);

    if (errorEliminarVenta) {
      return res.status(500).json({
        error: errorEliminarVenta.message,
      });
    }

    res.status(200).json({
      mensaje: "Venta eliminada correctamente.",
      id_venta: id,
    });
  } catch (error) {
    console.error(error);

    res.status(500).json({
      error: error.message,
    });
  }
};

// Reporte de ventas
export const reporteVentas = async (req, res) => {
  try {
    const {
      periodo,
      fecha_inicio,
      fecha_fin,
      id_vendedor,
      id_categoria,
      id_subcategoria,
    } = req.query;

    let fechaInicio;
    let fechaFin;

    const ahora = new Date();

    // VENTAS DE HOY

    if (periodo === "hoy") {
      fechaInicio = new Date();
      fechaInicio.setHours(0, 0, 0, 0);

      fechaFin = new Date();
      fechaFin.setHours(23, 59, 59, 999);
    }

    // SEMANA ACTUAL
    else if (periodo === "semana") {
      fechaInicio = new Date();

      const dia = fechaInicio.getDay();

      const diferencia = dia === 0 ? 6 : dia - 1;

      fechaInicio.setDate(fechaInicio.getDate() - diferencia);

      fechaInicio.setHours(0, 0, 0, 0);

      fechaFin = new Date();
      fechaFin.setHours(23, 59, 59, 999);
    }

    // MES ACTUAL
    else if (periodo === "mes") {
      fechaInicio = new Date(ahora.getFullYear(), ahora.getMonth(), 1);

      fechaInicio.setHours(0, 0, 0, 0);

      fechaFin = new Date(ahora.getFullYear(), ahora.getMonth() + 1, 0);

      fechaFin.setHours(23, 59, 59, 999);
    }

    // FECHAS PERSONALIZADAS
    else if (fecha_inicio && fecha_fin) {
      fechaInicio = new Date(fecha_inicio);
      fechaInicio.setHours(0, 0, 0, 0);

      fechaFin = new Date(fecha_fin);
      fechaFin.setHours(23, 59, 59, 999);
    } else {
      return res.status(400).json({
        error: "Debe indicar un periodo o un rango de fechas.",
      });
    }

    // CONSULTAR VENTAS

    const { data, error } = await obtenerReporteVentas(
      fechaInicio.toISOString(),
      fechaFin.toISOString(),
    );

    if (error) {
      return res.status(500).json({
        error: error.message,
      });
    }

    let ventas = data || [];

    // FILTRO POR VENDEDOR

    if (id_vendedor) {
      ventas = ventas.filter(
        (venta) => String(venta.id_vendedor) === String(id_vendedor),
      );
    }

    // FILTRO POR CATEGORÍA

    if (id_categoria) {
      ventas = ventas
        .map((venta) => {
          const detallesFiltrados = venta.detalle_venta.filter(
            (detalle) =>
              String(detalle.productos?.subcategorias?.categorias?.id) ===
              String(id_categoria),
          );

          return {
            ...venta,
            detalle_venta: detallesFiltrados,
          };
        })
        .filter((venta) => venta.detalle_venta.length > 0);
    }

    // FILTRO POR SUBCATEGORÍA

    if (id_subcategoria) {
      ventas = ventas
        .map((venta) => {
          const detallesFiltrados = venta.detalle_venta.filter(
            (detalle) =>
              String(detalle.productos?.subcategorias?.id) ===
              String(id_subcategoria),
          );

          return {
            ...venta,
            detalle_venta: detallesFiltrados,
          };
        })
        .filter((venta) => venta.detalle_venta.length > 0);
    }

    // CALCULAR RESUMEN

    let totalVentas = 0;
    let totalUnidades = 0;
    let totalDetalles = 0;

    ventas.forEach((venta) => {
      venta.detalle_venta.forEach((detalle) => {
        totalUnidades += Number(detalle.cantidad);

        totalDetalles++;
      });

      // Si no hay filtros de categoría/subcategoría
      // usamos el total de la venta

      if (!id_categoria && !id_subcategoria) {
        totalVentas += Number(venta.total);
      } else {
        venta.detalle_venta.forEach((detalle) => {
          totalVentas += Number(detalle.subtotal);
        });
      }
    });

    // RESPUESTA

    res.status(200).json({
      periodo: periodo || "personalizado",

      fecha_inicio: fechaInicio,

      fecha_fin: fechaFin,

      resumen: {
        cantidad_ventas: ventas.length,

        cantidad_detalles: totalDetalles,

        unidades_vendidas: totalUnidades,

        total_vendido: totalVentas,
      },

      ventas,
    });
  } catch (error) {
    console.error(error);

    res.status(500).json({
      error: error.message,
    });
  }
};
