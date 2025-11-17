// src/controllers/authController.js
import bcrypt from 'bcrypt';
import { OAuth2Client } from 'google-auth-library';
import {
    makeNewTokenId,
    createAccessToken,
    createRefreshToken,
    verifyRefreshToken
} from '../utils/jwt.js';
import * as userModel from '../models/userModel.js';
import { sendEmail } from '../services/mailer.js';
import crypto from 'crypto';
import { generateCode } from '../utils/code.js';

const ACCESS_CLIENT_ID = process.env.GOOGLE_WEB_CLIENT_ID;
const ACCESS_CLIENT_SECRET = process.env.GOOGLE_CLIENT_SECRET;
const VERIFY_TOKEN_SECRET = process.env.VERIFY_TOKEN_SECRET;

if (!process.env.JWT_ACCESS_SECRET || !process.env.JWT_REFRESH_SECRET) {
    throw new Error('Missing JWT secrets');
}
if (!VERIFY_TOKEN_SECRET) {
    throw new Error('Missing VERIFY_TOKEN_SECRET');
}

const isEmail = (v) => typeof v === 'string' && v.includes('@') && v.length <= 254;
function hmacHex(s) {
    return crypto.createHmac('sha256', VERIFY_TOKEN_SECRET).update(String(s)).digest('hex');
}
function timingSafeEqHex(a, b) {
    try {
        const A = Buffer.from(String(a), 'hex');
        const B = Buffer.from(String(b), 'hex');
        return A.length === B.length && crypto.timingSafeEqual(A, B);
    } catch { return false; }
}

// Some userModel methods return { rows: [...] } while others return plain objects.
// Normalize to a single user object or null.
function normalizeUser(result) {
    if (!result) return null;
    if (result.rows && Array.isArray(result.rows)) return result.rows[0] || null;
    return result;
}

/* Signup */
export async function signupHandler(req, res) {
    try {
        let { name, email, password } = req.body || {};
        if (!name || !isEmail(email) || !password) {
            return res.status(400).json({ message: 'missing or invalid fields' });
        }
        email = email.trim().toLowerCase();

        const existing = normalizeUser(await userModel.findUserByEmail(email));
        if (existing) return res.status(409).json({ message: 'email already in use' });

        const saltRounds = Number(process.env.BCRYPT_SALT_ROUNDS || 10);
        const password_hash = await bcrypt.hash(password, saltRounds);

        const user = normalizeUser(await userModel.createUser({
            name, email, password_hash
        }));

        const ttlHours = Number(process.env.VERIFY_TOKEN_EXPIRES_HOURS || 24);
        const token = crypto.randomBytes(32).toString('hex');
        const tokenHash = hmacHex(token);
        const expiresAt = new Date(Date.now() + ttlHours * 3600 * 1000).toISOString();
        await userModel.saveEmailVerificationToDb(email, tokenHash, expiresAt);

        const verifyLink = `${process.env.BASE_URL || 'http://192.168.1.155:4000'}/verify-email?email=${encodeURIComponent(email)}&token=${token}`;
        try {
            await sendEmail({
                to: email,
                subject: 'Verify your email',
                text: `Verify your email: ${verifyLink}\nThis link expires in ${ttlHours} hours.`,
                html: `<p>Verify your email by clicking <a href="${verifyLink}">this link</a>.</p><p>Expires in ${ttlHours} hours.</p>`
            });
        } catch (mailErr) {
            console.error('verify email send failed', mailErr);
        }

        return res.status(201).json({
            message: 'Account created. Please verify your email before logging in.',
            user: { id: user?.id, name: user?.name, email: user?.email, is_verified: user.is_verified }
        });
    } catch (err) {
        console.error('signup error', err);
        return res.status(500).json({ message: 'server error' });
    }
}

