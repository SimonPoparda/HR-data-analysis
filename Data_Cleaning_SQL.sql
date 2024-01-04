CREATE DATABASE HR_project;
USE HR_project;

SELECT *
INTO backup_hr
FROM hr_data;

DROP TABLE hr_data;

SELECT *
INTO hr_data
FROM backup_hr;

SELECT * 
FROM hr_data;

SELECT termdate
FROM hr_data
ORDER BY termdate DESC;

-- cleaning termdate column
SELECT SUBSTRING(termdate, 1, CHARINDEX('U', termdate) - 1)
FROM hr_data;

UPDATE hr_data
SET termdate = FORMAT(CONVERT(DATETIME, SUBSTRING(termdate, 1, CHARINDEX('U', termdate) - 1), 120), 'yyyy-MM-dd');

-- copy converted time values from termdate to termdate_fix (date data type)
ALTER TABLE hr_data
ADD termdate_fix DATE;

UPDATE hr_data
SET termdate_fix = CASE
	WHEN termdate IS NOT NULL AND ISDATE(termdate) = 1 THEN CAST(termdate AS DATETIME)
	ELSE NULL 
	END;

ALTER TABLE hr_data
DROP COLUMN termdate;

-- creating age column
ALTER TABLE hr_data
ADD age nvarchar(50);

UPDATE hr_data
SET age = DATEDIFF(year, birthdate, GETDATE());





