import Groq from "groq-sdk";
import { supabase } from "../config/supabase.js"; // Ruta a tu cliente de Supabase existente

const groq = new Groq({ apiKey: process.env.GROQ_API_KEY });

export const chatearia = async (req, res) => {
  try {
    const { mensaje, sesionId, usuarioId } = req.body;

    if (!mensaje || !mensaje.trim()) {
      return res.status(400).json({ message: "Debes enviar un mensaje." });
    }

    // Si el cliente no manda sesion, creamos un identificador temporal
    const idSesionValido = sesionId || `mega_sesion_${Date.now()}`;

    // 1. Obtener la carta desde tu tabla 'productos' en Supabase
    const { data: productos, error: errorProductos } = await supabase
      .from("productos")
      .select("nombre,descripcion,precio,stock,foto,id_subcategoria")
      .eq("activo", true);

    if (errorProductos) {
      console.error("Error al consultar Supabase:", errorProductos.message);
      return res.status(500).json({ message: "Error al consultar productos." });
    }

    if (!productos || productos.length === 0) {
      return res.status(200).json({
        respuesta:
          "¡Hola! En este momento no tenemos registrado este producto en nuestro inventario.",
      });
    }

    // 2. Armar catalogo para la IA
    // FIX: antes faltaban stock y foto -> la IA no podia responder con esos datos
    // porque simplemente no estaban en el texto que se le mandaba.
    const catalogoTexto = productos
      .map(
        (p) =>
          `- **${p.nombre}**: $${Number(p.precio).toLocaleString("es-CO")} COP | ` +
          `Stock: ${p.stock} unidades | Foto: ${p.foto || "sin foto"} | ` +
          `Descripcion: ${p.descripcion}`,
      )
      .join("\n");

    const systemPrompt = `
Eres el asesor virtual y anfitrión de la tienda de tecnología "Megatech2".
Tu personalidad es alegre, amable, cercana y educada.

CATÁLOGO ACTUAL EN TIENDA:
${catalogoTexto}

REGLAS DE ATENCIÓN:

1. SALUDOS SIN INTENCIÓN DE COMPRA
   Si el cliente solo saluda o hace conversación casual (ej: "Hola", "¿Cómo estás?", "Buenas"),
   responde con cortesía y cercanía, SIN mencionar productos, precios ni inventario:
   "¡Hola! Bienvenido a Megatech2. Qué alegría tenerte aquí, ¿en qué te podemos colaborar hoy?"

2. CONSULTAS DE INVENTARIO Y PRECIOS
   Da precios y disponibilidad ÚNICAMENTE cuando el cliente pregunte explícitamente por
   productos, precios, existencias o el catálogo.

3. FUENTE DE VERDAD
   Usa EXCLUSIVAMENTE la información del CATÁLOGO ACTUAL EN TIENDA. Nunca inventes
   productos, precios o cantidades que no estén ahí. Si el producto no existe en el
   catálogo, indícalo amablemente y sugiere algo similar si lo hay.
   Si un producto tiene 0 unidades de stock, acláraselo al cliente (agotado).

4. FORMATO OBLIGATORIO PARA MOSTRAR PRODUCTOS
   Cuando muestres uno o más productos, usa SIEMPRE este formato exacto, uno por línea,
   sin texto adicional entre productos:

   📦 [Nombre del producto]
      💰 Precio: $[precio] COP
      📊 Disponibles: [cantidad] unidades

   Si son varios productos, sepáralos con una línea en blanco entre cada uno.
   No uses párrafos narrativos para listar productos. No mezcles texto corrido con datos.
   No incluyas el link de la foto en el texto (eso lo maneja el frontend aparte).

5. FORMATO DE PRECIOS
   Siempre en pesos colombianos, con separador de miles: "$XX.XXX COP" (ej: $1.250.000 COP).

6. ESTILO DE RESPUESTA
   Sé conciso y claro. Antes de la lista de productos, una frase corta de introducción.
   Después de la lista, puedes ofrecer ayuda adicional en una sola frase breve.
   No muestres tu razonamiento interno, solo la respuesta final.

7. FUERA DE ALCANCE
   Si preguntan algo no relacionado con Megatech2 ni su catálogo, redirige amablemente
   la conversación.
`;

    // 3. Inferencia con Groq
    // FIX: gpt-oss-20b es un modelo de razonamiento. Gasta tokens "pensando"
    // antes de dar la respuesta final (eso queda en reasoning_content, no en content).
    // Con max_tokens muy bajo, el razonamiento se come todo el presupuesto y
    // "content" queda vacío -> por eso caía siempre en el mensaje de fallback.
    const completion = await groq.chat.completions.create({
  model: "openai/gpt-oss-20b",
  messages: [
    { role: "system", content: systemPrompt },
    { role: "user", content: mensaje },
  ],
  temperature: 0.3,
  max_tokens: 2500, // Súbelo a 2500 para dar espacio al razonamiento y a la respuesta
  reasoning_effort: "low", 
});

    let respuestaTexto = completion.choices[0]?.message?.content?.trim();

    // Salvaguarda: si por algun motivo sigue vacio, evitamos el mensaje generico
    // y devolvemos algo mas util para depurar en desarrollo.
    if (!respuestaTexto) {
      console.warn(
        "Respuesta vacia de Groq. finish_reason:",
        completion.choices[0]?.finish_reason,
        "reasoning_content:",
        completion.choices[0]?.message?.reasoning_content,
      );
      respuestaTexto =
        "Disculpa, tuve un problema generando la respuesta. ¿Podrías repetir tu pregunta?";
    }

    // 4. Guardar ambos mensajes (pregunta y respuesta) en la tabla 'mensajes_chat' de Supabase
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
      console.error(
        "Error guardando el historial en Supabase:",
        errorInsert.message,
      );
      // No frenamos la respuesta al cliente aunque falle el guardado en BD
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

// Endpoint extra para recuperar la conversacion si el usuario vuelve a abrir la app
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
