-- 01__schemas.sql
-- Purpose: create the core schemas for the MLB Flagship warehouse
-- Layering:
--   raw_lahman = raw CSV landing + typed raw tables
--   stg        = cleaned / typed staging views
--   dm_macro   = dimensional marts and report-facing views

CREATE SCHEMA IF NOT EXISTS raw_lahman;
CREATE SCHEMA IF NOT EXISTS stg;
CREATE SCHEMA IF NOT EXISTS dm_macro;
