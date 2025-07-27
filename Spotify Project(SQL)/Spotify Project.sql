-- Creating a Database
CREATE DATABASE Spotify;
USE Spotify;

-- Creating a Table 
CREATE TABLE spotify_data(
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);
-- Truncate Duplicate Values
TRUNCATE TABLE spotify_data;

-- Loading the CSV File
LOAD DATA LOCAL INFILE 'C:/Users/kk/Desktop/Spotify Project(SQL)/Spotify.csv'
INTO TABLE spotify_data
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
SELECT COUNT(*) FROM spotify_data;
SELECT * FROM spotify_data;

-- OBJECTIVE NO.1: Retrieve the names of all tracks that have more than 1 billion streams.
SELECT track,stream
FROM spotify_data
WHERE stream > 1000000000;

-- Counting Them
SELECT COUNT(*) AS most_popular_track 
FROM spotify_data
WHERE stream > 1000000000;

-- OBJECTIVE 2: List all albums along with their respective artists.
SELECT DISTINCT album,artist
FROM spotify_data;

-- Counting Them
SELECT artist, COUNT(DISTINCT album) AS album_count
FROM spotify_data
GROUP BY artist
ORDER BY album_count DESC;

-- OBJECTIVE NO.3: Get the total number of comments for tracks where licensed = TRUE(i.e True=1)
SELECT SUM(comments) AS total_comments
FROM spotify_data
WHERE Licensed=1;

-- OBJECTIVE NO.4: Find all tracks that belong to the album type single.
SELECT * 
FROM spotify_data
WHERE album_type = 'single';

-- Counting Them
SELECT COUNT(*) AS total_single
FROM spotify_data
WHERE album_type ='single';

-- OBJECTIVE NO.5: Count the total number of tracks by each artist.
SELECT artist, COUNT(*) AS total_tracks
FROM spotify_data
GROUP BY artist
ORDER BY total_tracks DESC;

-- OBJECTIVE NO.6: Calculate the average danceability of tracks in each album.
SELECT album, ROUND(AVG(danceability),2) AS avg_danceability
FROM spotify_data
GROUP BY album
ORDER BY avg_danceability DESC;

-- OBJECTIVE NO.7: Find the top 5 tracks with the highest energy values.
SELECT track,artist,energy
FROM spotify_data
ORDER BY energy
LIMIT 10;

-- OBJECTIVE NO.8: List all tracks along with their views,artist and likes where official_video and order them in the descending order(i.e. TRUE=1).
SELECT track,artist,views,likes
FROM spotify_data
WHERE official_video=1
ORDER BY views DESC;

-- OBJECTIVE NO.9: For each album, calculate the total views of all associated tracks.
SELECT album,SUM(views) AS total_views
FROM spotify_data
GROUP BY album
ORDER BY total_views DESC;

-- OBJECTIVE NO.10: Retrieve the top 10 track names that have been streamed on Spotify more than YouTube.
-- Stream means Spotify Streaming and views means 
SELECT track, stream, views 
FROM spotify_data
WHERE stream > views
LIMIT 10;

-- OBJECTIVE NO.11: Find the top 3 most-viewed tracks for each artist using window functions.
SELECT *
FROM (
    SELECT 
        artist,
        track,
        views,
        ROW_NUMBER() OVER (PARTITION BY artist ORDER BY views DESC) AS track_rank
    FROM spotify_data
) AS ranked_tracks
WHERE track_rank <= 3;

-- OBJECTIVE NO. 12: Write a query to find tracks where the liveness score is above the average.

-- To find average of liveness
SELECT ROUND(AVG(liveness),2)
    FROM spotify_data;
-- Now find the tracks
SELECT * 
FROM spotify_data
WHERE Liveness > (
	SELECT AVG(liveness)
    FROM spotify_data
);

-- OBJECTIVE NO.13: Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.
WITH energy_stats AS (
    SELECT 
        album,
        MAX(Energy) AS max_energy,
        MIN(Energy) AS min_energy
    FROM spotify_data
    GROUP BY Album
)
SELECT 
    album,
    ROUND(max_energy - min_energy, 2) AS energy_difference
FROM energy_stats;

-- OBJECTIVE NO.14: Find tracks where the energy-to-liveness ratio is greater than 1.2.
SELECT 
	Track,
    energy,
    liveness,
    ROUND(Energy/Liveness,2) AS energy_liveness_ratio
FROM
	spotify_data
WHERE 
	liveness > 0 AND (energy/liveness)>1.2 ;

-- OBJECTIVE NO.15: Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.

-- IN OUR DATASET,THERE ARE SOME UNCERTAIN VALUES IN VIEWS,LIKES AND COMMENTS COLUMN LIKE 'M' AND 'K' WHICH STANDS FOR MILLIONS AND THOUSANDS OR MAYBE NULL/NAN VALUES.THAT'S WHY MYSQL COULD NOT ABLE TO INTERPRET THESE VALUES AND RETURNED ALL COLUMNS ZEROES.THEREFORE WE FIRST CLEAN OUR DATA.

-- Clean 'views'
UPDATE spotify_data
SET views_clean = 
  CASE
    WHEN views LIKE '%M' THEN CAST(REPLACE(views, 'M', '') AS DECIMAL(10,2)) * 1000000
    WHEN views LIKE '%K' THEN CAST(REPLACE(views, 'K', '') AS DECIMAL(10,2)) * 1000
    WHEN views REGEXP '^[0-9]+$' THEN CAST(views AS DECIMAL(20,0))
    ELSE NULL
  END;

