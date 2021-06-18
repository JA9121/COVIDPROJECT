-- Data Cleaning 

SELECT *
FROM PortfolioProjectJA91.dbo.NashvilleHousing

-- Standardize Date Format

SELECT saledate2, CONVERT(date, saledate)
FROM PortfolioProjectJA91.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET saledate = CONVERT(date, saledate)

ALTER TABLE NashvilleHousing
ADD saledate2 DATE;

UPDATE NashvilleHousing
SET Saledate2 = CONVERT(date, saledate)

-- Populate Property Address Data

SELECT *
FROM PortfolioProjectJA91.dbo.NashvilleHousing
ORDER BY parcelid

SELECT a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress, ISNULL(a.propertyaddress, b.propertyaddress)
FROM PortfolioProjectJA91.dbo.NashvilleHousing a
JOIN PortfolioProjectJA91.dbo.NashvilleHousing b
	ON a.parcelid = b.parcelid
	AND a.[UniqueID] <> b.[uniqueid]
WHERE a.propertyaddress IS NULL

UPDATE a
SET propertyaddress = ISNULL(a.propertyaddress, b.propertyaddress)
FROM PortfolioProjectJA91.dbo.NashvilleHousing a
JOIN PortfolioProjectJA91.dbo.NashvilleHousing b
	ON a.parcelid = b.parcelid
	AND a.[UniqueID] <> b.[uniqueid]
WHERE a.propertyaddress IS NULL

--Breaking Out Address Into Individual Columns (Address, City, State)

SELECT propertyaddress
FROM PortfolioProjectJA91.dbo.NashvilleHousing

SELECT 
SUBSTRING(propertyaddress, 1, CHARINDEX(',',propertyaddress)-1) AS SplitAddress
, SUBSTRING(propertyaddress, CHARINDEX(',',propertyaddress)+1, LEN(propertyaddress)) AS SplitStreetName

FROM PortfolioProjectJA91.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD SplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET SplitAddress = SUBSTRING(propertyaddress, 1, CHARINDEX(',',propertyaddress)-1)

ALTER TABLE NashvilleHousing
ADD SplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET SplitCity = SUBSTRING(propertyaddress, CHARINDEX(',',propertyaddress)+1, LEN(propertyaddress))


SELECT owneraddress
FROM PortfolioProjectJA91.dbo.NashvilleHousing

SELECT
PARSENAME(REPLACE(owneraddress,',','.'),3)
,PARSENAME(REPLACE(owneraddress,',','.'),2)
,PARSENAME(REPLACE(owneraddress,',','.'),1)
FROM PortfolioProjectJA91.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(owneraddress,',','.'),3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(owneraddress,',','.'),2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(owneraddress,',','.'),1)

-- Change Y and N to Yes and No in "Sold as Vacant" Field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProjectJA91.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
,CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	  WHEN SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant
	  END
FROM PortfolioProjectJA91.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	  WHEN SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant
	  END;

--Remove Duplicates

WITH RowNumCTE AS (
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProjectJA91.dbo.NashvilleHousing
)

SELECT *
FROM RowNumCTE
WHERE row_num > 1

-- Delete Unused Columns

SELECT *
FROM PortfolioProjectJA91.dbo.NashvilleHousing

ALTER TABLE PortfolioProjectJA91.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate




