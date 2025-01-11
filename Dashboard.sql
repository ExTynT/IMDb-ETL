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
ORDER BY
    avg_gross_income DESC





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
ORDER BY
    dd.year, dg.genre_name;




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
  GROUP BY month, month_name
)
SELECT
    month,
    month_name,
    avg_movie_count
  FROM AverageMonthlyCounts
ORDER BY
   month;






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
ORDER BY
    dd.year, dg.genre_name;


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
WHERE da.height IS NOT NULL
GROUP BY
    da.height
HAVING COUNT(DISTINCT fm.movie_id) >= 2
ORDER BY da.height;


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
	Role_Mapping rm ON mam.movie_id = rm.movie_id AND mam.actor_id = rm.name_id
WHERE rm.category IN ('actor','actress')
GROUP BY
    gender
ORDER BY
    gender;

