import {
  obtenerPedidos,
  obtenerPedidoPorId,
  crearPedido,
  actualizarPedido,
  eliminarPedido,
  obtenerPedidosConDetallePorCedula,
  contarPedidosPorEntregar,
  obtenerPedidosConDetalle,
  obtenerClientesPorIds,
} from "../model/pedidos.js";
import { porid as UserModel } from "../model/usuarios.js";
import { crearDetalle } from "../model/detalle_pedido.js";
import { actualizarStock } from "../model/productos.js";
import { enviarconfirmacionpedido } from "../utils/sendemail.js";
import { supabase } from "../config/supabase.js";

// Formatear fecha y hora de Bogotá
const formatearFechaBogota = (fecha) => {
  return new Date(`${fecha}Z`).toLocaleString("es-CO", {
    timeZone: "America/Bogota",
    day: "2-digit",
    month: "2-digit",
    year: "numeric",
    hour: "2-digit",
    minute: "2-digit",
    hour12: true,
  });
};

export const obtener = async (req, res) => {
  const { data, error } = await obtenerPedidos();

  if (error) {
    return res.status(500).json(error);
  }

  const pedidosFormateados = data.map((pedido) => ({
    ...pedido,
    fecha_formateada: formatearFechaBogota(pedido.fecha),
  }));

  res.json(pedidosFormateados);
};

export const obtenerPorId = async (req, res) => {
  const { id } = req.params;

  const { data, error } = await obtenerPedidoPorId(id);

  if (error) {
    return res.status(404).json(error);
  }

  const pedidoFormateado = {
    ...data,
    fecha_formateada: formatearFechaBogota(data.fecha),
  };

  res.json(pedidoFormateado);
};

export const crear = async (req, res) => {
  const { id_cliente, productos } = req.body;

  // VALIDAR CLIENTE
  if (!id_cliente) {
    return res.status(400).json({ mensaje: "Debe enviar el id del cliente" });
  }

  const { data: cliente, error: errorCliente } = await supabase
    .from("usuarios")
    .select("id")
    .eq("id", id_cliente)
    .single();

  if (errorCliente || !cliente) {
    return res.status(404).json({ mensaje: "El cliente no existe" });
  }

  // VALIDAR PRODUCTOS
  if (!Array.isArray(productos) || productos.length === 0) {
    return res.status(400).json({ mensaje: "Debe enviar productos" });
  }

  // Validar cada producto y tomar el precio real de la base de datos
  let totalCalculado = 0;
  const detalles = [];

  for (const item of productos) {
    const cantidad = Number(item.cantidad);

    if (!Number.isInteger(cantidad) || cantidad <= 0) {
      return res.status(400).json({
        mensaje: `La cantidad del producto ${item.id_producto} debe ser un número entero mayor que 0`,
      });
    }

    const { data: productoActual, error } = await supabase
      .from("productos")
      .select("id, nombre, precio, stock, activo")
      .eq("id", item.id_producto)
      .single();

    if (productoActual.activo === false) {
      return res.status(400).json({
        mensaje: `El producto "${productoActual.nombre}" ya no está disponible`,
      });
    }

    if (productoActual.stock < cantidad) {
      return res.status(400).json({
        mensaje: `No hay suficiente stock para ${productoActual.nombre}`,
        stockDisponible: productoActual.stock,
        cantidadSolicitada: cantidad,
      });
    }

    const precio = Number(productoActual.precio);
    const subtotal = precio * cantidad;
    totalCalculado += subtotal;

    detalles.push({
      id_producto: productoActual.id,
      cantidad,
      precio_unitario: precio,
      subtotal,
      _stockActual: productoActual.stock, // solo para descontar después
    });
  }

  // Crear pedido
  const { data: pedido, error } = await crearPedido({
    fecha: new Date(),
    estado: "Por pagar",
    total: totalCalculado,
    id_cliente,
  });

  if (error) {
    return res.status(500).json(error);
  }

  const idPedido = pedido[0].id;

  // Crear detalle (sin el campo auxiliar _stockActual)
  const { data: detalle, error: errorDetalle } = await crearDetalle(
    detalles.map(({ _stockActual, ...d }) => ({ id_pedido: idPedido, ...d })),
  );

  if (errorDetalle) {
    return res.status(500).json({
      mensaje: "No se pudo crear el detalle del pedido",
      error: errorDetalle,
    });
  }

  // Descontar stock
  for (const d of detalles) {
    await actualizarStock(d.id_producto, d._stockActual - d.cantidad);
  }

  res.status(201).json({
    mensaje: "Pedido y detalle creados correctamente",
    pedido: {
      ...pedido[0],
      fecha_formateada: formatearFechaBogota(pedido[0].fecha),
    },
    detalle,
  });
};

