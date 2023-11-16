# EDA/Exploring the Nashville Housing data


# Selecting all columns used in the table


SELECT *
FROM NashvilleProject.nashville_data;

SELECT propertysplitcity,
	   saledateconverted,
	   saleprice,
	   landuse, 
	   bedrooms,
	   fullbath,
	   halfbath
FROM NashvilleProject.nashville_data
WHERE propertysplitcity LIKE '%nash%'
ORDER BY 1,2;

# Examining distribution of Nashville housing prices

SELECT 
	saleprice,
    COUNT(saleprice) as count_of_saleprice
FROM NashvilleProject.nashville_data
GROUP BY 1
ORDER BY 2 DESC;

# Examining average sale price over time

SELECT 
	saledateconverted,
    ROUND(AVG(saleprice)) as Avg_sale_price
FROM NashvilleProject.nashville_data
#WHERE propertysplitcity LIKE '%nash%'
GROUP BY 1
ORDER BY 1;

# Examining running sales over time segmented by city

WITH sales_over_time as (
SELECT 
	propertysplitcity,
    saledateconverted,
    SUM(saleprice) as total_sales 
FROM NashvilleProject.nashville_data
GROUP BY 1,2
)

SELECT 
	*,
    SUM(total_sales) OVER (PARTITION BY propertysplitcity 
						   ORDER BY propertysplitcity, saledateconverted) as runnning_sales
FROM sales_over_time
GROUP BY propertysplitcity, saledateconverted;

# Average sale price of every property 

SELECT 
	landuse,
    ROUND(AVG(saleprice)) as Avg_saleprice
FROM NashvilleProject.nashville_data
GROUP BY 1
ORDER BY 2 DESC;

# Average sale price and count of distinct combinations of bedrooms, fullbath, and halfbath

SELECT 
	bedrooms,
    fullbath,
    halfbath,
    COUNT(*) as number_of_units,
    ROUND(AVG(saleprice)) as Avg_saleprice
FROM NashvilleProject.nashville_data
WHERE bedrooms is not null 
AND fullbath is not null
AND halfbath is not null
GROUP BY 1, 2, 3
ORDER BY 4 DESC;

# The distribution of properties across Nashville area

SELECT 
	propertysplitcity,
    COUNT(*) as Number_of_properties
FROM NashvilleProject.nashville_data
GROUP BY 1
ORDER BY 2 DESC;

# The distribution of sales by date

SELECT 
	saledateconverted as Date,
    COUNT(*) as Number_of_sales
FROM NashvilleProject.nashville_data
GROUP BY 1
ORDER BY 1;

# Distribution of the number of distinct properties across the Nashville area

SELECT 
	propertysplitcity,
    landuse,
    COUNT(*)
FROM NashvilleProject.nashville_data
GROUP BY 1,2
ORDER BY 3 DESC;













