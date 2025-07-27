# Spotify Music Data Analysis using SQL

Welcome to my **Spotify Music Analysis Project**, where I explore and extract powerful insights from a real-world dataset using **MYSQL**.

From track recommendations and engagement metrics to advanced **window functions** and **custom KPIs**, this project demonstrates my SQL proficiency with real music data!

---

## Dataset Overview

The dataset contains detailed information about Spotify tracks and their YouTube statistics, including:

- Artist & Album Info  
- Audio Features (danceability, energy, liveness, etc.)  
- Streaming Stats (views, likes, comments, streams)  
- Video Metadata (official video, licensed)  



## Project Objectives & Queries

| # | Objective |
|--|-----------|
| 1 | Retrieve the names of all tracks that have **more than 1 billion streams** |
| 2 | List all **albums with their respective artists** |
| 3 | Get the **total number of comments** for licensed tracks |
| 4 | Find all tracks that belong to **album type = 'single'** |
| 5 | Count the **total number of tracks by each artist** |
| 6 | Calculate the **average danceability** of tracks in each album |
| 7 | Find the **top 5 tracks with the highest energy values** |
| 8 | List all tracks with **views and likes** where official_video = TRUE |
| 9 | For each album, calculate the **total views** of all tracks |
| 10 | Retrieve tracks that have been **streamed on Spotify more than YouTube** |
| 11 | Use **window functions** to find the **top 3 most-viewed tracks per artist** |
| 12 | Find tracks where the **liveness score is above average** |
| 13 | Use a **WITH clause** to calculate the **energy range** per album |
| 14 | Find tracks with **energy-to-liveness ratio > 1.2** |
| 15 | Compute **cumulative likes** ordered by views using **window functions** |
| 16 | Identify tracks where **likes per view exceed a certain threshold (e.g., 20%)** |
| 17 | Define a custom **Engagement Score = (likes + comments) / views** to rank user interaction |
| 18 | **Rank tracks** by duration per artist and retrieve the longest and shortest |
| 19 | Classify tracks as **High/Low Danceability** and compare average views |
| 20 | **Rank albums** by total sum of **likes + comments + views** |
| 21 | **Content-Based Song Recommender (Simulated):** Recommend tracks similar to _Despacito_ and _Shape of You_ using `views`, `likes`, `energy`, and `danceability` |

---

## Project Highlights

- Fully written in **Structured Query Language (SQL)**  
- Demonstrates **data wrangling, KPIs, window functions**, and **ranking**  
- Includes a **custom recommender system** using audio features  
- Built with real-world data and real music tracks  
- Ideal for showcasing on **GitHub, LinkedIn, and your Resume**

---

## Tools & Skills Used

- MySQL / PostgreSQL  
- Window Functions (RANK, ROW_NUMBER, CUME_SUM)  
- Aggregates & Grouping  
- Subqueries & CTEs  
- Custom KPI Definitions  
- Data Classification & Recommendations  

---

## Example Queries

Songs Recommender System (e.g. ‘Shape of You’)
---
```
SELECT 
  'Shape of You' AS base_track,
  t2.track, 
  t2.artist,
  t2.views,
  t2.liveness,
  t2.danceability,
  t2.energy,
  -- Calculate similarity score based on feature differences
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
```
---

Classify songs by danceability and compare average views
---
```
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

```
---

## What I Learned

- How to **design analytical SQL queries** from real-world music-based questions  
- Applied advanced SQL techniques like **ranking, custom metrics, and CTEs**  
- Simulated a **basic recommender system** with **feature similarity**  
- Interpreted **streaming trends and user engagement KPIs**


## How to Use
- Load Spotify Data.csv into your preferred SQL database (MySQL / PostgreSQL recommended)

- Navigate to the Spotify Project file and execute the SQL scripts corresponding to each objective

- Customize filters, thresholds, or metrics based on your interests and analytical goals

- Use the insights for dashboards, reports, or further predictive modeling

## License

This project is free for educational and non-commercial use.
Feel free to fork, improve, or reuse with credits.

---

Download the dataset: https://drive.google.com/file/d/11-A-Yyc_5Dw05p101Mcz-n-2-3eft5qz/view?usp=drive_link

---
## Let's Connect!

### Ashar Aftab 

Email: asharaftab2004@gmail.com

LinkedIn: www.linkedin.com/in/ashar-aftab-b09924295

---

“Where words fail, music speaks.” — Hans Christian Andersen

---

> If you found this project useful or insightful, consider giving it a ⭐ on GitHub!

