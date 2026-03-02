-- 06__dm_facts_team_season_and_payroll.sql
-- Purpose: create team-season level fact tables for performance and payroll analysis

SET search_path = dm_macro, public;

-- =========================================================
-- FACT: TEAM SEASON PERFORMANCE
-- Grain: season x league x team
-- Source: stg.v_teams
-- =========================================================

DROP TABLE IF EXISTS dm_macro.fact_team_season;

CREATE TABLE dm_macro.fact_team_season AS
SELECT
  t.yearid        AS season,
  t.lgid          AS lgid,
  t.teamid        AS teamid,
  t.team_name     AS team_name,

  -- volume / outcomes
  t.g             AS g,
  t.w             AS w,
  t.l             AS l,
  t.r             AS runs,
  t.ra            AS runs_allowed,

  -- batting environment
  t.ab            AS ab,
  t.h             AS h,
  t.bb            AS bb,
  t.so            AS so,
  t.hr            AS hr,

  -- simple PA proxy
  (t.ab + COALESCE(t.bb, 0)) AS pa_simple,

  -- core KPIs
  t.r::NUMERIC / NULLIF(t.g, 0) AS r_per_game,

  (t.h + COALESCE(t.bb, 0))::NUMERIC
    / NULLIF(t.ab + COALESCE(t.bb, 0), 0) AS obp_simple,

  t.w::NUMERIC / NULLIF(t.g, 0) AS win_pct,

  -- pythagorean expectation using exponent 2
  (POWER(t.r::NUMERIC, 2))
    / NULLIF(POWER(t.r::NUMERIC, 2) + POWER(t.ra::NUMERIC, 2), 0) AS pyth_win_pct,

  -- run differential
  (t.r - t.ra) AS run_diff

FROM stg.v_teams t
WHERE t.lgid IN ('AL', 'NL');

CREATE INDEX IF NOT EXISTS ix_fact_team_season_key
  ON dm_macro.fact_team_season (season, lgid, teamid);


-- =========================================================
-- FACT: TEAM SEASON PAYROLL
-- Grain: season x league x team
-- Source: stg.v_salaries
-- =========================================================

DROP TABLE IF EXISTS dm_macro.fact_team_payroll;

CREATE TABLE dm_macro.fact_team_payroll AS
SELECT
  s.yearid AS season,
  s.lgid   AS lgid,
  s.teamid AS teamid,

  -- payroll metrics
  SUM(s.salary)::NUMERIC(14,2) AS payroll_total,
  AVG(s.salary)::NUMERIC(14,2) AS payroll_avg_player,
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY s.salary) AS payroll_median_player,

  -- roster coverage
  COUNT(*) AS payroll_rows,
  COUNT(DISTINCT s.playerid) AS players_paid

FROM stg.v_salaries s
WHERE s.lgid IN ('AL', 'NL')
GROUP BY
  s.yearid,
  s.lgid,
  s.teamid;

CREATE INDEX IF NOT EXISTS ix_fact_team_payroll_key
  ON dm_macro.fact_team_payroll (season, lgid, teamid);
