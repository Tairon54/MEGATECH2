import express from "express";
import {listarProductos,obtenerProducto,crear,actualizar,eliminar,bajoStock,listarBajoStock,masVendidos} from "../controller/productos.js";
import { verificarToken, verificarRol } from "../middleware/auth.js";
import { cloudinary, upload } from "../config/claudinary.js";

const router = express.Router();

router.get("/", listarProductos);

router.get("/bajo-stock",verificarToken,
    verificarRol("Admin","Empleado"), bajoStock);

    router.get("/bajo-stock/lista", verificarToken,
    verificarRol("Admin", "Empleado"), listarBajoStock);

router.get("/obtener/:id", obtenerProducto);

router.post(
    "/crear",
    verificarToken,
    verificarRol("Admin"),
    upload.single("file"),
    crear
);

router.put(
    "/actualizar/:id",
    verificarToken,
    verificarRol("Admin"),
    upload.single("file"),
    actualizar
);

router.delete(
    "/eliminar/:id",
    verificarToken,
    verificarRol("Admin"),
    eliminar
);

router.get("/mas-vendidos", masVendidos);

export default router;
