import nodemailer from 'nodemailer';
import dotenv from 'dotenv';

dotenv.config();

const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASS,
    }
});

export const enviarconfirmacionpedido = async (correo, nombre, pedidoid, total) => {
    const mailOptions = {
        from: process.env.EMAIL_USER,
        to: correo,
        subject: `👍 Pedido confirmado #${pedidoid}`,
        html: `
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
</head>

<body style="margin:0;padding:0;background:#0b1728;font-family:Arial,sans-serif;">

<table width="100%" cellpadding="0" cellspacing="0" style="padding:30px 0;">
<tr>
<td align="center">

<table width="420" cellpadding="0" cellspacing="0"
style="background:#10243f;border-radius:20px;border:2px solid #1da1f2;color:white;overflow:hidden;">

<tr>
<td style="background:#0d1c31;padding:20px;text-align:center;border-bottom:2px solid #1da1f2;">

<h1 style="margin:0;color:#29b6f6;">
Megatech2
</h1>

<p style="margin-top:8px;color:#b9dfff;">
Confirmación de Pedido
</p>

</td>
</tr>

<tr>
<td style="padding:30px;">

<p style="font-size:18px;">
Hola <strong>${nombre || 'Usuario'}</strong>,
</p>

<p style="color:#d8e9ff;line-height:25px;">
¡Gracias por realizar tu compra! Tu pedido ha sido confirmado correctamente.
</p>

<div style="
background:#0d1c31;
border:2px solid #35e27b;
border-radius:15px;
padding:20px;
margin:25px 0;">

<div style="text-align:center;font-size:48px;">🛒</div>

<h2 style="
text-align:center;
color:#35e27b;
margin:10px 0 20px;">
Pedido Confirmado
</h2>

<table width="100%" style="color:white;font-size:16px;">
<tr>
<td><strong>Número de pedido:</strong></td>
<td style="text-align:right;color:#29b6f6;">
#${pedidoid}
</td>
</tr>

<tr>
<td style="padding-top:12px;"><strong>Total:</strong></td>
<td style="padding-top:12px;text-align:right;color:#35e27b;font-size:18px;font-weight:bold;">
$${total.toLocaleString('es-CO')}
</td>
</tr>
</table>

</div>

<div style="
margin-top:20px;
padding:15px;
background:#0b1728;
border-left:5px solid #29b6f6;
border-radius:8px;">

<strong style="color:#29b6f6;">
📦 Próximo paso
</strong>

<p style="margin:8px 0 0;color:#d8e9ff;">
Desde administracion le informamos que su pedido ya fue revisado y verificado y ya puede pasar al punto fisico para que sele haga la respectiva entrega 
</p>

</div>

<p style="margin-top:30px;color:#d8e9ff;">
Gracias por confiar en <strong>Megatech2</strong>.
</p>

</td>
</tr>

<tr>
<td style="
background:#0d1c31;
padding:18px;
text-align:center;
font-size:13px;
color:#9fb8d6;">

Atentamente,<br>
<strong style="color:#29b6f6;">
Equipo de Soporte - Megatech2
</strong>

<br><br>

© 2026 Megatech2 - Sistema de Gestión de Inventario

</td>
</tr>

</table>

</td>
</tr>
</table>

</body>
</html>
`
    };

    try {
        await transporter.sendMail(mailOptions);
        return { success: true, message: 'Correo de confirmación enviado correctamente' };
    } catch (error) {
        console.error('Error enviando el email de confirmación:', error);
        return { success: false, error: error.message };
    }
};

export const enviarAlertaStock = async (correo, nombre, producto, stock, descripcion) => {
    await transporter.sendMail({
        from: process.env.EMAIL_USER,
        to: correo,
        subject: "⚠ Alerta de inventario",
        html: `
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
</head>

<body style="margin:0;padding:0;background:#0b1728;font-family:Arial,sans-serif;">

<table width="100%" cellpadding="0" cellspacing="0" style="padding:30px 0;">
<tr>
<td align="center">

<table width="450" cellpadding="0" cellspacing="0"
style="background:#10243f;border-radius:20px;border:2px solid #1da1f2;color:white;overflow:hidden;">

<tr>
<td style="background:#0d1c31;padding:20px;text-align:center;border-bottom:2px solid #1da1f2;">

<h1 style="margin:0;color:#29b6f6;">
Megatech2
</h1>

<p style="margin-top:8px;color:#b9dfff;">
Alerta de Inventario
</p>

</td>
</tr>

<tr>
<td style="padding:30px;">

<p style="font-size:18px;">
Hola <strong>${nombre}</strong>,
</p>

<p style="color:#d8e9ff;line-height:25px;">
El sistema ha detectado que uno de los productos del inventario ha alcanzado un nivel bajo de existencias.
</p>

<div style="
background:#0d1c31;
border:2px solid #ff9800;
border-radius:15px;
padding:20px;
margin:25px 0;">

<div style="text-align:center;font-size:48px;">⚠️</div>

<h2 style="
text-align:center;
color:#ff9800;
margin:10px 0 20px;">
Stock Bajo
</h2>

<table width="100%" style="color:white;font-size:16px;">

<tr>
<td><strong>Producto:</strong></td>
<td style="text-align:right;color:#29b6f6;">
${producto}
</td>
</tr>

<tr>
<td style="padding-top:12px;">
<strong>Descripción:</strong>
</td>

<td style="
padding-top:12px;
text-align:right;
color:#d8e9ff;">
${descripcion}
</td>

</tr>

<tr>
<td style="padding-top:12px;">
<strong>Unidades disponibles:</strong>
</td>

<td style="
padding-top:12px;
text-align:right;
color:#ff4d4d;
font-size:18px;
font-weight:bold;">
${stock}
</td>

</tr>

</table>

</div>

<div style="
margin-top:20px;
padding:15px;
background:#0b1728;
border-left:5px solid #35e27b;
border-radius:8px;">

<strong style="color:#35e27b;">
📦 Acción recomendada
</strong>

<p style="margin:8px 0 0;color:#d8e9ff;">
Se recomienda abastecer este producto lo antes posible para evitar quedarse sin existencias y garantizar la disponibilidad para los clientes.
</p>

</div>

<p style="margin-top:30px;color:#d8e9ff;">
Este es un mensaje generado automáticamente por el sistema de inventario.
</p>

</td>
</tr>

<tr>
<td style="
background:#0d1c31;
padding:18px;
text-align:center;
font-size:13px;
color:#9fb8d6;">

Atentamente,<br>

<strong style="color:#29b6f6;">
Equipo de Soporte - Megatech2
</strong>

<br><br>

© 2026 Megatech2 - Sistema de Gestión de Inventario - Tienda Tecnológica

</td>
</tr>

</table>

</td>
</tr>
</table>

</body>
</html>
`
    });

};

