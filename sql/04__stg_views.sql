-- 04__stg_views.sql
-- Purpose: create clean staging views on top of typed raw Lahman tables
-- Notes:
--   - standardize naming
--   - expose analysis-ready grains
--   - derive simple batting metrics used downstream

SET search_path = stg, public;

-- =========================================================
-- TEAMS
-- Grain: team-season
-- =========================================================

CREATE OR REPLACE VIEW stg.v_teams AS
SELECT
  t."yearID"         AS yearid,
  t."lgID"           AS lgid,
  t."teamID"         AS teamid,
  t."franchID"       AS franchid,
  t."divID"          AS divid,
  t."Rank"           AS rank,
  t."G"              AS g,
  t."Ghome"          AS ghome,
  t."W"              AS w,
  t."L"              AS l,
  t."DivWin"         AS divwin,
  t."WCWin"          AS wcwin,
  t."LgWin"          AS lgwin,
  t."WSWin"          AS wswin,
  t."R"              AS r,
  t."AB"             AS ab,
  t."H"              AS h,
  t."2B"             AS dbl,
  t."3B"             AS tpl,
  t."HR"             AS hr,
  t."BB"             AS bb,
  t."SO"             AS so,
  t."SB"             AS sb,
  t."CS"             AS cs,
  t."HBP"            AS hbp,
  t."SF"             AS sf,
  t."RA"             AS ra,
  t."ER"             AS er,
  t."ERA"            AS era,
  t."CG"             AS cg,
  t."SHO"            AS sho,
  t."SV"             AS sv,
  t."IPouts"         AS ipouts,
  t."HA"             AS ha,
  t."HRA"            AS hra,
  t."BBA"            AS bba,
  t."SOA"            AS soa,
  t."E"              AS e,
  t."DP"             AS dp,
  t."FP"             AS fp,
  t."name"           AS team_name,
  t."park"           AS park,
  t."attendance"     AS attendance,
  t."BPF"            AS bpf,
  t."PPF"            AS ppf,
  t."teamIDBR"       AS teamidbr,
  t."teamIDlahman45" AS teamidlahman45,
  t."teamIDretro"    AS teamidretro
FROM raw_lahman.teams_raw t;


-- =========================================================
-- SALARIES
-- Grain: player-season-team
-- =========================================================

CREATE OR REPLACE VIEW stg.v_salaries AS
SELECT
  s."yearID"   AS yearid,
  s."teamID"   AS teamid,
  s."lgID"     AS lgid,
  s."playerID" AS playerid,
  s."salary"   AS salary
FROM raw_lahman.salaries_raw s;


-- =========================================================
-- BATTING
-- Grain: player-season-stint
-- =========================================================

CREATE OR REPLACE VIEW stg.v_batting AS
SELECT
  b."playerID" AS playerid,
  b."yearID"   AS yearid,
  b."stint"    AS stint,
  b."teamID"   AS teamid,
  b."lgID"     AS lgid,
  b."G"        AS g,
  b."AB"       AS ab,
  b."R"        AS r,
  b."H"        AS h,
  b."2B"       AS dbl,
  b."3B"       AS tpl,
  b."HR"       AS hr,
  b."RBI"      AS rbi,
  b."SB"       AS sb,
  b."CS"       AS cs,
  b."BB"       AS bb,
  b."SO"       AS so,
  b."IBB"      AS ibb,
  b."HBP"      AS hbp,
  b."SH"       AS sh,
  b."SF"       AS sf,
  b."GIDP"     AS gidp,
  (COALESCE(b."AB", 0) + COALESCE(b."BB", 0))::INT AS pa_simple
FROM raw_lahman.batting_raw b;


-- =========================================================
-- BATTING PY TEAM
-- Grain: player-season-team
-- Purpose: align batting grain to salaries grain
-- =========================================================

