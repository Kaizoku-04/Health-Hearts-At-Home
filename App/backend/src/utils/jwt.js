// src/utils/jwt.js
import jwt from 'jsonwebtoken';
import { v4 as uuidv4 } from 'uuid';

const ACCESS_SECRET = process.env.JWT_ACCESS_SECRET;
const REFRESH_SECRET = process.env.JWT_REFRESH_SECRET;
const ACCESS_EXP = process.env.ACCESS_TOKEN_EXPIRES_IN || '15m';
const REFRESH_EXP = process.env.REFRESH_TOKEN_EXPIRES_IN || '7d';

if (!ACCESS_SECRET) {
    console.warn('JWT_ACCESS_SECRET is not set. Tokens will not be secure.');
}
if (!REFRESH_SECRET) {
    console.warn('JWT_REFRESH_SECRET is not set. Refresh tokens will not be secure.');
}

export function createAccessToken(user) {
    if (!ACCESS_SECRET) throw new Error('Missing ACCESS_SECRET');
    return jwt.sign({ userId: user.id }, ACCESS_SECRET, { expiresIn: ACCESS_EXP });
}

export function createRefreshToken(userId, tokenId) {
    if (!REFRESH_SECRET) throw new Error('Missing REFRESH_SECRET');
    return jwt.sign({ userId, tokenId }, REFRESH_SECRET, { expiresIn: REFRESH_EXP });
}

export function verifyAccessToken(token) {
    try {
        return jwt.verify(token, ACCESS_SECRET);
    } catch (err) {
        const message = err && err.name === 'TokenExpiredError' ? 'access token expired' : 'invalid access token';
        const e = new Error(message);
        e.original = err;
        throw e;
    }
}

export function verifyRefreshToken(token) {
    try {
        return jwt.verify(token, REFRESH_SECRET);
    } catch (err) {
        const message = err && err.name === 'TokenExpiredError' ? 'refresh token expired' : 'invalid refresh token';
        const e = new Error(message);
        e.original = err;
        throw e;
    }
}

export function makeNewTokenId() {
    return uuidv4();
}
