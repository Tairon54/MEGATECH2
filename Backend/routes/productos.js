import express from "express";
import {
  listarProductos,
  obtenerProducto,
  crear,
  actualizar,
  eliminar,
  restaurar,
  inventarioCompleto,
  bajoStock,
  listarBajoStock,
} from "../controller/productos.js";
import { verificarToken, verificarRol } from "../middleware/auth.js";
import { cloudinary, upload } from "../config/claudinary.js";

const router = express.Router();

router.get("/", listarProductos);

router.get(
  "/bajo-stock",
  verificarToken,
  verificarRol("Admin", "Empleado"),
  bajoStock,
);

router.get(
  "/bajo-stock/lista",
  verificarToken,
  verificarRol("Admin", "Empleado"),
  listarBajoStock,
);

// Inventario completo (incluye eliminados) para la gestión contable
router.get(
  "/inventario-completo",
  verificarToken,
  verificarRol("Admin", "Empleado"),
  inventarioCompleto,
);

router.get("/obtener/:id", obtenerProducto);

router.post(
  "/crear",
  verificarToken,
  verificarRol("Admin"),
  upload.single("file"),
  crear,
);

router.put(
  "/actualizar/:id",
  verificarToken,
  verificarRol("Admin"),
  upload.single("file"),
  actualizar,
);

// "Eliminar" = ocultar (el producto se conserva en la base de datos)
router.delete("/eliminar/:id", verificarToken, verificarRol("Admin"), eliminar);

// Volver a mostrar un producto eliminado
router.put("/restaurar/:id", verificarToken, verificarRol("Admin"), restaurar);

export default router;
