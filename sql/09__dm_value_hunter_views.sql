-- 09__dm_value_hunter_views.sql
-- Purpose: create player-level value hunter views for Page 3 of the Power BI report
--
-- Notes:
--   - v_value_hunters_pyteam:
--       SQL-heavy player-season-team scoring view with season-standardized metrics
--   - v_value_hunters_base:
--       simplified Power BI-facing source used for final dashboard measures

SET search_path = dm_macro, public;

-- =========================================================
-- VIEW: VALUE HUNTERS PYTEAM
-- Grain: player x season x team
-- Purpose:
--   season-standardized offensive production + salary efficiency
--   useful as a SQL showcase and for further experimentation
-- =========================================================

CREATE OR REPLACE VIEW dm_macro.v_value_hunters_pyteam AS
WITH joined AS (
  SELECT
    m.playerid,
    m.yearid,
    m.teamid,
    m.lgid,

    -- volume
    m.ab,
    m.h,
    m.bb,
    m.so,
    m.hr,
    m.sb,
    m.cs,
    m.pa_simple,

    -- offensive metrics
    m.ba_simple,
    m.obp_simple,
    m.slg,
    m.ops,
    m.hr_per_pa,
    m.k_pct,
    m.sb_pct,

    -- salary
    s.salary::NUMERIC AS salary,
    (s.salary::NUMERIC / 1000000.0) AS salary_millions

  FROM stg.v_batting_py_team_metrics m
  INNER JOIN stg.v_salaries s
    ON s.playerid = m.playerid
   AND s.yearid   = m.yearid
   AND s.teamid   = m.teamid

  WHERE m.lgid IN ('AL', 'NL')
    AND m.pa_simple >= 200
    AND s.salary IS NOT NULL
),

stats AS (
  SELECT
    yearid,

    AVG(obp_simple)         AS mu_obp,
    STDDEV_SAMP(obp_simple) AS sd_obp,

    AVG(slg)                AS mu_slg,
    STDDEV_SAMP(slg)        AS sd_slg,

    AVG(hr_per_pa)          AS mu_hrpa,
    STDDEV_SAMP(hr_per_pa)  AS sd_hrpa,

    AVG(k_pct)              AS mu_kpct,
    STDDEV_SAMP(k_pct)      AS sd_kpct,

    AVG(sb_pct)             AS mu_sb,
    STDDEV_SAMP(sb_pct)     AS sd_sb

  FROM joined
  GROUP BY yearid
),

scored AS (
  SELECT
    j.*,

    -- season-standardized z-scores
    (j.obp_simple - s.mu_obp)  / NULLIF(s.sd_obp,  0) AS z_obp,
    (j.slg        - s.mu_slg)  / NULLIF(s.sd_slg,  0) AS z_slg,
    (j.hr_per_pa  - s.mu_hrpa) / NULLIF(s.sd_hrpa, 0) AS z_hrpa,
    (j.k_pct      - s.mu_kpct) / NULLIF(s.sd_kpct, 0) AS z_kpct,
    (j.sb_pct     - s.mu_sb)   / NULLIF(s.sd_sb,   0) AS z_sb

  FROM joined j
  INNER JOIN stats s
    USING (yearid)
)

SELECT
  s.playerid,
  s.yearid,
  s.teamid,
  s.lgid,

  s.ab,
  s.h,
  s.bb,
  s.so,
  s.hr,
  s.sb,
  s.cs,
  s.pa_simple,

  s.ba_simple,
  s.obp_simple,
  s.slg,
  s.ops,
  s.hr_per_pa,
  s.k_pct,
  s.sb_pct,

  s.salary,
  s.salary_millions,

  -- production index: transparent weighted offensive composite
  (
      0.45 * COALESCE(s.z_obp, 0)
    + 0.35 * COALESCE(s.z_slg, 0)
    + 0.15 * COALESCE(s.z_hrpa, 0)
    + 0.05 * COALESCE(s.z_sb, 0)
    - 0.20 * COALESCE(s.z_kpct, 0)
  )::NUMERIC(18,6) AS prod_index,

  -- value score: production per salary unit
  (
    (
        0.45 * COALESCE(s.z_obp, 0)
      + 0.35 * COALESCE(s.z_slg, 0)
      + 0.15 * COALESCE(s.z_hrpa, 0)
      + 0.05 * COALESCE(s.z_sb, 0)
      - 0.20 * COALESCE(s.z_kpct, 0)
    )
    / NULLIF(s.salary_millions + 0.25, 0)
  )::NUMERIC(18,6) AS value_score,

  DENSE_RANK() OVER (
    PARTITION BY s.yearid
    ORDER BY
      (
        (
            0.45 * COALESCE(s.z_obp, 0)
          + 0.35 * COALESCE(s.z_slg, 0)
          + 0.15 * COALESCE(s.z_hrpa, 0)
          + 0.05 * COALESCE(s.z_sb, 0)
          - 0.20 * COALESCE(s.z_kpct, 0)
        )
        / NULLIF(s.salary_millions + 0.25, 0)
      ) DESC
  ) AS value_rank_season

FROM scored s;


-- =========================================================
-- VIEW: VALUE HUNTERS BASE
-- Grain: player x season x team
-- Purpose:
--   simplified, Power BI-safe base view used for final dashboard measures
--   leaves composite scoring to DAX in the report layer
-- =========================================================

CREATE OR REPLACE VIEW dm_macro.v_value_hunters_base AS
SELECT
  m.playerid,
  m.yearid,
  m.teamid,
  m.lgid,

  -- volume
  m.ab,
  m.h,
  m.bb,
  m.so,
  m.hr,
  m.sb,
  m.cs,
  m.pa_simple,

  -- offensive metrics
  m.ba_simple,
  m.obp_simple,
  m.slg,
  m.ops,
  m.hr_per_pa,
  m.k_pct,
  m.sb_pct,

  -- salary
  s.salary::NUMERIC AS salary,
  (s.salary::NUMERIC / 1000000.0) AS salary_millions

FROM stg.v_batting_py_team_metrics m
INNER JOIN stg.v_salaries s
  ON s.playerid = m.playerid
 AND s.yearid   = m.yearid
 AND s.teamid   = m.teamid

WHERE m.lgid IN ('AL', 'NL')
  AND m.pa_simple >= 200
  AND s.salary IS NOT NULL;
