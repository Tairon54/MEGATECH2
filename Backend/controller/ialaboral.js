import Groq from "groq-sdk";
import { supabase } from "../config/supabase.js";

const groq = new Groq({ apiKey: process.env.GROQ_API_KEY });

export const chatearia = async (req, res) => {
  try {
    const { mensaje, sesionId, usuarioId } = req.body;

    if (!mensaje || !mensaje.trim()) {
      return res.status(400).json({ message: "Debes enviar un mensaje." });
    }

    const idSesionValido = sesionId || `mega_sesion_${Date.now()}`;

    // 1. Obtener los productos (Seleccionamos solo campos esenciales)
    const { data: productos, error: errorProductos } = await supabase
      .from("productos")
      .select("nombre, precio, stock") // Omitimos 'descripcion' y 'foto' para ahorrar miles de tokens
      .eq("activo", true)
      .limit(50); // Opcional: limita la cantidad máxima en memoria si la tienda es muy grande

    if (errorProductos) {
      console.error("Error al consultar Supabase:", errorProductos.message);
      return res.status(500).json({ message: "Error al consultar productos." });
    }

    if (!productos || productos.length === 0) {
      return res.status(200).json({
        respuesta: "¡Hola! En este momento no tenemos productos disponibles en el inventario.",
      });
    }

    // 2. Armar un catálogo ultraligero
    const catalogoTexto = productos
      .map(
        (p) =>
          `- ${p.nombre} | $${Number(p.precio).toLocaleString("es-CO")} COP | Stock: ${p.stock}`
      )
      .join("\n");

    const systemPrompt = `
Eres el asesor virtual de la tienda de tecnología "Megatech2".
Tu personalidad es alegre, amable, cercana y educada.

CATÁLOGO DISPONIBLE:
${catalogoTexto}

REGLAS DE ATENCIÓN:
1. SALUDOS: Si el cliente solo saluda (ej: "Hola", "Buenas"), responde con cortesía sin mencionar precios ni catálogo:
   "¡Hola! Bienvenido a Megatech2. Qué alegría tenerte aquí, ¿en qué te podemos colaborar hoy?"

2. CONSULTAS: Muestra precios y stock ÚNICAMENTE cuando pregunten por productos.

3. FUENTE DE VERDAD: Usa solo el catálogo proporcionado. Si un producto no está o tiene stock 0, indícalo.

4. FORMATO PARA PRODUCTOS:
   📦 [Nombre]
      💰 Precio: $[precio] COP
      📊 Disponibles: [cantidad] unidades

5. ESTILO: Respuestas cortas, concisas y claras.
`;

    // 3. Inferencia con Groq
    // Cambiamos a llama-3.1-8b-instant o llama-3.3-70b-versatile (tienen límites TPM mucho más altos)
    const completion = await groq.chat.completions.create({
      model: "llama-3.1-8b-instant", 
      messages: [
        { role: "system", content: systemPrompt },
        { role: "user", content: mensaje.trim() },
      ],
      temperature: 0.3,
      max_tokens: 1000,
    });

    let respuestaTexto = completion.choices[0]?.message?.content?.trim();

    if (!respuestaTexto) {
      respuestaTexto = "Disculpa, tuve un problema generando la respuesta. ¿Podrías repetir tu pregunta?";
    }

    // 4. Guardar en Supabase
    const registrosAInsertar = [
      {
        sesion_id: idSesionValido,
        usuario_id: usuarioId || null,
        emisor: "user",
        mensaje: mensaje.trim(),
      },
      {
        sesion_id: idSesionValido,
        usuario_id: usuarioId || null,
        emisor: "bot",
        mensaje: respuestaTexto,
      },
    ];

    const { error: errorInsert } = await supabase
      .from("mensajes_chat")
      .insert(registrosAInsertar);

    if (errorInsert) {
      console.error("Error guardando historial:", errorInsert.message);
    }

    return res.status(200).json({
      respuesta: respuestaTexto,
      sesionId: idSesionValido,
    });

  } catch (error) {
    console.error("Error en Groq Chat Megatech:", error);
    return res.status(500).json({
      message: "Error al procesar la respuesta",
      error: error.message,
    });
  }
};

export const obtenerHistorialMega = async (req, res) => {
  try {
    const { sesionId } = req.params;

    const { data: historial, error } = await supabase
      .from("mensajes_chat")
      .select("emisor, mensaje, created_at")
      .eq("sesion_id", sesionId)
      .order("created_at", { ascending: true });

    if (error) {
      return res.status(500).json({
        message: "Error al consultar historial",
        error: error.message,
      });
    }

    return res.status(200).json({ historial: historial || [] });
  } catch (error) {
    return res
      .status(500)
      .json({ message: "Error interno", error: error.message });
  }
};