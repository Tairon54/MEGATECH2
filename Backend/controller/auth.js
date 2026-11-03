import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import { crearuser, obtenercorreo } from "../model/usuarios.js";
import { supabase } from "../config/supabase.js";
import { enviarCodigoVerificacion } from "../utils/emailservices.js";

// REGISTRO
export const registro = async (req, res) => {
  try {
    const { cedula, nombre, apellido, telefono, correo, contraseña } = req.body;

    // Validar datos básicos
    if (
      !cedula ||
      !nombre ||
      !apellido ||
      !telefono ||
      !correo ||
      !contraseña
    ) {
      return res.status(400).json({
        error: "Faltan datos",
      });
    }

    // --- NUEVO: Validar seguridad de la contraseña ---
    // Mínimo 8 caracteres, al menos una mayúscula, una minúscula y un carácter especial
    const regexPassword = /^(?=.*[a-z])(?=.*[A-Z])(?=.*[\W_]).{8,}$/;
    if (!regexPassword.test(contraseña)) {
      return res.status(400).json({
        error: "La contraseña debe tener al menos 8 caracteres, incluir una mayúscula, una minúscula y un carácter especial.",
      });
    }
    // ------------------------------------------------

    // Verificar si el correo ya existe
    const { data: usuarioExiste, error: errorConsulta } =
      await obtenercorreo(correo);
    // ... (el resto del código sigue igual)

    if (errorConsulta) {
      return res.status(500).json({
        error: "Error al consultar el correo",
      });
    }

    if (usuarioExiste) {
      return res.status(400).json({
        error: "El email ya existe",
      });
    }

    // Encriptar contraseña
    const encriptar = await bcrypt.hash(contraseña, 10);

    // Rol por defecto
    const rol = "Cliente";

    // Generar código de verificación de 6 dígitos
    const codigoVerificacion = Math.floor(
      100000 + Math.random() * 900000,
    ).toString();

    // El código vence en 15 minutos
    const codigoVerificacionExpiracion = new Date(Date.now() + 15 * 60 * 1000);

    // Crear usuario UNA SOLA VEZ
    const { data, error } = await crearuser(
      cedula,
      nombre,
      apellido,
      telefono,
      correo,
      encriptar,
      rol,
      false,
      codigoVerificacion,
      codigoVerificacionExpiracion,
    );

    // Verificar error de Supabase
    if (error) {
      console.error("Error creando usuario:", error);

      return res.status(500).json({
        error: "Error al crear el usuario en la base de datos",
        detalle: error.message,
      });
    }

    // Enviar código de verificación por correo
    const resultadoEnvio = await enviarCodigoVerificacion(
  correo,
  nombre,
  codigoVerificacion,
);

    // Obtener usuario creado
    const usuarioCreado = Array.isArray(data) ? data[0] : data;

    const usuarioRespuesta = {
      id: usuarioCreado.id,
      cedula: usuarioCreado.cedula,
      nombre: usuarioCreado.nombre,
      apellido: usuarioCreado.apellido,
      telefono: usuarioCreado.telefono,
      correo: usuarioCreado.correo,
      rol: usuarioCreado.rol,
    };

    // Si Brevo falla
    if (!resultadoEnvio.exito) {
      return res.status(500).json({
        message:
          "Usuario creado correctamente, pero no se pudo enviar el correo de verificación",
        emailEnviado: false,
        usuario: usuarioRespuesta,
      });
    }

    // Registro exitoso
    return res.status(201).json({
      message: "Usuario creado correctamente",
      emailEnviado: true,
      usuario: usuarioRespuesta,
    });
  } catch (error) {
    console.error("Error en el registro:", error);

    return res.status(500).json({
      error: error.message,
    });
  }
};

