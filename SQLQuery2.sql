-- Standardize date format

SELECT *
INTO NashvilleHousingCopy
FROM NashvilleHousing

ALTER TABLE NashvilleHousingCopy
ADD SaleDateConverted date;

UPDATE NashvilleHousingCopy
SET SaleDateConverted = CONVERT(date,SaleDate)

-- Populate Property Address Data

SELECT *
FROM NashvilleHousingCopy
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousingCopy AS a
JOIN NashvilleHousingCopy AS b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousingCopy AS a
JOIN NashvilleHousingCopy AS b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


-- Breaking Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM NashvilleHousingCopy

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress)) AS Address
FROM NashVilleHousingCopy


ALTER TABLE NashvilleHousingCopy
ADD PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousingCopy
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)

ALTER TABLE NashvilleHousingCopy
ADD PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousingCopy
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress))


SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
,PARSENAME(REPLACE(OwnerAddress,',','.'),2)
,PARSENAME(REPLACE(OwnerAddress,',','.'),3)
FROM NashvilleHousingCopy

ALTER TABLE NashvilleHousingCopy
ADD OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousingCopy
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousingCopy
ADD OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousingCopy
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousingCopy
ADD OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousingCopy
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

-- Change Y and N to Yes and No in 'SoldAsVacant'

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousingCopy
GROUP BY SoldAsVacant

SELECT SoldAsVacant, 
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END AS '123'
FROM NashvilleHousingCopy

UPDATE NashvilleHousingCopy
SET SoldAsVacant = CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END

-- Remove Duplicates

WITH RowNumCTE AS(
SELECT *, 
ROW_NUMBER() OVER(PARTITION BY ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference ORDER BY UniqueID) AS Row_num
FROM NashvilleHousingCopy
--ORDER BY ParcelID
)

SELECT *
INTO NashvilleHousingCopy2
FROM RowNumCTE


-- Delete Unused Columns

SELECT *
FROM NashvilleHousingCopy2

ALTER TABLE NashvilleHousingCopy2
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE NashvilleHousingCopy2
DROP COLUMN SaleDate

ALTER TABLE NashvilleHousingCopy2
DROP COLUMN Row_num
