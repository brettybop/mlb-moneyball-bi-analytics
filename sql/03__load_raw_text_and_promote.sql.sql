-- 03__load_raw_text_and_promote.sql
-- Purpose: promote permissive *_raw_text landing tables into typed *_raw tables
-- Pattern:
--   1) remove accidental header rows
--   2) TRUNCATE typed raw tables
--   3) INSERT ... SELECT with TRIM + NULLIF + safe casts

SET search_path = raw_lahman, public;

-- =========================================================
-- TEAMS: remove accidental header row
-- =========================================================

DELETE FROM raw_lahman.teams_raw_text
WHERE TRIM("yearID") = 'yearID';

TRUNCATE TABLE raw_lahman.teams_raw;

INSERT INTO raw_lahman.teams_raw (
  "yearID",
  "lgID",
  "teamID",
  "franchID",
  "divID",
  "Rank",
  "G",
  "Ghome",
  "W",
  "L",
  "DivWin",
  "WCWin",
  "LgWin",
  "WSWin",
  "R",
  "AB",
  "H",
  "2B",
  "3B",
  "HR",
  "BB",
  "SO",
  "SB",
  "CS",
  "HBP",
  "SF",
  "RA",
  "ER",
  "ERA",
  "CG",
  "SHO",
  "SV",
  "IPouts",
  "HA",
  "HRA",
  "BBA",
  "SOA",
  "E",
  "DP",
  "FP",
  "name",
  "park",
  "attendance",
  "BPF",
  "PPF",
  "teamIDBR",
  "teamIDlahman45",
  "teamIDretro"
)
SELECT
  NULLIF(TRIM("yearID"), '')::INT,
  NULLIF(TRIM("lgID"), ''),
  NULLIF(TRIM("teamID"), ''),
  NULLIF(TRIM("franchID"), ''),
  NULLIF(TRIM("divID"), ''),
  NULLIF(TRIM("Rank"), '')::INT,
  NULLIF(TRIM("G"), '')::INT,
  NULLIF(TRIM("Ghome"), '')::INT,
  NULLIF(TRIM("W"), '')::INT,
  NULLIF(TRIM("L"), '')::INT,
  NULLIF(TRIM("DivWin"), ''),
  NULLIF(TRIM("WCWin"), ''),
  NULLIF(TRIM("LgWin"), ''),
  NULLIF(TRIM("WSWin"), ''),
  NULLIF(TRIM("R"), '')::INT,
  NULLIF(TRIM("AB"), '')::INT,
  NULLIF(TRIM("H"), '')::INT,
  NULLIF(TRIM("2B"), '')::INT,
  NULLIF(TRIM("3B"), '')::INT,
  NULLIF(TRIM("HR"), '')::INT,
  NULLIF(TRIM("BB"), '')::INT,
  NULLIF(TRIM("SO"), '')::INT,
  NULLIF(TRIM("SB"), '')::INT,
  NULLIF(TRIM("CS"), '')::INT,
  NULLIF(TRIM("HBP"), '')::INT,
  NULLIF(TRIM("SF"), '')::INT,
  NULLIF(TRIM("RA"), '')::INT,
  NULLIF(TRIM("ER"), '')::INT,
  NULLIF(TRIM("ERA"), '')::NUMERIC(8,3),
  NULLIF(TRIM("CG"), '')::INT,
  NULLIF(TRIM("SHO"), '')::INT,
  NULLIF(TRIM("SV"), '')::INT,
  NULLIF(TRIM("IPouts"), '')::INT,
  NULLIF(TRIM("HA"), '')::INT,
  NULLIF(TRIM("HRA"), '')::INT,
  NULLIF(TRIM("BBA"), '')::INT,
  NULLIF(TRIM("SOA"), '')::INT,
  NULLIF(TRIM("E"), '')::INT,
  NULLIF(TRIM("DP"), '')::INT,
  NULLIF(TRIM("FP"), '')::NUMERIC(8,3),
  NULLIF(TRIM("name"), ''),
  NULLIF(TRIM("park"), ''),
  NULLIF(TRIM("attendance"), '')::BIGINT,
  NULLIF(TRIM("BPF"), '')::INT,
  NULLIF(TRIM("PPF"), '')::INT,
  NULLIF(TRIM("teamIDBR"), ''),
  NULLIF(TRIM("teamIDlahman45"), ''),
  NULLIF(TRIM("teamIDretro"), '')
FROM raw_lahman.teams_raw_text
WHERE TRIM("yearID") <> ''
  AND TRIM("yearID") ~ '^\d{4}$';


-- =========================================================
-- BATTING: remove accidental header row
-- =========================================================

DELETE FROM raw_lahman.batting_raw_text
WHERE TRIM("playerID") = 'playerID';

TRUNCATE TABLE raw_lahman.batting_raw;

INSERT INTO raw_lahman.batting_raw (
  "playerID",
  "yearID",
  "stint",
  "teamID",
  "lgID",
  "G",
  "AB",
  "R",
  "H",
  "2B",
  "3B",
  "HR",
  "RBI",
  "SB",
  "CS",
  "BB",
  "SO",
  "IBB",
  "HBP",
  "SH",
  "SF",
  "GIDP"
)
SELECT
  NULLIF(TRIM("playerID"), ''),
  NULLIF(TRIM("yearID"), '')::INT,
  NULLIF(TRIM("stint"), '')::INT,
  NULLIF(TRIM("teamID"), ''),
  NULLIF(TRIM("lgID"), ''),
  NULLIF(TRIM("G"), '')::INT,
  NULLIF(TRIM("AB"), '')::INT,
  NULLIF(TRIM("R"), '')::INT,
  NULLIF(TRIM("H"), '')::INT,
  NULLIF(TRIM("2B"), '')::INT,
  NULLIF(TRIM("3B"), '')::INT,
  NULLIF(TRIM("HR"), '')::INT,
  NULLIF(TRIM("RBI"), '')::INT,
  NULLIF(TRIM("SB"), '')::INT,
  NULLIF(TRIM("CS"), '')::INT,
  NULLIF(TRIM("BB"), '')::INT,
  NULLIF(TRIM("SO"), '')::INT,
  NULLIF(TRIM("IBB"), '')::INT,
  NULLIF(TRIM("HBP"), '')::INT,
  NULLIF(TRIM("SH"), '')::INT,
  NULLIF(TRIM("SF"), '')::INT,
  NULLIF(TRIM("GIDP"), '')::INT
FROM raw_lahman.batting_raw_text
WHERE TRIM("playerID") <> ''
  AND TRIM("yearID") ~ '^\d{4}$';


-- =========================================================
-- SALARIES: remove accidental header row
-- =========================================================

DELETE FROM raw_lahman.salaries_raw_text
WHERE TRIM("playerID") = 'playerID';

TRUNCATE TABLE raw_lahman.salaries_raw;

INSERT INTO raw_lahman.salaries_raw (
  "yearID",
  "teamID",
  "lgID",
  "playerID",
  "salary"
)
SELECT
  NULLIF(TRIM("yearID"), '')::INT,
  NULLIF(TRIM("teamID"), ''),
  NULLIF(TRIM("lgID"), ''),
  NULLIF(TRIM("playerID"), ''),
  NULLIF(REPLACE(TRIM("salary"), ',', ''), '')::NUMERIC(14,2)
FROM raw_lahman.salaries_raw_text
WHERE TRIM("playerID") <> ''
  AND TRIM("yearID") ~ '^\d{4}$';
