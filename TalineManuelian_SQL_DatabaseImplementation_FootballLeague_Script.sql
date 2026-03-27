/* FOOTBALL LEAGUE DATABASE
      DDL: TABLE CREATION   */

-- reset for during development
DROP TABLE IF EXISTS result CASCADE;
DROP TABLE IF EXISTS event CASCADE;
DROP TABLE IF EXISTS match_fixture CASCADE;
DROP TABLE IF EXISTS player CASCADE;
DROP TABLE IF EXISTS venue CASCADE;
DROP TABLE IF EXISTS team CASCADE;
DROP TABLE IF EXISTS "group" CASCADE;

-- Set DateStyle to DD/MM/YYYY
SET datestyle = 'DMY';

-- 1) TEAM
CREATE TABLE team (
  team_id INT PRIMARY KEY,
  team_name VARCHAR(50) NOT NULL UNIQUE
);

SELECT *
FROM team;

-- 2) GROUP (group needs to be quoted as it is a reserved keyword)
CREATE TABLE "group" (
  group_id INT PRIMARY KEY,
  group_name VARCHAR(50) NOT NULL UNIQUE
);

-- 3) VENUE
CREATE TABLE venue (
  venue_id INT PRIMARY KEY,
  venue_name VARCHAR(50) NOT NULL UNIQUE
);

-- 4) PLAYER
CREATE TABLE player (
  player_id INT PRIMARY KEY,
  consultant_id INT NOT NULL, 
  player_name VARCHAR(100) NOT NULL UNIQUE,
  team_id INT NOT NULL,
  group_id INT NOT NULL,
  
  -- foreign keys to player
  CONSTRAINT fk_player_team FOREIGN KEY (team_id) REFERENCES team(team_id),
  CONSTRAINT fk_player_group FOREIGN KEY (group_id) REFERENCES "group"(group_id)
);

-- 5) MATCH
CREATE TABLE match_fixture (-- match renamed to match_fixture as could be confusing with function 'match')
  match_id INT PRIMARY KEY,
  match_date DATE NOT NULL,
  match_time TIME NOT NULL,
  venue_id INT NOT NULL,
  home_team_id INT NOT NULL,
  away_team_id INT NOT NULL,
  week_number INT NULL,
  match_type VARCHAR(10) NOT NULL,
  
  -- foreign keys to match
  CONSTRAINT fk_match_venue FOREIGN KEY (venue_id) REFERENCES venue(venue_id),
  CONSTRAINT fk_match_home_team FOREIGN KEY (home_team_id) REFERENCES team(team_id),
  CONSTRAINT fk_match_away_team FOREIGN KEY (away_team_id) REFERENCES team(team_id),

  -- Domain constraints
  CONSTRAINT chk_match_type CHECK (match_type IN ('Season','Friendly')),
  CONSTRAINT chk_teams_different CHECK (home_team_id <> away_team_id),

  -- Friendly vs Season week rule 
  CONSTRAINT chk_week_by_type CHECK (
    (match_type = 'Friendly' AND week_number IS NULL)
    OR (match_type = 'Season' AND week_number IS NOT NULL)
  ));

-- 6) EVENT (goals/cards stored here)
CREATE TABLE event (
  event_id INT PRIMARY KEY,
  match_id INT NOT NULL,
  player_id INT NOT NULL,
  event_type VARCHAR(10) NOT NULL,
  game_minute INT NOT NULL, -- minute renamed to game_minute

  -- foreign keys to event
  CONSTRAINT fk_event_match FOREIGN KEY (match_id) REFERENCES match_fixture(match_id),
  CONSTRAINT fk_event_player FOREIGN KEY (player_id) REFERENCES player(player_id),

  -- event range of options (can be ammended if there are new additions later on, for now only these)
  CONSTRAINT chk_event_type CHECK (event_type IN ('Goal','Yellow','Red')),
  CONSTRAINT chk_game_minute CHECK (game_minute BETWEEN 0 AND 90)
  );

-- 7) RESULT: stores points per team per match
CREATE TABLE result (
  result_id INT PRIMARY KEY,
  match_id INT NOT NULL,
  team_id INT NOT NULL,
  points INT NULL, --future games points will be NULL as they are yet to occur

  -- constraint that each match must have exactly two result rows: one for home and one for away team
  CONSTRAINT uq_result_match_team UNIQUE (match_id, team_id),

  -- foreign keys to result
  CONSTRAINT fk_result_match FOREIGN KEY (match_id) REFERENCES match_fixture(match_id),
  CONSTRAINT fk_result_team FOREIGN KEY (team_id) REFERENCES team(team_id),
  
  -- constraint for point options
  CONSTRAINT chk_points CHECK (points IN (0,1,3))
);

/* DML: REFERENCE DATA */

-- 1) TEAM
INSERT INTO team (team_id, team_name) VALUES
(1,'Data Masters'),
(2,'BI Gods'),
(3,'Vis Wizards'),
(4,'Data Cleaners');

-- 2) GROUP
INSERT INTO "group" (group_id, group_name) VALUES
(1,'Cohort 4'),
(2,'Cohort 5'),
(3,'Cohort 6'),
(4,'Cohort 7'),
(5,'Bench'),
(6,'Training Team'),
(7,'HR'),
(8,'Consultants');

-- 3) VENUE
INSERT INTO venue (venue_id, venue_name) VALUES
(1,'Wimbeldon 1'),
(2,'Wimbeldon 2'),
(3,'Wimbeldon 3');

/* DML: TRANSACTIONAL DATA */

-- 4) Players
INSERT INTO player (player_id,
consultant_id,
player_name,
team_id,
group_id) VALUES
(1,200,'Aedan Petty',1,1),
(2,201,'Aliza Santos',1,3),
(3,202,'Kalynn Vaughan',1,6),
(4,203,'Arjun Bauer',1,3),
(5, 202,'Lilian Huber',1,2),
(6,	203,'Lizeth Roberts',1,6),
(7,	203,'Nathan Mcdowell',1,7),
(8,	204,'Alvin Ali',1,8),
(9,	204,'Jordin Christensen',1,7),
(10, 205,'Saul Blevins',1,7),
(11, 205,'Carina Meza',2,2),
(12, 206,'Isabelle Campos',2,5),
(13, 206,'Kyleigh Phelps',2,1),
(14, 207,'Angela Wong',2,7),
(15, 207,'Kole Rojas',2,7),
(16, 208,'Martha Potts',2,4),
(17, 208,'Tomas Powell',2,6),
(18, 209,'Paxton Clarke',2,5),
(19, 209,'Jamya Dodson',2,8),
(20, 210,'Georgia Clements',2,8),
(21, 210,'Edwin Crawford',3,2),
(22, 211,'Malachi Osborn',3,8),
(23, 211,'Zion Kent',3,2),
(24, 212,'Anahi Reyes',3,5),
(25, 212,'Maddox Cabrera',3,8),
(26, 213,'Brody Gutierrez',3,4),
(27, 213,'Hayley Stevenson',3,3),
(28, 214,'Kamora Sanchez',3,8),
(29, 214,'Livia Holmes',3,6),
(30, 215,'Tanner Jenkins',3,8),
(31, 215,'Madelyn Meadows',4,5),
(32, 216,'Paola Wilkerson',4,3),
(33, 216,'Jared Patton',4,6),
(34, 217,'Pierre Washington',4,8),
(35, 217,'Dominik Cochran',4,4),
(36, 218,'Miya Skinner',4,4),
(37, 218,'Mara Barnett',4,5),
(38, 219,'Cornelius Dodson',4,2),
(39, 219,'Ashleigh Kaiser',4,6),
(40, 220,'Weston Meza',4,6)
;

-- 5) Matches
INSERT INTO match_fixture (match_id,
match_date,
match_time,
venue_id,
home_team_id,
away_team_id,
week_number,
match_type) VALUES
(1,'01/10/2022','16:00',1,1,	2,	1,	'Season'),
(2,'01/10/2022','16:00',2,3,	4,	1,	'Season'),
(3,'08/10/2022','16:00',2,1,	3,	2,	'Season'),
(4,'08/10/2022','16:00',3,	2,	4,	2, 'Season'),
(5,'22/10/2022','16:00',3,	1,	4,	3,	'Season'),
(6,'22/10/2022','16:00',2,	2,	3,	3,	'Season'),
(7,'29/10/2022','16:00',1,	2,	1,	4,	'Season'),
(8,'29/10/2022','16:00',3,	4,	3,	4,	'Season'),
(9,'05/11/2022','16:00',3,	3,	1,	5,	'Season'),
(10,'05/11/2022','16:00',1,	4,	2,	5,	'Season'),
(11,'12/11/2022','16:00',2,	4,	1,	6,	'Season'),
(12,'12/11/2022','16:00',3,	3,	2,	6, 'Season'),
(13,'12/11/2023','16:00',1,	4,	1,NULL,'Friendly'),
(14,'12/11/2023','16:00',3,	3,	2,NULL,	'Friendly')
;

