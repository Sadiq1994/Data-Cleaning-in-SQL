/*
Cleaning Data in SQL Queries
*/

SELECT * 
FROM Housing_Project;


--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

SELECT SaleDate,CONVERT(DATE,SaleDate)
FROM Housing_Project;


ALTER TABLE Housing_project
ADD SaleDateConverted Date;

UPDATE Housing_Project
SET SaleDateConverted = CONVERT(DATE,SaleDate);

SELECT SaleDateConverted FROM Housing_Project;



 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

-- 1. selected PropertyAddress column from Housing_Project Table and found NULL values
SELECT PropertyAddress
FROM Housing_Project;

-- 2. Found 29 Rows conatining NULL values in ProperyAddress column
SELECT * 
FROM Housing_Project
WHERE PropertyAddress IS NULL;

--3. In order to find why the PropertyAddress had NULL values instead of propertyaddress, I performed self join on the table considering the ParcelId and the PropertyAdress columns
-- since the ParcelId had same Id's repeated and was containing the propertyaddress.

SELECT a.ParcelID,a.PropertyAddress, b.ParcelID, b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Housing_Project a
JOIN Housing_Project b
    on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Housing_Project a
JOIN Housing_Project b
    on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;


--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM Housing_Project;


SELECT
SUBSTRING( PropertyAddress,1,CHARINDEX(',', PropertyAddress) - 1) AS Address,
SUBSTRING( PropertyAddress,CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS City
FROM Housing_Project;

ALTER TABLE Housing_project
ADD ProprtySplitAdrdress VARCHAR(255);

UPDATE Housing_Project
SET ProprtySplitAdrdress = SUBSTRING( PropertyAddress,1,CHARINDEX(',', PropertyAddress) - 1);

ALTER TABLE Housing_project
ADD ProprtySplitCity VARCHAR(255);

UPDATE Housing_Project
SET ProprtySplitCity = SUBSTRING( PropertyAddress,CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress));

SELECT OwnerAddress FROM Housing_Project;

SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM Housing_Project;


ALTER TABLE Housing_project
ADD OwnerSplitAddress VARCHAR(255);

UPDATE Housing_Project
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3);

ALTER TABLE Housing_project
ADD OwnerSplitCity VARCHAR(255);

UPDATE Housing_Project
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2);

ALTER TABLE Housing_project
ADD OwnerSplitState VARCHAR(255);

UPDATE Housing_Project
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1);


SELECT * FROM Housing_Project;



--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant),COUNT(SoldAsVacant) AS sold_cnt
FROM Housing_Project
GROUP BY SoldAsVacant
ORDER BY sold_cnt;

SELECT SoldAsVacant,
   CASE WHEN SoldAsVacant = 'Y' THEN 'Yes' 
        WHEN SoldAsVacant = 'N' THEN 'No' 
		ELSE SoldAsVacant 
		END
FROM Housing_Project;

UPDATE Housing_Project
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes' 
        WHEN SoldAsVacant = 'N' THEN 'No' 
		ELSE SoldAsVacant 
		END


-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
WITH cte AS
(
SELECT *,
  ROW_NUMBER() OVER(
  PARTITION BY ParcelID,
               PropertyAddress,
			   SaleDate,
			   SalePrice,
			   LegalReference
  ORDER BY  UniqueID ) row_num
FROM Housing_Project
)
SELECT * FROM cte
WHERE row_num > 1;

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns
DROP TABLE Housing_Project_Copy;

-- Made a copy of the Table before deleting the unused columns
select *
INTO Housing_Project_Copy
FROM Housing_ProjecT;

ALTER TABLE Housing_Project_Copy
DROP COLUMN SaleDate,PropertyAddress,OwnerAddress,TaxDistrict;