// Actualizar
export const actualizar = async (req, res) => {
  try {
    const { id } = req.params;
    const { estado } = req.body;

    // ==========================================
    // VALIDAR ESTADO
    // ==========================================

    const estadosValidos = ["Por pagar", "Por entregar", "Entregado", "Cancelado"];

    if (!estado) {
      return res.status(400).json({
        mensaje: "Debe enviar el estado",
      });
    }

    if (!estadosValidos.includes(estado)) {
      return res.status(400).json({
        mensaje: "Estado no válido",
        estadosPermitidos: estadosValidos,
      });
    }

    // ==========================================
    // BUSCAR EL PEDIDO
    // ==========================================

    const { data: pedidoActual, error: errorPedido } =
      await obtenerPedidoPorId(id);

    if (errorPedido || !pedidoActual) {
      return res.status(404).json({
        mensaje: "El pedido no existe",
      });
    }
    // ESTADO ACTUAL

    const estadoActual = pedidoActual.estado;

    // ==========================================
    // VALIDAR FLUJO
    // ==========================================

    if (
  estadoActual === "Por pagar" &&
  estado !== "Por entregar" &&
  estado !== "Cancelado"
) {
  return res.status(400).json({
    mensaje: "Un pedido Por pagar solo puede pasar a Por entregar o Cancelado",
  });
}

    if (estadoActual === "Por entregar" && estado !== "Entregado") {
      return res.status(400).json({
        mensaje: "Un pedido Por entregar solamente puede pasar a Entregado",
      });
    }

    if (estadoActual === "Cancelado") {
  return res.status(400).json({
    mensaje: "Un pedido Cancelado no puede cambiar de estado",
  });
}

    if (estadoActual === "Entregado") {
      return res.status(400).json({
        mensaje: "Un pedido Entregado no puede cambiar de estado",
      });
    }

    // ==========================================
// CANCELAR: devolver los productos al stock
// ==========================================
if (estado === "Cancelado") {
  // Solo cambia si sigue "Por pagar" (evita devolver el stock dos veces)
  const { data: cancelado, error: errorCancelar } = await supabase
    .from("pedidos")
    .update({ estado: "Cancelado" })
    .eq("id", id)
    .eq("estado", "Por pagar")
    .select();

  if (errorCancelar || !cancelado || cancelado.length === 0) {
    return res.status(400).json({
      mensaje: "Solo se puede cancelar un pedido que siga Por pagar",
    });
  }

  const { data: detalle } = await supabase
    .from("detalle_pedido")
    .select("id_producto, cantidad")
    .eq("id_pedido", id);

  for (const d of detalle || []) {
    const { data: producto } = await supabase
      .from("productos")
      .select("stock")
      .eq("id", d.id_producto)
      .single();

    if (producto) {
      await actualizarStock(d.id_producto, producto.stock + d.cantidad);
    }
  }

  return res.status(200).json({
    mensaje: "Pedido cancelado y stock devuelto",
    pedido: cancelado,
  });
}

    // ==========================================
    // ACTUALIZAR ESTADO
    // ==========================================

    const { data, error } = await actualizarPedido(id, { estado: estado });

    if (error) {
      return res.status(500).json({
        mensaje: "Error al actualizar el pedido",
        error,
      });
    }

    // ==========================================
    // ENVIAR CORREO
    // ==========================================

    if (estado === "Por entregar") {
      const idCliente = pedidoActual.id_cliente;

      // Buscar cliente

      const { data: cliente, error: errorCliente } = await UserModel(idCliente);

      if (errorCliente || !cliente) {
        return res.status(404).json({
          mensaje: "El pedido se actualizó, pero no se encontró el cliente",
        });
      }

      // Enviar correo

      const resultadoCorreo = await enviarconfirmacionpedido(
        cliente.correo,
        cliente.nombre,
        id,
        pedidoActual.total,
      );

      if (!resultadoCorreo.success) {
        return res.status(500).json({
          mensaje: "El pedido se actualizó, pero no se pudo enviar el correo",
          error: resultadoCorreo.error,
        });
      }
    }

    // ==========================================
    // RESPUESTA
    // ==========================================

    return res.status(200).json({
      mensaje: "Pedido actualizado correctamente",

      pedido: data,
    });
  } catch (error) {
    return res.status(500).json({
      mensaje: "Error interno del servidor",

      error: error.message,
    });
  }
};

