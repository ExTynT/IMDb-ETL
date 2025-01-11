# ETL pre dataset IMDb movies

## Úvod
Účelom tohto repozitáru je analýza dát z IMDb movies datasetu a následná implementácia ETL procesu pomocou Snowflake. Projekt sa zameriava na hlbšie preskúmanie rôznych aspektov filmového priemyslu, ako sú hodnotenia, popularita, finančný úspech a geografické rozloženie filmov.

---

## Cieľ
Cieľom projektu je implementovať ETL proces v Snowflake na analýzu dát z IMDb movies datasetu. Projekt sa sústreďuje na nasledujúce témy:
- Vplyv kombinácií žánrov na finančný úspech filmov.
- Konzistentnosť režisérov z pohľadu priemerných hodnotení.
- Geografické rozloženie filmovej produkcie podľa krajín a jazykov.
- Vývoj diváckych preferencií sledovaný hodnoteniami a hlasmi v priebehu rokov.
- Vzťah medzi výškou hercov a úspechom ich filmov.

---

## Dátová štruktúra
### Zdrojové dáta
Používam dáta z datasetu [SQL---IMDb-Movie-Analysis](https://github.com/AntaraChat/SQL---IMDb-Movie-Analysis/tree/main).

---

### **Tabuľka Movie**
Faktová tabuľka, ktorá uchováva základné informácie o filmoch.

| **Stĺpec**               | **Typ**       | **Popis**                                                                 |
|--------------------------|---------------|---------------------------------------------------------------------------|
| `id`                    | VARCHAR(10)   | Primárny kľúč, ktorý identifikuje film.                                  |
| `title`                 | VARCHAR(200)  | Názov filmu.                                                             |
| `year`                  | INT           | Rok vydania filmu.                                                       |
| `date_published`        | DATE          | Dátum publikácie filmu.                                                 |
| `duration`              | INT           | Dĺžka filmu v minútach.                                                 |
| `country`               | VARCHAR(250)  | Krajina, kde bol film vyrobený.                                          |
| `worlwide_gross_income` | VARCHAR(30)   | Celosvetové tržby filmu.                                                 |
| `languages`             | VARCHAR(200)  | Jazyky, v ktorých je film dostupný.                                      |
| `production_company`    | VARCHAR(200)  | Produkčná spoločnosť filmu.                                              |

---

### **Tabuľka Genre**
Mapuje žánre filmov.

| **Stĺpec**      | **Typ**       | **Popis**                                                                 |
|-----------------|---------------|---------------------------------------------------------------------------|
| `movie_id`      | VARCHAR(10)   | Identifikátor filmu (cudzí kľúč odkazujúci na `movie`).                   |
| `genre`         | VARCHAR(20)   | Názov žánru.                                                             |
| **PK**          | (`movie_id`, `genre`) | Kombinácia `movie_id` a `genre` je primárny kľúč.                       |

---

### **Tabuľka Director Mapping**
Mapuje režisérov k filmom.

| **Stĺpec**      | **Typ**       | **Popis**                                                                 |
|-----------------|---------------|---------------------------------------------------------------------------|
| `movie_id`      | VARCHAR(10)   | Identifikátor filmu (cudzí kľúč odkazujúci na `movie`).                   |
| `name_id`       | VARCHAR(10)   | Identifikátor mena režiséra (cudzí kľúč odkazujúci na `names`).           |
| **PK**          | (`movie_id`, `name_id`) | Kombinácia `movie_id` a `name_id` je primárny kľúč.                      |

---

### **Tabuľka Role Mapping**
Mapuje hercov a ich kategórie k filmom.

| **Stĺpec**      | **Typ**       | **Popis**                                                                 |
|-----------------|---------------|---------------------------------------------------------------------------|
| `movie_id`      | VARCHAR(10)   | Identifikátor filmu (cudzí kľúč odkazujúci na `movie`).                   |
| `name_id`       | VARCHAR(10)   | Identifikátor mena herca (cudzí kľúč odkazujúci na `names`).              |
| `category`      | VARCHAR(10)   | Kategória roly (napr. herec, režisér).                                   |
| **PK**          | (`movie_id`, `name_id`) | Kombinácia `movie_id` a `name_id` je primárny kľúč.                      |

---

### **Tabuľka Names**
Uchováva informácie o osobách (herci, režiséri atď.).

| **Stĺpec**              | **Typ**       | **Popis**                                                                 |
|-------------------------|---------------|---------------------------------------------------------------------------|
| `id`                    | VARCHAR(10)   | Primárny kľúč, ktorý identifikuje osobu.                                 |
| `name`                  | VARCHAR(100)  | Meno osoby.                                                              |
| `height`                | INT           | Výška osoby.                                                             |
| `date_of_birth`         | DATE          | Dátum narodenia osoby.                                                  |
| `known_for_movies`      | VARCHAR(100)  | Filmy, pre ktoré je osoba známa.                                         |

---

### **Tabuľka Ratings**
Uchováva hodnotenia filmov.

| **Stĺpec**          | **Typ**       | **Popis**                                                                 |
|---------------------|---------------|---------------------------------------------------------------------------|
| `movie_id`          | VARCHAR(10)   | Identifikátor filmu (cudzí kľúč odkazujúci na `movie`).                   |
| `avg_rating`        | DECIMAL(3,1)  | Priemerné hodnotenie filmu.                                               |
| `total_votes`       | INT           | Celkový počet hlasov.                                                    |
| `median_rating`     | INT           | Medián hodnotenia.                                                        |
| **PK**              | `movie_id`    | `movie_id` je primárny kľúč.                                             |

---


# ERD Diagram
Surové dáta sú organizované v rámci relačného modelu, ktorý je znázornený pomocou entitno-relačného diagramu (ERD).

<p align="center">
    <img src="https://github.com/user-attachments/assets/6b7794a5-a7f2-40ca-aa9c-875b5b53b81b" alt="IMDb-ERD_IMG">
    <br>
    <em>Obrázok 1: Entitno-relačný diagram IMDb Movies Dataset</em>
</p>



# Návrh dimenzionálneho modelu pre IMDb Movies Dataset

## Úvod
Pre projekt som navrhol **multi-dimenzionálny model typu hviezda**, ktorý slúži na analýzu filmovej databázy IMDb. Model sa skladá z centrálnej faktovej tabuľky a ôsmich dimenzionálnych tabuliek. Každá dimenzia je navrhnutá pre špecifický aspekt analýzy - od časových trendov až po geografické vzory v produkcii filmov.

<p align="center">
    <img src="https://github.com/user-attachments/assets/4d4bbab2-3c1d-4fc0-957f-7a0a3ce16e31" alt="IMDb_star_schema_IMG mwb">
    <br>
    <em>Obrázok 2: Schéma dimenzionálneho modelu IMDb Movies Dataset</em>
</p>

## Popis dimenzionálneho modelu

### Faktová tabuľka (Fact_Movie)
Centrálna tabuľka obsahujúca merateľné metriky o filmoch:
- Finančné metriky (tržby)
- Metriky hodnotenia (priemerné hodnotenie, počet hlasov)
- Agregované metriky (počet žánrov)

### Dimenzionálne tabuľky a ich charakteristika

#### 1. Dim_Date (SCD Type 1)
- **Obsah**: Kalendárne atribúty pre časovú analýzu
- **Vzťah k faktom**: Umožňuje sledovanie trendov v čase a sezónne analýzy
- **Dôvod typu**: Časové údaje sa nemenia, nie je potrebná história zmien

#### 2. Dim_Movie (SCD Type 2)
- **Obsah**: Základné informácie o filmoch
- **Vzťah k faktom**: Hlavná dimenzia poskytujúca kontext k metrikám
- **Dôvod typu**: Potrebné sledovať zmeny v údajoch o filme (napr. názov, dĺžka)

#### 3. Dim_Director (SCD Type 2)
- **Obsah**: Informácie o režiséroch a ich kariére
- **Vzťah k faktom**: Umožňuje analýzu vplyvu režiséra na úspech filmu
- **Dôvod typu**: Sledovanie zmien v kariérnych metrikách režisérov

#### 4. Dim_Actor (SCD Type 2)
- **Obsah**: Biografické údaje hercov
- **Vzťah k faktom**: Analýza vplyvu obsadenia na úspešnosť
- **Dôvod typu**: Potreba zachytiť zmeny v kariére hercov

#### 5. Dim_Genre (SCD Type 1)
- **Obsah**: Kategorizácia filmových žánrov
- **Vzťah k faktom**: Umožňuje žánrovú analýzu úspešnosti
- **Dôvod typu**: Žánre sú stabilné kategórie

#### 6. Dim_Production_Company (SCD Type 1)
- **Obsah**: Údaje o produkčných spoločnostiach
- **Vzťah k faktom**: Analýza úspešnosti štúdií
- **Dôvod typu**: Základné údaje o spoločnostiach sa často nemenia

## Detailná štruktúra tabuliek

### Faktová tabuľka: **Fact_Movie**

#### Hlavné metriky:
| **Metrika** | **Typ** | **Popis** |
|-------------|---------|-----------|
| `worldwide_gross_income` | DECIMAL(15,2) | Celkové svetové tržby filmu - kľúčový indikátor úspechu |
| `avg_rating` | DECIMAL(3,1) | Priemerné hodnotenie filmu (0-10) - ukazovateľ kvality |
| `total_votes` | INT | Počet všetkých hodnotení - miera popularity |
| `median_rating` | INT | Medián hodnotení (0-10) - stabilnejší ukazovateľ kvality |
| `genre_count` | INT | Počet priradených žánrov - žánrová diverzita |

#### Dimenzionálne kľúče:
| **Kľúč** | **Typ** | **Popis** |
|-----------|---------|-----------|
| `movie_id` | VARCHAR(10) | Hlavný identifikátor filmu |
| `date_key` | INT | Referencia na časovú dimenziu |
| `primary_genre_id` | INT | Odkaz na primárny žáner filmu |

### Dimenzionálne tabuľky

#### 1. Dim_Date
| **Stĺpec** | **Typ** | **Popis** |
|------------|---------|-----------|
| `date_key` | INT | Surrogate kľúč pre časovú dimenziu |
| `full_date` | DATE | Kompletný dátum |
| `year` | INT | Rok (1900-2100) pre historické analýzy |
| `quarter` | INT | Kvartál (1-4) pre sezónne trendy |
| `month` | INT | Mesiac (1-12) pre mesačné analýzy |
| `is_weekend` | BOOLEAN | Indikátor víkendového dňa |
| `is_holiday` | BOOLEAN | Označenie sviatkov |

#### 2. Dim_Movie
| **Stĺpec** | **Typ** | **Popis** |
|------------|---------|-----------|
| `movie_id` | VARCHAR(10) | Unikátny identifikátor filmu |
| `title` | VARCHAR(200) | Oficiálny názov filmu |
| `year` | INT | Rok vydania |
| `duration` | INT | Dĺžka filmu v minútach |
| `valid_from` | DATE | Začiatok platnosti záznamu |
| `is_current` | BOOLEAN | Indikátor aktuálnosti záznamu |

#### 3. Dim_Director
| **Stĺpec** | **Typ** | **Popis** |
|------------|---------|-----------|
| `director_id` | VARCHAR(10) | Unikátny identifikátor režiséra |
| `director_name` | VARCHAR(100) | Meno režiséra |
| `career_start_year` | INT | Rok začiatku kariéry |
| `total_movies` | INT | Celkový počet režírovaných filmov |
| `avg_career_rating` | DECIMAL(3,2) | Priemerné hodnotenie všetkých filmov |

#### 4. Dim_Actor
| **Stĺpec** | **Typ** | **Popis** |
|------------|---------|-----------|
| `actor_id` | VARCHAR(10) | Unikátny identifikátor herca |
| `actor_name` | VARCHAR(100) | Meno herca |
| `date_of_birth` | DATE | Dátum narodenia |
| `height` | INT | Výška herca v cm |

### Mapovacie tabuľky

#### Movie_Genre_Mapping
| **Stĺpec** | **Typ** | **Pravidlá** |
|------------|---------|--------------|
| `movie_id` | VARCHAR(10) | ON DELETE CASCADE |
| `genre_id` | INT | ON DELETE RESTRICT |

#### Movie_Actor_Mapping
| **Stĺpec** | **Typ** | **Pravidlá** |
|------------|---------|--------------|
| `movie_id` | VARCHAR(10) | ON DELETE CASCADE |
| `actor_id` | VARCHAR(10) | ON DELETE RESTRICT |
| `role_category` | VARCHAR(50) | NOT NULL |
| `is_lead_role` | BOOLEAN | NOT NULL |


# ETL Proces v Snowflake

Použil som ETL (Extract, Transform, Load) proces v Snowflake na spracovanie dát z IMDb. Tento proces zahŕňa tri hlavné fázy: **extrakciu** dát z CSV súborov do staging tabuliek, **transformáciu** a štruktúrovanie dát spolu s vytvorením dimenzionálnych tabuliek a nakoniec **načítanie** dát do faktovej a mapovacích tabuliek pre hlbšiu analýzu.

---
## 1. Extrakcia Dát (Extract)

### Účel
Načítanie dát zo zdrojových CSV súborov do staging tabuliek v Snowflake.

### Použité Príkazy
```sql
-- Vytvorenie stage pre dáta
CREATE OR REPLACE STAGE GROUNDHOG_IMDB_stage;

-- Výpis obsahu stage (pre kontrolu)
LIST @GROUNDHOG_IMDB_stage;

-- Kopírovanie dát z CSV súborov do staging tabuliek
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
```

### Vysvetlenie
*   `CREATE OR REPLACE STAGE GROUNDHOG_IMDB_stage;`: Vytvorí alebo nahradí stage s názvom `GROUNDHOG_IMDB_stage` pre uloženie CSV súborov.
*   `LIST @GROUNDHOG_IMDB_stage;`: Slúži pre kontrolu obsahu stage.
*   `COPY INTO`: Načíta dáta zo špecifikovaných CSV súborov do staging tabuliek.
*   `FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1)`: Špecifikuje formát CSV.
*   `ON_ERROR = 'CONTINUE'`:  Preskočí chybné riadky a pokračuje v načítavaní.

---
## 2. Transformácia Dát (Transform)
V tejto časti kódu prebieha transformácia surových dát a **vytvorenie tabuliek dimenzionálneho modelu**. Každá tabuľka má špecifický účel a je navrhnutá s ohľadom na typ dát, ktoré bude uchovávať a ako sa budú dáta meniť v čase (SCD typ).

### A) Vytvorenie a Naplnenie Tabuľky `Dim_Date` (SCD Typ 1)
```sql
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
```
*   **Účel:** Tabuľka pre časovú analýzu, uchováva kalendárne atribúty.
*   **SCD Typ:** 1, dáta sa nemenia, nepotrebujem históriu.

### B) Vytvorenie a Naplnenie Tabuľky `Dim_Country` (SCD Typ 1)
```sql
-- Dimension: Country
CREATE TABLE Dim_Country (
    country_id INT IDENTITY PRIMARY KEY,
    country_name VARCHAR(100) NOT NULL UNIQUE
);

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
```
*   **Účel:** Uchováva zoznam krajín, kde sa filmy produkovali.
*   **SCD Typ:** 1, dáta sa nemenia, nepotrebujem históriu.

### C) Vytvorenie a Naplnenie Tabuľky `Dim_Production_Company` (SCD Typ 1)
```sql
-- Dimension: Production Company
CREATE TABLE Dim_Production_Company (
    production_company_id INT IDENTITY PRIMARY KEY,
    production_company_name VARCHAR(200) NOT NULL UNIQUE
);

-- pomocná tabuľka pre unikátne produkčné spoločnosti
CREATE OR REPLACE TEMPORARY TABLE temp_production_company AS
SELECT DISTINCT production_company
FROM GROUNDHOG_IMDB.staging.movie
WHERE production_company IS NOT NULL;

-- Vloženie dát z pomocnej tabuľky temp_production_company do tabuľky Dim_Production_Company
INSERT INTO Dim_Production_Company (production_company_name)
SELECT production_company
FROM temp_production_company;
```
*   **Účel:** Uchováva zoznam produkčných spoločností.
*   **SCD Typ:** 1, dáta sa nemenia, nepotrebujem históriu.

### D) Vytvorenie a Naplnenie Tabuľky `Dim_Movie` (SCD Typ 2)
```sql
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
```
*   **Účel:** Uchováva základné informácie o filmoch.
*   **SCD Typ:** 2, sledujem historické zmeny dát (názov, dĺžka, atď.).

### E) Vytvorenie a Naplnenie Tabuľky `Dim_Genre` (SCD Typ 1)
```sql
-- Dimension: Genre
CREATE TABLE Dim_Genre (
    genre_id INT IDENTITY PRIMARY KEY,
    genre_name VARCHAR(50) NOT NULL UNIQUE
);

-- pomocná tabuľka pre unikátne žánre
CREATE OR REPLACE TEMPORARY TABLE temp_genre_names AS
SELECT DISTINCT genre
FROM GROUNDHOG_IMDB.staging.genre
WHERE genre IS NOT NULL;

-- Vloženie dát z pomocnej tabuľky temp_genre_names do tabuľky Dim_Genre
INSERT INTO Dim_Genre (genre_name)
SELECT genre
FROM temp_genre_names;
```
*  **Účel:** Uchováva zoznam filmových žánrov.
*  **SCD Typ:** 1, žánre sú stabilné, nepotrebujem históriu.

### F) Vytvorenie a Naplnenie Tabuľky `Dim_Director` (SCD Typ 2)
```sql
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
```
*   **Účel:** Uchováva informácie o režiséroch a ich kariére.
*  **SCD Typ:** 2, sledujem historické zmeny v dátach o režiséroch.

### G) Vytvorenie a Naplnenie Tabuľky `Dim_Actor` (SCD Typ 2)
```sql
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
```
*   **Účel:** Uchováva informácie o hercoch a ich kariére.
*   **SCD Typ:** 2, sledujem historické zmeny v dátach o hercoch.

### H) Vytvorenie a Naplnenie Tabuľky `Dim_Language` (SCD Typ 1)
```sql
-- Dimension: Language
CREATE TABLE Dim_Language (
    language_id INT IDENTITY PRIMARY KEY,
    language_name VARCHAR(50) NOT NULL UNIQUE
);

-- pomocná tabuľka, rozdelíme viac jazykov do jednotlivých záznamov
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
```
*  **Účel:** Uchováva zoznam jazykov, v ktorých boli filmy vytvorené.
*  **SCD Typ:** 1, zoznam jazykov sa nemení, nepotrebujem históriu.

### Vytvorenie mapovacích tabuliek
Vytvorím mapovacie tabuľky, ktoré slúžia na prepájanie medzi dimenzionálnymi a faktovými tabuľkami.
```sql
-- Movie-Genre Mapping
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
```
*   **Účel:**  Tabuľky prepájajú dimenzionálne tabuľky navzájom, a s faktovou tabuľkou.

### I) Vytvorenie a Naplnenie Tabuľky `Fact_Movie`
```sql
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

USE DATABASE GROUNDHOG_IMDB;
USE SCHEMA public;

-- Transformácia Fact_Movie
INSERT INTO Fact_Movie (movie_id, date_key, worldwide_gross_income, avg_rating, total_votes, median_rating, genre_count, primary_genre_id)
SELECT
    m.id,
    YEAR(DATE_TRUNC('MONTH', m.date_published)) * 10000 + MONTH(DATE_TRUNC('MONTH', m.date_published)) * 100 + 1 AS date_key,
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
```
*   **Účel:** Uchovávam v nej metrické fakty o filmoch, ako sú tržby, hodnotenia a hlasovania, spojené s dimenziami.
*   Používam `CREATE TABLE` pre vytvorenie faktovej tabuľky.
* Používam `INSERT INTO SELECT` na naplnenie tabuľky transformovanými dátami.

---

# 3. Načítanie Dát (Load)

V mojom ETL procese som integroval načítanie dát (Load) priamo do transformačnej fázy, kde som postupne plnil jednotlivé dimenzionálne a faktové tabuľky. Tento prístup som zvolil pre efektívnejšie spracovanie dát a elimináciu potreby dodatočného kroku načítania.

Všetky potrebné `INSERT` príkazy som vykonal počas transformačnej fázy:
- Načítal som dáta do dimenzionálnych tabuliek (`Dim_Date`, `Dim_Movie`, `Dim_Director`, atď.)
- Naplnil som mapovacie tabuľky (`Movie_Genre_Mapping`, `Movie_Actor_Mapping`, atď.)
- Vytvoril a naplnil som faktovú tabuľku (`Fact_Movie`)

Samostatnú fázu načítania som preto nepotreboval, keďže všetky dáta som už načítal do cieľových tabuliek počas transformácie.

---

### 4. Odstránenie temporary tabuliek

```sql
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
```
* **Účel**: Vyčistenie po dočasných tabulkách.

---

# Vizualizácia Dát v IMDb Dashboarde

Vytvoril som komplexný dashboard obsahujúci 6 kľúčových vizualizácií. Tieto vizualizácie analyzujú rôzne aspekty filmového priemyslu a poskytujú jedinečný pohľad na dáta z IMDb databázy.

<p align="center">
<img src="https://github.com/user-attachments/assets/ad49b8ff-748d-4b30-b163-3d8f33ec53c1" alt="IMDb Dashboard">
<br>
<em>Obrázok 3: Ukážka Dashboardu IMDb</em>
</p>

# Analýza SQL Dotazov a Vizualizácií

---
## 1. Analýza Kombinácií Žánrov a Tržieb
**Účel:** Analyzuje priemerné tržby pre rôzne kombinácie filmových žánrov.

**Otázka:** Ktoré kombinácie žánrov generujú najvyššie tržby?

**SQL Dotaz:**
```sql
WITH GenreCombos AS (
    SELECT
        LISTAGG(dg.genre_name, ', ') WITHIN GROUP (ORDER BY dg.genre_name) AS genres,
        AVG(COALESCE(NULLIF(fm.worldwide_gross_income, 0), 0)) AS avg_gross_income
    FROM
        Fact_Movie fm
    JOIN
        Movie_Genre_Mapping mgm ON fm.movie_id = mgm.movie_id
    JOIN
        Dim_Genre dg ON mgm.genre_id = dg.genre_id
    GROUP BY
        fm.movie_id
    QUALIFY ROW_NUMBER() OVER (PARTITION BY fm.movie_id ORDER BY MIN(dg.genre_name)) = 1
)
SELECT 
    genres,
    avg_gross_income
FROM GenreCombos
ORDER BY
    avg_gross_income DESC;
```

---
## 2. Časový Vývoj Tržieb podľa Žánrov
**Účel:** Sleduje trendy v tržbách jednotlivých žánrov v priebehu času.

**Otázka:** Ako sa mení finančná úspešnosť rôznych žánrov v čase?

**SQL Dotaz:**
```sql
WITH GenreYearlyTrends AS (
    SELECT
        dd.year,
        dg.genre_name,
        AVG(COALESCE(NULLIF(fm.worldwide_gross_income, 0), 0)) AS avg_gross_income
    FROM
        Fact_Movie fm
    JOIN
        Dim_Date dd ON fm.date_key = dd.date_key
    JOIN
        Movie_Genre_Mapping mgm ON fm.movie_id = mgm.movie_id
    JOIN
        Dim_Genre dg ON mgm.genre_id = dg.genre_id
    GROUP BY
        dd.year, dg.genre_name
)
SELECT *
FROM GenreYearlyTrends
ORDER BY
    year, genre_name;
```

---
## 3. Sezónnosť Anglických Filmov
**Účel:** Analyzuje mesačné trendy v produkcii anglických filmov.

**Otázka:** Existujú preferované mesiace pre vydávanie anglických filmov?

**SQL Dotaz:**
```sql
WITH MonthlyMovieCounts AS (
    SELECT
        dd.year,
        dd.month,
        dd.month_name,
        COUNT(DISTINCT fm.movie_id) AS movie_count
    FROM
        Fact_Movie fm
    JOIN
        Movie_Language_Mapping mlm ON fm.movie_id = mlm.movie_id
    JOIN
        Dim_Language dl ON mlm.language_id = dl.language_id
    JOIN
        Dim_Date dd ON fm.date_key = dd.date_key
    WHERE
        dl.language_name = 'English'
    GROUP BY
        dd.year, dd.month, dd.month_name
),
AverageMonthlyCounts AS (
    SELECT
        month,
        month_name,
        AVG(movie_count) as avg_movie_count
    FROM MonthlyMovieCounts
    GROUP BY 
        month, month_name
)
SELECT *
FROM AverageMonthlyCounts
ORDER BY
    month;
```

---
## 4. Vývoj Hodnotení Žánrov
**Účel:** Sleduje zmeny v diváckom hodnotení žánrov v čase.

**Otázka:** Ako sa mení popularita rôznych žánrov z pohľadu diváckych hodnotení?

**SQL Dotaz:**
```sql
WITH GenreRatingTrends AS (
    SELECT
        dd.year,
        dg.genre_name,
        AVG(fm.avg_rating) AS avg_rating
    FROM
        Fact_Movie fm
    JOIN
        Dim_Date dd ON fm.date_key = dd.date_key
    JOIN
        Movie_Genre_Mapping mgm ON fm.movie_id = mgm.movie_id
    JOIN
        Dim_Genre dg ON mgm.genre_id = dg.genre_id
    GROUP BY
        dd.year, dg.genre_name
)
SELECT *
FROM GenreRatingTrends
ORDER BY
    year, genre_name;
```
---
## 5. Vzťah medzi Výškou Hercov a Tržbami
**Účel:** Skúma koreláciu medzi výškou hercov a finančným úspechom filmov.

**Otázka:** Existuje vzťah medzi výškou hercov a tržbami filmov?

**SQL Dotaz:**
```sql
WITH ActorHeightAnalysis AS (
    SELECT
        da.height,
        AVG(COALESCE(NULLIF(fm.worldwide_gross_income, 0), 0)) AS avg_gross_income,
        COUNT(DISTINCT fm.movie_id) AS movie_count
    FROM
        Fact_Movie fm
    JOIN
        Movie_Actor_Mapping mam ON fm.movie_id = mam.movie_id
    JOIN
        Dim_Actor da ON mam.actor_id = da.actor_id
    WHERE 
        da.height IS NOT NULL
    GROUP BY
        da.height
    HAVING 
        COUNT(DISTINCT fm.movie_id) >= 2
)
SELECT *
FROM ActorHeightAnalysis
ORDER BY 
    height;
```
---
## 6. Zastúpenie Pohlaví vo Filmoch
**Účel:** Analyzuje rodovú rovnováhu v obsadzovaní filmov.

**Otázka:** Aké je zastúpenie mužov a žien v hlavných úlohách?

**SQL Dotaz:**
```sql
WITH GenderDistribution AS (
    SELECT
        CASE
            WHEN rm.category = 'actor' THEN 'Muž'
            WHEN rm.category = 'actress' THEN 'Žena'
            ELSE 'Neznáme'
        END AS gender,
        COUNT(DISTINCT fm.movie_id) AS movie_count
    FROM
        Fact_Movie fm
    JOIN
        Movie_Actor_Mapping mam ON fm.movie_id = mam.movie_id
    JOIN
        Dim_Actor da ON mam.actor_id = da.actor_id
    JOIN
        Role_Mapping rm ON mam.movie_id = rm.movie_id 
                      AND mam.actor_id = rm.name_id
    WHERE 
        rm.category IN ('actor','actress')
    GROUP BY
        gender
)
SELECT *
FROM GenderDistribution
ORDER BY
    gender;
```
---
<p align="center">
<em>Autor: Ivan Klopček</em>
</p>



