# MLB Run Environment & Value Hunter Analytics (Power BI + PostgreSQL)

This project is my **flagship baseball analytics dashboard** built with **PostgreSQL** and **Power BI**.

It answers three layers of questions:

1. **League-level run environment:**  
   How has scoring, on-base ability, and pitcher dominance changed over time?

2. **Team-level performance vs payroll:**  
   Does payroll actually buy wins, and which teams over- or under-perform their spend?

3. **Player-level “Value Hunter”:**  
   Which hitters deliver the most production for the least salary in a given season?

The stack and patterns (star schema, staging, DAX measures, relationship design) are meant to mirror real data analyst / analytics engineer work.

---

## Data Source

The project uses the open **Baseball Databank (Lahman)** dataset (via the Kaggle “Baseball Databank” mirror).

Key tables used:

- `Teams` – team-season results (R, AB, HR, BB, SO, etc.)
- `Batting` – player-season batting stats
- `Salaries` – player salaries by team and season

The raw CSVs are not included in this repo; users can download them directly from Kaggle / Lahman and run the SQL scripts to reproduce the model.

---

## Tech Stack

- **Database:** PostgreSQL  
  - Schemas: `raw_lahman`, `stg`, `dm_macro`  
  - Features used: CTEs, window functions, `STDDEV_SAMP`, `corr`, views
- **BI Tool:** Power BI Desktop  
  - Star schema modeling, relationships, time intelligence  
  - DAX measures for KPIs and value scoring
- **Language:** SQL + DAX

---

## Data Modeling Overview

### Schemas

- **`raw_lahman`**  
  Landing tables for CSV imports (`teams_raw`, `batting_raw`, `salaries_raw`).

- **`stg` (staging)**  
  Cleaned / typed views, e.g.:
  - `stg.v_teams` – typed team-season stats
  - `stg.v_batting_py_team_metrics` – player-year batting metrics by team
  - `stg.v_salaries` – salaries aligned on `playerid`, `yearid`, `teamid`

- **`dm_macro` (data mart)**  
  Dimensional model for analytics:
  - `dm_macro.dim_season` – seasons
  - `dm_macro.dim_league` – AL / NL / MLB
  - `dm_macro.league_season_kpi_simple` – macro KPIs by league/season
  - `dm_macro.v_team_payroll_perf` – team-season performance vs payroll
  - `dm_macro.v_value_hunters_base` – player-season batting + salary for value analysis  
  - `dm_macro.v_dim_season_date` – season → mid-year date for time intelligence

In Power BI, `v_dim_season_date[season_date]` is marked as the **Date table**, with relationships:

- `v_dim_season_date[season]` → league and team fact tables
- `v_dim_season_date[season]` → value hunter base `[yearid]`

This enables DAX time functions and consistent season filtering.

---

## Power BI Pages & Questions Answered

### 📄 Page 1 – League Run Environment & Eras

**Goal:** Understand how the **game itself** has evolved.

Questions:

- **Is scoring up or down over time?**  
  - Runs per game (R/G) by season  
  - Year-over-year change and 5-year moving average

- **Is on-base ability changing?**  
  - OBP (simple) by season  
  - “Are hitters getting on base more or less over time?”

- **Are pitchers getting better?**  
  - League-wide **K%**, **BB%**, **HR%** trends over time  
  - Shows “three true outcomes” era and pitcher dominance

- **How do AL and NL compare across eras?**  
  - AL vs NL R/G, HR%, K% by season  
  - Breakdown by era buckets (e.g., pre-1969, 1969–1993, 1994–2004, 2005+)

- **How do different eras look in aggregate?**  
  - Average R/G, OBP, K%, HR% by era bucket

---

### 📄 Page 2 – Team Performance vs Payroll

**Goal:** Evaluate how **team spending** translates into performance.

Questions:

- **Does payroll actually buy wins?**  
  - Scatter: team payroll vs win% by season  
  - Correlation between spending and winning

- **Which teams over- or under-perform their payroll?**  
  - Per-season:
    - Payroll rank vs Win% rank  
    - Rank delta (Win% Rank – Payroll Rank)  
    - Overperform vs Pythagorean expectation (actual vs expected wins)
  - Table with conditional formatting to highlight big over/under achievers

- **How does this relationship change over time?**  
  - Season slicer to move through history and see the scatter reshape

---

### 📄 Page 3 – Value Hunter (Player-Level Bargains)

**Goal:** Identify the **most underpaid hitters**: maximum production for minimal salary.

Key measures (DAX):

- `VH Prod Index` – composite production score using:
  - OBP, SLG, HR per PA, SB%, K%