// Eliminar
export const eliminar = async (req, res) => {
  const { id } = req.params;

  const { error } = await eliminarPedido(id);

  if (error) {
    return res.status(500).json(error);
  }

  res.json({
    mensaje: "Pedido eliminado correctamente",
  });
};

export const pedidosPorCedula = async (req, res) => {
  try {
    const { cedula } = req.params;

    if (!cedula) {
      return res.status(400).json({
        mensaje: "Debe enviar la cédula",
      });
    }

    const { data, error } = await obtenerPedidosConDetallePorCedula(cedula);

    if (error) {
      return res.status(500).json({
        mensaje: "Error al buscar los pedidos",
        error: error.message,
      });
    }

    // Mismo formato que /pedidos/resumen (cliente, fecha, artículos...)
    return res.status(200).json(await armarResumen(data));
  } catch (error) {
    return res.status(500).json({
      mensaje: "Error interno del servidor",
      error: error.message,
    });
  }
};

export const contarPorEntregar = async (req, res) => {
  const { count, error } = await contarPedidosPorEntregar();

  if (error) {
    return res.status(500).json(error);
  }

  res.json({ total: count });
};

const formatearFechaSegura = (fecha) => {
  if (!fecha) return "";
  const texto = String(fecha);
  const conZona = /(Z|[+-]\d{2}:?\d{2})$/i.test(texto) ? texto : `${texto}Z`;
  const d = new Date(conZona);
  if (isNaN(d.getTime())) return texto;

  return d.toLocaleString("es-CO", {
    timeZone: "America/Bogota",
    day: "2-digit",
    month: "2-digit",
    year: "numeric",
    hour: "2-digit",
    minute: "2-digit",
    hour12: true,
  });
};

// Arma, para cada pedido: cliente (nombre, apellido, teléfono), foto del primer
// producto, cantidad de artículos y la lista completa de artículos.
// Lo usan /pedidos/resumen y /pedidos/cedula/:cedula
const armarResumen = async (pedidos) => {
  // Traer los clientes de todos los pedidos en UNA sola consulta
  const idsClientes = [
    ...new Set(pedidos.map((p) => p.id_cliente).filter(Boolean)),
  ];
  const mapaClientes = {};

  if (idsClientes.length > 0) {
    const { data: clientes } = await obtenerClientesPorIds(idsClientes);
    (clientes || []).forEach((c) => {
      mapaClientes[c.id] = c;
    });
  }

  return pedidos.map((pedido) => {
    // El "primer producto" es el primer artículo que se guardó en el pedido
    const detalle = [...(pedido.detalle_pedido || [])]
      .sort((a, b) => a.id - b.id)
      .map((d) => ({
        id: d.id,
        id_producto: d.id_producto,
        nombre: d.productos?.nombre ?? "Producto eliminado",
        descripcion: d.productos?.descripcion ?? "",
        foto: d.productos?.foto ?? null,
        cantidad: d.cantidad,
        precio_unitario: d.precio_unitario,
        subtotal: d.subtotal,
      }));

    const { detalle_pedido, ...datosPedido } = pedido;

    return {
      ...datosPedido,
      fecha_formateada: formatearFechaSegura(pedido.fecha),
      cliente: mapaClientes[pedido.id_cliente] || null,
      foto_principal: detalle[0]?.foto ?? null,
      cantidad_articulos: detalle.length,
      detalle,
    };
  });
};

// GET /pedidos/resumen
export const listarResumen = async (req, res) => {
  try {
    const { data: pedidos, error } = await obtenerPedidosConDetalle();

    if (error) {
      return res.status(500).json({
        mensaje: "Error al obtener los pedidos",
        error: error.message,
      });
    }

    res.json(await armarResumen(pedidos));
  } catch (error) {
    res
      .status(500)
      .json({ mensaje: "Error interno del servidor", error: error.message });
  }
};
