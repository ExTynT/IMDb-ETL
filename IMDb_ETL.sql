CREATE DATABASE GROUNDHOG_IMDb;

-- Vytvorenie staging schémy a tabuliek
CREATE SCHEMA IF NOT EXISTS GROUNDHOG_IMDB.staging;
USE SCHEMA GROUNDHOG_IMDB.staging;

-- Tabuľka filmov
DROP TABLE IF EXISTS movie;
CREATE TABLE movie
(
id VARCHAR(10) NOT NULL,
title VARCHAR(200) DEFAULT NULL,
year INT DEFAULT NULL,
date_published DATE DEFAULT null,
duration INT,
country VARCHAR(250),
worlwide_gross_income VARCHAR(30),
languages VARCHAR(200),
production_company VARCHAR(200),
PRIMARY KEY (id)
);

-- Tabuľka žánrov
DROP TABLE IF EXISTS genre;
CREATE TABLE genre
(
movie_id VARCHAR(10),
genre VARCHAR(20),
PRIMARY KEY (movie_id, genre),
FOREIGN KEY (movie_id) REFERENCES movie(id)
);

-- Tabuľka mien (režisérov, hercov/herečiek)
DROP TABLE IF EXISTS names;
CREATE TABLE names
(
id varchar(10) NOT NULL,
name varchar(100) DEFAULT NULL,
height int DEFAULT NULL,
date_of_birth date DEFAULT null,
known_for_movies varchar(100),
PRIMARY KEY (id)
);

-- Tabuľka hodnotení filmov
DROP TABLE IF EXISTS ratings;
CREATE TABLE ratings
(
movie_id VARCHAR(10) NOT NULL,
avg_rating DECIMAL(3,1),
total_votes INT,
median_rating INT,
PRIMARY KEY (movie_id),
FOREIGN KEY (movie_id) REFERENCES movie(id)
);



-- Tabuľka prepojenia filmov a režisérov
DROP TABLE IF EXISTS director_mapping;
CREATE TABLE director_mapping
(
movie_id VARCHAR(10),
name_id VARCHAR(10),
PRIMARY KEY (movie_id, name_id),
FOREIGN KEY (movie_id) REFERENCES movie(id),
FOREIGN KEY (name_id) REFERENCES names(id)
);

-- Tabuľka prepojenia filmov a hercov/herečiek
DROP TABLE IF EXISTS role_mapping;
CREATE TABLE role_mapping
(
movie_id VARCHAR(10) NOT NULL,
name_id VARCHAR(10) NOT NULL,
category VARCHAR(10),
PRIMARY KEY (movie_id, name_id),
FOREIGN KEY (movie_id) REFERENCES movie(id),
FOREIGN KEY (name_id) REFERENCES names(id)
);


CREATE OR REPLACE STAGE GROUNDHOG_IMDB_stage;

LIST @GROUNDHOG_IMDB_stage;

COPY INTO GROUNDHOG_IMDB.staging.movie
FROM @groundhog_imdb_stage/movie.csv
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1)
ON_ERROR = 'CONTINUE';

COPY INTO GROUNDHOG_IMDB.staging.genre
FROM @groundhog_imdb_stage/genre.csv
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1)
ON_ERROR = 'CONTINUE';

COPY INTO GROUNDHOG_IMDB.staging.names
FROM @groundhog_imdb_stage/names.csv
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1)
ON_ERROR = 'CONTINUE';


COPY INTO GROUNDHOG_IMDB.staging.ratings
FROM @groundhog_imdb_stage/ratings.csv
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1)
ON_ERROR = 'CONTINUE';

COPY INTO GROUNDHOG_IMDB.staging.director_mapping
FROM @groundhog_imdb_stage/director_mapping.csv
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1)
ON_ERROR = 'CONTINUE';

COPY INTO GROUNDHOG_IMDB.staging.role_mapping
FROM @groundhog_imdb_stage/role_mapping.csv
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1)
ON_ERROR = 'CONTINUE';


-- Dimension: Date
CREATE TABLE Dim_Date (
    date_key INT PRIMARY KEY,
    full_date DATE NOT NULL,
    year INT NOT NULL,
    quarter INT NOT NULL,
    month INT NOT NULL,
    month_name VARCHAR(20) NOT NULL,
    week INT NOT NULL,
    day_of_month INT NOT NULL,
    day_of_week INT NOT NULL,
    day_name VARCHAR(20) NOT NULL,
    is_weekend BOOLEAN NOT NULL,
    decade INT NOT NULL,
    is_holiday BOOLEAN NOT NULL DEFAULT FALSE,
    season VARCHAR(20) NOT NULL
);

