-- 07__dm_league_season_kpis.sql
-- Purpose: create the league-season macro KPI fact table
-- Grain: season x scope
-- Scope values:
--   - AL
--   - NL
--   - MLB (rollup across AL + NL)

SET search_path = dm_macro, public;

DROP TABLE IF EXISTS dm_macro.league_season_kpi_simple;

CREATE TABLE dm_macro.league_season_kpi_simple (
  season        INT NOT NULL,
  scope         TEXT NOT NULL,   -- 'AL', 'NL', or 'MLB'

  games         INT,
  runs          INT,
  ab            INT,
  h             INT,
  bb            INT,
  so            INT,
  hr            INT,
  pa_simple     INT,

  r_per_game    NUMERIC(8,3),
  obp_simple    NUMERIC(8,3),
  k_pct_simple  NUMERIC(8,3),
  bb_pct_simple NUMERIC(8,3),
  hr_pct_simple NUMERIC(8,3),

  PRIMARY KEY (season, scope),
  CONSTRAINT fk_lskps_season FOREIGN KEY (season)
    REFERENCES dm_macro.dim_season(season),
  CONSTRAINT fk_lskps_scope FOREIGN KEY (scope)
    REFERENCES dm_macro.dim_league(league_id)
);

WITH base AS (
  SELECT
    t.yearid AS season,
    t.lgid   AS scope,
    SUM(t.g)  AS games,
    SUM(t.r)  AS runs,
    SUM(t.ab) AS ab,
    SUM(t.h)  AS h,
    SUM(t.bb) AS bb,
    SUM(t.so) AS so,
    SUM(t.hr) AS hr
  FROM stg.v_teams t
  WHERE t.lgid IN ('AL', 'NL')
  GROUP BY
    t.yearid,
    t.lgid
),

calc_leagues AS (
  SELECT
    season,
    scope,
    games,
    runs,
    ab,
    h,
    bb,
    so,
    hr,

    (ab + bb) AS pa_simple,

    runs::NUMERIC / NULLIF(games, 0) AS r_per_game,

    (h + bb)::NUMERIC
      / NULLIF(ab + bb, 0) AS obp_simple,

    so::NUMERIC
      / NULLIF(ab + bb, 0) AS k_pct_simple,

    bb::NUMERIC
      / NULLIF(ab + bb, 0) AS bb_pct_simple,

    hr::NUMERIC
      / NULLIF(ab + bb, 0) AS hr_pct_simple

  FROM base
),

base_totals AS (
  SELECT
    season,
    'MLB'::TEXT AS scope,
    SUM(games) AS games,
    SUM(runs)  AS runs,
    SUM(ab)    AS ab,
    SUM(h)     AS h,
    SUM(bb)    AS bb,
    SUM(so)    AS so,
    SUM(hr)    AS hr
  FROM base
  GROUP BY season
),

calc_totals AS (
  SELECT
    season,
    scope,
    games,
    runs,
    ab,
    h,
    bb,
    so,
    hr,

    (ab + bb) AS pa_simple,

    runs::NUMERIC / NULLIF(games, 0) AS r_per_game,

    (h + bb)::NUMERIC
      / NULLIF(ab + bb, 0) AS obp_simple,

    so::NUMERIC
      / NULLIF(ab + bb, 0) AS k_pct_simple,

    bb::NUMERIC
      / NULLIF(ab + bb, 0) AS bb_pct_simple,

    hr::NUMERIC
      / NULLIF(ab + bb, 0) AS hr_pct_simple

  FROM base_totals
)

INSERT INTO dm_macro.league_season_kpi_simple (
  season,
  scope,
  games,
  runs,
  ab,
  h,
  bb,
  so,
  hr,
  pa_simple,
  r_per_game,
  obp_simple,
  k_pct_simple,
  bb_pct_simple,
  hr_pct_simple
)
SELECT * FROM calc_leagues

UNION ALL

SELECT * FROM calc_totals;


CREATE INDEX IF NOT EXISTS ix_league_season_kpi_simple_season_scope
  ON dm_macro.league_season_kpi_simple (season, scope);