-- 6) Events
INSERT INTO event (event_id,
match_id,
player_id,
event_type,
game_minute) VALUES
(1,	1,	8,	'Goal',	5),
(2, 1,	7,	'Goal',	80),
(3,	1,	12,	'Yellow',10),
(4,	2,	27,	'Goal', 11),
(5,	2,	30,	'Yellow',30),
(6,	2,	35,	'Goal',	10),
(7,	3,	8,	'Goal',	2),
(8,	3,	8,	'Goal',	88),
(9,	3,	1,	'Yellow',10),
(10, 3,	9,	'Yellow',70),
(11,3,	27,	'Goal',	85),
(12,4,	19,	'Goal',	20),
(13,4,	17,	'Goal',	40),
(14,4,	35,	'Goal',	30),
(15,4,	32,	'Red',	40),
(16,5,	10,	'Yellow',35),
(17,5,	38, 'Yellow',88),
(18,6,	19,	'Goal',	5),
(19,6,	28,	'Goal',	2),
(20,6,	27,	'Goal',	55),
(21,7,	19,	'Goal',	1),
(22,7,	16,	'Goal',	82),
(23,7,	8,	'Goal',	35),
(24,7,	3,	'Goal',	77),
(25,7,	3,	'Yellow',60),
(26,8,	35,	'Goal',	66),
(27,8,	35,	'Yellow',10),
(28,8,	25,	'Goal',	12),
(29,8,	27,	'Goal',	68),
(30,9,	29,	'Goal',	20),
(31,9,	29,	'Goal',	25),
(32,9,	26,	'Goal',	85),
(33,9,	23,	'Yellow',30),
(34,9,	7,	'Goal',	77),
(35,9,	8,	'Goal',	89),
(36,10,	32,	'Red',	10),
(37,10,	19,	'Goal',	75),
(38,11,	35,	'Goal',	25),
(39,11,	37,	'Goal',	46),
(40,11, 1,	'Yellow',62),
(41,12, 26,	'Goal',	80),
(42,12,	25,	'Goal',	90),
(43,12,	19,	'Goal',	29),
(44,12,	18, 'Goal',	87),
(45,12,	17,	'Yellow',42)
;

-- 7) Results: TWO rows per match (one per team)
-- Example: match 1 home team got 3, away team got 1
INSERT INTO result (result_id,
match_id,
team_id,
points) VALUES
(1,1,1,3),
(2,1,2,0),
(3,2,3,1),
(4,2,4,1),
(5,3,1,3),
(6,3,3,0),
(7,4,2,3),
(8,4,4,0),
(9,5,1,1),
(10,5,4,1),
(11,6,2,0),
(12,6,3,3),
(13,7,2,1),
(14,7,1,1),
(15,8,4,0),
(16,8,3,3),
(17,9,3,3),
(18,9,1,0),
(19,10,4,0),
(20,10,2,3),
(21,11,4,3),
(22,11,1,0),
(23,12,3,1),
(24,12,2,1),
(25,13,4,NULL),
(26,13,1,NULL),
(27,14,3,NULL),
(28,14,2,NULL)
;

/* TESTING: QUERYING THE DATA */

/* 1) Listing all students, who play for a particular department
(i.e. Cohort 4 group). */
SELECT p.player_id, p.player_name, t.team_name, g.group_name
FROM player p
JOIN team t ON t.team_id = p.team_id
JOIN "group" g ON g.group_id = p.group_id
WHERE g.group_name = 'Cohort 4'
ORDER BY p.player_name;

/* 2) Listing all fixtures for a specific date
(i.e. 29th of October 2022 and including team names and venues). */
SELECT
  m.match_id,
  m.match_date,
  m.match_time,
  ht.team_name AS home_team,
  at.team_name AS away_team,
  v.venue_name,
  m.match_type,
  m.week_number
FROM match_fixture m
JOIN team ht ON ht.team_id = m.home_team_id
JOIN team at ON at.team_id = m.away_team_id
JOIN venue v ON v.venue_id = m.venue_id
WHERE m.match_date = DATE '29-10-2022'
ORDER BY m.match_time, m.match_id;