// creamos el login
export const login = async (req, res) => {
  try {
    const { correo, contraseña } = req.body;

    // Validar datos
    if (!correo || !contraseña) {
      return res.status(400).json({
        error: "Todos los datos son requeridos",
      });
    }

    // Buscar usuario
    const { data: usuario, error } = await obtenercorreo(correo);

    console.log("USUARIO:", usuario);

    if (error) {
      console.error("Error buscando usuario:", error);
      return res.status(500).json({
        error: "Error al consultar el usuario",
      });
    }

    if (!usuario) {
      return res.status(400).json({
        error: "Email no registrado",
      });
    }

    // Verificar contraseña
    const passwordValida = await bcrypt.compare(contraseña, usuario.contraseña);

    if (!passwordValida) {
      return res.status(400).json({
        error: "Contraseña incorrecta",
      });
    }
    // CUENTA DESACTIVADA POR EL ADMIN
    if (usuario.activo === false) {
      return res.status(403).json({
        error: "Tu cuenta está desactivada. Comunícate con el administrador.",
      });
    }

    // VERIFICAR CUENTA
    if (usuario.idVerified !== true) {
      console.log("CUENTA NO VERIFICADA");
      console.log("idVerified:", usuario.idVerified);
      console.log("tipo:", typeof usuario.idVerified);

      return res.status(403).json({
        error: "Tu cuenta no ha sido verificada",
      });
    }

    // Generar token
    const token = jwt.sign(
      {
        id: usuario.id,
        correo: usuario.correo,
        rol: usuario.rol,
      },
      process.env.JWT_SECRET,
      {
        expiresIn: "1h",
      },
    );

    return res.status(200).json({
      message: "Login exitoso",
      token,
      usuario: {
        id: usuario.id,
        cedula: usuario.cedula,
        nombre: usuario.nombre,
        apellido: usuario.apellido,
        telefono: usuario.telefono,
        correo: usuario.correo,
        rol: usuario.rol,
      },
    });
  } catch (error) {
    console.error("Error en el login:", error);

    return res.status(500).json({
      error: error.message,
    });
  }
};
// verificar cuenta con código de 6 dígitos
export const verificarCuenta = async (req, res) => {
  try {
    const { correo, codigo } = req.body;

    if (!correo || !codigo) {
      return res.status(400).json({
        error: "correo y código de verificación son requeridos",
      });
    }

    // Buscar el usuario en Supabase
    const { data: usuario, error: errorUsuario } = await supabase
      .from("usuarios")
      .select(
        "id, correo, idVerified, codigoVerificacion, codigoVerificacionExpiracion",
      )
      .eq("correo", correo)
      .single();

    if (errorUsuario || !usuario) {
      return res.status(404).json({
        error: "Usuario no encontrado",
      });
    }

    // Revisar si ya está activo
    if (usuario.idVerified) {
      return res.status(400).json({
        error: "La cuenta ya ha sido verificada",
      });
    }

    // Comparar el código
    if (String(usuario.codigoVerificacion).trim() !== String(codigo).trim()) {
      console.log("Código guardado:", usuario.codigoVerificacion);
      console.log("Código recibido:", codigo);
      return res.status(400).json({
        error: "Código de verificación incorrecto",
      });
    }

    // Validar expiración (15 minutos)
    const ahora = new Date();
    const expiracion = new Date(usuario.codigoVerificacionExpiracion);

    if (ahora > expiracion) {
      return res.status(400).json({
        error: "El código de verificación ha expirado",
      });
    }

    // Activar la cuenta
    const { error: errorActualizar } = await supabase
      .from("usuarios")
      .update({
        idVerified: true,
        codigoVerificacion: null,
        codigoVerificacionExpiracion: null,
      })
      .eq("id", usuario.id);

    if (errorActualizar) {
      return res.status(500).json({
        error: "Error al actualizar el estado de verificación",
      });
    }

    return res.status(200).json({
      message: "Cuenta verificada correctamente",
    });
  } catch (error) {
    console.error("Error en la verificación de cuenta:", error);

    return res.status(500).json({
      error: error.message,
    });
  }
};

// REENVIAR CÓDIGO DE VERIFICACIÓN

export const reenviarCodigo = async (req, res) => {
  try {
    const { correo } = req.body;

    // Validar correo
    if (!correo) {
      return res.status(400).json({
        error: "El correo es requerido",
      });
    }

    // Buscar usuario
    const { data: usuario, error: errorUsuario } = await supabase
      .from("usuarios")
      .select("id, nombre, correo, idVerified")
      .eq("correo", correo)
      .maybeSingle();

    if (errorUsuario) {
      console.error("Error buscando usuario:", errorUsuario);

      return res.status(500).json({
        error: "Error al consultar el usuario",
      });
    }

    // Usuario no existe
    if (!usuario) {
      return res.status(404).json({
        error: "Usuario no encontrado",
      });
    }

    // Verificar si ya está verificado
    if (usuario.idVerified === true) {
      return res.status(400).json({
        error: "La cuenta ya está verificada",
      });
    }

    // Generar nuevo código
    const codigoVerificacion = Math.floor(
      100000 + Math.random() * 900000,
    ).toString();

    console.log("Nuevo código generado:", codigoVerificacion);

    // Nueva expiración de 15 minutos
    const codigoVerificacionExpiracion = new Date(Date.now() + 15 * 60 * 1000);

    // Guardar código en Supabase
    const { error: errorActualizar } = await supabase
      .from("usuarios")
      .update({
        codigoVerificacion,
        codigoVerificacionExpiracion,
      })
      .eq("id", usuario.id);

    if (errorActualizar) {
      console.error("Error guardando código:", errorActualizar);

      return res.status(500).json({
        error: "No se pudo guardar el código de verificación",
      });
    }

    // Enviar código por correo
    const resultadoEnvio = await enviarCodigoVerificacion(
      usuario.correo,
      usuario.nombre,
      codigoVerificacion,
    );

    // Verificar envío
    if (!resultadoEnvio.exito) {
      console.error("Error enviando correo:", resultadoEnvio);

      return res.status(500).json({
        error: "El código fue generado, pero no se pudo enviar el correo",
      });
    }

    return res.status(200).json({
      message: "Código de verificación enviado correctamente",
      emailEnviado: true,
    });
  } catch (error) {
    console.error("Error reenviando código:", error);

    return res.status(500).json({
      error: error.message,
    });
  }
};
