// src/middlewares/auth.js
import { verifyAccessToken } from '../utils/jwt.js';
import * as userModel from '../models/userModel.js';

export default function authMiddlewareFactory(opts = {}) {
    // opts could include requiredRole / requireActive etc.
    return async function authMiddleware(req, res, next) {
        try {
            const authHeader = req.headers.authorization || req.headers.Authorization;
            if (!authHeader) {
                res.set('WWW-Authenticate', 'Bearer realm="api"');
                return res.status(401).json({ message: 'missing auth' });
            }

            // Accept: "Bearer <token>" (case-insensitive)
            const parts = authHeader.split(' ');
            if (parts.length !== 2) {
                res.set('WWW-Authenticate', 'Bearer realm="api"');
                return res.status(401).json({ message: 'invalid authorization header format' });
            }
            const scheme = parts[0];
            const token = parts[1];
            if (!/^Bearer$/i.test(scheme) || !token) {
                res.set('WWW-Authenticate', 'Bearer realm="api"');
                return res.status(401).json({ message: 'missing token' });
            }

            // verify token (may throw on invalid/expired)
            const payload = await verifyAccessToken(token);
            // prefer named userId or id
            const userId = payload?.userId ?? payload?.id ?? payload?.sub;

            if (!userId) {
                res.set('WWW-Authenticate', 'Bearer realm="api", error="invalid_token"');
                return res.status(401).json({ message: 'invalid access token (no subject)' });
            }

            // ensure user still exists
            const user = await userModel.findUserById(userId);
            if (!user) {
                res.set('WWW-Authenticate', 'Bearer realm="api", error="invalid_token"');
                return res.status(401).json({ message: 'user not found' });
            }

            // Optional: revoke/rotation checks (example)
            // if (payload.tokenId && user.refresh_token_id && payload.tokenId !== user.refresh_token_id) {
            //   return res.status(401).json({ message: 'token revoked' });
            // }

            req.userId = user.id;
            req.user = user;
            return next();
        } catch (err) {
            // Could inspect err.name/message to vary response for expired vs invalid tokens
            res.set('WWW-Authenticate', 'Bearer realm="api", error="invalid_token"');
            return res.status(401).json({ message: 'invalid or expired access token' });
        }
    };
}

// usage:
// import authMiddlewareFactory from './middlewares/auth.js';
// const authMiddleware = authMiddlewareFactory();
// app.use('/api', authMiddleware);
