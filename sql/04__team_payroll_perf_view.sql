-- 04__team_payroll_perf_view.sql

-- Team payroll by season/team
CREATE OR REPLACE VIEW dm_macro.v_team_payroll AS
SELECT
  s.yearid AS season,
  s.teamid,
  s.lgid,
  SUM(s.salary) AS payroll_total
FROM stg.v_salaries s
GROUP BY s.yearid, s.teamid, s.lgid;

-- Join team performance
CREATE OR REPLACE VIEW dm_macro.v_team_payroll_perf AS
SELECT
  t.yearid AS season,
  t.teamid,
  t.lgid,
  t.team_name,
  t.g,
  t.w,
  t.l,
  t.r,
  t.ra,
  t.win_pct,
  p.payroll_total
FROM stg.v_teams t
LEFT JOIN dm_macro.v_team_payroll p
  ON p.season = t.yearid
 AND p.teamid = t.teamid
 AND p.lgid   = t.lgid;
