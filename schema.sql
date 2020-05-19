BEGIN;

-- drop all existing tables
DROP TABLE IF EXISTS td.users_scopes;
DROP TABLE IF EXISTS td.users;
DROP TABLE IF EXISTS td.scopes;


-- drop schema
DROP SCHEMA IF EXISTS td;

-- drop all existing functions
DROP FUNCTION IF EXISTS set_current_timestamp_updated_at();

-- create schema
CREATE SCHEMA IF NOT EXISTS td;

-- create the users table
CREATE TABLE td.users (
  id              SERIAL PRIMARY KEY,
  first_name      VARCHAR (30),
  last_name       VARCHAR (30),
  email           VARCHAR (30) NOT NULL UNIQUE,
  token_version   INT DEFAULT 0,
  created_at      TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  updated_at      TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL
);

-- create the scopes table
CREATE TABLE td.scopes (
  id              SERIAL PRIMARY KEY,
  name            VARCHAR (50) NOT NULL,
  description     VARCHAR NOT NULL,
  created_at      TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  updated_at      TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL
);

-- create the user / scopes junction table
CREATE TABLE td.users_scopes (
  user_id         INT REFERENCES td.users (id),
  scope_id        INT REFERENCES td.scopes (id),
  PRIMARY KEY     (user_id, scope_id)
);

-- function to update timestamp
CREATE FUNCTION set_current_timestamp_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  _new record;
BEGIN
  _new := NEW;
  _new."updated_at" = NOW();
  RETURN _new;
END;
$$;

-- trigger for updating td.users updated_at
CREATE TRIGGER set_td_users_updated_at BEFORE UPDATE ON td.users FOR EACH ROW EXECUTE PROCEDURE set_current_timestamp_updated_at();

-- trigger for updating td.scopes updated_at
CREATE TRIGGER set_td_scopes_updated_at BEFORE UPDATE ON td.scopes FOR EACH ROW EXECUTE PROCEDURE set_current_timestamp_updated_at();