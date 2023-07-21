CREATE TABLE appleStore_description_combined AS

SELECT * FROM appleStore_description1

UNION ALL

SELECT * FROM appleStore_description2

UNION ALL

SELECT * FROM appleStore_description3

UNION ALL

SELECT * FROM appleStore_description4


**Exploratory Data Analyses**

-- check the number of unique apps in both tablesAppleStore

SELECT COUnt(DISTINCT id) as UniqueAppIDs
FROM AppleStore

SELECT COUNT(DISTINCT id) AS UniqueAppIDs
FROM appleStore_description_combined

-- Check for any missing values in key fieldsAppleStore
SELECT Count(*) AS MissingValues
FROM AppleStore
WHERE track_name is NULL or user_rating is null or prime_genre is NULL

SELECT Count(*) AS MissingValues
FROM appleStore_description_combined
WHERE app_desc is NULL

--Find out the number of apps per genreAppleStore
SELECT prime_genre, COUNT(*) AS NumApps
FROM AppleStore
GROUP by prime_genre
ORder BY NumApps DESC

--Get an overview of the app' ratings
SELECT min(user_rating) AS MinRating,
		max(user_rating) AS MaxRating,
        avg(user_rating) AS AvgRating
FROM AppleStore

**Data Analysis**

--Determine whether paid apps have higher rating than free apps

SELECT CASE
			WHEN price > 0 THEN 'Paid'
            ELSE 'Free'
         END AS App_Type,
         avg(user_rating) AS Avg_Rating
FROM AppleStore
GROUP BY App_Type

-- Check if apps with more supported languages have higher ratingsAppleStore

SELECT CASE
		When lang_num < 10 THEN '<10 languages'
        WHEN lang_num BETWEEN 10 and 30 THEN '10-30 languages'
        ELSE '>30 Languages'
    END AS language_bucket,
         avg(user_rating) AS Avg_Rating
FROM AppleStore
GROUP BY language_bucket
ORDER BY Avg_Rating DESC

-- Check genres with low ratings
SELECT prime_genre,
		avg(user_rating) AS Avg_Rating
FROM AppleStore
GROUP BY prime_genre
ORDER BY Avg_Rating ASC

-- Check if there is correlation between the length of the app description and the user rating

SELECT CASE
			WHEN length(b.app_desc) <500 THEN 'Short'
            WHEN length(b.app_desc) BETWEEN 500 and 1000 then 'Medium'
            ELSE 'Long'
		END AS description_length_bucket,
        avg(a.user_rating) AS avg_rating

FROM
	AppleStore as a

JOIn
	appleStore_description_combined AS b

ON a.id = b.id

GROUP by description_length_bucket
ORDER by avg_rating DESC

-- Check the top rated apps for each genre

SELECT prime_genre,
		track_name,
        user_rating

FROM (
  	SELECT
  	prime_genre,
  	track_name,
  	user_rating,
  	RANK() OVER(PARTITION BY prime_genre ORDER BY user_rating DESC, rating_count_tot DESC) AS rank
  	FROM
  	AppleStore
  ) AS a
WHERE
a.rank = 1