import { supabase } from "../config/supabase.js";

// Actualizar stock del producto
export const actualizarStock = async (id, nuevoStock) => {
  return await supabase
    .from("productos")
    .update({ stock: nuevoStock })
    .eq("id", id)
    .select();
};

// Obtener todos los productos activos
export const obtenerProductos = async () => {
  return await supabase
    .from("productos")
    .select(
      `
            *,
            subcategorias(nombre)
        `,
    )
    .eq("activo", true);
};

// Obtener un producto por ID
export const obtenerProductoPorId = async (id) => {
  return await supabase
    .from("productos")
    .select(
      `
            *,
            subcategorias(nombre)
        `,
    )
    .eq("id", id)
    .eq("activo", true)
    .single();
};

// Crear producto
export const crearProducto = async (producto) => {
  return await supabase.from("productos").insert([producto]).select().single();
};

// Actualizar producto
export const actualizarProducto = async (id, producto) => {
  return await supabase
    .from("productos")
    .update(producto)
    .eq("id", id)
    .select()
    .single();
};

// Desactivar producto sin borrarlo de la base de datos
export const desactivarProducto = async (id) => {
  return await supabase
    .from("productos")
    .update({ activo: false })
    .eq("id", id)
    .eq("activo", true)
    .select()
    .single();
};

// Restaurar un producto desactivado
export const restaurarProducto = async (id) => {
  return await supabase
    .from("productos")
    .update({ activo: true })
    .eq("id", id)
    .eq("activo", false)
    .select()
    .single();
};

// Obtener inventario completo: productos activos e inactivos
export const obtenerInventarioCompleto = async () => {
  return await supabase.from("productos").select(`
            *,
            subcategorias(nombre)
        `);
};

// Eliminar físicamente un producto de la base de datos
export const eliminarProducto = async (id) => {
  return await supabase.from("productos").delete().eq("id", id);
};

// Contar productos con stock bajo
export const contarProductosBajoStock = async (umbral = 5) => {
  return await supabase
    .from("productos")
    .select("*", { count: "exact", head: true })
    .eq("activo", true)
    .lte("stock", umbral);
};

// Obtener productos con stock bajo
export const obtenerProductosBajoStock = async (umbral = 5) => {
    return await supabase
        .from("productos")
        .select("id, nombre, descripcion, precio, stock, foto, subcategorias(nombre)")
        .eq("activo", true)  
        .lte("stock", umbral)
        .order("stock", { ascending: true });
};

// Productos más vendidos: suma las unidades de detalle_venta por producto
export const obtenerMasVendidos = async (limite = 3) => {
    const unidades = new Map(); // id_producto -> total de unidades vendidas
    const TAM_PAGINA = 1000;    // Supabase devuelve máx. 1000 filas por consulta
    let desde = 0;

    while (true) {
        const { data, error } = await supabase
            .from("detalle_venta")
            .select("id_producto, cantidad")
            .order("id", { ascending: true })
            .range(desde, desde + TAM_PAGINA - 1);

        if (error) return { data: null, error };

        for (const fila of data) {
            const id = Number(fila.id_producto);
            unidades.set(id, (unidades.get(id) || 0) + Number(fila.cantidad));
        }

        if (data.length < TAM_PAGINA) break;
        desde += TAM_PAGINA;
    }

    if (unidades.size === 0) return { data: [], error: null };

    // Solo productos con stock (igual que el resto del catálogo del cliente)
    const { data: productos, error } = await supabase
        .from("productos")
        .select("*, subcategorias(nombre)")
        .gt("stock", 0);

    if (error) return { data: null, error };

    const top = productos
        .filter((p) => unidades.has(Number(p.id)))
        .map((p) => ({ ...p, total_vendido: unidades.get(Number(p.id)) }))
        .sort((a, b) => b.total_vendido - a.total_vendido || a.nombre.localeCompare(b.nombre))
        .slice(0, limite);

    return { data: top, error: null };
};
