import express from "express";
import {obtener,obtenerPorId,crear,actualizar,eliminar,pedidosPorCedula, contarPorEntregar
    ,listarResumen} from "../controller/pedidos.js";
import { verificarRol, verificarToken } from "../middleware/auth.js";

const router = express.Router();

router.get("/",verificarToken,verificarRol('Admin','Empleado'), obtener);
router.get("/resumen", verificarToken, verificarRol('Admin','Empleado'), listarResumen);
router.get("/contar/por-entregar", verificarToken, verificarRol('Admin', 'Empleado'), contarPorEntregar);
router.get("/obtener/:id",verificarToken,verificarRol('Admin','Empleado'), obtenerPorId);
router.get("/cedula/:cedula", verificarToken, verificarRol('Admin','Empleado'), pedidosPorCedula);
router.post("/crear",verificarToken,verificarRol('Cliente'), crear);
router.put("/actualizar/:id",verificarToken,verificarRol('Admin'), actualizar);
router.delete("/eliminar/:id",verificarToken,verificarRol('Admin'), eliminar);


export default router;