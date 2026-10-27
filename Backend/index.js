import express from 'express';
import dotenv from 'dotenv';
import cors from 'cors';

import { conectaDB } from './config/supabase.js';

import authRoutes from './routes/auth.js';
import userRoutes from './routes/usuarios.js';
import categoriasRoutes from './routes/categorias.js';
import subcategoriasRoutes from './routes/sub_categorias.js';
import productosRouter from './routes/productos.js';
import pedidosRouter from './routes/pedidos.js';
import detallePedidoRouter from './routes/detalle_pedido.js';
import vetasRouter from './routes/ventas.js';
import comproRouter from './routes/comprobante.js';
import ialaboralRouter from './routes/ialaboral.js';
import iaclieRouter from './routes/iaclie.js';

// Cargar variables de entorno
dotenv.config();

// Crear la aplicación
const app = express();

// Configurar middlewares
app.use(express.json());
app.use(cors());

// Ruta principal para comprobar que funciona
app.get('/', (req, res) => {
  res.json({
    mensaje: 'Bienvenido al backend de MEGATECH2',
    estado: 'en linea',
    version: '1.0.0',
  });
});

// Rutas de la API
app.use('/categorias', categoriasRoutes);
app.use('/subcategorias', subcategoriasRoutes);
app.use('/productos', productosRouter);
app.use('/pedidos', pedidosRouter);
app.use('/detalle_pedido', detallePedidoRouter);
app.use('/usuario', userRoutes);
app.use('/auth', authRoutes);
app.use('/ventas', vetasRouter);
app.use('/compro', comproRouter);
app.use('/ialaboral', ialaboralRouter);
app.use('/iaclie', iaclieRouter);

// Usar el puerto asignado por Render
const PORT = process.env.PORT || 3000;

// Iniciar servidor
app.listen(PORT, '0.0.0.0', async () => {
  console.log(`Servidor escuchando en el puerto ${PORT}`);

  try {
    await conectaDB();
    console.log('Conexión con la base de datos comprobada');
  } catch (error) {
    console.error('Error al conectar con la base de datos:', error);
  }
});