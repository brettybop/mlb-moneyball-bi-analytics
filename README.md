# ⚾ MLB Run Environment & Value Hunter Analytics (Power BI + PostgreSQL)

This project is my **flagship baseball analytics dashboard** built with **PostgreSQL** and **Power BI**.

Specifically we look at a bunch of baseball data from the Lahman Baseball Databank ranging back to the late 1800's. 

Baseball has been around a long time and there is a bunch of great data we can analyze. Let's dig in!

## 🎯 Project Objective
This project answers three layers of questions:

1. **League-level run environment:**  
   How has scoring, on-base ability, and pitcher dominance changed over time?

2. **Team-level performance vs payroll:**  
   Does payroll actually buy wins, and which teams over- or under-perform their spend?

3. **Player-level “Value Hunter”:**  
   Which hitters deliver the most production for the least salary in a given season?

**VISIT LINK BELOW TO VISIT PUBLIC VERSION OF THE DASHBOARD**
```
https://app.powerbi.com/view?r=eyJrIjoiYjIyMWJlYjUtNjJmNi00MDdmLTkwOTQtYjkwNDczYmNjMDMyIiwidCI6IjJhMDkyZDhmLTNjNDktNDkwMy05ZTA2LThhNjU4MzY1YWI1OCIsImMiOjZ9&embedImagePlaceholder=true
```
---

## 📊 Data Source

We use the open **Baseball Databank (Lahman)** dataset (via the Kaggle “Baseball Databank” mirror).

```
https://www.kaggle.com/datasets/open-source-sports/baseball-databank
```

Key tables used:

- `Teams` – team-season results (R, AB, HR, BB, SO, etc.)
- `Batting` – player-season batting stats
- `Salaries` – player salaries by team and season

The raw CSVs are contained within the `/data` folder.

---

## Tech Stack

- **Database:** PostgreSQL  
  - Schemas: `raw_lahman`, `stg`, `dm_macro`  
  - Features used:
       - CTEs
       - window functions
       - `DENSE_RANK`
       - `LAG`
       - rolling 5-year averages
       - `STDDEV_SAMP`
       - `corr`
       - typed views and materialized fact tables
- **BI Tool:** Power BI Desktop  
  - Star schema modeling
  - relationships
  - time intelligence  
  - DAX measures for KPIs and value scoring
- **Language:** SQL + DAX

---

## 🧱 Data Modeling Overview

### Schemas

- **`raw_lahman`**  
  Raw CSV Landing + typed raw tables (`teams_raw`;`teams_raw_text`, `batting_raw`;`batting_raw_text`, `salaries_raw`;`salaries_raw_text`).

- **`stg` (staging)**  
  Cleaned / typed views, e.g.:
  - `stg.v_teams`
  - `stg.v_salaries`
  - `stg.v_batting`
  - `stg.v_batting_py_team_metrics`
  - `stg.v_batting_py_team` 

- **`dm_macro` (data mart)**  
  Dimensions:
  - `dm_macro.dim_season` – seasons
  - `dm_macro.dim_league` – AL / NL / MLB
  Fact tables:
  - `dm_macro.fact_team_season`
  - `dm_macro.league_season_kpi_simple` – macro KPIs by league/season
  - `dm_macro.v_team_payroll_perf` – team-season performance vs payroll
  Views:
  - `dm_macro.v_value_hunters_base` – player-season batting + salary for value analysis  
  - `dm_macro.v_dim_season_date` – season → mid-year date for time intelligence
  - `dm_macro.v_team_payroll_perf`
  - `dm_macro.v_mlb_trend`
  - `dm_macro.v_value_hunters_pyteam

In Power BI, `v_dim_season_date[season_date]` is marked as the **Date table**, with relationships:

- `v_dim_season_date[season]` → `league_season_kpi_simple[season]`
- `v_dim_season_date[season]` → `v_team_payroll_perf[season]`
- `v_dim_season_date[season]` → `v_value_hunters_base[yearid]`

This enables DAX time functions and consistent season filtering.

---

## 🗐 Power BI Pages & Questions Answered

### 📄 Page 1 – League Run Environment & Eras

**Goal:** Understand how the **game itself** has evolved.

Questions:

- **Is scoring up or down over time?**  
  - Runs per game (R/G) by season
  - Year-over-year change
  - 5-year moving average

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
Run:
- `01__schemas.sql`
- `02__raw_tables.sql`

This creates:
- raw_lahman
- stg
- dm_macro

3. **Download Lahman / Baseball Databank CSVs**
Download the Teams, Batting, and Salaries CSVs from the Baseball Databank / Lahman Kaggle dataset.
Place them in a local data/ or data/raw/ folder.

4. **Load raw CSVs into the `*_raw_text` tables**
Use either:
- `COPY` statements from psql, or
- the pgAdmin *Import/Export* tool

Load the CSVs into:
- `raw_lahman.teams_raw_text`
- `raw_lahman.batting_raw_text`
- `raw_lahman.salaries_raw_text`

5. **Promote raw text to typed raw tables**
Run:
- `03__load_raw_text_and_promote.sql`

This script:
- removes accidental header rows
- trims whitespace
- converts blank strings to NULL
- and casts text into typed raw tables

6. **Build the staging layer**
Run:
- `04__stg_views.sql`

7. **Build the dimensional mart**
Run:
- `05__dm_dims.sql`
- `06__dm_facts_team_season_and_payroll.sql`
- `07__dm_league_season_kpis.sql`
- `08__dm_views_trends_and_payroll_perf.sql`
- `09__dm_value_hunter_views.sql`

8. **Run validation checks**
Optionally run:
- `99__sanity_checks.sql`

9. **Open the Power BI report**
- Open powerbi/mlb_moneyball_dashboard.pbix
- Update PostgreSQL server/database connection if needed:
   - Transform Data → Data source settings

10. **Set relationships and Date table**

In Power BI:
- Mark v_dim_season_date[season_date] as the Date table
- Confirm relationships:
   - v_dim_season_date[season] → league_season_kpi_simple[season]
   - v_dim_season_date[season] → v_team_payroll_perf[season]
   - v_dim_season_date[season] → v_value_hunters_base[yearid]

11. **Refresh the model**
- Click Refresh in Power BI Desktop
- All report pages should populate with data

## 📁 Repository Structure

```plaintext
mlb-moneyball-bi/
├─ README.md
├─ powerbi/
│  └─ mlb_moneyball_dashboard.pbix
├─ sql/
│  ├─ 00__README_run_order.md
│  ├─ 01__schemas.sql
│  ├─ 02__raw_tables.sql
│  ├─ 03__load_raw_text_and_promote.sql
│  ├─ 04__stg_views.sql
│  ├─ 05__dm_dims.sql
│  ├─ 06__dm_facts_team_season_and_payroll.sql
│  ├─ 07__dm_league_season_kpis.sql
│  ├─ 08__dm_views_trends_and_payroll_perf.sql
│  ├─ 09__dm_value_hunter_views.sql
│  └─ 99__sanity_checks.sql
├─ data/
│  └─ (raw Lahman CSVs)
└─ images/
   ├─ model_view_BI
   └─ extras
```
