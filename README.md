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
