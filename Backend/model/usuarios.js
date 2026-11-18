import { supabase } from "../config/supabase.js";

// obtener todos los usuarios
export const UserModel = {
  obtenertodos: async () => {
    const { data, error } = await supabase
      .from("usuarios")
      .select("id,cedula,nombre,apellido,telefono,correo,rol,activo");
    return { data, error };
  },
};

// crear nuevo usuario
export const crearuser = async (
  cedula,
  nombre,
  apellido,
  telefono,
  correo,
  contraseña,
  rol,
  idVerified,
  codigoVerificacion,
  codigoVerificacionExpiracion,
) => {
  const { data, error } = await supabase
    .from("usuarios")
    .insert([
      {
        cedula,
        nombre,
        apellido,
        telefono,
        correo,
        contraseña,
        rol,
        idVerified: false,
        codigoVerificacion,
        codigoVerificacionExpiracion,
      },
    ])
    .select();
  return { data, error };
};

// buscar el usuario por email
export const obtenercorreo = async (correo) => {
  const { data, error } = await supabase
    .from("usuarios")
    .select("*")
    .eq("correo", correo)
    .maybeSingle();
  return { data, error };
};

// obtener un usuario por id
export const porid = async (id) => {
  const { data, error } = await supabase
    .from("usuarios")
    .select("*")
    .eq("id", id)
    .single();
  return { data, error };
};

// actualizar usuario
export const actualizar = async (id, campos) => {
  const { data, error } = await supabase
    .from("usuarios")
    .update(campos)
    .eq("id", id)
    .select("cedula,nombre,apellido,telefono,correo,contraseña,rol");
  return { data, error };
};

// eliminar usuario
export const eliminar = async (id) => {
  const { data, error } = await supabase
    .from("usuarios")
    .delete()
    .eq("id", id)
    .select();
  return { data, error };
};

// obtener todos los empleados y admins
export const obtenerAdminsYEmpleados = async () => {
  const { data, error } = await supabase
    .from("usuarios")
    .select("nombre, correo")
    .in("rol", ["Admin", "Empleado"]);

  return { data, error };
};

// Buscar usuario por cédula
export const buscarPorCedula = async (cedula) => {
  const { data, error } = await supabase
    .from("usuarios")
    .select("*")
    .eq("cedula", cedula)
    .single();

  if (error) throw error;

  return data;
};

// Elimina al usuario Y todos sus registros relacionados (orden: hijos primero)
export const eliminarCuentaCompleta = async (idUsuario) => {
  // Borra filas de una tabla donde la columna esté en la lista de valores
  const borrar = async (tabla, columna, valores) => {
    if (!valores || valores.length === 0) return;
    const { error } = await supabase
      .from(tabla)
      .delete()
      .in(columna, valores);
    if (error) throw new Error(`${tabla}: ${error.message}`);
  };

  try {
    // 1. Ids de los pedidos y ventas del usuario
    const { data: pedidos, error: e1 } = await supabase
      .from("pedidos")
      .select("id")
      .eq("id_cliente", idUsuario);
    if (e1) throw new Error(`pedidos: ${e1.message}`);

    const { data: ventas, error: e2 } = await supabase
      .from("ventas")
      .select("id")
      .eq("id_cliente", idUsuario);
    if (e2) throw new Error(`ventas: ${e2.message}`);

    const idsPedidos = (pedidos || []).map((p) => p.id);
    const idsVentas = (ventas || []).map((v) => v.id);

    // 2. Tablas hijas primero
    await borrar("mensajes_chat", "usuario_id", [idUsuario]);
    await borrar("recovery_codes", "usuario_id", [idUsuario]);

    await borrar("comprobantes", "id_pedido", idsPedidos);
    await borrar("comprobantes", "id_cliente", [idUsuario]);

    await borrar("detalle_pedido", "id_pedido", idsPedidos);
    await borrar("pedidos", "id_cliente", [idUsuario]);

    await borrar("detalle_venta", "id_venta", idsVentas);
    await borrar("ventas", "id_cliente", [idUsuario]);

    // 3. Por último, el usuario
    const { data, error } = await supabase
      .from("usuarios")
      .delete()
      .eq("id", idUsuario)
      .select();

    return { data, error };
  } catch (err) {
    return { data: null, error: err };
  }
};
