import { BrevoClient } from "@getbrevo/brevo";

export const enviarCodigoVerificacion = async (email, nombre, codigo, esReenvio = false) => {
  try {
    const brevo = new BrevoClient({
      apiKey: process.env.BREVO_API_KEY,
    });

    const result = await brevo.transactionalEmails.sendTransacEmail({
       subject: esReenvio
    ? `Nuevo código: ${codigo} - MEGATECH2`
    : `Tu código de verificación: ${codigo} - MEGATECH2`,
      sender: {
        name: process.env.EMAIL_FROM_ALCRIS || "Megatech2",
        email: process.env.EMAIL_USER,
      },
      to: [
        {
          email: email,
          name: nombre,
        },
      ],
      htmlContent: `
<div style="
  margin: 0;
  padding: 0;
  width: 100%;
  background: linear-gradient(135deg, #0D47A1, #1976D2, #42A5F5);
  font-family: Arial, Helvetica, sans-serif;
">
  <div style="
    max-width: 600px;
    margin: 0 auto;
    padding: 40px 20px;
  ">

    <!-- TARJETA PRINCIPAL -->
    <div style="
      background-color: #ffffff;
      border-radius: 20px;
      padding: 35px 30px;
      text-align: center;
      box-shadow: 0 8px 25px rgba(0,0,0,0.15);
    ">

      <!-- LOGO / NOMBRE -->
      <div style="margin-bottom: 25px;">
        <h1 style="
          margin: 0;
          color: #1565C0;
          font-size: 30px;
          font-weight: bold;
        ">
          MEGATECH2
        </h1>

        <p style="
          margin: 8px 0 0 0;
          color: #777777;
          font-size: 14px;
        ">
          Tu tecnología, más fácil
        </p>
      </div>

      <!-- ICONO -->
      <div style="
        width: 70px;
        height: 70px;
        margin: 0 auto 20px auto;
        background-color: #E3F2FD;
        border-radius: 50%;
        line-height: 70px;
        font-size: 32px;
      ">
        ✓
      </div>

      <!-- TITULO -->
      <h2 style="
        margin: 0 0 12px 0;
        color: #222222;
        font-size: 24px;
      ">
        Verifica tu cuenta
      </h2>

      <!-- SALUDO -->
      <p style="
        color: #555555;
        font-size: 16px;
        line-height: 1.6;
        margin: 10px 0;
      ">
        Hola <strong>${nombre}</strong>,
      </p>

      <p style="
        color: #666666;
        font-size: 15px;
        line-height: 1.6;
        margin: 10px 0 25px 0;
      ">
        Gracias por registrarte en MEGATECH2.
        Para completar tu registro, utiliza el siguiente
        código de verificación:
      </p>

      <!-- CODIGO -->
      <div style="
        background-color: #E3F2FD;
        border: 2px dashed #1976D2;
        border-radius: 14px;
        padding: 20px;
        margin: 25px 0;
      ">
        <p style="
          margin: 0 0 10px 0;
          color: #555555;
          font-size: 13px;
        ">
          TU CÓDIGO DE VERIFICACIÓN
        </p>

        <div style="
          color: #1565C0;
          font-size: 36px;
          font-weight: bold;
          letter-spacing: 8px;
        ">
          ${codigo}
        </div>
      </div>

      <!-- EXPIRACION Y AVISO -->
      <p style="
        color: #777777;
        font-size: 13px;
        line-height: 1.6;
        margin-top: 20px;
      ">
        ⏱ Este código es válido durante
        <strong>15 minutos</strong>.
        <br>
        Si solicitaste varios códigos, usa
        <strong>solo el más reciente</strong>;
        los anteriores dejan de funcionar.
      </p>

      <!-- AVISO DE SEGURIDAD -->
      <p style="
        color: #888888;
        font-size: 13px;
        line-height: 1.5;
        margin-top: 20px;
      ">
        Si no realizaste este registro, puedes ignorar
        este correo electrónico.
      </p>

      <!-- LINEA -->
      <div style="
        height: 1px;
        background-color: #eeeeee;
        margin: 30px 0 20px 0;
      "></div>

      <!-- PIE -->
      <p style="
        margin: 0;
        color: #999999;
        font-size: 12px;
      ">
        © 2026 MEGATECH2
      </p>

      <p style="
        margin: 5px 0 0 0;
        color: #aaaaaa;
        font-size: 11px;
      ">
        Este es un correo automático, por favor no respondas.
      </p>

    </div>
  </div>
</div>
`,
    });
    console.log("Correo enviado correctamente");
    return { exito: true, result };
  } catch (error) {
    console.error("Error al enviar el correo con Brevo:", error);
    return { exito: false, error };
  }
};
