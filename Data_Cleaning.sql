/*

Cleaning Data in SQL Queries

*/

Select *
From PortfolioProject.dbo.NashvilleHousing
---------------------------------------------------------
-- Standarized Date Format

Select SaleDate, Convert(Date,SaleDate)
From PortfolioProject.dbo.NashvilleHousing

Update dbo.NashvilleHousing
Set SaleDate = Convert(Date,SaleDate)
Where SaleDate = SaleDate

Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update dbo.NashvilleHousing
Set SaleDateConverted = Convert(Date,SaleDate)

-- Populate Property Adress data

Select *
From NashvilleHousing
--Where PropertyAddress  
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

--Breaking out Adress into Individual Columns (Address, City, Sate)

Select PropertyAddress
From NashvilleHousing
--Where PropertyAddress  
--order by ParcelID

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) As Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) As Address

From NashvilleHousing

Alter Table NashvilleHousing
Add PropertySplitAdress Nvarchar(255);

Update dbo.NashvilleHousing
Set PropertySplitAdress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)

Alter Table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update dbo.NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress))

Select *
From NashvilleHousing


Select OwnerAddress
From NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) 
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From NashvilleHousing

Alter Table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update dbo.NashvilleHousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) 

Alter Table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update dbo.NashvilleHousing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

Alter Table NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update dbo.NashvilleHousing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


Select SoldAsVacant,
Case When SoldAsVacant = 'N' Then 'No'
	 When SoldAsvacant = 'Y' Then 'Yes'
	 Else SoldAsVacant
	 End
From NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = Case When SoldAsVacant = 'N' Then 'No'
	 When SoldAsvacant = 'Y' Then 'Yes'
	 Else SoldAsVacant
	 End

--Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order By 
					UniqueID
					) row_num

From NashvilleHousing
--Order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress

