 use portfolioproject;

/*

Cleaning data in sql.

*/

SELECT *
FROM housing_data

---- Standardise sale date


SELECT SaleDate, CONVERT(date,SaleDate)
FROM housing_data;

UPDATE housing_data
SET SaleDate = CONVERT(date,SaleDate);

--if theupdate query does not work then, what we can do is,
-- first add another column using alter table command and then set that column equal to converted saledate
--ALTER TABLE housing_data
--ADD sale_date_converted Date;

--update housing_data
--SET sale_date_converted = CONVERT(date,SaleDate);


--- Populate property address data


SELECT *
FROM housing_data
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID;

-- from the above query we got to know that if the parcel id is same then the address will also be same 
--so, with this we can populate null values in property address column
-- For this we have to self join.

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM housing_data AS a
JOIN housing_data AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <>  b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM housing_data AS a
JOIN housing_data AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <>  b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;


---- Breaking out address into individual columns(Address, City, State)

SELECT PropertyAddress
FROM housing_data
--WHERE PropertyAddress IS NULL
--ORDER BY ParcelID;

-- To perform this we will be using "substring" and "sharacter incex(char index)"

SELECT
SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress) -1) AS address,
SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress) +1, LEN (PropertyAddress))AS address
FROM housing_data;

ALTER TABLE housing_data
ADD property_split_address NvarChar(255);

update housing_data
SET property_split_address = SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress) -1);


ALTER TABLE housing_data
ADD property_split_city NvarChar(255);

update housing_data
SET property_split_city = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress) +1, LEN (PropertyAddress));

SELECT*
FROM housing_data;

-- Another way of splitting the column is by using 'PARSENAME' 

SELECT OwnerAddress
FROM housing_data;

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM housing_data;

ALTER TABLE housing_data
ADD owner_split_address NvarChar(255);

update housing_data
SET owner_split_address = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);


ALTER TABLE housing_data
ADD owner_split_city NvarChar(255);

update housing_data
SET owner_split_city = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);


ALTER TABLE housing_data
ADD owner_split_state NvarChar(255);

update housing_data
SET owner_split_state = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);


SELECT *
FROM housing_data;


---- Change Y and N to Yes and No 'Sold ad Vacant' field.

SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant)
FROM housing_data
GROUP BY SoldAsVacant;


SELECT SoldAsVacant,
	CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM housing_data;

UPDATE housing_data
SET SoldAsVacant = CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END



--- Removing duplicates


WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SaleDate,
				SalePrice,
				LegalReference
				ORDER BY
				UniqueID
				) row_num
FROM housing_data
--Order by ParcelID;
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress


SELECT *
FROM housing_data

WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SaleDate,
				SalePrice,
				LegalReference
				ORDER BY
				UniqueID
				) row_num
FROM housing_data
--Order by ParcelID;
)
DELETE
FROM RowNumCTE
WHERE row_num > 1;
--ORDER BY PropertyAddress




-----Deleting unused columns.

SELECT * 
From housing_data;


ALTER TABLE housing_data
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress;


ALTER TABLE housing_data
DROP COLUMN SaleDate;


































 

















