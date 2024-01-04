-- QUESTIONS TO ANSWER FROM THE DATA

-- 1) What's the age distribution in the company?
-- age distribution
-- age group by gender
--2) What's the gender breakdown in the company?
--3) How does gender vary across departments and job titles? 
--4) What's the race distribution in the company?
--5) What's the average length of employment in the company?
--6) Which department has the highest turnover rate?
--7) What is the tenure distribution for each department?
--8) How many employees work remotely for each department?
--9) What's the distribution of employees across different states?
--10) How are job titles distributed in the company?
--11) How have employee hire counts varied over time?

USE HR_project;

-- 1) What's the age distribution in the company?
-- age distribution
SELECT * 
FROM hr_data

SELECT 
	MIN(age) as Youngest_Employee,
	MAX(age) as Oldest_Employee
FROM hr_data;

-- additional question - find number of people under 30
CREATE VIEW age AS (
    SELECT age, COUNT(*) AS count_age
    FROM hr_data
    GROUP BY age
);

SELECT SUM(count_age) as sum_under_30
FROM age
WHERE age < 30;

DROP VIEW age;

-- age group count
SELECT age_group, count(*) as count_groups
FROM
(SELECT CASE
	WHEN age >= 22 and age <= 30 THEN '22 - 30'
	WHEN age >= 31 and age <= 50 THEN '31 - 40'
	WHEN age >= 31 and age <= 50 THEN '41 - 50'
	ELSE '50+'
	END AS age_group
FROM hr_data
WHERE termdate_fix IS NULL
) AS sub_age_groups  -- have not been terminated yet
GROUP BY age_group
ORDER BY age_group

-- age group by gender
SELECT age_group, gender, count(*) as count_groups
FROM
(SELECT gender, CASE
	WHEN age >= 22 and age <= 30 THEN '22 - 30'
	WHEN age >= 31 and age <= 50 THEN '31 - 40'
	WHEN age >= 31 and age <= 50 THEN '41 - 50'
	ELSE '50+'
	END AS age_group
FROM hr_data
WHERE termdate_fix IS NULL
) AS sub_age_groups  -- have not been terminated yet
GROUP BY age_group, gender
ORDER BY age_group, gender

--2) What's the gender breakdown in the company?
SELECT gender, count(*) as count_gender
FROM hr_data
WHERE termdate_fix IS NULL
GROUP BY gender
ORDER BY gender ASC;

--3) How does gender vary across departments and job titles? 
SELECT jobtitle, gender, COUNT(*) as job_count
FROM hr_data
WHERE termdate_fix IS NULL
GROUP BY jobtitle, gender
ORDER BY jobtitle, gender ASC;

SELECT department, gender, COUNT(*) as department_count
FROM hr_data
WHERE termdate_fix IS NULL
GROUP BY department, gender
ORDER BY department, gender ASC;

--4) What's the race distribution in the company?
SELECT race, COUNT(*) as race_count
FROM hr_data
WHERE termdate_fix IS NULL
GROUP BY race
ORDER BY race_count DESC;

--5) What's the average length of employment in the company?
SELECT 
    hire_date, 
    termdate_fix,
    DATEDIFF(YEAR, hire_date, termdate_fix) AS date_difference_years,
    DATEDIFF(MONTH, hire_date, termdate_fix) % 12 AS date_difference_months
FROM 
    hr_data
WHERE 
    termdate_fix IS NOT NULL;

SELECT AVG(DATEDIFF(MONTH, hire_date, termdate_fix)) / 12 AS Avg_time
FROM hr_data
WHERE termdate_fix IS NOT NULL AND termdate_fix <= GETDATE();



--6) Which department has the highest turnover rate?
SELECT department, 
    terminated_count, 
    total_count,
	(ROUND((CAST(terminated_count AS FLOAT) * 100.00 / total_count), 2)) AS termination_percentage -- only 2 decimal places
FROM 
(SELECT department, COUNT(*) AS total_count, SUM(CASE
	WHEN termdate_fix IS NOT NULL AND termdate_fix <= GETDATE() 
	THEN 1 ELSE 0
	END) AS terminated_count
FROM hr_data
GROUP BY department
) AS subquery
ORDER BY termination_percentage DESC;


--7) What is the tenure distribution for each department?
SELECT department, AVG(DATEDIFF(MONTH, hire_date, termdate_fix)) / 12 AS Avg_time
FROM hr_data
WHERE termdate_fix IS NOT NULL AND termdate_fix <= GETDATE()
GROUP BY department
ORDER BY Avg_time DESC;

--8) How many employees work remotely for each department?
SELECT location, COUNT(*) AS location_count
FROM hr_data
WHERE termdate_fix IS NULL
GROUP BY location;

--9) What's the distribution of employees across different states?
SELECT location_state, COUNT(*) AS state_count
FROM hr_data
WHERE termdate_fix IS NULL
GROUP BY location_state
ORDER BY state_count DESC;

--10) How are job titles distributed in the company?
SELECT jobtitle, COUNT(*) AS job_count
FROM hr_data
WHERE termdate_fix IS NULL
GROUP BY jobtitle
ORDER BY job_count DESC;

--11) How have employee hire counts varied over time?
SELECT YEAR(hire_date) AS hire_year, COUNT(*) AS total_count
FROM hr_data
GROUP BY YEAR(hire_date)
ORDER BY hire_year;

SELECT SUM(total_count) AS sum_hires
FROM
(
    SELECT 
        YEAR(hire_date) AS hire_year, 
        COUNT(*) AS total_count
    FROM hr_data
    GROUP BY YEAR(hire_date)
) AS subquery; -- sum of hires

-- hires and terminations
SELECT 
	hire_year,
	hires,
	terminations,
	hires - terminations AS net_change,
	ROUND(CAST(hires - terminations AS float)/hires, 2) * 100 AS percent_hire_change
FROM (
	SELECT 
		YEAR(hire_date) AS hire_year,
		COUNT(*) AS hires,
		SUM(CASE 
				WHEN termdate_fix IS NOT NULL AND termdate_fix <= GETDATE() THEN 1 ELSE 0
				END) AS terminations
	FROM hr_data
	GROUP BY YEAR(hire_date)) AS subquery
ORDER BY hire_year;