CREATE TABLE Dim_Country (
    country_id INT IDENTITY PRIMARY KEY,
    country_name VARCHAR(100) NOT NULL UNIQUE
);


-- Dimension: Production Company
CREATE TABLE Dim_Production_Company (
    production_company_id INT IDENTITY PRIMARY KEY,
    production_company_name VARCHAR(200) NOT NULL UNIQUE
);

-- Dimension: Movie
CREATE TABLE Dim_Movie (
    movie_id VARCHAR(10) PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    year INT NOT NULL,
    duration INT NOT NULL,
    production_company_id INT,
    country_id INT,
    valid_from DATE NOT NULL,
    valid_to DATE,
    is_current BOOLEAN NOT NULL DEFAULT TRUE,
    FOREIGN KEY (production_company_id) REFERENCES Dim_Production_Company(production_company_id) 
        ON DELETE SET NULL ON UPDATE CASCADE,
    FOREIGN KEY (country_id) REFERENCES Dim_Country(country_id) 
        ON DELETE SET NULL ON UPDATE CASCADE
);

-- Dimension: Genre
CREATE TABLE Dim_Genre (
    genre_id INT IDENTITY PRIMARY KEY,
    genre_name VARCHAR(50) NOT NULL UNIQUE
);

-- Dimension: Director
CREATE TABLE Dim_Director (
    director_id VARCHAR(10) PRIMARY KEY,
    director_name VARCHAR(100) NOT NULL,
    date_of_birth DATE,
    height INT,
    career_start_year INT,
    total_movies INT NOT NULL DEFAULT 0,
    avg_career_rating DECIMAL(3,2),
    valid_from DATE NOT NULL,
    valid_to DATE,
    is_current BOOLEAN NOT NULL DEFAULT TRUE
);

-- Dimension: Actor
CREATE TABLE Dim_Actor (
    actor_id VARCHAR(10) PRIMARY KEY,
    actor_name VARCHAR(100) NOT NULL,
    date_of_birth DATE,
    height INT,
    valid_from DATE NOT NULL,
    valid_to DATE,
    is_current BOOLEAN NOT NULL DEFAULT TRUE
);

-- Dimension: Language
CREATE TABLE Dim_Language (
    language_id INT IDENTITY PRIMARY KEY,
    language_name VARCHAR(50) NOT NULL UNIQUE
);

