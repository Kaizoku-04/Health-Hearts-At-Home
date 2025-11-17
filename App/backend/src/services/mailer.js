// src/services/mailer.js
import { MailerSend, EmailParams, Sender, Recipient } from 'mailersend';

const MAILERSEND_API_KEY = process.env.MAILERSEND_API_KEY;
const MAIL_FROM_EMAIL = process.env.MAILERSEND_FROM_EMAIL;
const MAIL_FROM_NAME = process.env.MAILERSEND_FROM_NAME || 'Your App';

function mailerDisabled() {
  return !MAILERSEND_API_KEY || !MAIL_FROM_EMAIL;
}

let client = null;
function getMailerClient() {
  if (mailerDisabled()) return null;
  if (!client) client = new MailerSend({ apiKey: MAILERSEND_API_KEY });
  return client;
}

export async function sendEmail({ to, subject, text, html }) {
  if (!to) throw new Error('sendEmail: "to" required');

  const msClient = getMailerClient();
  if (!msClient) {
    console.warn('MailerSend not configured; skipping sendEmail');
    return { ok: false, skipped: true };
  }

  const sentFrom = new Sender(MAIL_FROM_EMAIL, MAIL_FROM_NAME);
  const recipients = [new Recipient(to)];

  const emailParams = new EmailParams()
    .setFrom(sentFrom)
    .setTo(recipients)
    .setSubject(subject)
    .setText(text || '')
    .setHtml(html || '');

  try {
    const result = await msClient.email.send(emailParams);
    return result;
  } catch (err) {
    console.error('mailersend send error', err);
    throw err;
  }
}

export default sendEmail;
