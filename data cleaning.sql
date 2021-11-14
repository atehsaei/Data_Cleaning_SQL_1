/****** Script for SelectTopNRows command from SSMS  ******/
use PortfolioProject
go



select SaleDate, convert (date, SaleDate) from [dbo].[Nashvillehousing]

  update Nashvillehousing
  set SaleDate  = CONVERT (date, SaleDate)

  -- adding column Sales_Date as SalesDate revised

  alter table [dbo].[Nashvillehousing]
  add Sales_Date date; 

  update Nashvillehousing
  set Sales_Date  = CONVERT (date, SaleDate)

  --dropping Saledate column 

  alter table [dbo].[Nashvillehousing]
drop column [SaleDate]; 

-- fill null property address
select * from [dbo].[Nashvillehousing]
where [PropertyAddress] is null
order by [ParcelID]

--join on parcelid address based on unique ID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from  [dbo].[Nashvillehousing] a
join [dbo].[Nashvillehousing] b
on a.[ParcelID]=b.[ParcelID] 
and a.UniqueID  <> b.UniqueID
where a.PropertyAddress is null

 
-- fill null
update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress) -- here isnull etc. means when
--  a.PropertyAddress is null, fill it with b.PropertyAddress
from  [dbo].[Nashvillehousing] a
join [dbo].[Nashvillehousing] b
on a.[ParcelID]=b.[ParcelID] 
and a.UniqueID  <> b.UniqueID
where a.PropertyAddress is null

-- splitting address columns into: address, city, state:

-- 1) splitting [PropertyAddress] using substring:

select [PropertyAddress]
from [dbo].[Nashvillehousing]

select 
SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING (PropertyAddress,  CHARINDEX(',', PropertyAddress) +1 , len (PropertyAddress)) as city

from [dbo].[Nashvillehousing]

alter table [Nashvillehousing]
add Street_Address nvarchar(500);

update  [Nashvillehousing]
set Street_Address = SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

alter table [Nashvillehousing]
add Property_City nvarchar(500);

update  [Nashvillehousing]
set Property_City = SUBSTRING (PropertyAddress,  CHARINDEX(',', PropertyAddress) +1 , len (PropertyAddress))


-- 2) splitting [OwnerAddress] using PARSEAME:

select 
parsename (replace(OwnerAddress,',','.'),3) as Owner_Street_Address
,parsename (replace(OwnerAddress,',','.'),2) as Owner_City
,parsename (replace(OwnerAddress,',','.'),1) as Owner_State
 from [dbo].[Nashvillehousing]

 alter table [Nashvillehousing]
add Owner_Street_Address nvarchar(500); 

update  [Nashvillehousing]
set Owner_Street_Address = parsename (replace(OwnerAddress,',','.'),3)

alter table [Nashvillehousing]
add Owner_City nvarchar(500);

update  [Nashvillehousing]
set Owner_City = parsename (replace(OwnerAddress,',','.'),2)

alter table [Nashvillehousing]
add Owner_State nvarchar(500);

update  [Nashvillehousing]
set Owner_State = parsename (replace(OwnerAddress,',','.'),1)
from [dbo].[Nashvillehousing]


----- Changing Y, Yes and N, No to 0 and 1 for future machine learning 

select distinct (SoldAsVacant) , count (SoldAsVacant)
from [dbo].[Nashvillehousing]
group by SoldAsVacant
order by 2

select SoldAsVacant
, case when SoldAsVacant = 'Y' then '1'
       when SoldAsVacant = 'Yes' then '1'
	   when SoldAsVacant = 'N' then '0'
	   else '0'
	   end 
from [dbo].[Nashvillehousing]

update [Nashvillehousing]
set SoldAsVacant= case when SoldAsVacant = 'Y' then '1'
       when SoldAsVacant = 'Yes' then '1'
	   when SoldAsVacant = 'N' then '0'
	   else '0'
	   end