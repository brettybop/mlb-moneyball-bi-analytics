-- 02__raw_tables.sql
-- Purpose: create raw landing tables for Lahman CSV imports
-- Pattern:
--   1) *_raw_text  = permissive landing tables (all TEXT)
--   2) *_raw       = typed raw tables promoted from raw_text

SET search_path = raw_lahman, public;

-- =========================================================
-- TEAMS
-- =========================================================

DROP TABLE IF EXISTS raw_lahman.teams_raw_text;
CREATE TABLE raw_lahman.teams_raw_text (
  "yearID"           TEXT,
  "lgID"             TEXT,
  "teamID"           TEXT,
  "franchID"         TEXT,
  "divID"            TEXT,
  "Rank"             TEXT,
  "G"                TEXT,
  "Ghome"            TEXT,
  "W"                TEXT,
  "L"                TEXT,
  "DivWin"           TEXT,
  "WCWin"            TEXT,
  "LgWin"            TEXT,
  "WSWin"            TEXT,
  "R"                TEXT,
  "AB"               TEXT,
  "H"                TEXT,
  "2B"               TEXT,
  "3B"               TEXT,
  "HR"               TEXT,
  "BB"               TEXT,
  "SO"               TEXT,
  "SB"               TEXT,
  "CS"               TEXT,
  "HBP"              TEXT,
  "SF"               TEXT,
  "RA"               TEXT,
  "ER"               TEXT,
  "ERA"              TEXT,
  "CG"               TEXT,
  "SHO"              TEXT,
  "SV"               TEXT,
  "IPouts"           TEXT,
  "HA"               TEXT,
  "HRA"              TEXT,
  "BBA"              TEXT,
  "SOA"              TEXT,
  "E"                TEXT,
  "DP"               TEXT,
  "FP"               TEXT,
  "name"             TEXT,
  "park"             TEXT,
  "attendance"       TEXT,
  "BPF"              TEXT,
  "PPF"              TEXT,
  "teamIDBR"         TEXT,
  "teamIDlahman45"   TEXT,
  "teamIDretro"      TEXT
);

DROP TABLE IF EXISTS raw_lahman.teams_raw;
CREATE TABLE raw_lahman.teams_raw (
  "yearID"           INT,
  "lgID"             TEXT,
  "teamID"           TEXT,
  "franchID"         TEXT,
  "divID"            TEXT,
  "Rank"             INT,
  "G"                INT,
  "Ghome"            INT,
  "W"                INT,
  "L"                INT,
  "DivWin"           TEXT,
  "WCWin"            TEXT,
  "LgWin"            TEXT,
  "WSWin"            TEXT,
  "R"                INT,
  "AB"               INT,
  "H"                INT,
  "2B"               INT,
  "3B"               INT,
  "HR"               INT,
  "BB"               INT,
  "SO"               INT,
  "SB"               INT,
  "CS"               INT,
  "HBP"              INT,
  "SF"               INT,
  "RA"               INT,
  "ER"               INT,
  "ERA"              NUMERIC(8,3),
  "CG"               INT,
  "SHO"              INT,
  "SV"               INT,
  "IPouts"           INT,
  "HA"               INT,
  "HRA"              INT,
  "BBA"              INT,
  "SOA"              INT,
  "E"                INT,
  "DP"               INT,
  "FP"               NUMERIC(8,3),
  "name"             TEXT,
  "park"             TEXT,
  "attendance"       BIGINT,
  "BPF"              INT,
  "PPF"              INT,
  "teamIDBR"         TEXT,
  "teamIDlahman45"   TEXT,
  "teamIDretro"      TEXT
);

CREATE INDEX IF NOT EXISTS ix_teams_raw_year_lg_team
  ON raw_lahman.teams_raw ("yearID", "lgID", "teamID");


-- =========================================================
-- BATTING
-- =========================================================

DROP TABLE IF EXISTS raw_lahman.batting_raw_text;
CREATE TABLE raw_lahman.batting_raw_text (
  "playerID"         TEXT,
  "yearID"           TEXT,
  "stint"            TEXT,
  "teamID"           TEXT,
  "lgID"             TEXT,
  "G"                TEXT,
  "AB"               TEXT,
  "R"                TEXT,
  "H"                TEXT,
  "2B"               TEXT,
  "3B"               TEXT,
  "HR"               TEXT,
  "RBI"              TEXT,
  "SB"               TEXT,
  "CS"               TEXT,
  "BB"               TEXT,
  "SO"               TEXT,
  "IBB"              TEXT,
  "HBP"              TEXT,
  "SH"               TEXT,
  "SF"               TEXT,
  "GIDP"             TEXT
);

DROP TABLE IF EXISTS raw_lahman.batting_raw;
CREATE TABLE raw_lahman.batting_raw (
  "playerID"         TEXT,
  "yearID"           INT,
  "stint"            INT,
  "teamID"           TEXT,
  "lgID"             TEXT,
  "G"                INT,
  "AB"               INT,
  "R"                INT,
  "H"                INT,
  "2B"               INT,
  "3B"               INT,
  "HR"               INT,
  "RBI"              INT,
  "SB"               INT,
  "CS"               INT,
  "BB"               INT,
  "SO"               INT,
  "IBB"              INT,
  "HBP"              INT,
  "SH"               INT,
  "SF"               INT,
  "GIDP"             INT,
  PRIMARY KEY ("playerID", "yearID", "stint")
);

CREATE INDEX IF NOT EXISTS ix_batting_raw_year_lg
  ON raw_lahman.batting_raw ("yearID", "lgID");

CREATE INDEX IF NOT EXISTS ix_batting_raw_player
  ON raw_lahman.batting_raw ("playerID");


-- =========================================================
-- SALARIES
-- =========================================================

DROP TABLE IF EXISTS raw_lahman.salaries_raw_text;
CREATE TABLE raw_lahman.salaries_raw_text (
  "yearID"           TEXT,
  "teamID"           TEXT,
  "lgID"             TEXT,
  "playerID"         TEXT,
  "salary"           TEXT
);

DROP TABLE IF EXISTS raw_lahman.salaries_raw;
CREATE TABLE raw_lahman.salaries_raw (
  "yearID"           INT,
  "teamID"           TEXT,
  "lgID"             TEXT,
  "playerID"         TEXT,
  "salary"           NUMERIC(14,2),
  PRIMARY KEY ("playerID", "yearID", "teamID")
);

CREATE INDEX IF NOT EXISTS ix_salaries_raw_year_lg
  ON raw_lahman.salaries_raw ("yearID", "lgID");

CREATE INDEX IF NOT EXISTS ix_salaries_raw_player
  ON raw_lahman.salaries_raw ("playerID");
