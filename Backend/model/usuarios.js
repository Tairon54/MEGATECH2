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
  codigoVerficacion,
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
        codigoVerficacion,
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
