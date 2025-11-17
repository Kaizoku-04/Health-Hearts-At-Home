// data/database.js
import pg from 'pg';
import 'dotenv/config';

const { Pool } = pg;

const pool = new Pool({
  connectionString: process.env.DATABASE_URL || undefined,
  host: process.env.PGHOST,
  port: process.env.PGPORT ? Number(process.env.PGPORT) : undefined,
  user: process.env.PGUSER,
  password: process.env.PGPASSWORD,
  database: process.env.PGDATABASE,
  max: Number(process.env.PG_POOL_MAX || 10),
  idleTimeoutMillis: Number(process.env.PG_IDLE_TIMEOUT_MS || 30000),
  connectionTimeoutMillis: Number(process.env.PG_CONN_TIMEOUT_MS || 2000),
  ssl: process.env.PGSSL === 'true' ? { rejectUnauthorized: false } : false,
  // optional hardening:
  allowExitOnIdle: false,
  keepAlive: true,
  maxUses: Number(process.env.PG_MAX_USES || 0), // 0 = unlimited; e.g. set 10000 in prod
});

pool.on('error', (err) => {
  console.error('Unexpected error on idle PostgreSQL client', err);
});

export async function query(text, params) {
  return pool.query(text, params);
}

export { pool };

// optional: clean shutdown helper
export async function close() {
  await pool.end();
}

// Init / migrations (only auth/entry related)
export async function init() {
  if (process.env.DB_INIT === 'false') {
    console.log('DB init skipped (DB_INIT=false)');
    return;
  }

  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    // citext for case-insensitive email/username handling
    await client.query(`CREATE EXTENSION IF NOT EXISTS citext;`);

    // Users table (minimal fields for registration/login)
    await client.query(`
      CREATE TABLE IF NOT EXISTS users (
        id SERIAL PRIMARY KEY,
        name TEXT,
        email CITEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        refresh_token_id TEXT,
        is_verified BOOLEAN NOT NULL DEFAULT FALSE,
        verified_at TIMESTAMPTZ,
        created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
        updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
      );
    `);

    // Updated-at trigger to auto-update updated_at on row changes
    await client.query(`
      CREATE OR REPLACE FUNCTION set_updated_at()
      RETURNS TRIGGER AS $$
      BEGIN
        NEW.updated_at = now();
        RETURN NEW;
      END;
      $$ LANGUAGE plpgsql;
    `);

    await client.query(`
      DO $$
      BEGIN
        IF NOT EXISTS (
          SELECT 1 FROM pg_trigger WHERE tgname = 'users_set_updated_at'
        ) THEN
          CREATE TRIGGER users_set_updated_at
          BEFORE UPDATE ON users
          FOR EACH ROW EXECUTE PROCEDURE set_updated_at();
        END IF;
      END$$;
    `);

    // Password resets (for "forgot password" flows)
    await client.query(`
      CREATE TABLE IF NOT EXISTS password_resets (
        id SERIAL PRIMARY KEY,
        email CITEXT NOT NULL,
        token_hash TEXT NOT NULL,
        expires_at TIMESTAMPTZ NOT NULL,
        created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
        consumed_at TIMESTAMPTZ
      );
    `);
    await client.query(`CREATE INDEX IF NOT EXISTS idx_password_resets_email ON password_resets(email);`);
    await client.query(`CREATE INDEX IF NOT EXISTS idx_password_resets_expires ON password_resets(expires_at);`);
    // At most one active reset per email:
    await client.query(`
      CREATE UNIQUE INDEX IF NOT EXISTS uq_pw_reset_active
      ON password_resets(email)
      WHERE consumed_at IS NULL;
    `);
    await client.query(`
      CREATE INDEX IF NOT EXISTS idx_password_resets_active_exp
      ON password_resets(expires_at)
      WHERE consumed_at IS NULL;
    `);

    // Email verifications (for sign-up confirmation flows)
    await client.query(`
      CREATE TABLE IF NOT EXISTS email_verifications (
        id SERIAL PRIMARY KEY,
        email CITEXT NOT NULL,
        token_hash TEXT NOT NULL,
        expires_at TIMESTAMPTZ NOT NULL,
        created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
        consumed_at TIMESTAMPTZ
      ); 
    `);
    await client.query(`CREATE INDEX IF NOT EXISTS idx_email_verifications_email ON email_verifications(email);`);
    await client.query(`CREATE INDEX IF NOT EXISTS idx_email_verifications_expires ON email_verifications(expires_at);`);
    // One active verification per email:
    await client.query(`
      CREATE UNIQUE INDEX IF NOT EXISTS uq_email_verify_active
      ON email_verifications(email)
      WHERE consumed_at IS NULL;
    `);
    await client.query(`
      CREATE INDEX IF NOT EXISTS idx_email_verifications_active_exp
      ON email_verifications(expires_at)
      WHERE consumed_at IS NULL;
    `);

    await client.query('COMMIT');
    console.log('Postgres auth schema ensured');
  } catch (err) {
    await client.query('ROLLBACK');
    console.error('Failed to init DB schema', err);
    throw err;
  } finally {
    client.release();
  }
}

export default { pool, query, init, close };
