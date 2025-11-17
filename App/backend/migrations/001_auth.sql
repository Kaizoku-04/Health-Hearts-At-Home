BEGIN;

CREATE EXTENSION IF NOT EXISTS citext;

-- Users (minimal fields for registration/login)
CREATE TABLE IF NOT EXISTS users (
  id               SERIAL PRIMARY KEY,
  name             TEXT,
  email            CITEXT UNIQUE NOT NULL,
  password_hash    TEXT NOT NULL,
  refresh_token_id TEXT,
  is_verified      BOOLEAN NOT NULL DEFAULT FALSE,
  verified_at      TIMESTAMPTZ,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at       TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Backfill constraints/columns safely if table existed before
ALTER TABLE users
  ALTER COLUMN email SET NOT NULL,
  ALTER COLUMN password_hash SET NOT NULL,
  ALTER COLUMN is_verified SET NOT NULL,
  ALTER COLUMN created_at SET DEFAULT now(),
  ALTER COLUMN updated_at SET DEFAULT now();

-- Password resets (tokenized)
CREATE TABLE IF NOT EXISTS password_resets (
  id          SERIAL PRIMARY KEY,
  email       CITEXT NOT NULL,
  token_hash  TEXT NOT NULL,
  expires_at  TIMESTAMPTZ NOT NULL,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  consumed_at TIMESTAMPTZ
);

-- rename old code_hash -> token_hash if it exists
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name='password_resets' AND column_name='code_hash'
  ) AND NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name='password_resets' AND column_name='token_hash'
  ) THEN
    ALTER TABLE password_resets RENAME COLUMN code_hash TO token_hash;
  END IF;
END$$;

CREATE INDEX IF NOT EXISTS idx_password_resets_email   ON password_resets(email);
CREATE INDEX IF NOT EXISTS idx_password_resets_expires ON password_resets(expires_at);

-- One active reset per email
CREATE UNIQUE INDEX IF NOT EXISTS uq_pw_reset_active
  ON password_resets(email)
  WHERE consumed_at IS NULL;

-- Email verifications
CREATE TABLE IF NOT EXISTS email_verifications (
  id          SERIAL PRIMARY KEY,
  email       CITEXT NOT NULL,
  token_hash  TEXT NOT NULL,
  expires_at  TIMESTAMPTZ NOT NULL,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  consumed_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_email_verifications_email   ON email_verifications(email);
CREATE INDEX IF NOT EXISTS idx_email_verifications_expires ON email_verifications(expires_at);

-- One active verification per email
CREATE UNIQUE INDEX IF NOT EXISTS uq_email_verify_active
  ON email_verifications(email)
  WHERE consumed_at IS NULL;

-- updated_at helper (auto-update updated_at on row changes)
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END; $$ LANGUAGE plpgsql;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'users_set_updated_at') THEN
    CREATE TRIGGER users_set_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE PROCEDURE set_updated_at();
  END IF;
END$$;

COMMIT;
