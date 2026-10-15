import { 
  obtenerProductos, 
  obtenerProductoPorId, 
  crearProducto, 
  actualizarProducto, 
  eliminarProducto, 
  contarProductosBajoStock,
  obtenerProductosBajoStock,
  obtenerMasVendidos 
} from "../model/productos.js";
import { obtenerAdminsYEmpleados } from "../model/usuarios.js";
import { enviarAlertaStock } from '../utils/sendemail.js';

// Helper: sube un buffer a Cloudinary usando la API REST directa (Unsigned)
const subirImagenCloudinary = async (buffer, originalname, mimetype) => {
  const formData = new FormData();
  
  // Crear el Blob desde el buffer de multer
  const blob = new Blob([buffer], { type: mimetype });
  formData.append("file", blob, originalname);
  
  // Configurar preset y carpeta
  formData.append("upload_preset", "ml_default");
  formData.append("folder", "productos");

  const cloudName = process.env.CLOUDINARY_CLOUD_NAME || "f5akv7vt";
  const response = await fetch(`https://api.cloudinary.com/v1_1/${cloudName}/image/upload`, {
    method: "POST",
    body: formData
  });

  const resultado = await response.json();

  if (!response.ok) {
    throw { status: response.status, detalle: resultado };
  }

  return resultado.secure_url;
};

// GET: Listar todos los productos
export const listarProductos = async (req, res) => {
  const { data, error } = await obtenerProductos();

  if (error) {
    return res.status(500).json({ error: error.message });
  }

  res.json(data);
};

// GET: Obtener un producto por ID
export const obtenerProducto = async (req, res) => {
  const { id } = req.params;

  const { data, error } = await obtenerProductoPorId(id);

  if (error) {
    return res.status(404).json({ error: error.message });
  }

  res.json(data);
};

// POST: Crear nuevo producto
export const crear = async (req, res) => {
  try {
    const nuevoProducto = { ...req.body };

    if (req.file) {
      try {
        // Asignamos la URL a la propiedad 'foto' que coincide con la base de datos
        nuevoProducto.foto = await subirImagenCloudinary(
          req.file.buffer,
          req.file.originalname,
          req.file.mimetype
        );
      } catch (cloudinaryError) {
        console.error("Error subiendo imagen a Cloudinary:", cloudinaryError);
        return res.status(cloudinaryError.status || 500).json({
          error: "Error de autenticación o configuración en Cloudinary.",
          detalle: cloudinaryError.detalle || cloudinaryError
        });
      }
    }

    const { data, error } = await crearProducto(nuevoProducto);

    if (error) {
      return res.status(400).json({ error: error.message });
    }

    res.status(201).json(data);
  } catch (error) {
    console.error("ERROR AL CREAR PRODUCTO:", error);
    res.status(500).json({
      error: "Error al crear el producto.",
      detalle: error.message || error
    });
  }
};

// PUT: Actualizar producto
export const actualizar = async (req, res) => {
  try {
    const { id } = req.params;
    const cambios = { ...req.body };

    if (req.file) {
      try {
        // Asignamos la URL a la propiedad 'foto'
        cambios.foto = await subirImagenCloudinary(
          req.file.buffer,
          req.file.originalname,
          req.file.mimetype
        );
      } catch (cloudinaryError) {
        console.error("Error subiendo imagen a Cloudinary:", cloudinaryError);
        return res.status(cloudinaryError.status || 500).json({
          error: "Error de autenticación o configuración en Cloudinary.",
          detalle: cloudinaryError.detalle || cloudinaryError
        });
      }
    }

    const { data, error } = await actualizarProducto(id, cambios);

    if (error) {
      return res.status(400).json({ error: error.message });
    }

    // Verificar si el producto quedó con poco stock
    await verificarStock(data);

    res.json(data);
  } catch (error) {
    console.error("ERROR AL ACTUALIZAR PRODUCTO:", error);
    res.status(500).json({
      error: "Error al actualizar el producto.",
      detalle: error.message || error
    });
  }
};

// DELETE: Eliminar producto
export const eliminar = async (req, res) => {
  const { id } = req.params;

  const { error } = await eliminarProducto(id);

  if (error) {
    return res.status(400).json({ error: error.message });
  }

  res.json({
    mensaje: "Producto eliminado correctamente"
  });
};

// Helper: Verificar niveles de stock y enviar alertas
export const verificarStock = async (producto) => {
  if (producto && producto.stock <= 5) {
    const { data: usuarios } = await obtenerAdminsYEmpleados();

    if (usuarios && usuarios.length > 0) {
      for (const usuario of usuarios) {
        await enviarAlertaStock(
          usuario.correo,
          usuario.nombre,
          producto.nombre,
          producto.stock,
          producto.descripcion
        );
      }
    }
  }
};

// GET: Contar productos con bajo stock
export const bajoStock = async (req, res) => {
  const { count, error } = await contarProductosBajoStock();

  if (error) {
    return res.status(500).json({ error: error.message });
  }

  res.json({ total: count });
};

export const listarBajoStock = async (req, res) => {
  const { data, error } = await obtenerProductosBajoStock();
 
  if (error) {
    return res.status(500).json({ error: error.message });
  }
 
  res.json(data);
};

// GET: Los productos más vendidos (público, lo ve también el invitado)
export const masVendidos = async (req, res) => {
  const limite = Math.min(Number(req.query.limite) || 3, 10);

  const { data, error } = await obtenerMasVendidos(limite);

  if (error) {
    return res.status(500).json({ error: error.message });
  }

  res.json(data);
};