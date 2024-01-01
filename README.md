# HR Data Analysis

In this project I performed exploratory data analysis on data from human resources department, as well as cleaned and visualized the data using SQL and PowerBI




## Objectives

- Load data from .CSV file to MS SQL SERVER Database
- Clean the data using SQL Queries (data standardization, changing data types, etc. using statements: UPDATE, ALTER, CASE )
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

## Summary

## Authors

- [@Szymon Poparda](https://www.linkedin.com/in/szymon-poparda-02b96a248/)
