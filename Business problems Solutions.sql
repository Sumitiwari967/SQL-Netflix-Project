-- Business problems

--1 Count the number of Movies vs TV Shows

SELECT  
	 type, 
	 COUNT(*) as total_content 
FROM netflix 
GROUP BY type;

-- 2. FOnd the most common rating for movies and TV shows

SELECT
	type,
	rating
FROM
(
	SELECT 
		type,
		rating,
		COUNT(*),
		RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) as ranking
	FROM netflix 
	GROUP BY 1,2
) as t1
WHERE 
	ranking = 1;

-- 3 List all movies released in a specific year 

SELECT * FROM netflix 
where type = 'Movie' AND release_year = 2019; 

--4  Find the top 5 countries with the most content on Netflix

SELECT 
	UNNEST(STRING_TO_ARRAY(country, ',')) as new_country,
	COUNT(show_id) as total_content
FROM netflix
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- 5 . Identify the longest movie

SELECT * FROM netflix
where 
	type = 'Movie'
	AND
	duration = (SELECT MAX(duration) FROM netflix);

-- 6 .  Find content added in the last 5 years

SELECT 
	*
	FROM netflix
where
	TO_DATE(date_added,'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';

-- 7 . Find all the movies/TV shows by director 'Rajiv Chilaka'!

SELECT * FROM netflix
WHERE director ILIKE  '%Rajiv Chilaka%';

-- 8 List all TV shows with more than 5 seasons

SELECT 
	*
FROM netflix
where 
	type = 'TV Show'
	AND
	SPLIT_PART(duration, ' ', 1)::INT > 5;

-- 9 Count the number of content items in each genre

SELECT 
	UNNEST(STRING_TO_ARRAY(listed_in, ',')) as genre,
	COUNT(show_id) as total_content
FROM netflix
GROUP BY 1;

-- 10 Find each year and the average numbers of content release in India on netflix. 
-- return top 5 year with highest avg content release !

SELECT 
	EXTRACT(YEAR FROM  TO_DATE(date_added, 'Month DD,YYYY')) as year,
	COUNT(*) as yearly_content,
	ROUND(
	COUNT(*)::numeric/(SELECT COUNT(*) FROM netflix WHERE country = 'India')::numeric * 100,2 )
	as avg_content_per_year
FROM netflix 
WHERE country = 'India'
GROUP BY 1;

-- 11 List all movies that are documentaries
SELECT * FROM netflix
where
	listed_in ILIKE '%documentaries%';

-- 12 Find all content without a director

SELECT * FROM netflix 
WHERE director is null;

-- 13 Find how many movies actor 'Salman Khan' appeared in last 10 years!

SELECT * FROM netflix
WHERE
	casts ILIKE '%Salman Khan%'
	AND 
	release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10 ;

-- 14 Find the top 10 actors who have appeared in the highest number of movies produced in India.

SELECT 
	UNNEST(STRING_TO_ARRAY(casts, ',')) as actor,
	COUNT(*)
FROM netflix
WHERE COUNTRY = 'India'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;

/*15 Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category. */

SELECT 
    category,
	TYPE,
    COUNT(*) AS content_count
FROM (
    SELECT 
		*,
        CASE 
            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY 1,2
ORDER BY 2;

-- 16 Find the top 10 longest-running movies on Netflix based on their runtime.
SELECT title, duration
FROM netflix
WHERE type = 'Movie'
ORDER BY CAST(REPLACE(duration, ' min', '') AS INT) DESC
LIMIT 10;

-- 17  Find the most frequent director on Netflix

SELECT director, COUNT(*) AS title_count
FROM netflix
WHERE director IS NOT NULL
GROUP BY director
ORDER BY title_count DESC
LIMIT 1;

-- 18  Find the average duration of movies and TV shows

-- For Movies (duration in minutes)
SELECT 'Movie' AS type, AVG(CAST(REPLACE(duration, ' min', '') AS INT)) AS avg_duration
FROM netflix
WHERE type = 'Movie'

UNION

-- For TV Shows (duration in seasons)
SELECT 'TV Show' AS type, AVG(CAST(REPLACE(duration, ' Seasons', '') AS INT)) AS avg_duration
FROM netflix
WHERE type = 'TV Show' AND duration LIKE '%Seasons';




