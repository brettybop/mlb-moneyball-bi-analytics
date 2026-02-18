# SQL Run Order

Follow steps in chronological order to reproduce MLB Flagship locally.

```plaintext
1. 01__schemas_and_raw_tables.sql
2. Load CSVs into raw tables (pgAdmin import / \copy)
3. 02__stg_views.sql
4. 03__dm_macro_dims_and_league_kpis.sql
5. 04__team_payroll_perf_view.sql
6. 05__value_hunter_views.sql
7. 99__sanity_checks.sql (optional)
```
