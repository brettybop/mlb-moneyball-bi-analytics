-- 02__stg_views.sql

CREATE OR REPLACE VIEW stg.v_teams AS
SELECT
  yearid,
  lgid,
  teamid,
  name AS team_name,
  w, l, g,
  r, ra,
  ab, h, bb, so, hr,
  attendance,
  CASE WHEN g > 0 THEN w::numeric / g ELSE NULL END AS win_pct
FROM raw_lahman.teams_raw;

CREATE OR REPLACE VIEW stg.v_salaries AS
SELECT
  yearid,
  teamid,
  lgid,
  playerid,
  salary
FROM raw_lahman.salaries_raw;

-- Batting metrics (player-year-team)
CREATE OR REPLACE VIEW stg.v_batting_py_team_metrics AS
SELECT
  b.playerid,
  b.yearid,
  b.teamid,
  b.lgid,
  SUM(COALESCE(b.ab,0)) AS ab,
  SUM(COALESCE(b.h,0)) AS h,
  SUM(COALESCE(b.bb,0)) AS bb,
  SUM(COALESCE(b.so,0)) AS so,
  SUM(COALESCE(b.hr,0)) AS hr,
  SUM(COALESCE(b.sb,0)) AS sb,
  SUM(COALESCE(b.sf,0)) AS sf,
  SUM(COALESCE(b.hbp,0)) AS hbp,
  -- simple PA proxy (consistent with your earlier macro approach)
  SUM(COALESCE(b.ab,0) + COALESCE(b.bb,0)) AS pa_simple,
  -- rates
  (SUM(COALESCE(b.h,0) + COALESCE(b.bb,0)))::numeric
    / NULLIF(SUM(COALESCE(b.ab,0) + COALESCE(b.bb,0)),0) AS obp_simple,
  (SUM(COALESCE(b.so,0)))::numeric
    / NULLIF(SUM(COALESCE(b.ab,0) + COALESCE(b.bb,0)),0) AS k_pct_simple,
  (SUM(COALESCE(b.hr,0)))::numeric
    / NULLIF(SUM(COALESCE(b.ab,0) + COALESCE(b.bb,0)),0) AS hr_pct_simple
FROM raw_lahman.batting_raw b
GROUP BY b.playerid, b.yearid, b.teamid, b.lgid;