export const enviarCancelacionPedido = async (correo, nombre, pedidoid, total) => {
    const mailOptions = {
        from: process.env.EMAIL_USER,
        to: correo,
        subject: `❌ Pedido cancelado #${pedidoid}`,
        html: `
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
</head>

<body style="margin:0;padding:0;background:#0b1728;font-family:Arial,sans-serif;">

<table width="100%" cellpadding="0" cellspacing="0" style="padding:30px 0;">
<tr>
<td align="center">

<table width="420" cellpadding="0" cellspacing="0"
style="background:#10243f;border-radius:20px;border:2px solid #1da1f2;color:white;overflow:hidden;">

<tr>
<td style="background:#0d1c31;padding:20px;text-align:center;border-bottom:2px solid #1da1f2;">
<h1 style="margin:0;color:#29b6f6;">Megatech2</h1>
<p style="margin-top:8px;color:#b9dfff;">Pedido Cancelado</p>
</td>
</tr>

<tr>
<td style="padding:30px;">

<p style="font-size:18px;">
Hola <strong>${nombre || 'Usuario'}</strong>,
</p>

<p style="color:#d8e9ff;line-height:25px;">
Te informamos que tu pedido fue cancelado porque no se registró el pago correspondiente.
</p>

<div style="background:#0d1c31;border:2px solid #ff5252;border-radius:15px;padding:20px;margin:25px 0;">

<div style="text-align:center;font-size:48px;">🚫</div>

<h2 style="text-align:center;color:#ff5252;margin:10px 0 20px;">
Pedido Cancelado
</h2>

<table width="100%" style="color:white;font-size:16px;">
<tr>
<td><strong>Número de pedido:</strong></td>
<td style="text-align:right;color:#29b6f6;">#${pedidoid}</td>
</tr>
<tr>
<td style="padding-top:12px;"><strong>Total:</strong></td>
<td style="padding-top:12px;text-align:right;color:#ff5252;font-size:18px;font-weight:bold;">
$${Number(total || 0).toLocaleString('es-CO')}
</td>
</tr>
<tr>
<td style="padding-top:12px;"><strong>Motivo:</strong></td>
<td style="padding-top:12px;text-align:right;color:#d8e9ff;">Falta de pago</td>
</tr>
</table>

</div>

<div style="margin-top:20px;padding:15px;background:#0b1728;border-left:5px solid #29b6f6;border-radius:8px;">
<strong style="color:#29b6f6;">🛍️ ¿Aún quieres tus productos?</strong>
<p style="margin:8px 0 0;color:#d8e9ff;">
Puedes volver a realizar tu pedido desde la app cuando quieras y subir tu comprobante de pago para que lo verifiquemos.
</p>
</div>

<p style="margin-top:30px;color:#d8e9ff;">
Gracias por confiar en <strong>Megatech2</strong>.
</p>

</td>
</tr>

<tr>
<td style="background:#0d1c31;padding:18px;text-align:center;font-size:13px;color:#9fb8d6;">
Atentamente,<br>
<strong style="color:#29b6f6;">Equipo de Soporte - Megatech2</strong>
<br><br>
© 2026 Megatech2 - Sistema de Gestión de Inventario
</td>
</tr>

</table>

</td>
</tr>
</table>

</body>
</html>
`
    };

    try {
        await transporter.sendMail(mailOptions);
        return { success: true, message: 'Correo de cancelación enviado correctamente' };
    } catch (error) {
        console.error('Error enviando el email de cancelación:', error); 
        return { success: false, error: error.message };
    }
};
