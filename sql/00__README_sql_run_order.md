# SQL Run Order

Follow steps in chronological order to reproduce MLB Flagship locally.

```plaintext
sql/
├─ 00__README_run_order.md
├─ 01__schemas.sql
├─ 02__raw_tables.sql
├─ 03__load_raw_text_and_promote.sql
├─ 04__stg_views.sql
├─ 05__dm_dims.sql
├─ 06__dm_facts_team_season_and_payroll.sql
├─ 07__dm_league_season_kpis.sql
├─ 08__dm_views_trends_and_payroll_perf.sql
├─ 09__dm_value_hunter_views.sql
└─ 99__sanity_checks.sql
```

# SQL Run Order (mlb_flagship)

## One-time setup
1. 01__schemas.sql
2. 02__raw_tables.sql

## Load data (CSV → raw_text → typed raw)
3. Import CSVs into:
   - raw_lahman.teams_raw_text
   - raw_lahman.batting_raw_text
   - raw_lahman.salaries_raw_text
4. 03__load_raw_text_and_promote.sql

## Build staging layer (clean + typed views)
5. 04__stg_views.sql

## Build dimensional mart (dims + facts + semantic views)
6. 05__dm_dims.sql
7. 06__dm_facts_team_season_and_payroll.sql
8. 07__dm_league_season_kpis.sql
9. 08__dm_views_trends_and_payroll_perf.sql
10. 09__dm_value_hunter_views.sql

## Validate
11. 99__sanity_checks.sql
