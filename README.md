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
![image-removebg-preview_(1)-A6LAKHhMi-transformed](https://github.com/user-attachments/assets/58c244ff-505c-4ab2-864c-844b445e4317)

Táto tabuľka uchováva žánre filmov:
- **movie_id**: Identifikátor filmu (cudzí kľúč odkazujúci na tabuľku movie).
- **genre**: Názov žánru.
- **Primárny kľúč**: Kombinácia movie_id a genre.

### Director Mapping
![image-removebg-preview (2)](https://github.com/user-attachments/assets/7a50c2a5-9def-45c9-bc0d-02aa12bc32d4)

Táto tabuľka mapuje režisérov k filmom:
- **movie_id**: Identifikátor filmu (cudzí kľúč odkazujúci na tabuľku movie).
- **name_id**: Identifikátor mena režiséra (cudzí kľúč odkazujúci na tabuľku names).
- **Primárny kľúč**: Kombinácia movie_id a name_id.

### Role Mapping
![image-removebg-preview (3)](https://github.com/user-attachments/assets/025544d2-0712-462b-b619-902ab399fb0b)

Táto tabuľka mapuje hercov a ich kategórie k filmom:
- **movie_id**: Identifikátor filmu (cudzí kľúč odkazujúci na tabuľku movie).
- **name_id**: Identifikátor mena herca (cudzí kľúč odkazujúci na tabuľku names).
- **category**: Kategória roly (napr. herec, režisér).
- **Primárny kľúč**: Kombinácia movie_id a name_id.

### Names
![pixelcut-export](https://github.com/user-attachments/assets/33d2cd05-efe0-452a-a9a9-9429da976b82)

Táto tabuľka uchováva informácie o osobách (herci, režiséri atď.):
- **id**: Jedinečný identifikátor osoby (primárny kľúč).
- **name**: Meno osoby.
- **height**: Výška osoby.
- **date_of_birth**: Dátum narodenia osoby.
- **known_for_movies**: Filmy, pre ktoré je osoba známa.

### Ratings
![image-removebg-preview (5) (1)](https://github.com/user-attachments/assets/782b6ae4-5fcd-447a-bfa4-2cf07f09c1b4)

Táto tabuľka uchováva hodnotenia filmov:
- **movie_id**: Identifikátor filmu (cudzí kľúč odkazujúci na tabuľku movie).
- **avg_rating**: Priemerné hodnotenie filmu.
- **total_votes**: Celkový počet hlasov.
- **median_rating**: Medián hodnotenia.
- **Primárny kľúč**: movie_id.



