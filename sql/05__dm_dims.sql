-- 05__dm_dims.sql
-- Purpose: create dimensional tables and helper date view for the MLB macro mart

SET search_path = dm_macro, public;

-- =========================================================
-- DIMENSION: SEASON
-- Grain: one row per MLB season
-- =========================================================

CREATE TABLE IF NOT EXISTS dm_macro.dim_season (
  season INT PRIMARY KEY
);

INSERT INTO dm_macro.dim_season (season)
SELECT DISTINCT
  t.yearid AS season
FROM stg.v_teams t
WHERE t.yearid IS NOT NULL
ON CONFLICT (season) DO NOTHING;


-- =========================================================
-- DIMENSION: LEAGUE
-- Grain: one row per league bucket used in reporting
-- Note:
--   Includes AL, NL, and MLB total for rollup reporting
-- =========================================================

CREATE TABLE IF NOT EXISTS dm_macro.dim_league (
  league_id   TEXT PRIMARY KEY,
  league_name TEXT
);

INSERT INTO dm_macro.dim_league (league_id, league_name)
VALUES
  ('AL',  'American League'),
  ('NL',  'National League'),
  ('MLB', 'Major League Baseball')
ON CONFLICT (league_id) DO NOTHING;


-- =========================================================
-- HELPER VIEW: SEASON DATE
-- Purpose:
--   provides a true DATE column for Power BI time intelligence
--   by anchoring each season to a mid-season date
-- =========================================================

CREATE OR REPLACE VIEW dm_macro.v_dim_season_date AS
SELECT
  s.season,
  make_date(s.season, 7, 1) AS season_date
FROM dm_macro.dim_season s;