/* Login */
export async function loginHandler(req, res) {
    try {
        let { email, password } = req.body;
        if (!email || !password) return res.status(400).json({ message: 'missing email or password' });

        email = email.trim().toLowerCase();
        const user = normalizeUser(await userModel.findUserByEmail(email));

        if (!user || !user.password_hash) return res.status(401).json({ message: 'invalid credentials' });

        const ok = await bcrypt.compare(password, user.password_hash);
        if (!ok) return res.status(401).json({ message: 'invalid credentials' });

        if (!user.is_verified) {
            // re-send verification link asynchronously (best-effort)
            (async () => {
                try {
                    const token = crypto.randomBytes(32).toString('hex');
                    const tokenHash = hmacHex(token);
                    const ttlHours = Number(process.env.VERIFY_TOKEN_EXPIRES_HOURS || 24);
                    const expiresAt = new Date(Date.now() + ttlHours * 3600 * 1000).toISOString();

                    await userModel.saveEmailVerificationToDb(user.email.toLowerCase(), tokenHash, expiresAt);
                    const link = `${process.env.BASE_URL || 'http://192.168.1.155:4000'}/verify-email?email=${encodeURIComponent(user.email)}&token=${token}`;
                    await sendEmail({
                        to: user.email,
                        subject: 'Verify your email',
                        text: `Verify: ${link}\nThis link expires in ${ttlHours} hours.`,
                        html: `<p>Please verify your email: <a href="${link}">Verify account</a></p><p>Expires in ${ttlHours} hours.</p>`
                    });
                } catch (_) { /* best-effort only */ }
            })();

            return res.status(403).json({ message: 'Email not verified. We re-sent your verification link.' });
        }

        const tokenId = makeNewTokenId();
        await userModel.updateUserRefreshId(user.id, tokenId);

        const accessToken = createAccessToken({ id: user.id });
        const refreshToken = createRefreshToken(user.id, tokenId);

        return res.json({
            user: {
                id: user.id,
                name: user.name,
                email: user.email,
                is_verified: user.is_verified,
            },
            accessToken,
            refreshToken
        });
    } catch (err) {
        console.error('login error', err);
        return res.status(500).json({ message: 'server error' });
    }
}

/* Refresh */
export async function refreshHandler(req, res) {
    try {
        const { refreshToken } = req.body;
        if (!refreshToken) return res.status(400).json({ message: 'missing refresh token' });

        const payload = verifyRefreshToken(refreshToken);
        const { userId, tokenId } = payload;

        const user = normalizeUser(await userModel.findUserById(userId));
        if (!user) return res.status(401).json({ message: 'invalid token' });

        if (!user.refresh_token_id || user.refresh_token_id !== tokenId) {
            return res.status(401).json({ message: 'invalid token (rotated or revoked)' });
        }

        const newTokenId = makeNewTokenId();
        await userModel.updateUserRefreshId(userId, newTokenId);

        const newAccessToken = createAccessToken({ id: userId });
        const newRefreshToken = createRefreshToken(userId, newTokenId);

        return res.json({ accessToken: newAccessToken, refreshToken: newRefreshToken });
    } catch (err) {
        console.error('refresh error', err);
        return res.status(401).json({ message: 'invalid refresh token' });
    }
}

/* Logout */
export async function logoutHandler(req, res) {
    try {
        const { userId } = req.userId ? req.userId : req.body;
        if (!userId) return res.status(401).json({ message: 'unauthorized' });
        await userModel.updateUserRefreshId(userId, null);
        return res.json({ ok: true });
    } catch (err) {
        console.error('logout error', err);
        return res.status(500).json({ message: 'server error' });
    }
}

/* Me */
export async function meHandler(req, res) {
    const user = normalizeUser(await userModel.findUserById(req.userId));
    if (!user) return res.status(404).json({ message: 'not found' });
    return res.json({ id: user.id, name: user.name, email: user.email });
}

