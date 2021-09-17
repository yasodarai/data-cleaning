SELECT * 
  FROM DataCleaning.dbo.NashvilleHousing;
 
 --standarize date format
SELECT SaleDate, CONVERT(Date,SaleDate)
   FROM DataCleaning.dbo.NashvilleHousing;

   ALTER TABLE NashvilleHousing
   ADD SaleDateConverted Date;

   --changing the data type
  -- UPDATE NashvilleHousing
  -- SET SaleDateConverted=CONVERT(Date,SaleDate);

--populate property address data
--some of them are null 
SELECT *
  FROM DataCleaning.dbo.NashvilleHousing
--  WHERE PropertyAddress is null
  order by ParcelID;

  SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
  FROM DataCleaning.dbo.NashvilleHousing a
  JOIN  DataCleaning.dbo.NashvilleHousing b
  ON a.ParcelID= b.ParcelID
  AND a.[UniqueID ]<>b.[UniqueID ]
  WHERE a.PropertyAddress is null;

  --replacing null in propertyaddress
UPDATE a
SET PropertyAddress =ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM DataCleaning.dbo.NashvilleHousing a
  JOIN  DataCleaning.dbo.NashvilleHousing b
  ON a.ParcelID= b.ParcelID
  AND a.[UniqueID ]<>b.[UniqueID ];
  
  --breaking out address into individual columns (address, city, state)
  SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)as Address,
   SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))as Address
  FROM DataCleaning.dbo.NashvilleHousing;

  ALTER TABLE NashvilleHousing
  ADD PropertySplitAddress Nvarchar(255);

  --splitting the column into two or more columns
  --UPDATE NashvilleHousing
 -- SET PropertySplitAddress =SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1);

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

--UPDATE NashvilleHousing
--SET PropertySplitCity= SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress));

--other way to split the column
--replace comma to period
SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
FROM DataCleaning.dbo.NashvilleHousing;


ALTER TABLE NashvilleHousing
  ADD OwnerSplitAddress Nvarchar(255);

 -- UPDATE NashvilleHousing
  --SET OwnerSplitAddress =PARSENAME(REPLACE(OwnerAddress, ',', '.'),3);

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

--UPDATE NashvilleHousing
--SET OwnerSplitCity= PARSENAME(REPLACE(OwnerAddress, ',', '.'),2);

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

--UPDATE NashvilleHousing
--SET OwnerSplitState= PARSENAME(REPLACE(OwnerAddress, ',', '.'),1);

--Change Y and N to Yes and No
SELECT SoldAsVacant,
CASE 
WHEN SoldASVacant='Y' THEN 'Yes'
WHEN SoldASVacant='N'THEN 'No'
ELSE SoldAsVacant
END 
FROM  DataCleaning.dbo.NashvilleHousing;

--UPDATE NashvilleHousing
--SET SoldAsVacant=CASE 
--WHEN SoldASVacant='Y' THEN 'Yes'
--WHEN SoldASVacant='N'THEN 'No'
--ELSE SoldAsVacant
--END ;

--remove duplication
WITH RowNumCTE AS(
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

From DataCleaning.dbo.NashvilleHousing)

--DELETE 
--From RowNumCTE
--Where row_num > 1;
select *
From RowNumCTE
Where row_num > 1;

ALTER TABLE DataCleaning.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate;