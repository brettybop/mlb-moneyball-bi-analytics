-- 99__sanity_checks.sql
-- Purpose: quick validation checks after rebuilding the MLB Flagship warehouse

-- =========================================================
-- 1) RAW LAYER CHECKS
-- =========================================================

-- Raw row counts
SELECT 'teams_raw_text'    AS object_name, COUNT(*) AS row_count FROM raw_lahman.teams_raw_text
UNION ALL
SELECT 'teams_raw'         AS object_name, COUNT(*) AS row_count FROM raw_lahman.teams_raw
UNION ALL
SELECT 'batting_raw_text'  AS object_name, COUNT(*) AS row_count FROM raw_lahman.batting_raw_text
UNION ALL
SELECT 'batting_raw'       AS object_name, COUNT(*) AS row_count FROM raw_lahman.batting_raw
UNION ALL
SELECT 'salaries_raw_text' AS object_name, COUNT(*) AS row_count FROM raw_lahman.salaries_raw_text
UNION ALL
SELECT 'salaries_raw'      AS object_name, COUNT(*) AS row_count FROM raw_lahman.salaries_raw
ORDER BY object_name;

-- Min / max year by raw table
SELECT
  'teams_raw' AS object_name,
  MIN("yearID") AS min_year,
  MAX("yearID") AS max_year
FROM raw_lahman.teams_raw

UNION ALL

SELECT
  'batting_raw' AS object_name,
  MIN("yearID") AS min_year,
  MAX("yearID") AS max_year
FROM raw_lahman.batting_raw

UNION ALL

SELECT
  'salaries_raw' AS object_name,
  MIN("yearID") AS min_year,
  MAX("yearID") AS max_year
FROM raw_lahman.salaries_raw;


-- =========================================================
-- 2) STAGING LAYER CHECKS
-- =========================================================

-- Staging row counts
SELECT 'stg.v_teams'                    AS object_name, COUNT(*) AS row_count FROM stg.v_teams
UNION ALL
SELECT 'stg.v_salaries'                 AS object_name, COUNT(*) AS row_count FROM stg.v_salaries
UNION ALL
SELECT 'stg.v_batting'                  AS object_name, COUNT(*) AS row_count FROM stg.v_batting
UNION ALL
SELECT 'stg.v_batting_py_team'          AS object_name, COUNT(*) AS row_count FROM stg.v_batting_py_team
UNION ALL
SELECT 'stg.v_batting_py_team_metrics'  AS object_name, COUNT(*) AS row_count FROM stg.v_batting_py_team_metrics
ORDER BY object_name;

-- Teams staging sanity sample
SELECT *
FROM stg.v_teams
ORDER BY yearid DESC, lgid, teamid
LIMIT 10;

-- Batting metrics sanity sample
SELECT
  yearid,
  lgid,
  teamid,
  playerid,
  pa_simple,
  ba_simple,
  obp_simple,
  slg,
  ops,
  hr_per_pa,
  k_pct,
  sb_pct
FROM stg.v_batting_py_team_metrics
ORDER BY yearid DESC, lgid, teamid, playerid
LIMIT 20;


-- =========================================================
-- 3) DIMENSION LAYER CHECKS
-- =========================================================

SELECT 'dim_season' AS object_name, COUNT(*) AS row_count FROM dm_macro.dim_season
UNION ALL
SELECT 'dim_league' AS object_name, COUNT(*) AS row_count FROM dm_macro.dim_league;

SELECT *
FROM dm_macro.dim_league
ORDER BY league_id;

SELECT *
FROM dm_macro.v_dim_season_date
ORDER BY season DESC
LIMIT 10;


-- =========================================================
-- 4) FACT TABLE CHECKS
-- =========================================================

SELECT 'fact_team_season'  AS object_name, COUNT(*) AS row_count FROM dm_macro.fact_team_season
UNION ALL
SELECT 'fact_team_payroll' AS object_name, COUNT(*) AS row_count FROM dm_macro.fact_team_payroll
UNION ALL
SELECT 'league_season_kpi_simple' AS object_name, COUNT(*) AS row_count FROM dm_macro.league_season_kpi_simple
ORDER BY object_name;

-- Fact season range
SELECT
  'fact_team_season' AS object_name,
  MIN(season) AS min_year,
  MAX(season) AS max_year
FROM dm_macro.fact_team_season

UNION ALL

SELECT
  'fact_team_payroll' AS object_name,
  MIN(season) AS min_year,
  MAX(season) AS max_year
FROM dm_macro.fact_team_payroll

UNION ALL

SELECT
  'league_season_kpi_simple' AS object_name,
  MIN(season) AS min_year,
  MAX(season) AS max_year
FROM dm_macro.league_season_kpi_simple;

-- League KPI row distribution
SELECT
  scope,
  COUNT(*) AS row_count
FROM dm_macro.league_season_kpi_simple
GROUP BY scope
ORDER BY scope;


-- =========================================================
-- 5) REPORT VIEW CHECKS
-- =========================================================

SELECT 'v_mlb_trend'               AS object_name, COUNT(*) AS row_count FROM dm_macro.v_mlb_trend
UNION ALL
SELECT 'v_team_payroll_perf'       AS object_name, COUNT(*) AS row_count FROM dm_macro.v_team_payroll_perf
UNION ALL
SELECT 'v_value_hunters_base'      AS object_name, COUNT(*) AS row_count FROM dm_macro.v_value_hunters_base
UNION ALL
SELECT 'v_value_hunters_pyteam'    AS object_name, COUNT(*) AS row_count FROM dm_macro.v_value_hunters_pyteam
ORDER BY object_name;

-- MLB trend sample
SELECT
  season,
  scope,
  r_per_game,
  rpg_yoy,
  rpg_5yr_ma,
  obp_simple,
  obp_yoy,
  obp_5yr_ma
FROM dm_macro.v_mlb_trend
ORDER BY season DESC
LIMIT 15;

-- Team payroll / performance sample
SELECT
  season,
  lgid,
  teamid,
  team_name,
  payroll_total,
  win_pct,
  payroll_rank_season,
  winpct_rank_season,
  overperform_vs_pyth
FROM dm_macro.v_team_payroll_perf
ORDER BY season DESC, payroll_rank_season
LIMIT 20;

-- Value hunter base sample
SELECT
  yearid,
  lgid,
  teamid,
  playerid,
  pa_simple,
  salary,
  salary_millions,
  obp_simple,
  slg,
  ops
FROM dm_macro.v_value_hunters_base
ORDER BY yearid DESC, salary_millions DESC
LIMIT 20;

-- Value hunter scored sample
SELECT
  yearid,
  lgid,
  teamid,
  playerid,
  pa_simple,
  salary_millions,
  prod_index,
  value_score,
  value_rank_season
FROM dm_macro.v_value_hunters_pyteam
ORDER BY yearid DESC, value_rank_season
LIMIT 20;


-- =========================================================
-- 6) NULL / COVERAGE CHECKS
-- =========================================================

-- Team payroll coverage by season
SELECT
  season,
  COUNT(*) AS teams_total,
  COUNT(*) FILTER (WHERE payroll_total IS NULL) AS teams_missing_payroll
FROM dm_macro.v_team_payroll_perf
GROUP BY season
ORDER BY season DESC;

-- Value hunter candidate counts by year
SELECT
  yearid,
  COUNT(*) AS qualified_players
FROM dm_macro.v_value_hunters_base
GROUP BY yearid
ORDER BY yearid DESC;

-- Any null salaries in value hunter base?
SELECT COUNT(*) AS null_salary_rows
FROM dm_macro.v_value_hunters_base
WHERE salary IS NULL;

-- Any null value scores in scored value hunter view?
SELECT COUNT(*) AS null_value_score_rows
FROM dm_macro.v_value_hunters_pyteam
WHERE value_score IS NULL;
