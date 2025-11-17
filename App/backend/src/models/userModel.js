// src/models/userModel.js
// PostgreSQL async model using db.query()
// Exports async functions that return rows / null similar to the previous API.

import db from '../../data/database.js';

// Helper: normalize email consistently in one place
function normalizeEmail(email) {
  return String(email || '').trim().toLowerCase();
}

/*
  Note: the DB uses CITEXT for the email column, so equality checks can use
  `email = $1` safely (CITEXT provides case-insensitive comparisons).
*/

/* ---- Users ---- */
export async function findUserByEmail(email) {
  const e = normalizeEmail(email);
  const sql = `
    SELECT id, name, email, password_hash, refresh_token_id, is_verified, verified_at, created_at, updated_at
    FROM users
    WHERE email = $1
    LIMIT 1
  `;
  const res = await db.query(sql, [e]);
  return res.rows[0] || null;
}

export async function findUserById(id) {
  const sql = `
    SELECT id, name, email, password_hash, refresh_token_id, is_verified, verified_at, created_at, updated_at
    FROM users
    WHERE id = $1
    LIMIT 1
  `;
  const res = await db.query(sql, [id]);
  return res.rows[0] || null;
}

export async function createUser({ name, email, password_hash, is_verified = false, verified_at = null }) {
  const e = normalizeEmail(email);
  const sql = `
    INSERT INTO users (name, email, password_hash, is_verified, verified_at)
    VALUES ($1, $2, $3, $4, $5)
    RETURNING id, name, email, password_hash, refresh_token_id, is_verified, verified_at, created_at, updated_at
  `;
  const res = await db.query(sql, [name || null, e, password_hash, is_verified, verified_at]);
  return res.rows[0] || null;
}

export async function updateUserRefreshId(userId, tokenId) {
  const sql = `UPDATE users SET refresh_token_id = $1, updated_at = now() WHERE id = $2 RETURNING id`;
  const res = await db.query(sql, [tokenId, userId]);
  return res.rowCount > 0;
}

export async function updateUserPassword(userId, newHash) {
  const sql = `UPDATE users SET password_hash = $1, updated_at = now() WHERE id = $2 RETURNING id`;
  const res = await db.query(sql, [newHash, userId]);
  return res.rowCount > 0;
}

/* ---- Password reset helpers ----
   We store only HMAC/token_hash in DB (controllers send raw code/token to user via email).
   saveResetCodeToDb is transactional: delete existing active entries then insert new one.
*/
export async function saveResetCodeToDb(email, tokenHash, expiresAt) {
  const e = normalizeEmail(email);
  const client = await db.pool.connect();
  try {
    await client.query('BEGIN');
    // remove any active (unconsumed) resets for this email
    await client.query(`DELETE FROM password_resets WHERE email = $1 AND consumed_at IS NULL`, [e]);
    const sql = `
      INSERT INTO password_resets (email, token_hash, expires_at, created_at)
      VALUES ($1, $2, $3, now())
      RETURNING id, email, token_hash, expires_at, created_at
    `;
    const res = await client.query(sql, [e, tokenHash, new Date(expiresAt)]);
    await client.query('COMMIT');
    return res.rows[0] || null;
  } catch (err) {
    await client.query('ROLLBACK').catch(() => { });
    throw err;
  } finally {
    client.release();
  }
}

export async function getResetEntryFromDb(email) {
  const e = normalizeEmail(email);
  const sql = `
    SELECT id, email, token_hash, expires_at, created_at, consumed_at
    FROM password_resets
    WHERE email = $1
      AND consumed_at IS NULL
    ORDER BY id DESC
    LIMIT 1
  `;
  const res = await db.query(sql, [e]);
  return res.rows[0] || null;
}

export async function deleteResetEntry(id) {
  const sql = `DELETE FROM password_resets WHERE id = $1`;
  await db.query(sql, [id]);
  return true;
}

export async function deleteResetEntriesByEmail(email) {
  const e = normalizeEmail(email);
  const sql = `DELETE FROM password_resets WHERE email = $1`;
  await db.query(sql, [e]);
  return true;
}

/* ---- Email verification helpers ----
   Similar pattern: ensure only one active verification exists (transactional insert after deleting any active ones).
*/
export async function saveEmailVerificationToDb(email, tokenHash, expiresAt) {
  const e = normalizeEmail(email);
  const client = await db.pool.connect();
  try {
    await client.query('BEGIN');
    await client.query(`DELETE FROM email_verifications WHERE email = $1 AND consumed_at IS NULL`, [e]);
    const sql = `
      INSERT INTO email_verifications (email, token_hash, expires_at, created_at)
      VALUES ($1, $2, $3, now())
      RETURNING id, email, token_hash, expires_at, created_at
    `;
    const res = await client.query(sql, [e, tokenHash, new Date(expiresAt)]);
    await client.query('COMMIT');
    return res.rows[0] || null;
  } catch (err) {
    await client.query('ROLLBACK').catch(() => { });
    throw err;
  } finally {
    client.release();
  }
}

export async function getEmailVerificationFromDb(email) {
  const e = normalizeEmail(email);
  const sql = `
    SELECT id, email, token_hash, expires_at, created_at, consumed_at
    FROM email_verifications
    WHERE email = $1
      AND consumed_at IS NULL
    ORDER BY id DESC
    LIMIT 1
  `;
  const res = await db.query(sql, [e]);
  return res.rows[0] || null;
}

export async function markUserAsVerified(email) {
  const e = normalizeEmail(email);
  const sql = `UPDATE users SET is_verified = true, verified_at = now(), updated_at = now() WHERE email = $1 RETURNING id`;
  const res = await db.query(sql, [e]);
  return res.rowCount > 0;
}

export async function deleteEmailVerification(id) {
  const sql = `DELETE FROM email_verifications WHERE id = $1`;
  await db.query(sql, [id]);
  return true;
}
