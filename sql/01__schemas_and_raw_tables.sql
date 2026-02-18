-- 01__schemas_and_raw_tables.sql
CREATE SCHEMA IF NOT EXISTS raw_lahman;
CREATE SCHEMA IF NOT EXISTS stg;
CREATE SCHEMA IF NOT EXISTS dm_macro;

-- RAW TABLE: Teams
CREATE TABLE IF NOT EXISTS raw_lahman.teams_raw (
  yearid INT,
  lgid TEXT,
  teamid TEXT,
  franchid TEXT,
  divid TEXT,
  rank INT,
  g INT,
  ghome INT,
  w INT,
  l INT,
  divwin TEXT,
  wcwin TEXT,
  lgwin TEXT,
  wswin TEXT,
  r INT,
  ab INT,
  h INT,
  "2b" INT,
  "3b" INT,
  hr INT,
  bb INT,
  so INT,
  sb INT,
  cs INT,
  hbp INT,
  sf INT,
  ra INT,
  er INT,
  era NUMERIC,
  cg INT,
  sho INT,
  sv INT,
  ipouts INT,
  ha INT,
  hra INT,
  bba INT,
  soa INT,
  e INT,
  dp INT,
  fp NUMERIC,
  name TEXT,
  park TEXT,
  attendance BIGINT,
  bpf INT,
  ppf INT,
  teamidbr TEXT,
  teamidlahman45 TEXT,
  teamidretro TEXT
);

-- RAW TABLE: Batting
CREATE TABLE IF NOT EXISTS raw_lahman.batting_raw (
  playerid TEXT,
  yearid INT,
  stint INT,
  teamid TEXT,
  lgid TEXT,
  g INT,
  ab INT,
  r INT,
  h INT,
  "2b" INT,
  "3b" INT,
  hr INT,
  rbi INT,
  sb INT,
  cs INT,
  bb INT,
  so INT,
  ibb INT,
  hbp INT,
  sh INT,
  sf INT,
  gidp INT
);

-- RAW TABLE: Salaries
CREATE TABLE IF NOT EXISTS raw_lahman.salaries_raw (
  yearid INT,
  teamid TEXT,
  lgid TEXT,
  playerid TEXT,
  salary BIGINT
);

-- Helpful indexes (optional but nice)
CREATE INDEX IF NOT EXISTS idx_teams_year_lg_team ON raw_lahman.teams_raw(yearid, lgid, teamid);
CREATE INDEX IF NOT EXISTS idx_batting_year_team_player ON raw_lahman.batting_raw(yearid, teamid, playerid);
CREATE INDEX IF NOT EXISTS idx_salaries_year_team_player ON raw_lahman.salaries_raw(yearid, teamid, playerid);
