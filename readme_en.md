# Football Tables

This project is a PL/SQL-based system for automating the generation of football championship fixtures and tables. It manages everything from registering countries and teams to creating the logical rounds (legs) for a championship.

## 1) Project Overview and Purpose
The main goal is to provide a database structure and backend logic (in Oracle PL/SQL) to organize football championships automatically. The system validates the number of participants and generates the necessary fixtures to cover all matches between the registered teams.

## 2) Usage Instructions
To use this project, you must have access to an Oracle database. Follow the execution order of the scripts:
1.  Run the table creation script located in `TABLES SCRIPT/TABLES.sql`.
2.  Compile the utility package: `PACKAGES/PKG_UTILS.pck`.
3.  Compile the main championship package: `PACKAGES/PKG_TABLESCHAMPIONSHIPS.pck`.

## 3) Step-by-Step Feature Guide
1.  **Register Countries**: Insert countries into the `COUNTRIES` table.
2.  **Register Teams**: Insert teams into the `TEAMS` table, associating them with a country.
3.  **Create a Championship**: Insert a new record into the `CHAMPIONSHIPS` table.
4.  **Register Teams in Championship**: Link teams to the championship using the `TEAMS_CHAMPIONSHIP` table.
5.  **Generate Matches**: Run the `PKG_TABLESCHAMPIONSHIPS.CREATE_CHAMPIONSHIP_MATCHES` procedure passing the championship ID.

## 4) Usage Examples

### Inserting Basic Data
```sql
-- Insert a country
INSERT INTO COUNTRIES (name, initials) VALUES ('Brazil', 'BRA');

-- Insert a team
INSERT INTO TEAMS (name, completename, initials, country_id)
VALUES ('Flamengo', 'Clube de Regatas do Flamengo', 'FLA', 1);

-- Create a championship
INSERT INTO CHAMPIONSHIPS (name, country_id, season)
VALUES ('Brasileirão', 1, '2023');

-- Link a team to the championship (TEAM_ID = 1, CHAMP_ID = 1)
INSERT INTO TEAMS_CHAMPIONSHIP (TEAM_ID, CHAMPIONSHIP_ID) VALUES (1, 1);
```

### Generating Championship Matches
```sql
DECLARE
  v_result VARCHAR2(4000);
BEGIN
  -- Assuming the championship ID is 1
  PKG_TABLESCHAMPIONSHIPS.CREATE_CHAMPIONSHIP_MATCHES(1, v_result);
  DBMS_OUTPUT.PUT_LINE(v_result);
END;
/
```

## 5) Dependencies and System Requirements
-   **Database**: Oracle Database 12c or higher (due to the use of `GENERATED ALWAYS AS IDENTITY`).
-   **Permissions**: The user must have privileges to create tables, packages, and sequences.

## 6) Frequently Asked Questions (FAQ)

### Why does the system require the number of teams to be a power of 2 (2, 4, 8, 16...)?
The `PKG_UTILS.CheckNumberOfTeams` function validates whether the number of participating teams follows a power-of-2 progression. This is commonly used in specific tournament formats or to ensure balanced round distribution according to the current package logic.

### How are matches organized?
Matches are divided into "legs" (rounds). The system attempts to ensure that each team plays only once per round.

## 7) Contribution Guidelines
Feel free to contribute to the project!
1.  **Fork** the repository.
2.  Create a **Branch** for your feature (`git checkout -b feature/new-feature`).
3.  **Commit** your changes.
4.  Send a **Pull Request**.

---

## Why do we use Cross Join to build the tables?
In the `CREATE_CHAMPIONSHIP_MATCHES` procedure, we use a technique similar to a **Cross Join** (Cartesian product) between the teams table (alias `a` for home teams and `b` for away teams).

The technical reason is that to generate a championship where everyone plays against everyone, we initially need all possible combinations of team pairs. The Cross Join generates this "universe" of fixtures. From this Cartesian product, we apply essential filters:
1.  `where a.home <> b.away`: Ensures a team does not play against itself.
2.  `WHERE NOT EXISTS (...)`: Ensures no duplicate matches are created (preventing "Team A x Team B" from being inserted again if "Team B x Team A" already exists or vice-versa, depending on the turn settings).

This approach simplifies the logic of discovering matches, allowing SQL to handle the data combination while PL/SQL focuses on organizing those matches within chronological rounds.
