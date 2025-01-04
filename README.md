# ETL pre dataset IMDb movies
Účelom tohoto repozitáru je analýza dát z IMDb movies datasetu a následná implementácia ETL procesu pomocou Snowflake. 

# Cieľ
Tento projekt je zameraný na implementáciu ETL procesu v Snowflake s cieľom preskúmať dáta z IMDb movies datasetu. Sústreďuje sa na zaujímavé témy, ako je vplyv kombinácií žánrov na finančný úspech, hodnotenia filmov z pohľadu konzistencie režisérov, geografické rozdelenie filmovej produkcie podľa krajín a jazykov, vývoj diváckych preferencií sledovaný hodnoteniami a hlasmi v priebehu rokov, či vzťah medzi výškou hercov a úspechom ich filmov. Projekt prináša zrozumiteľné vizualizácie, ktoré odhaľujú dôležité trendy a súvislosti v filmovom priemysle.

# Dátová štruktúra
## Zdrojové dáta
Využívam zdrojové dáta z datasetu [SQL---IMDb-Movie-Analysis](https://github.com/AntaraChat/SQL---IMDb-Movie-Analysis/tree/main).

## Tabuľky
Dataset pozostáva z 5 hlavných tabuliek:
- **movie**
- **role_mapping**
- **genre**
- **ratings**
- **director_mapping**

### Movie
<img src="https://github.com/user-attachments/assets/c57d5de5-37f7-44e1-b595-ed0d896defaf" alt="image-removebg-preview-6O2B6-5Ct-transformed" width="300" height="300"/>

<br>
<p>
  <em>Obrázok 1: Tabuľka Movie</em>
</p>

Táto tabuľka uchováva informácie o filmoch:
- **id**: Jedinečný identifikátor filmu (primárny kľúč).
- **title**: Názov filmu.
- **year**: Rok vydania filmu.
- **date_published**: Dátum vydania filmu.
- **duration**: Dĺžka filmu v minútach.
- **country**: Krajina, kde bol film vyrobený.
- **worlwide_gross_income**: Celosvetové tržby filmu.
- **languages**: Jazyky, v ktorých je film dostupný.
- **production_company**: Produkčná spoločnosť filmu.

### Genre
![pixelcut-export (1)](https://github.com/user-attachments/assets/e7095f3d-cf6b-4d7f-8728-b2cadc1f0f00)

<br>
<p>
  <em>Obrázok 2: Tabuľka Genre</em>
</p>

Táto tabuľka uchováva žánre filmov:
- **movie_id**: Identifikátor filmu (cudzí kľúč odkazujúci na tabuľku movie).
- **genre**: Názov žánru.
- **Primárny kľúč**: Kombinácia movie_id a genre.

### Director Mapping
![pixelcut-export (2)](https://github.com/user-attachments/assets/8e7bbcdf-b469-43c0-bb9c-92a31de605a0)

<br>
<p>
  <em>Obrázok 3: Tabuľka Director Mapping</em>
</p>

Táto tabuľka mapuje režisérov k filmom:
- **movie_id**: Identifikátor filmu (cudzí kľúč odkazujúci na tabuľku movie).
- **name_id**: Identifikátor mena režiséra (cudzí kľúč odkazujúci na tabuľku names).
- **Primárny kľúč**: Kombinácia movie_id a name_id.

### Role Mapping
![Betterimage ai_1735838067389](https://github.com/user-attachments/assets/6a8bd4a4-5952-459e-abd0-959dc63f86e5)

<br>
<p>
  <em>Obrázok 4: Tabuľka Role Mapping</em>
</p>

Táto tabuľka mapuje hercov a ich kategórie k filmom:
- **movie_id**: Identifikátor filmu (cudzí kľúč odkazujúci na tabuľku movie).
- **name_id**: Identifikátor mena herca (cudzí kľúč odkazujúci na tabuľku names).
- **category**: Kategória roly (napr. herec, režisér).
- **Primárny kľúč**: Kombinácia movie_id a name_id.

### Names
![pixelcut-export](https://github.com/user-attachments/assets/33d2cd05-efe0-452a-a9a9-9429da976b82)

<br>
<p>
  <em>Obrázok 5: Tabuľka Names</em>
</p>

Táto tabuľka uchováva informácie o osobách (herci, režiséri atď.):
- **id**: Jedinečný identifikátor osoby (primárny kľúč).
- **name**: Meno osoby.
- **height**: Výška osoby.
- **date_of_birth**: Dátum narodenia osoby.
- **known_for_movies**: Filmy, pre ktoré je osoba známa.

### Ratings
![Betterimage ai_1735838109943](https://github.com/user-attachments/assets/6d039ffa-0023-4521-b8e2-1904c1655961)

<br>
<p>
  <em>Obrázok 6: Tabuľka Ratings</em>
</p>

Táto tabuľka uchováva hodnotenia filmov:
- **movie_id**: Identifikátor filmu (cudzí kľúč odkazujúci na tabuľku movie).
- **avg_rating**: Priemerné hodnotenie filmu.
- **total_votes**: Celkový počet hlasov.
- **median_rating**: Medián hodnotenia.
- **Primárny kľúč**: movie_id.

# ERD Diagram
Surové dáta sú organizované v rámci relačného modelu, ktorý je znázornený pomocou entitno-relačného diagramu (ERD).

<p align="center">
  <img src="https://github.com/user-attachments/assets/e4454fdd-de45-4d17-88b5-40cc77739639?raw=true" alt="projektd"/>
  <br>
  <em>Obrázok 7: Entitno-relačná schéma IMDb-Movies</em>
</p>


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