-- Clean 'likes'
UPDATE spotify_data
SET likes_clean = 
  CASE
    WHEN likes LIKE '%M' THEN CAST(REPLACE(likes, 'M', '') AS DECIMAL(10,2)) * 1000000
    WHEN likes LIKE '%K' THEN CAST(REPLACE(likes, 'K', '') AS DECIMAL(10,2)) * 1000
    WHEN likes REGEXP '^[0-9]+$' THEN CAST(likes AS DECIMAL(20,0))
    ELSE NULL
  END;

-- Clean 'comments'
UPDATE spotify_data
SET comments_clean = 
  CASE
    WHEN comments LIKE '%M' THEN CAST(REPLACE(comments, 'M', '') AS DECIMAL(10,2)) * 1000000
    WHEN comments LIKE '%K' THEN CAST(REPLACE(comments, 'K', '') AS DECIMAL(10,2)) * 1000
    WHEN comments REGEXP '^[0-9]+$' THEN CAST(comments AS DECIMAL(20,0))
    ELSE NULL
  END;
-- Now Calculating cumulative likes ordered by views
SELECT  
  track, 
  views AS views_clean, 
  likes AS likes_clean,
  SUM(COALESCE(likes, 0)) OVER (ORDER BY views) AS cumulative_likes
FROM 
  spotify_data
WHERE views > 0 AND likes > 0;

-- OBJECTIVE NO.16: Find tracks where the number of likes per view exceeds a certain threshold.

-- WE WILL TAKE THRESHOLD VALUE 0.20(i.e.20%)
SELECT
	track,
    artist,
    likes,
    views,
    ROUND(likes/views,4) AS engagement_ratio
FROM
	spotify_data
WHERE 
	views>0 AND
    likes/views > 0.20
ORDER BY
	engagement_ratio DESC;
	
-- OBJECTIVE NO.17: Calculate a custom Engagement Score to identify tracks with the highest user interaction relative to views.
SELECT
	track,
    artist,
    views,
    likes,
    comments,
	ROUND((likes*2 + comments*3)/views ,4) AS engagement_score
FROM 
spotify_data
WHERE 
	views > 0
ORDER BY
	engagement_score DESC
LIMIT 10;

-- OBJECTIVE NO.18: Use window functions to rank tracks by duration per artist and show the longest and shortest.
WITH ranked_tracks AS (
  SELECT 
    artist,
    track,
    duration_min,
    RANK() OVER (PARTITION BY artist ORDER BY duration_min DESC) AS longest,
    RANK() OVER (PARTITION BY artist ORDER BY duration_min ASC) AS shortest
  FROM 
    spotify_data
)
SELECT 
  artist, track, duration_min, 'Longest' AS type
FROM 
  ranked_tracks
WHERE 
  longest = 1

UNION

SELECT 
  artist, track, duration_min, 'Shortest' AS type
FROM 
  ranked_tracks
WHERE 
  shortest = 1
ORDER BY 
  artist
LIMIT 10;

-- OBJECTIVE NO.19: Classify tracks as High/Low Danceability and compare average views.
WITH dance_groups AS (
  SELECT 
    track,
    views,
    CASE 
      WHEN danceability >= 0.7 THEN 'High Danceability'
      ELSE 'Low Danceability'
    END AS dancing_song
  FROM 
    spotify_data
  WHERE 
    views IS NOT NULL
)
SELECT 
  dancing_song,
  COUNT(*) AS track_count,
  ROUND(AVG(views), 0) AS avg_views
FROM 
  dance_groups
GROUP BY 
  dancing_song;
  
-- OBJECTIVE NO.20: Rank albums by the total sum of likes, comments, and views.
SELECT 
	album,
    ROUND(SUM(views+likes+comments),0) AS total_engagement
FROM 
	spotify_data
GROUP BY
album
ORDER BY 
	total_engagement DESC
LIMIT 10;

-- OBJECTIVE NO.21: Recommend similar songs to 'Despacito' and 'Shape of You' based on views,likes,energy,and danceability(Basic Recommender System).

-- DESPACITO
SELECT 
  'Despacito' AS base_track,
  t2.track, 
  t2.artist,
  t2.views,
  t2.liveness,
  t2.danceability,
  t2.energy,
  ABS(t1.views - t2.views) +
  ABS(t1.liveness - t2.liveness) +
  ABS(t1.danceability - t2.danceability) +
  ABS(t1.energy - t2.energy) AS similarity_score
FROM 
  spotify_data t1
JOIN 
  spotify_data t2 
ON 
  t1.track = 'Despacito' 
  AND t2.track != t1.track
ORDER BY 
  similarity_score ASC
LIMIT 5;

-- SHAPE OF YOU
SELECT 
  'Shape of You' AS base_track,
  t2.track, 
  t2.artist,
  t2.views,
  t2.liveness,
  t2.danceability,
  t2.energy,
  ABS(t1.views - t2.views) +
  ABS(t1.liveness - t2.liveness) +
  ABS(t1.danceability - t2.danceability) +
  ABS(t1.energy - t2.energy) AS similarity_score
FROM 
  spotify_data t1
JOIN 
  spotify_data t2 
ON 
  t1.track = 'Shape of You' 
  AND t2.track != t1.track
ORDER BY 
  similarity_score ASC
LIMIT 5;


