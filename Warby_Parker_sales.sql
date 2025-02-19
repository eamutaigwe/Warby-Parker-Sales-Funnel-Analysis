-- Select the first 10 rows of the survey table to get familar with the columns
 SELECT *
 FROM survey
 LIMIT 10;

 SELECT question, COUNT(DISTINCT user_id)
 FROM survey
 GROUP BY question;

 -- Examine the first five rows of each table.
 -- This helps us get familiar with the column names and information contained in each table.
 SELECT *
 FROM quiz
 LIMIT 5;

 SELECT *
 FROM home_try_on
 LIMIT 5;

 SELECT *
 FROM purchase
 LIMIT 5;

-- Merge the 3 tables using LEFT JOINs and generate new columns representing True or False values for 
-- customers who performed home_try_on and those who 
-- purchased.
 SELECT DISTINCT q.user_id,
     h.user_id IS NOT NULL AS 'is_home_try_on',
     h.number_of_pairs,
     p.user_id IS NOT NULL AS 'is_purchase'
FROM quiz AS q
LEFT JOIN home_try_on AS h
  ON q.user_id = h.user_id
LEFT JOIN purchase AS p
  ON p.user_id = q.user_id
LIMIT 10;

-- Calculate overall conversion across the funnel
WITH warby_parker_funnel AS (
  SELECT DISTINCT q.user_id,
     h.user_id IS NOT NULL AS 'is_home_try_on',
     h.number_of_pairs,
     p.user_id IS NOT NULL AS 'is_purchase'
FROM quiz AS q
LEFT JOIN home_try_on AS h
  ON q.user_id = h.user_id
LEFT JOIN purchase AS p
  ON p.user_id = q.user_id
)
SELECT COUNT(user_id) AS 'quiz_participants',
       SUM(is_home_try_on) AS 'home_try_on',
       SUM(is_purchase) AS 'purchased'
FROM warby_parker_funnel;

-- Compare conversion from quiz to home_try_on, and home_try_on to purchase
WITH 
  warby_parker_funnel AS (
    SELECT DISTINCT q.user_id,
      h.user_id IS NOT NULL AS 'is_home_try_on',
      h.number_of_pairs,
      p.user_id IS NOT NULL AS 'is_purchase'
    FROM quiz AS q
    LEFT JOIN home_try_on AS h
      ON q.user_id = h.user_id
    LEFT JOIN purchase AS p
      ON p.user_id = q.user_id
),
conversions AS (
SELECT COUNT(user_id) AS 'quiz_participants',
       SUM(is_home_try_on) AS 'home_try_on',
       SUM(is_purchase) AS 'purchased'
FROM warby_parker_funnel
)
SELECT 1.0 * quiz_participants / quiz_participants AS 'quiz_rate',
       1.0 * home_try_on / quiz_participants AS 'home_try_on_rate',
       1.0 * purchased / home_try_on AS 'purchase_rate'
FROM conversions;

-- Calculate the difference in purchase rates between customers who had 3 number_of_pairs and ones who had 5.
SELECT h.number_of_pairs,
       ROUND(1.0 * SUM(p.user_id IS NOT NULL) / COUNT(h.user_id), 2) AS 'purchase_rate'
FROM home_try_on AS h
LEFT JOIN purchase AS p
  ON h.user_id = p.user_id
GROUP BY 1
ORDER BY 2 DESC;

-- What was the most common response among the customers who took the quiz?
SELECT style, 
  COUNT(*)
FROM quiz
GROUP BY 1
ORDER BY 2 DESC;

-- What was the most common type of purchase made?
SELECT style,
   COUNT(*)
FROM purchase
GROUP BY 1
ORDER BY 2 DESC;