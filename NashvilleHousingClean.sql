# The Nashville Housing Project 


# Data Cleaning


# Fixing date format

UPDATE NashvilleProject.nashville_data
SET saledate = DATE_FORMAT(STR_TO_DATE(saledate, '%d-%b-%y'), '%m %d %Y');

UPDATE NashvilleProject.nashville_data
SET saledate = STR_TO_DATE(saledate, '%m %d %Y');

ALTER TABLE NashvilleProject.nashville_data
ADD saledateconverted DATE;

UPDATE NashvilleProject.nashville_data
SET saledateconverted = saledate;

SELECT *
FROM NashvilleProject.nashville_data;

# Fixing property address 

SELECT 
	a1.parcelid, 
	a1.propertyaddress, 
	a2.parcelid, 
    a2.propertyaddress, 
    IFNULL(a1.propertyaddress, a2.propertyaddress) as merged_propertyaddress
FROM NashvilleProject.nashville_data a1
JOIN NashvilleProject.nashville_data a2 
	ON a2.parcelid = a1.parcelid
	AND a2.uniqueid <> a1.uniqueid
WHERE a1.propertyaddress is null;


UPDATE NashvilleProject.nashville_data a1 
JOIN NashvilleProject.nashville_data a2 
	ON a2.parcelid = a1.parcelid
	AND a2.uniqueid <> a1.uniqueid
SET a1.propertyaddress = IFNULL(a1.propertyaddress, a2.propertyaddress)
WHERE a1.propertyaddress is null;

SELECT *
FROM NashvilleProject.nashville_data
WHERE propertyaddress is null;

# Separating propertyaddress into individual columns: address, city

SELECT 
	propertyaddress,
	SUBSTRING(propertyaddress, 1, LOCATE(',', propertyaddress) -1),
    SUBSTRING(propertyaddress, LOCATE(',', propertyaddress) +1, LENGTH(propertyaddress)) 
FROM NashvilleProject.nashville_data;


ALTER TABLE NashvilleProject.nashville_data
ADD Propertysplitaddress text;

UPDATE NashvilleProject.nashville_data
SET Propertysplitaddress = SUBSTRING(propertyaddress, 1, LOCATE(',', propertyaddress) -1);


ALTER TABLE NashvilleProject.nashville_data
ADD Propertysplitcity text;

UPDATE NashvilleProject.nashville_data
SET Propertysplitcity = SUBSTRING(propertyaddress, LOCATE(',', propertyaddress) +1, LENGTH(propertyaddress));

# Separating owneraddress into individual columns: address, state

SELECT 
	SUBSTRING_INDEX(owneraddress, ',', 1),
    SUBSTRING_INDEX(SUBSTRING_INDEX(owneraddress, ',', 2), ',', -1),
    SUBSTRING_INDEX(owneraddress, ',', -1)
FROM NashvilleProject.nashville_data;


ALTER TABLE NashvilleProject.nashville_data
ADD Ownersplitaddress text;

UPDATE NashvilleProject.nashville_data
SET Ownersplitaddress = SUBSTRING_INDEX(owneraddress, ',', 1);


ALTER TABLE NashvilleProject.nashville_data
ADD Ownersplitcity text;

UPDATE NashvilleProject.nashville_data
SET Ownersplitcity = SUBSTRING_INDEX(SUBSTRING_INDEX(owneraddress, ',', 2), ',', -1);


ALTER TABLE NashvilleProject.nashville_data
ADD Ownersplitstate text;

UPDATE NashvilleProject.nashville_data
SET Ownersplitstate = SUBSTRING_INDEX(owneraddress, ',', -1);

# Renaming and grouping individual columns 

SELECT DISTINCT 
	landuse, 
    count(*) 
FROM NashvilleProject.nashville_data 
GROUP BY 1;

UPDATE NashvilleProject.nashville_data
SET landuse = REPLACE(landuse, 'VACANT RES LAND', 'VACANT RESIDENTIAL LAND');


UPDATE NashvilleProject.nashville_data
SET landuse = REPLACE(landuse, 'VACANT RESIENTIAL LAND', 'VACANT RESIDENTIAL LAND');

# Fixing Y and N to Yes and No in Soldasvacant column

Select soldasvacant,
	CASE WHEN soldasvacant = 'Y' then 'Yes'
		 WHEN soldasvacant = 'N' then 'No'
		 ELSE soldasvacant END
FROM NashvilleProject.nashville_data;


UPDATE NashvilleProject.nashville_data
SET soldasvacant = CASE WHEN soldasvacant = 'Y' then 'Yes'
						WHEN soldasvacant = 'N' then 'No'
						ELSE soldasvacant END;

# Removing duplicates 

WITH Rownumcte as(
	SELECT 
		*,
		ROW_NUMBER() OVER(
		PARTITION BY parcelid,
					 propertyaddress,
					 saleprice,
					 saledate,
					 legalreference
					 ORDER BY 
						uniqueid) as rownum
	FROM NashvilleProject.nashville_data
),

dup AS (
	SELECT *
	FROM rownumcte
	WHERE rownum > 1)

DELETE FROM NashvilleProject.nashville_data
WHERE uniqueid in (SELECT uniqueid FROM dup)
;

# Deleting unused columns 

ALTER TABLE NashvilleProject.nashville_data
DROP COLUMN owneraddress,
DROP COLUMN taxdistrict,
DROP COLUMN propertyaddress,
DROP COLUMN saledate
;

SELECT *
FROM NashvilleProject.nashville_data;

























