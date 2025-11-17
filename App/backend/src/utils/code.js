// src/utils/code.js
import crypto from 'crypto';

/**
 * Generate a numeric reset code of given length using a cryptographically
 * secure RNG (crypto.randomInt). Falls back to 6 digits when env is missing/invalid.
 *
 * Returns a string with leading zeros preserved when applicable.
 */
export function generateCode() {
    const len = Math.max(1, Math.floor(Number(process.env.RESET_CODE_LENGTH) || 6));

    // cap length to avoid extremely large numbers (sane safety bound)
    const safeLen = Math.min(len, 12);

    const min = 10 ** (safeLen - 1);
    const max = 10 ** safeLen - 1;

    // crypto.randomInt is cryptographically secure and returns an integer in [min, max]
    const code = crypto.randomInt(min, max + 1);

    // ensure string length (pad with leading zeros if user set len that produces them)
    return String(code).padStart(safeLen, '0');
}

/**
 * Hash a value (e.g. reset code) using SHA-256 and return hex digest.
 */
export function hashValue(value) {
    return crypto.createHash('sha256').update(String(value)).digest('hex');
}
