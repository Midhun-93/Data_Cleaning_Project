# Data Cleaning Project: Layoffs Dataset

This project documents the comprehensive data cleaning process applied to a dataset about layoffs in major companies. It provided hands-on experience with essential techniques for cleaning and preparing data for analysis.

## Dataset Overview
The dataset includes attributes such as:
- Company
- Location
- Industry
- Total laid-off employees
- Percentage laid-off
- Date
- Stage
- Country
- Funds raised

## Steps in Data Cleaning

### 1. View and Stage Data
- Explored the raw dataset for structure and potential issues.
- Created a staging table (`layoffs_staging`) to avoid altering raw data, ensuring the original dataset remains intact for future use.

### 2. Handle Duplicates
- Used `ROW_NUMBER()` with `PARTITION BY` to identify duplicate rows.
- Created a secondary table (`layoffs_staging2`) to handle duplicates effectively.
- Removed duplicate rows to ensure data consistency.

### 3. Standardize Data
- Removed unnecessary spaces using the `TRIM` function.
- Standardized column values (e.g., unified industry names like "Crypto" and country names like "United States").
- Converted the `date` column from text to the `DATE` format to enable time-series analysis.

### 4. Address Null and Blank Values
- Identified and updated missing `industry` values by comparing rows with similar `company` and `location` attributes.
- Deleted rows where critical attributes (`total_laid_off`, `percentage_laid_off`) were `NULL`, as these were deemed irrelevant.

### 5. Optimize the Dataset
- Dropped unnecessary columns, including the temporary `row_num` column, after cleaning.
- Ensured the dataset is structured for efficient analysis.

## Key SQL Queries

### Duplicate Detection
```sql
SELECT *,
       ROW_NUMBER() OVER (PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;
```

### Standardizing `Industry` Values
```sql
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE '%Crypto%';
```

### Filling Missing `Industry` Values
```sql
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
ON t1.company = t2.company AND t1.location = t2.location
SET t1.industry = t2.industry  
WHERE t1.industry IS NULL AND t2.industry IS NOT NULL;
```

## Outcomes
- Successfully cleaned and structured the layoffs dataset, making it ready for analysis.
- Gained a deeper understanding of:
  - Managing staging tables.
  - Identifying and handling duplicate data.
  - Standardizing and cleaning column values.
  - Addressing missing and null values effectively.

## Conclusion
This project reinforced the importance of a robust data cleaning process for ensuring reliable analysis. It highlighted best practices for preserving raw data integrity while transforming datasets into a clean and usable format. The hands-on experience significantly improved my SQL skills and prepared me to handle complex data cleaning tasks efficiently.
