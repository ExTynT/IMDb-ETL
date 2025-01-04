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

![rErS](https://github.com/user-attachments/assets/265e24ab-443c-420a-9de1-300a303b43df)



# Návrh dimenzionálneho modelu pre IMDb Movies Dataset

## Úvod
Pre projekt som navrhol **multi-dimenzionálny model typu hviezda**, ktorý bude slúžiť na efektívnu analýzu dát z IMDb movies datasetu. Tento model pozostáva z **jednej faktovej tabuľky** a niekoľkých **dimenzionálnych tabuliek**, ktoré poskytujú kontext pre metriky vo faktovej tabuľke. Každá dimenzia je navrhnutá tak, aby podporovala rôzne témy analýzy, ako napríklad vplyv žánrov na finančný úspech, konzistentnosť režisérov alebo geografické rozloženie filmov.

![m](https://github.com/user-attachments/assets/00ba64f4-2970-49a1-bf66-26fa48704ec0)

---

## Faktová tabuľka: **Fact_Movie**
Faktová tabuľka je jadrom modelu a obsahuje všetky kľúčové metriky pre analýzu filmov. Používam ju na sledovanie rôznych aspektov filmového priemyslu, ako sú hodnotenia, popularita a finančný úspech.

### **Hlavné metriky**:
| **Metrika**               | **Typ**       | **Popis**                                                                 |
|---------------------------|---------------|--------------------------------------------------------------------------|
| `avg_rating`              | DECIMAL(3,1)  | Priemerné hodnotenie filmu (slúži na analýzu kvality filmov).            |
| `total_votes`             | INT           | Celkový počet hlasov (slúži na analýzu popularity filmov).               |
| `median_rating`           | INT           | Medián hodnotenia (slúži na analýzu konzistencie hodnotení).             |
| `worlwide_gross_income`   | VARCHAR(30)   | Celosvetové tržby filmu (slúži na analýzu finančného úspechu).           |
| `duration`                | INT           | Dĺžka filmu (slúži na analýzu vplyvu dĺžky na úspech filmu).             |

### **Kľúče**:
| **Kľúč**                     | **Typ**       | **Popis**                                                                 |
|------------------------------|---------------|--------------------------------------------------------------------------|
| `movie_id`                   | VARCHAR(10)   | Identifikátor filmu (odkazuje na `Dim_Movie`).                          |
| `director_id`                | VARCHAR(10)   | Identifikátor režiséra (odkazuje na `Dim_Director`).                    |
| `actor_id`                   | VARCHAR(10)   | Identifikátor herca (odkazuje na `Dim_Actor`).                          |
| `genre_id`                   | INT           | Identifikátor žánru (odkazuje na `Dim_Genre`).                          |
| `country_id`                 | INT           | Identifikátor krajiny (odkazuje na `Dim_Country`).                      |
| `production_company_id`       | INT           | Identifikátor produkčnej spoločnosti (odkazuje na `Dim_Production_Company`). |

---

## Dimenzionálne tabuľky

### **1. Dim_Movie**  
| **Stĺpec**              | **Typ**       | **Popis**                                                                 |
|-------------------------|---------------|--------------------------------------------------------------------------|
| `movie_id`             | VARCHAR(10)   | Primárny kľúč, ktorý identifikuje film.                                 |
| `title`                | VARCHAR(200)  | Názov filmu.                                                            |
| `year`                 | INT           | Rok vydania filmu.                                                      |
| `date_published`       | DATE          | Dátum publikácie filmu.                                                |
| `duration`             | INT           | Dĺžka filmu v minútach.                                                |
| `country`              | VARCHAR(100)  | Krajina, kde bol film vyrobený.                                        |
| `languages`            | VARCHAR(200)  | Jazyky, v ktorých je film dostupný.                                    |
| `production_company`   | VARCHAR(200)  | Produkčná spoločnosť filmu.                                            |

- **Typ dimenzie**: **SCD Type 1**.

### **2. Dim_Genre**  
| **Stĺpec**              | **Typ**       | **Popis**                                                                 |
|-------------------------|---------------|--------------------------------------------------------------------------|
| `genre_id`             | INT           | Primárny kľúč, ktorý identifikuje žáner.                                |
| `genre_name`           | VARCHAR(50)   | Názov žánru (napr. akčný, dráma, komédia).                              |

- **Typ dimenzie**: **SCD Type 1**.

### **3. Dim_Director**  
| **Stĺpec**              | **Typ**       | **Popis**                                                                 |
|-------------------------|---------------|--------------------------------------------------------------------------|
| `director_id`          | VARCHAR(10)   | Primárny kľúč, ktorý identifikuje režiséra.                             |
| `director_name`        | VARCHAR(100)  | Meno režiséra.                                                          |
| `date_of_birth`        | DATE          | Dátum narodenia režiséra.                                              |
| `height`               | INT           | Výška režiséra.                                                        |

- **Typ dimenzie**: **SCD Type 2**.

### **4. Dim_Actor**  
| **Stĺpec**              | **Typ**       | **Popis**                                                                 |
|-------------------------|---------------|--------------------------------------------------------------------------|
| `actor_id`             | VARCHAR(10)   | Primárny kľúč, ktorý identifikuje herca.                                |
| `actor_name`           | VARCHAR(100)  | Meno herca.                                                             |
| `date_of_birth`        | DATE          | Dátum narodenia herca.                                                 |
| `height`               | INT           | Výška herca.                                                           |

- **Typ dimenzie**: **SCD Type 2**.

### **5. Dim_Country**  
| **Stĺpec**              | **Typ**       | **Popis**                                                                 |
|-------------------------|---------------|--------------------------------------------------------------------------|
| `country_id`           | INT           | Primárny kľúč, ktorý identifikuje krajinu.                              |
| `country_name`         | VARCHAR(100)  | Názov krajiny.                                                          |

- **Typ dimenzie**: **SCD Type 1**.

### **6. Dim_Production_Company**  
| **Stĺpec**              | **Typ**       | **Popis**                                                                 |
|-------------------------|---------------|--------------------------------------------------------------------------|
| `production_company_id` | INT           | Primárny kľúč, ktorý identifikuje produkčnú spoločnosť.                |
| `production_company_name` | VARCHAR(200) | Názov produkčnej spoločnosti.                                           |

- **Typ dimenzie**: **SCD Type 1**.

---

## Mapovacie tabuľky

### **1. Movie_Genre_Mapping**  
| **Stĺpec**              | **Typ**       | **Popis**                                                                 |
|-------------------------|---------------|--------------------------------------------------------------------------|
| `movie_id`             | VARCHAR(10)   | Identifikátor filmu (cudzí kľúč odkazujúci na `Dim_Movie`).            |
| `genre_id`             | INT           | Identifikátor žánru (cudzí kľúč odkazujúci na `Dim_Genre`).            |

### **2. Movie_Director_Mapping**  
| **Stĺpec**              | **Typ**       | **Popis**                                                                 |
|-------------------------|---------------|--------------------------------------------------------------------------|
| `movie_id`             | VARCHAR(10)   | Identifikátor filmu (cudzí kľúč odkazujúci na `Dim_Movie`).            |
| `director_id`          | VARCHAR(10)   | Identifikátor režiséra (cudzí kľúč odkazujúci na `Dim_Director`).      |

### **3. Movie_Actor_Mapping**  
| **Stĺpec**              | **Typ**       | **Popis**                                                                 |
|-------------------------|---------------|--------------------------------------------------------------------------|
| `movie_id`             | VARCHAR(10)   | Identifikátor filmu (cudzí kľúč odkazujúci na `Dim_Movie`).            |
| `actor_id`             | VARCHAR(10)   | Identifikátor herca (cudzí kľúč odkazujúci na `Dim_Actor`).            |

---

## Zhrnutie
Tento dimenzionálny model typu hviezda je navrhnutý tak, aby podporoval komplexnú analýzu filmových dát. Faktová tabuľka obsahuje všetky kľúčové metriky, zatiaľ čo dimenzionálne tabuľky poskytujú kontext pre tieto metriky. Mapovacie tabuľky riešia vzťahy **M:N (mnoho k mnohým)** a zaisťujú flexibilitu pri analýze. Celý model je pripravený na implementáciu v Snowflake a bude slúžiť ako základ pre ďalšie vizualizácie a zisťovanie trendov v filmovom priemysle.