-- Movie-Genre Mapping
CREATE TABLE Movie_Genre_Mapping (
    movie_id VARCHAR(10) NOT NULL,
    genre_id INT NOT NULL,
    PRIMARY KEY (movie_id, genre_id),
    FOREIGN KEY (movie_id) REFERENCES Dim_Movie(movie_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (genre_id) REFERENCES Dim_Genre(genre_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Movie-Director Mapping
CREATE TABLE Movie_Director_Mapping (
    movie_id VARCHAR(10) NOT NULL,
    director_id VARCHAR(10) NOT NULL,
    PRIMARY KEY (movie_id, director_id),
    FOREIGN KEY (movie_id) REFERENCES Dim_Movie(movie_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (director_id) REFERENCES Dim_Director(director_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Movie-Actor Mapping
CREATE TABLE Movie_Actor_Mapping (
    movie_id VARCHAR(10) NOT NULL,
    actor_id VARCHAR(10) NOT NULL,
    role_category VARCHAR(50) NOT NULL,
    PRIMARY KEY (movie_id, actor_id),
    FOREIGN KEY (movie_id) REFERENCES Dim_Movie(movie_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (actor_id) REFERENCES Dim_Actor(actor_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Movie-Language Mapping
CREATE TABLE Movie_Language_Mapping (
    movie_id VARCHAR(10) NOT NULL,
    language_id INT NOT NULL,
    PRIMARY KEY (movie_id, language_id),
    FOREIGN KEY (movie_id) REFERENCES Dim_Movie(movie_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (language_id) REFERENCES Dim_Language(language_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Faktová tabuľka
CREATE TABLE Fact_Movie (
    movie_id VARCHAR(10) NOT NULL,
    date_key INT NOT NULL,
    worldwide_gross_income DECIMAL(15,2),
    avg_rating DECIMAL(3,1) NOT NULL,
    total_votes INT NOT NULL,
    median_rating INT NOT NULL,
    genre_count INT NOT NULL,
    primary_genre_id INT NOT NULL,
    PRIMARY KEY (movie_id),
    FOREIGN KEY (movie_id) REFERENCES Dim_Movie(movie_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (date_key) REFERENCES Dim_Date(date_key) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (primary_genre_id) REFERENCES Dim_Genre(genre_id) ON DELETE RESTRICT ON UPDATE CASCADE
);






-- Generovanie dátumov a ich atribútov do dočasnej tabuľky temp_date
CREATE OR REPLACE TEMPORARY TABLE temp_date AS
  WITH RECURSIVE DateSeries AS (
    SELECT DATE('2000-01-01') AS full_date
    UNION ALL
    SELECT DATEADD(day, 1, full_date)
    FROM DateSeries
    WHERE full_date < DATE('2025-12-31')
  )
  SELECT
        YEAR(full_date) * 10000 + MONTH(full_date) * 100 + DAY(full_date) as date_key,
        full_date,
        YEAR(full_date) as year,
        QUARTER(full_date) as quarter,
        MONTH(full_date) as month,
        MONTHNAME(full_date) as month_name,
        WEEKOFYEAR(full_date) as week,
        DAYOFMONTH(full_date) as day_of_month,
        DAYOFWEEK(full_date) as day_of_week,
        DAYNAME(full_date) as day_name,
         CASE WHEN DAYOFWEEK(full_date) IN (1,7) THEN TRUE ELSE FALSE END AS is_weekend,
        (YEAR(full_date) / 10) * 10 AS decade,
         CASE
            WHEN (MONTH(full_date) = 1 AND DAYOFMONTH(full_date) = 1) THEN TRUE  -- Deň vzniku Slovenskej republiky
            WHEN (MONTH(full_date) = 1 AND DAYOFMONTH(full_date) = 6) THEN TRUE  -- Zjavenie Pána
            WHEN (MONTH(full_date) = 5 AND DAYOFMONTH(full_date) = 1) THEN TRUE  -- Sviatok práce
            WHEN (MONTH(full_date) = 5 AND DAYOFMONTH(full_date) = 8) THEN TRUE  -- Deň víťazstva nad fašizmom
            WHEN (MONTH(full_date) = 7 AND DAYOFMONTH(full_date) = 5) THEN TRUE  -- Sviatok svätého Cyrila a Metoda
            WHEN (MONTH(full_date) = 8 AND DAYOFMONTH(full_date) = 29) THEN TRUE  -- Výročie SNP
            WHEN (MONTH(full_date) = 9 AND DAYOFMONTH(full_date) = 1) THEN TRUE  -- Deň Ústavy Slovenskej republiky
            WHEN (MONTH(full_date) = 9 AND DAYOFMONTH(full_date) = 15) THEN TRUE -- Sedembolestná Panna Mária
            WHEN (MONTH(full_date) = 11 AND DAYOFMONTH(full_date) = 1) THEN TRUE  -- Sviatok všetkých svätých
            WHEN (MONTH(full_date) = 11 AND DAYOFMONTH(full_date) = 17) THEN TRUE -- Deň boja za slobodu a demokraciu
            WHEN (MONTH(full_date) = 12 AND DAYOFMONTH(full_date) = 24) THEN TRUE -- Štedrý deň
            WHEN (MONTH(full_date) = 12 AND DAYOFMONTH(full_date) = 25) THEN TRUE  -- 1. Sviatok vianočný
            WHEN (MONTH(full_date) = 12 AND DAYOFMONTH(full_date) = 26) THEN TRUE  -- 2. Sviatok vianočný
            ELSE FALSE
        END AS is_holiday,
       CASE
            WHEN MONTH(full_date) IN (3, 4, 5) THEN 'Spring'
            WHEN MONTH(full_date) IN (6, 7, 8) THEN 'Summer'
            WHEN MONTH(full_date) IN (9, 10, 11) THEN 'Autumn'
            ELSE 'Winter'
         END AS season
    FROM DateSeries;

-- Vloženie dát z pomocnej tabuľky temp_date do tabuľky Dim_Date
INSERT INTO Dim_Date (date_key, full_date, year, quarter, month, month_name, week, day_of_month, day_of_week, day_name, is_weekend, decade, is_holiday, season)
SELECT date_key, full_date, year, quarter, month, month_name, week, day_of_month, day_of_week, day_name, is_weekend, decade, is_holiday, season
FROM temp_date;



-- Zmena typu stĺpca country_name na VARCHAR(255)
ALTER TABLE Dim_Country
ALTER COLUMN country_name SET DATA TYPE VARCHAR(255);


-- pomocná tabuľka pre unikátne krajiny
CREATE OR REPLACE TEMPORARY TABLE temp_country AS
SELECT DISTINCT country
FROM GROUNDHOG_IMDB.staging.movie
WHERE country IS NOT NULL;

-- Vloženie dát z pomocnej tabuľky temp_country do tabuľky Dim_Country
INSERT INTO Dim_Country (country_name)
SELECT country
FROM temp_country;


-- pomocná tabuľka pre unikátne produkčné spoločnosti
CREATE OR REPLACE TEMPORARY TABLE temp_production_company AS
SELECT DISTINCT production_company
FROM GROUNDHOG_IMDB.staging.movie
WHERE production_company IS NOT NULL;

-- Vloženie dát z pomocnej tabuľky temp_production_company do tabuľky Dim_Production_Company
INSERT INTO Dim_Production_Company (production_company_name)
SELECT production_company
FROM temp_production_company;



-- Vloženie dát do Dim_Movie
INSERT INTO Dim_Movie (movie_id, title, year, duration, production_company_id, country_id, valid_from, valid_to, is_current)
SELECT
    m.id,
    m.title,
    m.year,
    m.duration,
    COALESCE(pc.production_company_id, NULL),
    COALESCE(c.country_id, NULL),
    m.date_published, -- Nastavíme valid_from na dátum publikovania
    DATEADD(year, 5, m.date_published), -- Nastavíme valid_to na dátum + 5 rokov
    TRUE            -- is_current = TRUE pre aktuálne záznamy
FROM
    GROUNDHOG_IMDB.staging.movie m
LEFT JOIN Dim_Production_Company pc ON m.production_company = pc.production_company_name
LEFT JOIN Dim_Country c ON m.country = c.country_name;



-- pomocná tabuľka pre unikátne žánre
CREATE OR REPLACE TEMPORARY TABLE temp_genre_names AS
SELECT DISTINCT genre
FROM GROUNDHOG_IMDB.staging.genre
WHERE genre IS NOT NULL;

-- Vloženie dát z pomocnej tabuľky temp_genre_names do tabuľky Dim_Genre
INSERT INTO Dim_Genre (genre_name)
SELECT genre
FROM temp_genre_names;




-- 1. Vytvorenie pomocnej tabuľky s dátami a start dátumom + valid_to
CREATE OR REPLACE TEMPORARY TABLE temp_director_with_dates AS
SELECT
    n.id,
    n.name,
    n.date_of_birth,
    n.height,
    MIN(m.year) as career_start_year,
    COUNT(DISTINCT dm.movie_id) as total_movies,
    AVG(r.avg_rating) as avg_career_rating,
    MIN(m.date_published) as valid_from,
    DATEADD(year, 5, MIN(m.date_published)) as valid_to
FROM
    GROUNDHOG_IMDB.staging.names n
JOIN
    GROUNDHOG_IMDB.staging.director_mapping dm ON n.id = dm.name_id
JOIN
    GROUNDHOG_IMDB.staging.movie m ON dm.movie_id = m.id
LEFT JOIN GROUNDHOG_IMDB.staging.ratings r ON dm.movie_id = r.movie_id
GROUP BY n.id, n.name, n.date_of_birth, n.height;

-- 2. Vloženie dát do Dim_Director s vypočítanými valid_from a valid_to
INSERT INTO Dim_Director (director_id, director_name, date_of_birth, height, career_start_year, total_movies, avg_career_rating, valid_from, valid_to, is_current)
SELECT
    id,
    name,
    date_of_birth,
    height,
    career_start_year,
    total_movies,
    avg_career_rating,
    valid_from,
    valid_to,
    TRUE
FROM temp_director_with_dates;




-- 1. Vytvorenie pomocnej tabuľky s dátami a začiatkom kariéry
CREATE OR REPLACE TEMPORARY TABLE temp_actor_with_start_date AS
SELECT
    n.id,
    n.name,
    n.date_of_birth,
    n.height,
    MIN(m.date_published) as valid_from,
      DATEADD(year, 5, MIN(m.date_published)) as valid_to
FROM
    GROUNDHOG_IMDB.staging.names n
JOIN
    GROUNDHOG_IMDB.staging.role_mapping rm ON n.id = rm.name_id
JOIN
    GROUNDHOG_IMDB.staging.movie m ON rm.movie_id = m.id
WHERE rm.category IN ('actor', 'actress')
GROUP BY n.id, n.name, n.date_of_birth, n.height;

-- 2. Vloženie dát do Dim_Actor s vypočítanými valid_from a valid_to
INSERT INTO Dim_Actor (actor_id, actor_name, date_of_birth, height, valid_from, valid_to, is_current)
SELECT DISTINCT
    id,
    name,
    date_of_birth,
    height,
    valid_from,
    valid_to,
    TRUE
FROM temp_actor_with_start_date;





-- pomocná tabuľka, rozdelím viac jazykov do jednotlivých záznamov
CREATE OR REPLACE TEMPORARY TABLE temp_language_split AS
SELECT
    TRIM(value) as language
FROM
    GROUNDHOG_IMDB.staging.movie,
  LATERAL FLATTEN(INPUT => SPLIT(languages, ','));

-- pomocná tabuľka pre unikátne jazyky
CREATE OR REPLACE TEMPORARY TABLE temp_language AS
SELECT DISTINCT language
FROM temp_language_split
WHERE language IS NOT NULL;

-- Vloženie dát z pomocnej tabuľky temp_language do tabuľky Dim_Language
INSERT INTO Dim_Language (language_name)
SELECT language
FROM temp_language;



-- Movie-Genre Mapping (bez zmeny)
CREATE TABLE Movie_Genre_Mapping (
    movie_id VARCHAR(10) NOT NULL,
    genre_id INT NOT NULL,
    PRIMARY KEY (movie_id, genre_id),
    FOREIGN KEY (movie_id) REFERENCES Dim_Movie(movie_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (genre_id) REFERENCES Dim_Genre(genre_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Movie-Genre Mapping
INSERT INTO Movie_Genre_Mapping (movie_id, genre_id)
SELECT
    tg.movie_id,
    dg.genre_id
FROM
    GROUNDHOG_IMDB.staging.genre tg
JOIN
    Dim_Genre dg ON tg.genre = dg.genre_name;

    

-- Movie-Director Mapping
INSERT INTO Movie_Director_Mapping (movie_id, director_id)
SELECT
    dm.movie_id,
    dd.director_id
FROM
    GROUNDHOG_IMDB.staging.director_mapping dm
JOIN
    Dim_Director dd ON dm.name_id = dd.director_id;
    

-- Movie-Actor Mapping
INSERT INTO Movie_Actor_Mapping (movie_id, actor_id, role_category)
SELECT
    rm.movie_id,
    da.actor_id,
    rm.category
FROM
    GROUNDHOG_IMDB.staging.role_mapping rm
JOIN
    Dim_Actor da ON rm.name_id = da.actor_id
WHERE rm.category IN ('actor', 'actress');



-- Movie-Language Mapping
CREATE OR REPLACE TEMPORARY TABLE temp_language_split AS
SELECT
    TRIM(value) as language,
    id as movie_id
FROM
    GROUNDHOG_IMDB.staging.movie,
  LATERAL FLATTEN(INPUT => SPLIT(languages, ','));

INSERT INTO Movie_Language_Mapping (movie_id, language_id)
SELECT DISTINCT
    ts.movie_id,
    dl.language_id
FROM
    temp_language_split ts
JOIN
    Dim_Language dl ON ts.language = dl.language_name;




TRUNCATE TABLE fact_movie;

-- Transformácia Fact_Movie
 INSERT INTO Fact_Movie (movie_id, date_key, worldwide_gross_income, avg_rating, total_votes, median_rating, genre_count, primary_genre_id)
        SELECT
            m.id,
            DATE_PART(year,m.date_published) * 10000 + DATE_PART(month,m.date_published) * 100 + DATE_PART(day,m.date_published) as date_key,
            TRY_TO_DECIMAL(REPLACE(REPLACE(m.worlwide_gross_income, '$', ''), ',', ''), 15, 2) AS worldwide_gross_income,
            r.avg_rating,
            r.total_votes,
            r.median_rating,
            COUNT(DISTINCT g.genre),
            MIN(dg.genre_id)
        FROM
            GROUNDHOG_IMDB.staging.movie m
        LEFT JOIN
            GROUNDHOG_IMDB.staging.ratings r ON m.id = r.movie_id
        LEFT JOIN
          GROUNDHOG_IMDB.staging.genre g ON m.id = g.movie_id
        LEFT JOIN
          Dim_Genre dg ON g.genre = dg.genre_name
        GROUP BY m.id, m.date_published, m.worlwide_gross_income, r.avg_rating, r.total_votes, r.median_rating;



-- Odstránenie temporary tabuliek
DROP TABLE IF EXISTS temp_date;
DROP TABLE IF EXISTS temp_country;
DROP TABLE IF EXISTS temp_production_company;
DROP TABLE IF EXISTS temp_genre_names;
DROP TABLE IF EXISTS temp_language_split;
DROP TABLE IF EXISTS temp_language;
DROP TABLE IF EXISTS temp_director_with_start_date;
DROP TABLE IF EXISTS temp_actor_with_start_date;
DROP TABLE IF EXISTS temp_director_with_dates;