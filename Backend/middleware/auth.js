import jwt from "jsonwebtoken";
import { supabase } from "../config/supabase.js";

// Verifica que exista un token válido
export const verificarToken = (req, res, next) => {
  const authHeader = req.headers["authorization"];
  const token = authHeader && authHeader.split(" ")[1];

  if (!token) {
    return res.status(401).json({
      error: "Token no proporcionado, por favor inicie sesión",
    });
  }

  jwt.verify(token, process.env.JWT_SECRET, async (err, decoded) => {
    if (err) {
      return res.status(401).json({
        error: "Token inválido o expirado",
      });
    }
    try {
      // ¿la cuenta sigue activa?
      const { data } = await supabase
        .from("usuarios")
        .select("activo")
        .eq("id", decoded.id)
        .maybeSingle();

      if (data && data.activo === false) {
        return res.status(403).json({
          error: "Tu cuenta está desactivada. Comunícate con el administrador.",
        });
      }
    } catch (e) {
      console.error("Error verificando estado de la cuenta:", e);
      return res.status(500).json({ error: "Error al verificar la sesión" });
    }

    req.usuario = decoded;
    next();
  });
};

// Middleware para verificar roles
export const verificarRol = (...rolesPermitidos) => {
  return (req, res, next) => {
    if (!rolesPermitidos.includes(req.usuario.rol)) {
      return res.status(403).json({
        error: "No tienes permisos para realizar esta acción",
      });
    }

    next();
  };
};