CREATE OR REPLACE VIEW stg.v_batting_py_team AS
SELECT
  b.playerid,
  b.yearid,
  b.teamid,
  b.lgid,
  SUM(COALESCE(b.g, 0))         AS g,
  SUM(COALESCE(b.ab, 0))        AS ab,
  SUM(COALESCE(b.r, 0))         AS r,
  SUM(COALESCE(b.h, 0))         AS h,
  SUM(COALESCE(b.dbl, 0))       AS dbl,
  SUM(COALESCE(b.tpl, 0))       AS tpl,
  SUM(COALESCE(b.hr, 0))        AS hr,
  SUM(COALESCE(b.rbi, 0))       AS rbi,
  SUM(COALESCE(b.sb, 0))        AS sb,
  SUM(COALESCE(b.cs, 0))        AS cs,
  SUM(COALESCE(b.bb, 0))        AS bb,
  SUM(COALESCE(b.so, 0))        AS so,
  SUM(COALESCE(b.ibb, 0))       AS ibb,
  SUM(COALESCE(b.hbp, 0))       AS hbp,
  SUM(COALESCE(b.sh, 0))        AS sh,
  SUM(COALESCE(b.sf, 0))        AS sf,
  SUM(COALESCE(b.gidp, 0))      AS gidp,
  SUM(COALESCE(b.pa_simple, 0)) AS pa_simple
FROM stg.v_batting b
GROUP BY
  b.playerid,
  b.yearid,
  b.teamid,
  b.lgid;


-- =========================================================
-- BATTING PY TEAM METRICS
-- Grain: player-season-team
-- Purpose: derive simple offensive metrics for Value Hunter analysis
-- =========================================================

CREATE OR REPLACE VIEW stg.v_batting_py_team_metrics AS
SELECT
  b.playerid,
  b.yearid,
  b.teamid,
  b.lgid,
  b.ab,
  b.h,
  b.bb,
  b.so,
  b.hr,
  b.sb,
  b.cs,
  b.pa_simple,
  b.dbl,
  b.tpl,

  -- singles
  GREATEST(
    b.h - (COALESCE(b.dbl, 0) + COALESCE(b.tpl, 0) + COALESCE(b.hr, 0)),
    0
  ) AS singles,

  -- simple batting average proxy: H / AB
  b.h::NUMERIC / NULLIF(b.ab, 0) AS ba_simple,

  -- simple OBP proxy: (H + BB) / (AB + BB)
  (b.h + COALESCE(b.bb, 0))::NUMERIC
    / NULLIF(b.ab + COALESCE(b.bb, 0), 0) AS obp_simple,

  -- slugging: total bases / AB
  (
    (
      GREATEST(
        b.h - (COALESCE(b.dbl, 0) + COALESCE(b.tpl, 0) + COALESCE(b.hr, 0)),
        0
      )
      + 2 * COALESCE(b.dbl, 0)
      + 3 * COALESCE(b.tpl, 0)
      + 4 * COALESCE(b.hr, 0)
    )::NUMERIC
    / NULLIF(b.ab, 0)
  ) AS slg,

  -- OPS = OBP + SLG
  (
    (b.h + COALESCE(b.bb, 0))::NUMERIC
      / NULLIF(b.ab + COALESCE(b.bb, 0), 0)
    +
    (
      (
        GREATEST(
          b.h - (COALESCE(b.dbl, 0) + COALESCE(b.tpl, 0) + COALESCE(b.hr, 0)),
          0
        )
        + 2 * COALESCE(b.dbl, 0)
        + 3 * COALESCE(b.tpl, 0)
        + 4 * COALESCE(b.hr, 0)
      )::NUMERIC
      / NULLIF(b.ab, 0)
    )
  ) AS ops,

  -- home runs per simple PA
  COALESCE(b.hr, 0)::NUMERIC
    / NULLIF(b.ab + COALESCE(b.bb, 0), 0) AS hr_per_pa,

  -- strikeout rate per simple PA
  COALESCE(b.so, 0)::NUMERIC
    / NULLIF(b.ab + COALESCE(b.bb, 0), 0) AS k_pct,

  -- stolen base success rate
  COALESCE(b.sb, 0)::NUMERIC
    / NULLIF(COALESCE(b.sb, 0) + COALESCE(b.cs, 0), 0) AS sb_pct

FROM stg.v_batting_py_team b;
