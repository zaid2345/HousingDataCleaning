/*


Cleaning Data in SQL Queries


*/





select *
from portfolioProject.dbo.NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format


select saleDateconverted , CONVERT(date,saledate) as ConvertedSaleDate
from portfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
set SaleDate = CONVERT(date ,SaleDate)


-- If it doesn't Update properly


Alter table NashvilleHousing
Add saleDateconverted date;

Update NashvilleHousing
set saleDateconverted = CONVERT(date ,SaleDate)



 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data


Select *
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID



select Nvh.ParcelID , Nvh.PropertyAddress , Nvh2.ParcelID,Nvh2.PropertyAddress , ISNULL(Nvh.PropertyAddress,Nvh2.PropertyAddress)
from NashvilleHousing Nvh
join NashvilleHousing Nvh2
	on Nvh.ParcelID = Nvh2.ParcelID
	and Nvh.[UniqueID ] <> Nvh2.[UniqueID ]
where Nvh.PropertyAddress is null


update Nvh
set propertyAddress = ISNULL(Nvh.PropertyAddress,Nvh2.PropertyAddress)
from NashvilleHousing Nvh
join NashvilleHousing Nvh2
	on Nvh.ParcelID = Nvh2.ParcelID
	and Nvh.[UniqueID ] <> Nvh2.[UniqueID ]
where Nvh.PropertyAddress is null


--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) - 1) as address,
SUBSTRING(PropertyAddress,CHARINDEX(',',propertyAddress) + 1, len(PropertyAddress)) as city
from NashvilleHousing


Alter table NashvilleHousing
Add HousAddress nvarchar(255);


Update NashvilleHousing
set HousAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) - 1)



Alter table NashvilleHousing
Add HousCity nvarchar(255);



Update NashvilleHousing
set HousCity = SUBSTRING(PropertyAddress,CHARINDEX(',',propertyAddress) + 1, len(PropertyAddress))

select HousAddress, HousCity
from NashvilleHousing





select OwnerAddress
from NashvilleHousing


select
PARSENAME(REPLACE(OwnerAddress,',','.'),3)
,PARSENAME(REPLACE(OwnerAddress,',','.'),2)
,PARSENAME(REPLACE(OwnerAddress,',','.'),1)
from NashvilleHousing



Alter table NashvilleHousing
Add OwnersplitAddress nvarchar(255);


Update NashvilleHousing
set OwnersplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)


Alter table NashvilleHousing
Add OwnerCity nvarchar(255);


Update NashvilleHousing
set OwnerCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)


Alter table NashvilleHousing
Add Ownerstate nvarchar(255);


Update NashvilleHousing
set Ownerstate = PARSENAME(REPLACE(OwnerAddress,',','.'),1)


select OwnersplitAddress, ownerCity,ownerstate
from NashvilleHousing



--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field



select distinct(SoldAsVacant),count(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by 2



select SoldAsVacant  
,case when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 END
from NashvilleHousing



update NashvilleHousing
set SoldAsVacant =case when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 END






-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates



with RowNums as(
select*,
	ROW_NUMBER() over 
	(partition by parcelID,
				  propertyAddress,
				  saleDate,
				  salePrice,
				  legalreference
				  order by UniqueID) as row_nums
from NashvilleHousing

)
select *
from RowNums
where row_nums > 1





---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns



select * 
from NashvilleHousing



Alter table NashvilleHousing
drop column OwnerAddress , TaxDistrict , SaleDate ,propertyAddress