-- 3) Listing all the players who have scored more than 2 goals.
SELECT
  p.player_id,
  p.player_name,
  t.team_name,
  COUNT(*) AS goals_scored
FROM event e
JOIN player p ON p.player_id = e.player_id
JOIN team t   ON t.team_id = p.team_id
WHERE e.event_type = 'Goal'
GROUP BY p.player_id, p.player_name, t.team_name
HAVING COUNT(*) > 2
ORDER BY goals_scored DESC, p.player_name;

-- 4) Listing the number of cards (yellow and red) per team.
SELECT
  t.team_name,
  SUM(CASE WHEN e.event_type = 'Yellow' THEN 1 ELSE 0 END) AS yellow_cards,
  SUM(CASE WHEN e.event_type = 'Red' THEN 1 ELSE 0 END) AS red_cards,
  COUNT(*) AS total_cards
FROM event e
JOIN player p ON p.player_id = e.player_id
JOIN team t ON t.team_id = p.team_id
WHERE e.event_type IN ('Yellow', 'Red')
GROUP BY t.team_name
ORDER BY total_cards DESC, t.team_name;

-- 5) Return the games that are going to be played (friendly matches).
SELECT
  m.match_type,
  m.match_id,
  m.match_date,
  m.match_time,
  ht.team_name AS home_team,
  at.team_name AS away_team,
  v.venue_name
FROM match_fixture m
JOIN team ht ON ht.team_id = m.home_team_id
JOIN team at ON at.team_id = m.away_team_id
JOIN venue v ON v.venue_id = m.venue_id
WHERE m.match_type = 'Friendly'
ORDER BY m.match_date, m.match_time;

-- 6) The table displays the team's name and the points earned during the tournament.
SELECT
  t.team_name,
  COALESCE(SUM(r.points), 0) AS points
FROM team t
LEFT JOIN result r ON r.team_id = t.team_id
LEFT JOIN match_fixture m ON m.match_id = r.match_id
WHERE (m.match_type = 'Season' OR m.match_type IS NULL) -- keeps teams with zero matches
GROUP BY t.team_name
ORDER BY points DESC, t.team_name;

/* 7) For each team, present the distribution of goals scored
and conceded in each half of the match. */
SELECT t.team_name,
    -- Goals Scored: First Half
    COUNT(CASE 
            WHEN e.event_type = 'Goal'
             AND e.game_minute BETWEEN 0 AND 45
             AND p.team_id = t.team_id
            THEN 1
         END) AS goals_scored_first_half,
		 
	-- Goals Scored: Second Half
	COUNT(CASE 
            WHEN e.event_type = 'Goal'
             AND e.game_minute BETWEEN 46 AND 90
             AND p.team_id = t.team_id
            THEN 1
         END) AS goals_scored_second_half,

	-- Goals Scored: Full Match Totals
    COUNT(CASE 
            WHEN e.event_type = 'Goal'
             AND p.team_id = t.team_id
            THEN 1
         END) AS goals_scored_full_match,

	-- Goals Conceded: First Half
    COUNT(CASE
            WHEN e.event_type = 'Goal'
             AND e.game_minute BETWEEN 0 AND 45
             AND (
                  (p.team_id = m.home_team_id AND t.team_id = m.away_team_id)
               OR (p.team_id = m.away_team_id AND t.team_id = m.home_team_id)
                 )
            THEN 1
         END) AS goals_conceded_first_half,

    -- Goals Conceded: Second Half
    COUNT(CASE
            WHEN e.event_type = 'Goal'
             AND e.game_minute BETWEEN 46 AND 90
             AND (
                  (p.team_id = m.home_team_id AND t.team_id = m.away_team_id)
               OR (p.team_id = m.away_team_id AND t.team_id = m.home_team_id)
                 )
            THEN 1
         END) AS goals_conceded_second_half,

	-- Goals Conceded: Full Match Totals
    COUNT(CASE
            WHEN e.event_type = 'Goal'
             AND (
                  (p.team_id = m.home_team_id AND t.team_id = m.away_team_id)
               OR (p.team_id = m.away_team_id AND t.team_id = m.home_team_id)
                 )
            THEN 1
         END) AS goals_conceded_full_match

FROM team t
JOIN match_fixture m
    ON t.team_id IN (m.home_team_id, m.away_team_id)
JOIN event e
    ON e.match_id = m.match_id
JOIN player p
    ON p.player_id = e.player_id

GROUP BY t.team_name
ORDER BY goals_scored_full_match DESC, t.team_name;