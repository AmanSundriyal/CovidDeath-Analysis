-- standardize date format
select *
from PortfolioProject2..NashvilleHousing

select SaleDate, CONVERT(date,SaleDate) as SaleDateConverted
from PortfolioProject2..NashvilleHousing


begin transaction

select SaleDate, CONVERT(date,SaleDate)
from PortfolioProject2..NashvilleHousing

alter table PortfolioProject2..NashvilleHousing
ADD SaleDateConverted Date;

update PortfolioProject2..NashvilleHousing
set SaleDateConverted = CONVERT(date,SaleDate);

select SaleDateConverted
from PortfolioProject2..NashvilleHousing

commit transaction

-- populate property address data

select *
from PortfolioProject2..NashvilleHousing
where PropertyAddress is null
order by ParcelID


select n1.ParcelID, n1.PropertyAddress, ISNULL(n1.PropertyAddress, n2.PropertyAddress)
from PortfolioProject2..NashvilleHousing as n1 
join PortfolioProject2..NashvilleHousing as n2 
on n1.ParcelID = n2.ParcelID and n1.[UniqueID ] <> n2.[UniqueID ]

begin transaction

--alter table PortfolioProject2..NashvilleHousing
--ADD UpdatedPropertyAddress Nvarchar(255);

select UpdatedPropertyAddress
from NashvilleHousing

update NashvilleHousing
set UpdatedPropertyAddress = UpdatedPropertyAddress
select n1.ParcelID, n1.PropertyAddress, ISNULL(n1.PropertyAddress, n2.PropertyAddress) as UpdatedPropertyAddress
from PortfolioProject2..NashvilleHousing as n1
join PortfolioProject2..NashvilleHousing as n2
	on n1.ParcelID = n2.ParcelID
	and n1.[UniqueID ] <> n2.[UniqueID ]
where n1.PropertyAddress is null

rollback transaction

-- breaking out Property address into individual columns (Address, city)
select
PARSENAME(replace(PropertyAddress, ',', '.'), 2),
PARSENAME(replace(PropertyAddress, ',', '.'), 1)
from PortfolioProject2..NashvilleHousing

begin transaction

alter table NashvilleHousing
add PropertySplitAddress Nvarchar(255);

update NashvilleHousing
set PropertySplitAddress = PARSENAME(replace(PropertyAddress, ',', '.'), 2)

alter table NashvilleHousing
add PropertySplitCity Nvarchar(255);

update NashvilleHousing
set PropertySplitCity = PARSENAME(replace(PropertyAddress, ',', '.'), 1)

select *
from PortfolioProject2..NashvilleHousing

commit transaction


--breaking out Property address into individual columns (Address, city, state)
select
PARSENAME(replace(OwnerAddress, ',', '.'), 3),
PARSENAME(replace(OwnerAddress, ',', '.'), 2),
PARSENAME(replace(OwnerAddress, ',', '.'), 1)
from PortfolioProject2..NashvilleHousing

begin transaction

alter table NashvilleHousing
add OwnerSplitAddress Nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress, ',', '.'), 3)

alter table NashvilleHousing
add OwnerSplitCity Nvarchar(255);

update NashvilleHousing
set OwnerSplitCity = PARSENAME(replace(OwnerAddress, ',', '.'), 2)

alter table NashvilleHousing
add OwnerSplitState Nvarchar(255);

update NashvilleHousing
set OwnerSplitState = PARSENAME(replace(OwnerAddress, ',', '.'), 1)

select *
from PortfolioProject2..NashvilleHousing

commit transaction

--change Y and N to Yes and No in "Sold as Vacant" field

select distinct SoldAsVacant, COUNT(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by 2


select SoldAsVacant,
CASE
	when SoldAsVacant = 'Y' THEN 'Yes'
	when SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END
from NashvilleHousing

begin transaction

update NashvilleHousing
set SoldAsVacant = CASE
	when SoldAsVacant = 'Y' THEN 'Yes'
	when SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END

commit transaction

--Remove Duplicates

with rownumCTE
AS
(
select *,
ROW_NUMBER() over (partition by ParcelID,
								PropertyAddress,
								SalePrice,SaleDate,
								LegalReference
					order by UniqueID) rownum
from NashvilleHousing
)
Delete 
from rownumCTE
where rownum > 1

 --remove unused columns

 select * 
 from NashvilleHousing

 alter table NashvilleHousing
 DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict, SaleDate
