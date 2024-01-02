# HR Data Analysis

In this project I performed exploratory data analysis on data from human resources department, as well as cleaned and visualized the data using SQL and PowerBI




## Objectives

- Load data from .CSV file to MS SQL SERVER Database
- Clean the data using SQL Queries (data standardization, changing data types, etc. using: UPDATE, ALTER, CASE, subqueries, VIEWS)
- Perform Exploratory Data Analysis using SQL Queries
- Connect with MS SQL SERVER Database using PowerBI and create visualization



# Deployment
## Getting statistics for the channels

- Load the data into a MS SQL SERVER Database
The data was provided in a .CSV format and I needed to load it into a database. In order to do so I created a database:
```sql
CREATE DATABASE HR_project;
```

And used MS SQL SERVER "Import flat file" to load the data

![](images/load_data.png)

- Data Cleaning
While loading my data I noticed that "hire_date" column was not standardized and "termdate" column was not in the format and type that I wanted:


![](images/load_data_cleaning.png)

![](images/load_data_cleaning2.png)

I run SQL Queries to fix it

```sql
SELECT SUBSTRING(termdate, 1, CHARINDEX('U', termdate) - 1)
FROM hr_data
```

```sql
UPDATE hr_data
SET termdate = FORMAT(CONVERT(DATETIME, SUBSTRING(termdate, 1, CHARINDEX('U', termdate) - 1), 120), 'yyyy-MM-dd')
```

```sql
ALTER TABLE hr_data
ADD termdate_fix DATE;
```

```sql
UPDATE hr_data
SET termdate_fix = CASE
	WHEN termdate IS NOT NULL AND ISDATE(termdate) = 1 THEN CAST(termdate AS DATETIME)
	ELSE NULL 
	END;
```
![](images/termdate_clean.png)

I also created a new column called "age"
```sql
ALTER TABLE hr_data
ADD age nvarchar(50);

UPDATE hr_data
SET age = DATEDIFF(year, birthdate, GETDATE());
```

- Exploratory data analysis
```sql
-- 1) What's the age distribution in the company?
-- age distribution
SELECT 
	MIN(age) as Youngest_Employee,
	MAX(age) as Oldest_Employee
FROM hr_data;

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
```

```sql
--2) What's the gender breakdown in the company?
SELECT gender, count(*) as count_gender
FROM hr_data
WHERE termdate_fix IS NULL
GROUP BY gender
ORDER BY gender ASC;
```

```sql
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
```

```sql
--4) What's the race distribution in the company?
SELECT race, COUNT(*) as race_count
FROM hr_data
WHERE termdate_fix IS NULL
GROUP BY race
ORDER BY race_count DESC;
```

```sql
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
```

```sql
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
```

```sql
--7) What is the tenure distribution for each department?
SELECT department, AVG(DATEDIFF(MONTH, hire_date, termdate_fix)) / 12 AS Avg_time
FROM hr_data
WHERE termdate_fix IS NOT NULL AND termdate_fix <= GETDATE()
GROUP BY department
ORDER BY Avg_time DESC;
```

```sql
--8) How have employee hire counts varied over time?
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
```

```sql
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
```

## Summary
With this query I finished my project. I found meaningful insides and practiced lots of SQL!

## Authors

- [@Szymon Poparda](https://www.linkedin.com/in/szymon-poparda-02b96a248/)