- `VH Salary (Millions)` – salary in millions
- `VH Value Score` – production per salary unit
- `VH Value Rank (Season)` – rank by value score within each season

Questions:

- **Who are the top “value” hitters in a given season?**
  - Table of Top N (e.g. Top 10) value players:
    - playerid, teamid, salary, PA, OBP, SLG, Value Score, Value Rank

- **How does salary relate to production at the player level?**
  - Scatter:
    - X = Salary (Millions)  
    - Y = VH Prod Index  
    - Size = PA (playing time)  
    - Color = League or Team  
    - Filtered to Top N by value score
  - Top-left bubbles = biggest bargains (high production, low cost)

- **How many qualified “value candidates” exist per season, and how strong are they?**
  - Cards (examples):
    - Selected Season  
    - Qualified Players  
    - Top Value Player (ID)  
    - Top Value Score / Top 5 variant  
    - Top Value Salary (M)  
    - Top 5 Value Players (concatenated IDs)

---

## Key SQL & DAX Highlights

### SQL

- Layered modeling using **CTEs** and **views**:
  - Raw → Staging → Dimensional mart
- Window functions:
  - `DENSE_RANK()` for seasonal rankings
  - Rolling and aggregated stats by season/league/team
- `corr()` for correlation between payroll and win% / R/G
- Defensive coding:
  - `NULLIF(x, 0)` to avoid divide-by-zero
  - Consistent typing with `::int`, `::numeric`

### DAX

- Time intelligence driven by a custom season date dimension
- Rank measures using `RANKX` with `ALL` / `ALLSELECTED`
- Composite metrics (Prod Index, Value Score) defined as reusable measures
- TopN logic for:
  - Top value players per season
  - Cutoffs and card metrics based on the top group

---

## How to Reproduce

1. **Create PostgreSQL database**

   ```sql
   CREATE DATABASE mlb_flagship;

2. **Create schemas and raw tables**

In the mlb_flagship database:
- Create schemas: raw_lahman, stg, dm_macro.
- Create raw tables for at least:
   - raw_lahman.teams_raw
   - raw_lahman.batting_raw
   - raw_lahman.salaries_raw
See the SQL files in the sql/ folder for table definitions.

Download Lahman / Baseball Databank CSVs

Download the Teams, Batting, and Salaries CSVs from the Baseball Databank / Lahman Kaggle dataset.

Place them in a local data/ or data/raw/ folder (your choice).

Load raw data into PostgreSQL

Use either:

COPY statements from psql, or

The pgAdmin Import/Export tool

To load:

Teams → raw_lahman.teams_raw

Batting → raw_lahman.batting_raw

Salaries → raw_lahman.salaries_raw

Create staging views and data mart objects

Run the SQL scripts in the sql/ folder (in order) to:

Clean and type raw data into staging views:

stg.v_teams

stg.v_batting_py_team_metrics

stg.v_salaries

(and any other views defined in the scripts)

Populate dimension tables:

dm_macro.dim_season

dm_macro.dim_league

Build fact tables and views:

dm_macro.league_season_kpi_simple

dm_macro.v_team_payroll_perf

dm_macro.v_value_hunters_base

dm_macro.v_dim_season_date

Open the Power BI report

Open powerbi/mlb_moneyball_dashboard.pbix (or the PBIX file included in this repo).

Update the PostgreSQL server and database connection if needed
(Transform Data → Data source settings).

Set relationships and Date table (if needed)

In Power BI:

Confirm v_dim_season_date[season_date] is marked as the Date table.

Confirm relationships:

v_dim_season_date[season] → league_season_kpi_simple[season]

v_dim_season_date[season] → v_team_payroll_perf[season]

v_dim_season_date[season] → v_value_hunters_base[yearid]

Refresh the model

In Power BI Desktop, click Refresh.

All three report pages should now populate with data.

```plaintext
mlb-moneyball-bi/
├─ README.md
├─ powerbi/
│  └─ mlb_moneyball_dashboard.pbix
├─ sql/
│  ├─ 01_create_schemas_and_raw_tables.sql
│  ├─ 02_load_lahman_teams_batting_salaries.sql
│  ├─ 03_stg_views.sql
│  ├─ 04_dm_macro_league_kpis.sql
│  ├─ 05_team_payroll_perf.sql
│  └─ 06_value_hunters_base.sql
├─ data/
│  └─ (optional notes or sample files – raw Lahman CSVs not committed)
└─ images/
   ├─ page1_league_run_environment.png
   ├─ page2_team_payroll_vs_wins.png
   └─ page3_value_hunter.png
```
