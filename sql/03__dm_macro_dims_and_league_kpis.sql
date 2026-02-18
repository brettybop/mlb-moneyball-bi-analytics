-- 03__dm_macro_dims_and_league_kpis.sql
CREATE SCHEMA IF NOT EXISTS dm_macro;

-- Dimensions
CREATE TABLE IF NOT EXISTS dm_macro.dim_season (
  season INT PRIMARY KEY
);

INSERT INTO dm_macro.dim_season (season)
SELECT DISTINCT yearid FROM stg.v_teams
ON CONFLICT (season) DO NOTHING;

CREATE TABLE IF NOT EXISTS dm_macro.dim_league (
  league_id TEXT PRIMARY KEY,
  league_name TEXT
);

INSERT INTO dm_macro.dim_league (league_id, league_name) VALUES
  ('AL','American League'),
  ('NL','National League'),
  ('MLB','Major League Baseball')
ON CONFLICT (league_id) DO NOTHING;

-- Season date anchor for time intelligence
CREATE OR REPLACE VIEW dm_macro.v_dim_season_date AS
SELECT season, make_date(season, 7, 1) AS season_date
FROM dm_macro.dim_season;

-- Macro KPIs (league + MLB total)
DROP TABLE IF EXISTS dm_macro.league_season_kpi_simple;

CREATE TABLE dm_macro.league_season_kpi_simple (
  season INT NOT NULL,
  scope  TEXT NOT NULL,          -- 'AL','NL','MLB'
  games INT,
  runs  INT,
  ab    INT,
  h     INT,
  bb    INT,
  so    INT,
  hr    INT,
  pa_simple INT,
  r_per_game   NUMERIC(8,3),
  obp_simple   NUMERIC(8,3),
  k_pct_simple NUMERIC(8,3),
  bb_pct_simple NUMERIC(8,3),
  hr_pct_simple NUMERIC(8,3),
  PRIMARY KEY (season, scope),
  CONSTRAINT fk_season FOREIGN KEY (season) REFERENCES dm_macro.dim_season(season),
  CONSTRAINT fk_scope  FOREIGN KEY (scope)  REFERENCES dm_macro.dim_league(league_id)
);

WITH base AS (
  SELECT
    yearid AS season,
    lgid   AS scope,
    SUM(g)  AS games,
    SUM(r)  AS runs,
    SUM(ab) AS ab,
    SUM(h)  AS h,
    SUM(bb) AS bb,
    SUM(so) AS so,
    SUM(hr) AS hr
  FROM stg.v_teams
  WHERE lgid IN ('AL','NL')
  GROUP BY yearid, lgid
),
calc_leagues AS (
  SELECT season, scope, games, runs, ab, h, bb, so, hr,
         (ab + bb) AS pa_simple,
         runs::NUMERIC / NULLIF(games,0)       AS r_per_game,
         (h + bb)::NUMERIC / NULLIF(ab + bb,0) AS obp_simple,
         so::NUMERIC / NULLIF(ab + bb,0)       AS k_pct_simple,
         bb::NUMERIC / NULLIF(ab + bb,0)       AS bb_pct_simple,
         hr::NUMERIC / NULLIF(ab + bb,0)       AS hr_pct_simple
  FROM base
),
base_totals AS (
  SELECT season,
         'MLB'::TEXT AS scope,
         SUM(games) AS games, SUM(runs) AS runs, SUM(ab) AS ab, SUM(h) AS h,
         SUM(bb) AS bb, SUM(so) AS so, SUM(hr) AS hr
  FROM base
  GROUP BY season
),
calc_totals AS (
  SELECT season, scope, games, runs, ab, h, bb, so, hr,
         (ab + bb) AS pa_simple,
         runs::NUMERIC / NULLIF(games,0)       AS r_per_game,
         (h + bb)::NUMERIC / NULLIF(ab + bb,0) AS obp_simple,
         so::NUMERIC / NULLIF(ab + bb,0)       AS k_pct_simple,
         bb::NUMERIC / NULLIF(ab + bb,0)       AS bb_pct_simple,
         hr::NUMERIC / NULLIF(ab + bb,0)       AS hr_pct_simple
  FROM base_totals
)
INSERT INTO dm_macro.league_season_kpi_simple
(season, scope, games, runs, ab, h, bb, so, hr, pa_simple,
 r_per_game, obp_simple, k_pct_simple, bb_pct_simple, hr_pct_simple)
SELECT * FROM calc_leagues
UNION ALL
SELECT * FROM calc_totals;