/* Google OAuth sign-in / sign-up */
export async function googleHandler(req, res) {
    const { code, idToken, redirectUri } = req.body;
    if (!code && !idToken) return res.status(400).json({ message: 'provide code (serverAuthCode) or idToken' });

    if (!ACCESS_CLIENT_ID) {
        console.error('GOOGLE client id missing (ACCESS_CLIENT_ID)');
        return res.status(500).json({ message: 'Server configuration error' });
    }
    if (code && !ACCESS_CLIENT_SECRET) {
        console.warn('GOOGLE client secret missing (ACCESS_CLIENT_SECRET). Code exchange may fail.');
    }

    try {
        let payload;

        if (idToken) {
            const clientForVerify = new OAuth2Client(ACCESS_CLIENT_ID);
            const ticket = await clientForVerify.verifyIdToken({ idToken, audience: ACCESS_CLIENT_ID });
            payload = ticket.getPayload();
        } else {
            const oauth2Client = new OAuth2Client(ACCESS_CLIENT_ID, ACCESS_CLIENT_SECRET);
            let tokenResponse;
            try {
                if (redirectUri) tokenResponse = await oauth2Client.getToken({ code, redirect_uri: redirectUri });
                else tokenResponse = await oauth2Client.getToken(code);
            } catch (ex) {
                // fallback
                tokenResponse = await oauth2Client.getToken(code);
            }
            const tokens = tokenResponse.tokens ?? tokenResponse;
            oauth2Client.setCredentials(tokens);

            if (tokens.id_token) {
                const ticket = await oauth2Client.verifyIdToken({ idToken: tokens.id_token, audience: ACCESS_CLIENT_ID });
                payload = ticket.getPayload();
            } else if (tokens.access_token) {
                const info = await oauth2Client.getTokenInfo(tokens.access_token);
                payload = {
                    email: info.email,
                    name: info.email ? info.email.split('@')[0] : undefined,
                    sub: info.user_id || info.sub,
                };
            } else {
                return res.status(400).json({ message: 'no usable token (id_token/access_token) received from Google' });
            }
        }

        let { email, name } = payload || {};
        if (!email) return res.status(400).json({ message: 'email not provided by Google' });
        const normalizedEmail = email.trim().toLowerCase();
        let user = normalizeUser(await userModel.findUserByEmail(normalizedEmail));
        if (!user) {
            user = normalizeUser(await userModel.createUser({
                name: name || email.split('@')[0],
                email: normalizedEmail,
                password_hash: null,
                is_verified: true,
                verified_at: new Date()
            }));
        }

        const tokenId = makeNewTokenId();
        await userModel.updateUserRefreshId(user.id, tokenId);
        const accessToken = createAccessToken({ id: user.id });
        const refreshToken = createRefreshToken(user.id, tokenId);

        return res.json({
            user: { id: user.id, name: user.name, email: user.email },
            accessToken,
            refreshToken,
        });
    } catch (error) {
        console.error('Google OAuth error:', error);
        if (error && error.message && error.message.includes('invalid_grant')) {
            return res.status(400).json({ message: 'invalid or expired authorization code' });
        }
        return res.status(500).json({ message: 'Google authentication failed' });
    }
}

/* Send password reset code (via email) */
export async function sendResetCodeHandler(req, res) {
    try {
        let { email } = req.body || {};
        if (!isEmail(email)) return res.status(400).json({ message: 'Email required' });
        email = email.trim().toLowerCase();

        const user = normalizeUser(await userModel.findUserByEmail(email));
        if (!user) return res.json({ ok: true }); // do not reveal existence

        const code = generateCode();
        const codeHash = hmacHex(code);
        const expiresMin = Number(process.env.RESET_CODE_EXPIRES_MINUTES || 15);
        const expiresAt = new Date(Date.now() + expiresMin * 60 * 1000).toISOString();

        await userModel.deleteResetEntriesByEmail(email);
        await userModel.saveResetCodeToDb(email, codeHash, expiresAt);

        await sendEmail({
            to: email,
            subject: 'Password reset code',
            text: `Your reset code is: ${code}\nIt expires in ${expiresMin} minutes.`,
            html: `<p>Your reset code is: <b>${code}</b></p><p>It expires in ${expiresMin} minutes.</p>`
        });
        return res.json({ ok: true });
    } catch (err) {
        console.error('send-reset-code error', err);
        return res.status(500).json({ message: 'Failed to send email' });
    }
}

