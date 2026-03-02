-- 08__dm_views_trends_and_payroll_perf.sql
-- Purpose: create report-facing semantic views for macro trends and team payroll performance

SET search_path = dm_macro, public;

-- =========================================================
-- VIEW: MLB TREND
-- Grain: season
-- Purpose:
--   provides MLB-only trend metrics plus YoY deltas and rolling averages
--   for Page 1 of the Power BI report
-- =========================================================

CREATE OR REPLACE VIEW dm_macro.v_mlb_trend AS
SELECT
  lsk.season,
  lsk.scope,

  -- base KPIs
  lsk.games,
  lsk.runs,
  lsk.ab,
  lsk.h,
  lsk.bb,
  lsk.so,
  lsk.hr,
  lsk.pa_simple,
  lsk.r_per_game,
  lsk.obp_simple,
  lsk.k_pct_simple,
  lsk.bb_pct_simple,
  lsk.hr_pct_simple,

  -- YoY deltas
  lsk.r_per_game
    - LAG(lsk.r_per_game) OVER (PARTITION BY lsk.scope ORDER BY lsk.season) AS rpg_yoy,

  lsk.obp_simple
    - LAG(lsk.obp_simple) OVER (PARTITION BY lsk.scope ORDER BY lsk.season) AS obp_yoy,

  lsk.k_pct_simple
    - LAG(lsk.k_pct_simple) OVER (PARTITION BY lsk.scope ORDER BY lsk.season) AS k_pct_yoy,

  lsk.hr_pct_simple
    - LAG(lsk.hr_pct_simple) OVER (PARTITION BY lsk.scope ORDER BY lsk.season) AS hr_pct_yoy,

  -- rolling 5-season averages
  AVG(lsk.r_per_game) OVER (
    PARTITION BY lsk.scope
    ORDER BY lsk.season
    ROWS BETWEEN 4 PRECEDING AND CURRENT ROW
  ) AS rpg_5yr_ma,

  AVG(lsk.obp_simple) OVER (
    PARTITION BY lsk.scope
    ORDER BY lsk.season
    ROWS BETWEEN 4 PRECEDING AND CURRENT ROW
  ) AS obp_5yr_ma,

  AVG(lsk.k_pct_simple) OVER (
    PARTITION BY lsk.scope
    ORDER BY lsk.season
    ROWS BETWEEN 4 PRECEDING AND CURRENT ROW
  ) AS k_pct_5yr_ma,

  AVG(lsk.hr_pct_simple) OVER (
    PARTITION BY lsk.scope
    ORDER BY lsk.season
    ROWS BETWEEN 4 PRECEDING AND CURRENT ROW
  ) AS hr_pct_5yr_ma

FROM dm_macro.league_season_kpi_simple lsk
WHERE lsk.scope = 'MLB';


-- =========================================================
-- VIEW: TEAM PAYROLL PERFORMANCE
-- Grain: season x league x team
-- Purpose:
--   combines team payroll and team performance into one report-facing view
--   for Page 2 of the Power BI report
-- =========================================================

CREATE OR REPLACE VIEW dm_macro.v_team_payroll_perf AS
WITH base AS (
  SELECT
    p.season,
    p.lgid,
    p.teamid,

    -- payroll metrics
    p.payroll_total,
    p.payroll_avg_player,
    p.payroll_median_player,
    p.payroll_rows,
    p.players_paid,

    -- team performance metrics
    f.team_name,
    f.g,
    f.w,
    f.l,
    f.runs,
    f.runs_allowed,
    f.ab,
    f.h,
    f.bb,
    f.so,
    f.hr,
    f.pa_simple,
    f.r_per_game,
    f.obp_simple,
    f.win_pct,
    f.pyth_win_pct,
    f.run_diff

  FROM dm_macro.fact_team_payroll p
  INNER JOIN dm_macro.fact_team_season f
    ON f.season = p.season
   AND f.lgid   = p.lgid
   AND f.teamid = p.teamid
)

SELECT
  b.*,

  -- season-scoped ranks
  DENSE_RANK() OVER (
    PARTITION BY b.season
    ORDER BY b.payroll_total DESC
  ) AS payroll_rank_season,

  DENSE_RANK() OVER (
    PARTITION BY b.season
    ORDER BY b.win_pct DESC
  ) AS winpct_rank_season,

  -- performance relative to expected wins
  (b.win_pct - b.pyth_win_pct) AS overperform_vs_pyth

FROM base b;
