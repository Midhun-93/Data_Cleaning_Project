# Data Cleaning Project: Layoffs Dataset

This project highlights the data cleaning process applied to a dataset containing information about layoffs in major companies. It helped me understand key techniques for preparing raw data for analysis.

## Dataset Details
- **Attributes**: Company, location, industry, total laid-off, percentage laid-off, date, stage, country, and funds raised.

## Cleaning Process

### 1. Data Staging
- Created a staging table (`layoffs_staging`) to preserve the integrity of raw data.

### 2. Duplicate Removal
- Identified duplicates using `ROW_NUMBER()` with `PARTITION BY` and removed them via a secondary table.

### 3. Data Standardization
- Used `TRIM` to remove extra spaces.
- Standardized column values (e.g., "Crypto" for industry, "United States" for country).
- Converted the `date` column from text to `DATE` format.

### 4. Handling Null Values
- Identified and updated missing values in the `industry` column by comparing rows with matching `company` and `location` attributes.
- Deleted rows where both `total_laid_off` and `percentage_laid_off` were `NULL`.

### 5. Optimization
- Dropped unnecessary columns, such as the temporary `row_num` column, after cleaning.

## Key SQL Techniques
- Duplicate detection:
  ```sql
  SELECT *,
         ROW_NUMBER() OVER (PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
  FROM layoffs_staging;
  ```
- Standardizing `industry` values:
  ```sql
  UPDATE layoffs_staging2
  SET industry = 'Crypto'
  WHERE industry LIKE '%Crypto%';
  ```
- Filling missing `industry` values:
  ```sql
  UPDATE layoffs_staging2 t1
  JOIN layoffs_staging2 t2
  ON t1.company = t2.company AND t1.location = t2.location
  SET t1.industry = t2.industry  
  WHERE t1.industry IS NULL AND t2.industry IS NOT NULL;
  ```

## Outcomes
- Cleaned and structured dataset ready for analysis.
- Improved skills in data cleaning, duplication handling, and standardization using SQL.

## Conclusion
This project provided valuable insights into the importance of a robust data cleaning process. It emphasized maintaining raw data integrity while transforming it into a format suitable for analysis. The experience enhanced my SQL proficiency and prepared me for handling complex datasets effectively.

---

This project showcases the critical steps of transforming raw data into a reliable and analyzable format.
