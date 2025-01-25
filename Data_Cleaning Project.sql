-- Data cleaning
-- view the data

SELECT * FROM layoffs;

-- 1. CREATE a copy of the raw data_TABLE
-- 2. remove duplicates
-- 3. standardize data
-- 4. remove null values or blank values
-- 5. remove any columns or rows 

-- copying the raw data
# creating a duplicate TABLE 'layoffs_staging' coz the cleaning process IS not done in raw data 
# changing values in raw data IS avoided because if there IS a requirement of original raw data in future (one w/0 cleaning)
CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT layoffs_staging
SELECT  * FROM layoffs;

SELECT * FROM layoffs_staging;

-- removing duplicates

# creating a row using 'ROW_NUMBER, OVER(), PARTITION BY' statement to find the duplicate values in columns 
SELECT *,
ROW_NUMBER() OVER( 
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raISed_millions) as row_num
FROM layoffs_staging;

-- creating a CTE for extracting the duplicate value in the TABLE
WITH duplciate_CTE AS
(
SELECT *,
ROW_NUMBER() OVER( 
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raISed_millions) as row_num
FROM layoffs_staging
)
SELECT *
FROM duplciate_CTE
WHERE row_num > 1;

# FROM CTE we can't delete the duplicate values coz it's not an updaTABLE function in MySQL, but ig it can be done in MSSQLserver
# inorder to delete the duplicates FROM the staging TABLE (layoffs_staging) i am creating another TABLE named layoffs_staging2 and delete it FROM there

#syntax for creating new TABLE, using copy FROM clipboard funtion
CREATE TABLE `layoffs_staging2` (
`company` text,
`location` text,
`industry` text, 
`total_laid_off` int default null, 
`percentage_laid_off` text, 
`date` text, 
`stage` text, 
`country` text, 
`funds_raISed_millions` int default null, 
`row_num` int)
engine=InnoDB default charset=utf8mb4 collate=utf8mb4_0900_ai_ci;

#the reason to use this method instead of the CREATE TABLE is the values when tried to populate in new table is not taking the values created by query(row_num) to see the duplicate
SELECT * FROM layoffs_staging2;

INSERT into layoffs_staging2
SELECT *,
ROW_NUMBER() OVER( 
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raISed_millions) as row_num
FROM layoffs_staging;

# SELECTing and deleting the duplicate rows
SELECT * 
FROM layoffs_staging2
WHERE row_num > 1;

delete
FROM layoffs_staging2
WHERE row_num > 1;

-- standardize data
SELECT * 
FROM layoffs_staging2;

#using the trim cmd to remove the spaces in the columns
SELECT company, trim(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
set company = trim(company);

SELECT DISTINCT(industry)
FROM layoffs_staging2
order by 1;

#trying to standardise the column 'industry' 
SELECT * 
FROM layoffs_staging2
WHERE industry LIKE '%Crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE '%Crypto%'; 

SELECT DISTINCT(country)
FROM layoffs_staging2
order by 1;

SELECT * FROM layoffs_staging2
WHERE country LIKE '%United States%';

SELECT country , trim( trailing '.' FROM country )
FROM layoffs_staging2;

#standardizing the country column using trim statement on update cmd

update layoffs_staging2
set country = trim( trailing '.' FROM country )
WHERE country LIKE 'United States%';

SELECT DISTINCT(country)
FROM layoffs_staging2
order by 1;

#date column was in text format which needs to be changed into date format which will bw helpful when doing time series EDA
SELECT `date`, 
str_to_date(`date`, '%m/%d/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = str_to_date(`date`, '%m/%d/%Y');

SELECT `date`
FROM layoffs_staging2;

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` date;

-- 3. working with null and blank values
# in this table null values are mostly present in total_laid_off & percentage_laid_off

SELECT * FROM layoffs_staging2 
WHERE industry IS null or industry = '';

#updating the column 'industry' which has ' ' value to null
update layoffs_staging2
set industry = null
WHERE industry = '';

#trying to get the values of column 'industry' is null by comparing the same table in which the 'company' and 'location' of the same industry matche has values 
# JOIN statement is used to compare the same table against each other
SELECT * FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	on t1.company = t2.company
    and t1.location= t2.location
WHERE t1.industry IS NULL
and t2.industry IS not null;

# updating the values of the column 'industry' by comparing the values filtered by same company and location, then populating into the null values on the column 'industry'
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	on t1.company = t2.company
set t1.industry = t2.industry  
WHERE t1.industry IS NULL
and t2.industry IS not null;

SELECT * 
FROM layoffs_staging2
WHERE industry IS null;

-- removing columns or rows which are not required

# finding and deleting the column WHERE total_laid_off and percentage_laid_off are null.
# these data provides whether the company had laid off or not. since the value IS null we are going to remove them FROM TABLE

SELECT * FROM layoffs_staging2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

DELETE 
FROM layoffs_staging2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

# now removing the column row_num

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

SELECT *
FROM layoffs_staging2;
