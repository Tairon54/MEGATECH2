import { codigorecupera, marcarCodigoComoUsado, obtenerCodigoValido } from "../model/recuperar.js";
import { obtenercorreo, actualizar } from "../model/usuarios.js";
import { enviarCorreoBrevo } from "../utils/brevo.js";
import bcrypt from "bcryptjs";

// configuramos la logica para enviar el correo electronico
export const enviarcorreo = async (req, res) => {
    try {
        const { correo } = req.body;
        if (!correo) {
            return res.status(400).json({error: 'el correo electronico es requerido'});  
        }
        // verifica si el archivo existe
        const {data: usuario,error: errorusuario} = await obtenercorreo(correo);
        if (errorusuario || !usuario) {
            return res.status(400).json({error: 'usuario no encontrado'});
        }

        // generamos elcodigode recuperacion
        const codigo = Math.floor(100000 + Math.random() * 900000).toString(); // codigo de 6 digitos

        // guardar el codigo en la base de datos
        const {error: errorcodigo} = await codigorecupera (usuario.id, codigo);
        if (errorcodigo) {
            return res.status(500).json({error: 'error al generar codigo de recuperacion'});
        }

        // creamos el email del codigo
        await enviarCorreoBrevo({
            from: process.env.EMAIL_USER,
            to: correo,
            subject: `tu codigo de recuperacion es: ${codigo}`,
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
    Recuperación de contraseña
    </p>

    </td>
    </tr>

    <tr>
    <td style="padding:30px;">

    <p style="font-size:18px;">
    Hola <strong>${usuario.nombre || "Usuario"}</strong>,
    </p>

    <p style="color:#d8e9ff;line-height:25px;">
    Hemos recibido una solicitud para recuperar tu contraseña.
    Utiliza el siguiente código de verificación:
    </p>

    <div style="
    background:#0d1c31;
    border:2px solid #29b6f6;
    border-radius:15px;
    padding:20px;
    text-align:center;
    margin:25px 0;">

    <span style="
    font-size:42px;
    font-weight:bold;
    letter-spacing:10px;
    color:#35e27b;">
    ${codigo}
    </span>

    </div>

    <p style="color:#d8e9ff;">
    Este código será válido durante
    <strong style="color:#35e27b;">15 minutos.</strong>
    </p>

    <p style="color:#d8e9ff;">
    Si no solicitaste este cambio, simplemente ignora este correo.
    </p>

    <div style="
    margin-top:30px;
    padding:15px;
    background:#0b1728;
    border-left:5px solid #35e27b;
    border-radius:8px;">

    <strong style="color:#35e27b;">
    🔒 Consejo de seguridad
    </strong>

    <p style="margin:8px 0 0;color:#d8e9ff;">
    Nunca compartas este código con ninguna persona.
    El equipo de Megatech2 jamás lo solicitará.
    </p>

    </div>

    </td>
    </tr>

    <tr>
    <td style="
    background:#0d1c31;
    padding:18px;
    text-align:center;
    font-size:13px;
    color:#9fb8d6;">

    Gracias por utilizar
    <strong style="color:#29b6f6;">Megatech2</strong>.

    <br><br>

    © 2026 Megatech2 - Sistema de Gestión de Inventario - Tienda Tecnologica

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
        return res.status(200).json({ message: 'codigo de recuperacion enviado correctamente'});

    } catch (error) {
        console.error('Error en forgotPassword:', error);
        return res.status(500).json({ error: 'Error al procesar la solicitud' });
    }
};

// cambiar contraseña y verificar el codigo de recuperacion
export const  verificode = async  (req, res) => {
    try {
        const { correo, codigo, nuevacontraseña } = req.body;

        // verificamos las entradas
        if (!correo || !codigo || !nuevacontraseña) {
            return res.status(400).json({error: 'todos los datos son requeridos'});
        }

        // verificamos si el usuario ya esta en la base de datos 
        const {data: usuario} = await obtenercorreo(correo);
        if (!usuario) {
            return res.status(404).json({error: 'usuario no encontrado'});
        } 

        // verificamos que el correo sea correcto 
        const {data: codigorecupera} = await obtenerCodigoValido(usuario.id, codigo);
        if (!codigorecupera) {
            return res.status(400).json({error: 'codigo de recuperacion invalido o expirado'});
        }

        // encriptamos la contraseña
        const hashedcontraseña = await bcrypt.hash(nuevacontraseña, 10);

        // actualizamos la contraseña del usuario en la base de datos
        const {error: updateerror} = await actualizar(
            usuario.id, { contraseña: hashedcontraseña}
        );
        if (updateerror) throw updateerror 

        // marcamos el codigo como usado
        await marcarCodigoComoUsado(codigorecupera.id);

        // respondeos al cliemte que la contraseña se cambio correctamente
        await enviarCorreoBrevo({
            from: process.env.EMAIL_USER,
            to: correo,
            subject: 'Contraseña actualizada correctamente',
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
Contraseña Actualizada
</p>

</td>
</tr>

<tr>
<td style="padding:30px;">

<p style="font-size:18px;">
Hola <strong>${usuario.nombre || 'Usuario'}</strong>,
</p>

<p style="color:#d8e9ff;line-height:25px;">
Te informamos que tu contraseña ha sido actualizada correctamente.
</p>

<div style="
background:#0d1c31;
border:2px solid #35e27b;
border-radius:15px;
padding:20px;
text-align:center;
margin:25px 0;">

<div style="font-size:48px;">✅</div>

<h2 style="
margin:10px 0 5px;
color:#35e27b;">
Cambio realizado con éxito
</h2>

<p style="margin:0;color:#d8e9ff;">
Tu cuenta ya cuenta con la nueva contraseña.
</p>

</div>

<div style="
margin-top:25px;
padding:15px;
background:#0b1728;
border-left:5px solid #ff9800;
border-radius:8px;">

<strong style="color:#ff9800;">
⚠ Aviso de seguridad
</strong>

<p style="margin:8px 0 0;color:#d8e9ff;">
Si tú no realizaste este cambio, comunícate inmediatamente con el equipo de soporte para proteger tu cuenta.
</p>

</div>

<p style="margin-top:30px;color:#d8e9ff;">
Gracias por confiar en nosotros.
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
    });
    return res.status(200).json({message: 'contraseña actualizada'});

    } catch (error) {
        console.error('error en verifycode:', error);
        return res.status(500).json({error: 'error al procesar la solicitud'});
    }
}