/* Verify reset code (step 1: only verify email + code) */
export async function verifyResetHandler(req, res) {
    try {
        let { email, code } = req.body || {};
        if (!email || !code) return res.status(400).json({ message: 'Missing parameters' });

        const normalizedEmail = String(email).trim().toLowerCase();

        // fetch the latest non-consumed reset entry for this email
        const entry = await userModel.getResetEntryFromDb(normalizedEmail);
        if (!entry) return res.status(400).json({ message: 'Invalid or expired code' });

        // check expiry
        const expiresMs = new Date(entry.expires_at).getTime();
        if (Date.now() > expiresMs) {
            // remove expired entry for hygiene
            try { await userModel.deleteResetEntry(entry.id); } catch (_) { /* best effort */ }
            return res.status(400).json({ message: 'Code expired' });
        }

        // timing-safe compare between HMAC(code) and stored token_hash
        if (!timingSafeEqHex(hmacHex(String(code)), entry.token_hash)) {
            return res.status(400).json({ message: 'Invalid code' });
        }

        // SUCCESS: code is valid
        // NOTE: we do NOT consume/delete the reset entry here so the client can proceed
        // to the "enter new password" step and call confirm-reset which will perform
        // the actual password change and then delete/consume the entry.
        // If you prefer to make verify a one-time operation, call
        // await userModel.deleteResetEntry(entry.id) here instead.
        return res.json({ ok: true, message: 'Code verified' });
    } catch (err) {
        console.error('verify-reset error', err);
        return res.status(500).json({ message: 'Server error' });
    }
}


/* Confirm password reset using code */
export async function confirmResetHandler(req, res) {
    try {
        let { email, code, newPassword } = req.body;
        if (!email || !code || !newPassword) return res.status(400).json({ message: 'Missing parameters' });

        const entry = await userModel.getResetEntryFromDb(email);
        if (!entry) return res.status(400).json({ message: 'Invalid or expired code' });

        if (Date.now() > new Date(entry.expires_at).getTime()) {
            await userModel.deleteResetEntry(entry.id);
            return res.status(400).json({ message: 'Code expired' });
        }

        if (!timingSafeEqHex(hmacHex(String(code)), entry.token_hash)) {
            return res.status(400).json({ message: 'Invalid code' });
        }

        const saltRounds = Number(process.env.BCRYPT_SALT_ROUNDS || 10);
        const hashed = await bcrypt.hash(newPassword, saltRounds);
        const user = normalizeUser(await userModel.findUserByEmail(email));
        if (!user) return res.status(404).json({ message: 'User not found' });

        await userModel.updateUserPassword(user.id, hashed);
        await userModel.updateUserRefreshId(user.id, null);
        await userModel.deleteResetEntry(entry.id);

        return res.json({ ok: true });
    } catch (err) {
        console.error('confirm-reset error', err);
        return res.status(500).json({ message: 'Server error' });
    }
}

/* Verify email (link token) */
export async function verifyEmailHandler(req, res) {
    try {
        const { email, token } = req.query;
        if (!email || !token) return res.status(400).json({ message: 'Missing parameters' });

        const entry = await userModel.getEmailVerificationFromDb(email);
        if (!entry) return res.status(400).json({ message: 'Invalid or expired token' });

        if (Date.now() > new Date(entry.expires_at).getTime()) {
            return res.status(400).json({ message: 'Token expired' });
        }

        if (!timingSafeEqHex(hmacHex(token), entry.token_hash)) {
            return res.status(400).json({ message: 'Invalid token' });
        }

        await userModel.markUserAsVerified(email);
        await userModel.deleteEmailVerification(entry.id);

        return res.json({ ok: true });
    } catch (err) {
        console.error('verify-email error', err);
        return res.status(500).json({ message: 'Server error' });
    }
}
