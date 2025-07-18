
--Nashville Housing

select saledate, CONVERT(date,saledate) as preview
from PortfolioProject..nashvillehousing

update nashvillehousing
set SaleDate = CONVERT(date, SaleDate)

alter table nashvillehousing
add saledateconverted date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

select*
from PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate;


--Populate property address data

select a.[UniqueID ],  a.ParcelID, b.ParcelID, a.PropertyAddress, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) 
from PortfolioProject..NashvilleHousing as a
join PortfolioProject..NashvilleHousing as b 
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing as a
join PortfolioProject..NashvilleHousing as b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--breaking out property Address into individual column 

select PropertyAddress
from PortfolioProject..NashvilleHousing

select 
	SUBSTRING(propertyaddress, 1, CHARINDEX(',', PropertyAddress) -1) as address
	, SUBSTRING(propertyaddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress)) as city_town
from PortfolioProject..NashvilleHousing

alter table NashvilleHousing
add propertysplitaddress nvarchar(250);

update NashvilleHousing
set propertysplitaddress = SUBSTRING(propertyaddress, 1, CHARINDEX(',', PropertyAddress) -1) 

alter table NashvilleHousing
add propertysplitcity nvarchar(250);

update NashvilleHousing
set propertysplitcity  = SUBSTRING(propertyaddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress))


----spliting the address by using PARSENAME

select * from PortfolioProject..NashvilleHousing

select PARSENAME(replace(propertyaddress, ',', '.'), 1) as city
,PARSENAME(replace(propertyaddress, ',', '.'), 2) as address,
PARSENAME(replace(propertyaddress, ',', '.'), 3) as state
from PortfolioProject..NashvilleHousing

alter table PortfolioProject.dbo.NashvilleHousing
add ownersplitaddress nvarchar(250);

update PortfolioProject.dbo.NashvilleHousing
set ownersplitaddress = PARSENAME(replace(propertyaddress, ',', '.'), 2)

alter table PortfolioProject.dbo.NashvilleHousing
add ownersplitcity nvarchar(230);

update PortfolioProject.dbo.NashvilleHousing
set ownersplitcity = PARSENAME(replace(propertyaddress, ',', '.'), 1)

alter table PortfolioProject.dbo.NashvilleHousing
add ownersplitstate nvarchar(230);

update PortfolioProject.dbo.NashvilleHousing
set ownersplitstate = PARSENAME(replace(propertyaddress, ',', '.'), 3)


select distinct(SoldAsVacant), COUNT(soldasvacant)
from PortfolioProject..NashvilleHousing
group by SoldAsVacant
order by 2

update PortfolioProject..NashvilleHousing
set SoldAsVacant =
	case when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
	end
from PortfolioProject..NashvilleHousing

select * from PortfolioProject..NashvilleHousing

---Remove duplicates--

-- Step 1: Create a Common Table Expression (CTE) to identify duplicate records
WITH RowNumCTE AS (
    SELECT 
        *,  -- Select all columns
        ROW_NUMBER() OVER (
            PARTITION BY parcelID, propertyaddress, saleprice, saledateconverted  -- Group by these columns
            ORDER BY uniqueid  -- Assign row numbers within each group
        ) AS row_num
    FROM PortfolioProject..NashvilleHousing  -- Source table
)

-- Step 2: Select only the duplicate records (excluding the first occurrence)
SELECT * 
FROM RowNumCTE
WHERE row_num > 1  -- Return only rows identified as duplicates
ORDER BY propertyaddress;  -- Sort the result for easier review


---- deleting columns

select * from PortfolioProject..NashvilleHousing

alter table PortfolioProject..NashvilleHousing
drop column columnname1, columnname2

