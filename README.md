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

## Optimalizácia výkonu

### Vytvorené indexy a ich význam

#### Optimalizácia vyhľadávania
- **idx_movie_title**: Zrýchlenie vyhľadávania filmov podľa názvu
- **idx_director_name**: Optimalizácia queries na mená režisérov
- **idx_actor_name**: Rýchle vyhľadávanie hercov podľa mena
- **idx_date_year**: Podpora časových analýz podľa rokov
- **idx_worldwide_gross**: Optimalizácia radenia a filtrovania podľa tržieb
- **idx_avg_rating**: Zrýchlenie queries na hodnotenia filmov

#### Dôvody indexovania
- Zlepšenie výkonu častých dotazov
- Optimalizácia JOIN operácií
- Zrýchlenie agregačných funkcií
- Podpora efektívneho radenia a filtrovania

### SQL pre vytvorenie indexov
```sql
CREATE INDEX idx_movie_title ON Dim_Movie(title);
CREATE INDEX idx_director_name ON Dim_Director(director_name);
CREATE INDEX idx_actor_name ON Dim_Actor(actor_name);
CREATE INDEX idx_date_year ON Dim_Date(year);
CREATE INDEX idx_worldwide_gross ON Fact_Movie(worldwide_gross_income);
CREATE INDEX idx_avg_rating ON Fact_Movie(avg_rating);
```


