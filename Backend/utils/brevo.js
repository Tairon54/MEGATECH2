import { BrevoClient } from "@getbrevo/brevo";

// Envía un correo con Brevo (por API HTTP, funciona en Render).
// Recibe lo mismo que nodemailer: { to, subject, html }  (+ nombre opcional).
// El remitente sale de las variables de entorno, igual que el código de verificación.
export const enviarCorreoBrevo = async ({ to, nombre, subject, html }) => {
  const brevo = new BrevoClient({
    apiKey: process.env.BREVO_API_KEY,
  });

  return brevo.transactionalEmails.sendTransacEmail({
    subject,
    sender: {
      name: process.env.EMAIL_FROM_ALCRIS || "Megatech2",
      email: process.env.EMAIL_USER,
    },
    to: [{ email: to, name: nombre || to }],
    htmlContent: html,
  });
};