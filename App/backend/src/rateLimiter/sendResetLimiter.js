// src/rateLimiter/sendResetLimiter.js
import rateLimit from 'express-rate-limit';

/**
 * Rate limiter for /send-reset-code
 * - Key is email (if provided) otherwise a normalized IP string.
 * - Normalization handles IPv4-mapped IPv6 addresses (::ffff:...) and removes zone ids (%).
 */

function normalizeIp(req) {
    // try common sources in order of trust
    const forwarded = req.headers && req.headers['x-forwarded-for'];
    const firstForwarded = typeof forwarded === 'string' ? forwarded.split(',')[0].trim() : null;
    const ipCandidate = firstForwarded || req.ip || (req.socket && req.socket.remoteAddress) || req.connection && req.connection.remoteAddress;

    if (!ipCandidate) return 'unknown';

    // remove IPv6 zone id if present (e.g. fe80::1%eth0)
    const noZone = ipCandidate.split('%')[0];

    // convert IPv4-mapped IPv6 addresses like ::ffff:127.0.0.1 -> 127.0.0.1
    const ipv4Match = noZone.match(/::ffff:(\d+\.\d+\.\d+\.\d+)$/i);
    if (ipv4Match) return ipv4Match[1];

    // if it's already an IPv4 dotted address or a plain IPv6, return as-is
    return noZone;
}

export const sendResetLimiter = rateLimit({
    windowMs: Number(process.env.RATE_LIMIT_WINDOW_MS || 600000), // 10 minutes
    max: Number(process.env.RATE_LIMIT_MAX || 5),
    message: { message: 'Too many requests, try again later' },
    standardHeaders: true,
    legacyHeaders: false,

    // keyGenerator chooses a stable key per email or per normalized IP
    keyGenerator: (req /*, res */) => {
        try {
            const email = req.body && typeof req.body.email === 'string' ? req.body.email.toLowerCase().trim() : null;
            if (email) return `email:${email}`;
            const ip = normalizeIp(req);
            return `ip:${ip}`;
        } catch (e) {
            // fallback: don't throw — rate-limit lib will raise the ERR if we do
            return 'unknown';
        }
    },

    // optional: explicit handler to return the JSON message on limit hit
    handler: (req, res /*, next */) => {
        return res.status(429).json({ message: 'Too many requests, try again later' });
    },
});
