const nodemailer = require('nodemailer');
require('dotenv').config();

const smtpPort = parseInt(process.env.SMTP_PORT) || 465;

const transporter = nodemailer.createTransport({
  host: process.env.SMTP_HOST,
  port: smtpPort,
  secure: smtpPort === 465,
  auth: {
    user: process.env.SMTP_USER,
    pass: process.env.SMTP_PASS
  },
  tls: { rejectUnauthorized: false }
});

/**
 * Email gönder
 */
async function sendMail(to, subject, text, html) {
  try {
    await transporter.sendMail({
      from: process.env.SMTP_SENDER || process.env.SMTP_USER,
      to,
      subject,
      text,
      html
    });
    console.log(`[SMTP] Email gönderildi: ${to}`);
    return true;
  } catch (err) {
    console.error(`[SMTP] Email gönderilemedi: ${to}`, err.message);
    return false;
  }
}

function sendWelcomeEmail(to, password) {
  const text = `Tulpar Kilit - Hesabiniz olusturuldu.\n\nE-posta: ${to}\nSifre: ${password}\n\nGiris yaptiktan sonra sifrenizi degistirebilirsiniz.`;
  const html = `
    <div style="font-family:Arial,sans-serif;max-width:480px;margin:0 auto;padding:24px">
      <h2 style="color:#0d1b2a">Tulpar Kilit</h2>
      <p>Hesabiniz basariyla olusturuldu.</p>
      <p><b>E-posta:</b> ${to}</p>
      <p><b>Sifre:</b> <span style="color:#00b4b4;font-size:1.1em">${password}</span></p>
      <p>Giris yaptiktan sonra sifrenizi degistirebilirsiniz.</p>
    </div>`;
  return sendMail(to, 'Tulpar Kilit - Hesap Bilgileriniz', text, html);
}

function sendResetEmail(to, newPassword) {
  const text = `Tulpar Kilit - Sifreniz sifirlandi.\n\nYeni sifreniz: ${newPassword}\n\nGiris yaptiktan sonra sifrenizi degistirebilirsiniz.`;
  const html = `
    <div style="font-family:Arial,sans-serif;max-width:480px;margin:0 auto;padding:24px">
      <h2 style="color:#0d1b2a">Tulpar Kilit</h2>
      <p>Sifreniz sifirlandi.</p>
      <p><b>Yeni sifreniz:</b> <span style="color:#00b4b4;font-size:1.2em">${newPassword}</span></p>
      <p>Giris yaptiktan sonra sifrenizi degistirebilirsiniz.</p>
    </div>`;
  return sendMail(to, 'Tulpar Kilit - Sifre Sifirlama', text, html);
}

function sendInstitutionNotification(institutionEmail, userName, userEmail, institutionName) {
  const text = `Tulpar Kilit - ${institutionName} kurumuna yeni kullanici kaydoldu: ${userEmail}`;
  const html = `
    <div style="font-family:Arial,sans-serif;max-width:480px;margin:0 auto;padding:24px">
      <h2 style="color:#0d1b2a">Tulpar Kilit</h2>
      <p>${institutionName} kurumuna yeni bir kullanici kaydoldu.</p>
      <p><b>Kullanici:</b> ${userEmail}</p>
    </div>`;
  return sendMail(institutionEmail, 'Tulpar Kilit - Yeni Kullanici Kaydi', text, html);
}

module.exports = { sendMail, sendWelcomeEmail, sendResetEmail, sendInstitutionNotification };
