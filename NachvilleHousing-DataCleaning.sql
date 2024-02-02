--cleaning our data in sql querises
SELECT *
FROM NashvilleHousingData.dbo.NashvilleHousing

--standardize Data Format

SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM NashvilleHousingData.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted DATE;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

--populate Property Adress data


SELECT *
FROM NashvilleHousingData.dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

--populate Property Adress data


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousingData.dbo.NashvilleHousing AS a
JOIN NashvilleHousingData.dbo.NashvilleHousing AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousingData.dbo.NashvilleHousing AS a
JOIN NashvilleHousingData.dbo.NashvilleHousing AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


--breaking our data into individual columns (address, city, state)


SELECT PropertyAddress
FROM NashvilleHousingData.dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL
--ORDER BY ParcelID


SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS City

FROM NashvilleHousingData.dbo.NashvilleHousing



ALTER TABLE NashvilleHousing
ADD PropertySplitAdress NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAdress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

SELECT *
FROM NashvilleHousingData..NashvilleHousing


--breaking owner address column to do it more useful and readable
--easier way than a substring

SELECT OwnerAddress
FROM NashvilleHousingData..NashvilleHousing


SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM NashvilleHousingData..NashvilleHousing

--updating data in our table about owners address

ALTER TABLE NashvilleHousing
ADD OwnerSplitAdress NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAdress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


SELECT * 
FROM NashvilleHousingData..NashvilleHousing

--change Y and N in "Sold as vacant' field

SELECT DISTINCT (SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousingData..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant
,CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	  WHEN SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant
	  END
FROM NashvilleHousingData..NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	  WHEN SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant
	  END
FROM NashvilleHousingData..NashvilleHousing

--remove duplicates

WITH RowNumCTE AS (
SELECT *, 
ROW_NUMBER() OVER
(PARTITION BY ParcelID,
			  PropertyAddress,
			  SalePrice,
			  SaleDate,
			  LegalReference
			  ORDER BY
				UniqueID) row_num
FROM NashvilleHousingData..NashvilleHousing
)
--ORDER BY ParcelID


--DELETE
--FROM RowNumCTE
--WHERE row_num > 1
--ORDER BY PropertyAddress


SELECT *
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress

--delete Unused columns

SELECT *
FROM NashvilleHousingData..NashvilleHousing

ALTER TABLE NashvilleHousingData.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE NashvilleHousingData.dbo.NashvilleHousing
DROP COLUMN SaleDate







