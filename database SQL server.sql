USE [QLDIENTHOAI]
GO
/****** Object:  FullTextCatalog [FullText_Staff]    Script Date: 06/08/2023 2:17:11 am ******/
CREATE FULLTEXT CATALOG [FullText_Staff] WITH ACCENT_SENSITIVITY = ON
GO
/****** Object:  UserDefinedFunction [dbo].[FN_BestSellingProduct]    Script Date: 06/08/2023 2:17:11 am ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[FN_BestSellingProduct](
@dateStart datetime , 
@dateEnd datetime
)
returns @tb table ([Tên sản phẩm] nvarchar(50) , [Số lượng bán] int , [Giá sản phẩm] decimal)
as
begin
	insert into @tb([Tên sản phẩm] , [Số lượng bán] , [Giá sản phẩm] )
	
select p.name , sum(Quantity) , p.Price  from BILLDETAIL b
join PRODUCTS p on p.ProductID = b.ProductID
join BILL bb on bb.BillID = b.BillID
where bb.CreateDateOfBill between @dateStart and @dateEnd
group by p.name  , p.Price
having sum(Quantity) = 
(select max(tong) from(select   sum(b.Quantity) as tong from BILLDETAIL b
join PRODUCTS p on p.ProductID = b.ProductID
join BILL bb on bb.BillID = b.BillID
where bb.CreateDateOfBill between @dateStart and @dateEnd
group by p.name)as tong)
return;
end
GO
/****** Object:  UserDefinedFunction [dbo].[FN_FilterProductBill]    Script Date: 06/08/2023 2:17:11 am ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create FUNCTION [dbo].[FN_FilterProductBill](
    @startDate DATETIME , 
    @endDate DATETIME
)
returns @tb table (Name nvarchar(50) , Quantity int , Inventory int)
as
BEGIN

insert into @tb(Name  , Quantity  , Inventory )
    SELECT dbo.PRODUCTS.Name , sum(dbo.BILLDETAIL.Quantity), dbo.PRODUCTS.Inventory
    FROM          dbo.BILL INNER JOIN
                  dbo.BILLDETAIL ON dbo.BILL.BillID = dbo.BILLDETAIL.BillID INNER JOIN
                  dbo.PRODUCTS ON dbo.BILLDETAIL.ProductID = dbo.PRODUCTS.ProductID INNER JOIN
                  dbo.BRAND ON dbo.PRODUCTS.BrandID = dbo.BRAND.BrandID INNER JOIN
                  dbo.KINDOFPRODUCT ON dbo.PRODUCTS.KindOfProductID = dbo.KINDOFPRODUCT.KindOfProductID
                  where dbo.BILL.createDateOfBill BETWEEN @startDate AND @endDate
				  group by dbo.PRODUCTS.Name , dbo.PRODUCTS.Inventory
    return;
end
GO
/****** Object:  UserDefinedFunction [dbo].[FN_getBillIMPORT]    Script Date: 06/08/2023 2:17:11 am ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[FN_getBillIMPORT]
(
@dateStart datetime , 
@dateEnd datetime
)
returns @tb table ([Mã hóa đơn] varchar(6) , [Tên sản phẩm] nvarchar(50) , [Số lượng] int , [Giá sản phẩm] decimal , [Tổng tiền] decimal , [Tên công ty] nvarchar(50), [Nhân viên tiếp nhân] nvarchar(50) , [Ngày tạo hóa đơn] datetime)

as
begin 

	insert into @tb ([Mã hóa đơn] , [Tên sản phẩm] ,
	[Số lượng] , [Giá sản phẩm]  , [Tổng tiền]  , [Tên công ty], 
	[Nhân viên tiếp nhân] , [Ngày tạo hóa đơn] )
	SELECT dbo.IMPORT.ImportID, dbo.PRODUCTS.Name,
	dbo.IMPORT_DETAIL.Quantity, dbo.IMPORT_DETAIL.Price, dbo.IMPORT.Total, dbo.SUPPLIER.NameCompany,
	dbo.STAFF.Name , dbo.IMPORT.CreateDateOfBill
	FROM     dbo.IMPORT INNER JOIN
                  dbo.IMPORT_DETAIL ON dbo.IMPORT.ImportID = dbo.IMPORT_DETAIL.ImportID INNER JOIN
                  dbo.SUPPLIER ON dbo.IMPORT.SupplierID = dbo.SUPPLIER.SupplierID INNER JOIN
                  dbo.PRODUCTS ON dbo.IMPORT_DETAIL.ProductID = dbo.PRODUCTS.ProductID INNER JOIN
                  dbo.STAFF ON dbo.IMPORT.Account = dbo.STAFF.Account
				  where dbo.IMPORT.CreateDateOfBill between @dateStart and @dateEnd

return;
end
GO
/****** Object:  UserDefinedFunction [dbo].[FN_InventoryFilter]    Script Date: 06/08/2023 2:17:11 am ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE function [dbo].[FN_InventoryFilter]
(
	@Brand varchar(6) = '', 
	@Kindofproduct varchar(6) = ''
)
returns @table table ([Mã sản phẩm] int , [Tên sản phẩm] nvarchar(50) , [Loại sản phẩm] nvarchar(50) , [Thương hiệu] nvarchar(50) , [giá] decimal , [Số lượng tồn kho] int )

as
begin
	if(@Kindofproduct != '' and @brand != '')
	begin
		insert into @table ([Mã sản phẩm] , [Tên sản phẩm] , [Loại sản phẩm] , [Thương hiệu]  , [giá], [Số lượng tồn kho] )
		SELECT	dbo.PRODUCTS.ProductID , dbo.PRODUCTS.Name , dbo.KINDOFPRODUCT.KName , dbo.BRAND.BName , dbo.PRODUCTS.Price , 
                dbo.PRODUCTS.Inventory 
		FROM    dbo.PRODUCTS
		        INNER JOIN dbo.KINDOFPRODUCT ON dbo.PRODUCTS.KindOfProductID = dbo.KINDOFPRODUCT.KindOfProductID
				INNER JOIN dbo.BRAND ON dbo.BRAND.BrandID = PRODUCTS.BrandID
				where dbo.BRAND.BrandID = @Brand And dbo.KINDOFPRODUCT.KindOfProductID = @Kindofproduct
	return;
	end
	
	RETURN;
end
GO
/****** Object:  UserDefinedFunction [dbo].[FN_InventoryFilterQuantity]    Script Date: 06/08/2023 2:17:11 am ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create function [dbo].[FN_InventoryFilterQuantity]
(
	@quantityStart int,
	@quantityEnd int
)
returns @table table ([Mã sản phẩm] int , [Tên sản phẩm] nvarchar(50) , [Loại sản phẩm] nvarchar(50) , [Thương hiệu] nvarchar(50) , [giá] decimal , [Số lượng tồn kho] int )

as
begin
	
	begin
		insert into @table ([Mã sản phẩm] , [Tên sản phẩm] , [Loại sản phẩm] , [Thương hiệu]  , [giá], [Số lượng tồn kho] )
		SELECT	dbo.PRODUCTS.ProductID , dbo.PRODUCTS.Name , dbo.KINDOFPRODUCT.KName , dbo.BRAND.BName , dbo.PRODUCTS.Price , 
                dbo.PRODUCTS.Inventory 
		FROM    dbo.PRODUCTS
		        INNER JOIN dbo.KINDOFPRODUCT ON dbo.PRODUCTS.KindOfProductID = dbo.KINDOFPRODUCT.KindOfProductID
				INNER JOIN dbo.BRAND ON dbo.BRAND.BrandID = PRODUCTS.BrandID
				where dbo.PRODUCTS.Inventory between @quantityStart and @quantityEnd 
	end
	RETURN;
end
GO
/****** Object:  UserDefinedFunction [dbo].[FN_LittleSellingProduct]    Script Date: 06/08/2023 2:17:11 am ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE function [dbo].[FN_LittleSellingProduct](
@dateStart datetime , 
@dateEnd datetime
)
returns @tb table ([Tên sản phẩm] nvarchar(50) , [Số lượng bán] int , [Giá sản phẩm] decimal)
as
begin
	insert into @tb([Tên sản phẩm] , [Số lượng bán] , [Giá sản phẩm] )
	
select p.name , sum(Quantity) , p.Price  from BILLDETAIL b
join PRODUCTS p on p.ProductID = b.ProductID
join BILL bb on bb.BillID = b.BillID
where bb.CreateDateOfBill between @dateStart and @dateEnd
group by p.name  , p.Price
having sum(Quantity) = 
(select min(tong) from(select   sum(b.Quantity) as tong from BILLDETAIL b
join PRODUCTS p on p.ProductID = b.ProductID
join BILL bb on bb.BillID = b.BillID
where bb.CreateDateOfBill between @dateStart and @dateEnd
group by p.name)as tong)
return;
end
GO
/****** Object:  UserDefinedFunction [dbo].[FN_Profit]    Script Date: 06/08/2023 2:17:11 am ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE function [dbo].[FN_Profit]
(
@dateStart datetime,
@dateEnd datetime
)
returns decimal
as
begin
	declare @profit decimal = 0
	declare @price decimal
	declare @discount decimal
	declare @quantity int
	declare @idbill varchar(6)
	declare @idCheck varchar(6) = ''
	declare CsProfit cursor for
	select b.BillID , Price , Quantity , Discount from bill b 
	join BILLDETAIL bd on bd.BillID  = b.BillID
	where CreateDateOfBill between @dateStart and @dateEnd
	open CsProfit
	FETCH next from CsProfit into @idbill , @price , @quantity , @discount
	while @@FETCH_STATUS =0
	begin
		if(@idbill != @idCheck)
		begin
			set @profit = @profit + ((@price * @quantity) * 30 / 100) - @discount
			set @idCheck = @idbill
		end
		else
		begin
			set @profit = @profit + ((@price * @quantity) * 30 / 100)
		end
	FETCH next from CsProfit into @idbill , @price , @quantity , @discount
	end
	close CsProfit
	deallocate CsProfit
	
	return @profit;
end
GO
/****** Object:  UserDefinedFunction [dbo].[FN_Statistics]    Script Date: 06/08/2023 2:17:11 am ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE function [dbo].[FN_Statistics]
(
	@dateStart datetime , 
	@dateEnd DATETIME
)
RETURNS DECIMAL
As
BEGIN
	declare @Statistics DECIMAL
	select @Statistics =  sum(Total) from BILL
	where CreateDateOfBill BETWEEN @dateStart and @dateEnd
	RETURN @Statistics
END
GO
/****** Object:  Table [dbo].[BILL]    Script Date: 06/08/2023 2:17:11 am ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BILL](
	[BillID] [char](6) NOT NULL,
	[CustomerID] [char](6) NULL,
	[Account] [varchar](30) NULL,
	[Total] [decimal](18, 0) NULL,
	[CreateDateOfBill] [datetime] NULL,
	[Discount] [decimal](18, 0) NULL,
	[Description] [nvarchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[BillID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[BILLDETAIL]    Script Date: 06/08/2023 2:17:11 am ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BILLDETAIL](
	[BillID] [char](6) NOT NULL,
	[ProductID] [int] NOT NULL,
	[Quantity] [int] NOT NULL,
	[Price] [nvarchar](100) NULL,
	[ID] [int] IDENTITY(1,1) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[BillID] ASC,
	[ProductID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[BRAND]    Script Date: 06/08/2023 2:17:11 am ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BRAND](
	[BrandID] [varchar](6) NOT NULL,
	[BName] [nvarchar](50) NOT NULL,
	[BrandDescription] [nvarchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[BrandID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CUSTOMER]    Script Date: 06/08/2023 2:17:11 am ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CUSTOMER](
	[CustomerID] [char](6) NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[Phone] [int] NOT NULL,
	[Address] [nvarchar](50) NOT NULL,
	[Email] [varchar](50) NULL,
	[Description] [nvarchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[CustomerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[IMPORT]    Script Date: 06/08/2023 2:17:11 am ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[IMPORT](
	[ImportID] [varchar](6) NOT NULL,
	[SupplierID] [varchar](6) NOT NULL,
	[Account] [varchar](30) NULL,
	[Total] [decimal](18, 0) NULL,
	[CreateDateOfBill] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[ImportID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[IMPORT_DETAIL]    Script Date: 06/08/2023 2:17:11 am ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[IMPORT_DETAIL](
	[ImportID] [varchar](6) NOT NULL,
	[ProductID] [int] NOT NULL,
	[Quantity] [int] NOT NULL,
	[Price] [decimal](18, 0) NULL,
	[ID] [int] IDENTITY(1,1) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ImportID] ASC,
	[ProductID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[KINDOFPRODUCT]    Script Date: 06/08/2023 2:17:11 am ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[KINDOFPRODUCT](
	[KindOfProductID] [varchar](6) NOT NULL,
	[KName] [nvarchar](50) NOT NULL,
	[KindOfProductDescription] [nvarchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[KindOfProductID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PRODUCTS]    Script Date: 06/08/2023 2:17:11 am ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PRODUCTS](
	[ProductID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[KindOfProductID] [varchar](6) NOT NULL,
	[BrandID] [varchar](6) NOT NULL,
	[DateOfProduction] [datetime] NOT NULL,
	[Guarantee] [int] NOT NULL,
	[Price] [decimal](18, 0) NOT NULL,
	[Description] [nvarchar](100) NULL,
	[Inventory] [int] NULL,
 CONSTRAINT [PK_PRODUCTS] PRIMARY KEY CLUSTERED 
(
	[ProductID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[STAFF]    Script Date: 06/08/2023 2:17:11 am ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[STAFF](
	[Account] [varchar](30) NOT NULL,
	[Password] [varchar](30) NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[Phone] [int] NOT NULL,
	[CCCD] [int] NOT NULL,
	[Address] [nvarchar](50) NOT NULL,
	[Email] [varchar](50) NOT NULL,
	[BirthDay] [datetime] NOT NULL,
	[Role] [nvarchar](50) NOT NULL,
	[Descirption] [nvarchar](100) NULL,
 CONSTRAINT [PK_STAFF] PRIMARY KEY CLUSTERED 
(
	[Account] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SUPPLIER]    Script Date: 06/08/2023 2:17:11 am ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SUPPLIER](
	[SupplierID] [varchar](6) NOT NULL,
	[NameCompany] [nvarchar](50) NOT NULL,
	[Phone] [int] NOT NULL,
	[Address] [nvarchar](50) NOT NULL,
	[Representative] [nvarchar](50) NOT NULL,
	[Email] [varchar](50) NOT NULL,
	[Description] [nvarchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[SupplierID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  UserDefinedFunction [dbo].[FN_InventoryFilterPrice]    Script Date: 06/08/2023 2:17:11 am ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE function [dbo].[FN_InventoryFilterPrice]
(
@Start decimal ,
@End decimal
)
returns table
as
return
(
	SELECT
			dbo.PRODUCTS.ProductID AS [Mã sản phẩm], dbo.PRODUCTS.Name AS [Tên sản phẩm], dbo.KINDOFPRODUCT.KName AS [Loại sản phẩm], dbo.BRAND.BName AS [Thương hiệu], dbo.PRODUCTS.Price AS Giá, 
			dbo.PRODUCTS.Inventory AS [Số lượng trong kho]
	FROM    dbo.PRODUCTS INNER JOIN
			dbo.KINDOFPRODUCT ON dbo.PRODUCTS.KindOfProductID = dbo.KINDOFPRODUCT.KindOfProductID INNER JOIN
			dbo.BRAND ON dbo.PRODUCTS.BrandID = dbo.BRAND.BrandID
			where dbo.PRODUCTS.Price between @Start and @End 
)
GO
/****** Object:  View [dbo].[ViewBillExport]    Script Date: 06/08/2023 2:17:11 am ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create VIEW [dbo].[ViewBillExport] WITH SCHEMABINDING AS
SELECT dbo.BILLDETAIL.ID AS STT, dbo.BILL.BillID AS [Mã hóa đơn], dbo.PRODUCTS.Name AS [Tên sản phẩm], dbo.BILLDETAIL.Price AS Giá, dbo.BILLDETAIL.Quantity AS [Số lượng bán], dbo.BILL.Discount AS [Giảm giá], 
                  dbo.BILL.Total AS [Tổng tiền hóa đơn], dbo.CUSTOMER.Name AS [Tên khách hàng], dbo.STAFF.Name AS [Nhân viên tiếp nhận], dbo.BILL.CreateDateOfBill AS [Ngày bán], dbo.BILL.Description AS [mô tả]
FROM     dbo.BILL INNER JOIN
                  dbo.BILLDETAIL ON dbo.BILL.BillID = dbo.BILLDETAIL.BillID INNER JOIN
                  dbo.CUSTOMER ON dbo.BILL.CustomerID = dbo.CUSTOMER.CustomerID INNER JOIN
                  dbo.PRODUCTS ON dbo.BILLDETAIL.ProductID = dbo.PRODUCTS.ProductID INNER JOIN
                  dbo.STAFF ON dbo.BILL.Account = dbo.STAFF.Account
GO
SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET NUMERIC_ROUNDABORT OFF
GO
/****** Object:  Index [ViewBillExport]    Script Date: 06/08/2023 2:17:11 am ******/
CREATE UNIQUE CLUSTERED INDEX [ViewBillExport] ON [dbo].[ViewBillExport]
(
	[STT] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  View [dbo].[ViewBillImport]    Script Date: 06/08/2023 2:17:11 am ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[ViewBillImport] WITH SCHEMABINDING AS
SELECT dbo.IMPORT_DETAIL.ID AS STT, dbo.IMPORT.ImportID AS [Mã hóa đơn], dbo.PRODUCTS.Name AS [Tên sản phẩm], dbo.IMPORT_DETAIL.Quantity AS [Số lượng], dbo.IMPORT_DETAIL.Price AS Giá, 
                  dbo.IMPORT.Total AS [Tổng tiền hóa đơn], dbo.SUPPLIER.NameCompany AS [Tên công ty], dbo.STAFF.Name AS [Nhân viên tiếp nhân], dbo.IMPORT.CreateDateOfBill AS [Ngày nhập hàng]
FROM     dbo.IMPORT INNER JOIN
                  dbo.IMPORT_DETAIL ON dbo.IMPORT.ImportID = dbo.IMPORT_DETAIL.ImportID INNER JOIN
                  dbo.SUPPLIER ON dbo.IMPORT.SupplierID = dbo.SUPPLIER.SupplierID INNER JOIN
                  dbo.PRODUCTS ON dbo.IMPORT_DETAIL.ProductID = dbo.PRODUCTS.ProductID INNER JOIN
                  dbo.STAFF ON dbo.IMPORT.Account = dbo.STAFF.Account
GO
SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET NUMERIC_ROUNDABORT OFF
GO
/****** Object:  Index [ViewBillImport]    Script Date: 06/08/2023 2:17:11 am ******/
CREATE UNIQUE CLUSTERED INDEX [ViewBillImport] ON [dbo].[ViewBillImport]
(
	[STT] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  View [dbo].[ViewCUSTOMER]    Script Date: 06/08/2023 2:17:11 am ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[ViewCUSTOMER]
WITH SCHEMABINDING 
AS
SELECT TOP (100) PERCENT CustomerID AS [Mã khách hàng], Name AS [Tên khách hàng], Phone AS [Số điiện thoại], Address AS [Địa chỉ], Email, Description AS [Mô tả]
FROM     dbo.CUSTOMER
ORDER BY [Mã khách hàng] DESC
GO
/****** Object:  View [dbo].[ViewInventory]    Script Date: 06/08/2023 2:17:11 am ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create VIEW [dbo].[ViewInventory] WITH SCHEMABINDING AS
SELECT dbo.PRODUCTS.ProductID AS [Mã sản phẩm], dbo.PRODUCTS.Name AS [Tên sản phẩm], dbo.KINDOFPRODUCT.KName AS [Loại sản phẩm], dbo.BRAND.BName AS [Thương hiệu], dbo.PRODUCTS.Price AS Giá, 
                  dbo.PRODUCTS.Inventory AS [Số lượng trong kho]
FROM     dbo.PRODUCTS INNER JOIN
                  dbo.KINDOFPRODUCT ON dbo.PRODUCTS.KindOfProductID = dbo.KINDOFPRODUCT.KindOfProductID INNER JOIN
                  dbo.BRAND ON dbo.PRODUCTS.BrandID = dbo.BRAND.BrandID
GO
SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET NUMERIC_ROUNDABORT OFF
GO
/****** Object:  Index [IX_ViewInventory]    Script Date: 06/08/2023 2:17:11 am ******/
CREATE UNIQUE CLUSTERED INDEX [IX_ViewInventory] ON [dbo].[ViewInventory]
(
	[Mã sản phẩm] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  View [dbo].[ViewPersonallBill]    Script Date: 06/08/2023 2:17:11 am ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create VIEW [dbo].[ViewPersonallBill] WITH SCHEMABINDING AS
SELECT dbo.BILLDETAIL.ID AS STT, dbo.BILL.BillID AS [Mã hóa đơn], dbo.PRODUCTS.Name AS [Tên sản phẩm], dbo.BILLDETAIL.Price AS Giá, dbo.BILLDETAIL.Quantity AS [Số lượng bán], dbo.BILL.Discount AS [Giảm giá], 
                  dbo.BILL.Total AS [Tổng tiền hóa đơn], dbo.CUSTOMER.Name AS [Tên khách hàng], dbo.STAFF.Name AS [Nhân viên tiếp nhận],dbo.STAFF.Account AS [Tài khoản nhân viên], dbo.BILL.CreateDateOfBill AS [Ngày bán], dbo.BILL.Description AS [mô tả]
FROM     dbo.BILL INNER JOIN
                  dbo.BILLDETAIL ON dbo.BILL.BillID = dbo.BILLDETAIL.BillID INNER JOIN
                  dbo.CUSTOMER ON dbo.BILL.CustomerID = dbo.CUSTOMER.CustomerID INNER JOIN
                  dbo.PRODUCTS ON dbo.BILLDETAIL.ProductID = dbo.PRODUCTS.ProductID INNER JOIN
                  dbo.STAFF ON dbo.BILL.Account = dbo.STAFF.Account
GO
SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET NUMERIC_ROUNDABORT OFF
GO
/****** Object:  Index [ViewPersonallBill]    Script Date: 06/08/2023 2:17:11 am ******/
CREATE UNIQUE CLUSTERED INDEX [ViewPersonallBill] ON [dbo].[ViewPersonallBill]
(
	[STT] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  View [dbo].[ViewPRODUCTS]    Script Date: 06/08/2023 2:17:11 am ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[ViewPRODUCTS]
WITH SCHEMABINDING 
AS
SELECT dbo.PRODUCTS.ProductID AS [Mã sản phẩm], dbo.PRODUCTS.Name AS [Tên sản phẩm], dbo.BRAND.BName AS [Thương hiệu], dbo.KINDOFPRODUCT.KName AS [Loại sản phẩm], dbo.PRODUCTS.Price AS Giá, 
                  dbo.PRODUCTS.DateOfProduction AS [Ngày ra mắt], dbo.PRODUCTS.Guarantee AS [Bảo hành], dbo.PRODUCTS.Description AS [Mô tả]
FROM     dbo.PRODUCTS INNER JOIN
                  dbo.KINDOFPRODUCT ON dbo.PRODUCTS.KindOfProductID = dbo.KINDOFPRODUCT.KindOfProductID INNER JOIN
                  dbo.BRAND ON dbo.PRODUCTS.BrandID = dbo.BRAND.BrandID
GO
SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET NUMERIC_ROUNDABORT OFF
GO
/****** Object:  Index [ViewProducts]    Script Date: 06/08/2023 2:17:11 am ******/
CREATE UNIQUE CLUSTERED INDEX [ViewProducts] ON [dbo].[ViewPRODUCTS]
(
	[Mã sản phẩm] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  View [dbo].[ViewSTAFF]    Script Date: 06/08/2023 2:17:11 am ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create VIEW [dbo].[ViewSTAFF] WITH SCHEMABINDING  AS
SELECT Account AS [Tên tài khoản], Password AS [Mật khẩu], Name AS [Họ tên], Phone AS [Số điện thoại], CCCD, Address AS [Địa chỉ], Email, BirthDay AS [Ngày sinh], Role AS [Chức vụ], Descirption AS [Mô tả]
FROM     dbo.STAFF
GO
SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET NUMERIC_ROUNDABORT OFF
GO
/****** Object:  Index [ViewStaff]    Script Date: 06/08/2023 2:17:11 am ******/
CREATE UNIQUE CLUSTERED INDEX [ViewStaff] ON [dbo].[ViewSTAFF]
(
	[Tên tài khoản] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  View [dbo].[ViewSUPPLIER]    Script Date: 06/08/2023 2:17:11 am ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[ViewSUPPLIER]
WITH SCHEMABINDING 
AS
SELECT TOP (100) PERCENT SupplierID AS Mã, NameCompany AS [Tên công ty], Address AS [Địa chỉ], Phone AS [Số điên thoại], Representative AS [Người đại diện], Email, Description AS [Mô tả]
FROM     dbo.SUPPLIER
ORDER BY Mã DESC
GO
INSERT [dbo].[BILL] ([BillID], [CustomerID], [Account], [Total], [CreateDateOfBill], [Discount], [Description]) VALUES (N'HÐ0001', N'KH0021', N'nguyenkhanhson', CAST(53480000 AS Decimal(18, 0)), CAST(N'2023-06-17T04:28:26.993' AS DateTime), CAST(0 AS Decimal(18, 0)), N'')
INSERT [dbo].[BILL] ([BillID], [CustomerID], [Account], [Total], [CreateDateOfBill], [Discount], [Description]) VALUES (N'HÐ0002', N'KH0022', N'nguyenkhanhson', CAST(82320000 AS Decimal(18, 0)), CAST(N'2023-06-17T04:31:07.710' AS DateTime), CAST(1680000 AS Decimal(18, 0)), N'')
INSERT [dbo].[BILL] ([BillID], [CustomerID], [Account], [Total], [CreateDateOfBill], [Discount], [Description]) VALUES (N'HÐ0003', N'KH0019', N'nguyenkhanhson', CAST(114460000 AS Decimal(18, 0)), CAST(N'2023-06-17T17:46:50.013' AS DateTime), CAST(0 AS Decimal(18, 0)), N'')
INSERT [dbo].[BILL] ([BillID], [CustomerID], [Account], [Total], [CreateDateOfBill], [Discount], [Description]) VALUES (N'HÐ0004', N'KH0006', N'nguyenkhanhson', CAST(220136400 AS Decimal(18, 0)), CAST(N'2023-06-17T18:17:23.530' AS DateTime), CAST(2223600 AS Decimal(18, 0)), N'')
INSERT [dbo].[BILL] ([BillID], [CustomerID], [Account], [Total], [CreateDateOfBill], [Discount], [Description]) VALUES (N'HÐ0005', N'KH0018', N'nguyenkhanhson', CAST(28000000 AS Decimal(18, 0)), CAST(N'2023-06-17T18:18:07.270' AS DateTime), CAST(0 AS Decimal(18, 0)), N'')
INSERT [dbo].[BILL] ([BillID], [CustomerID], [Account], [Total], [CreateDateOfBill], [Discount], [Description]) VALUES (N'HÐ0006', N'KH0016', N'nguyenkhanhson', CAST(24990000 AS Decimal(18, 0)), CAST(N'2023-06-17T18:18:18.850' AS DateTime), CAST(0 AS Decimal(18, 0)), N'')
INSERT [dbo].[BILL] ([BillID], [CustomerID], [Account], [Total], [CreateDateOfBill], [Discount], [Description]) VALUES (N'HÐ0007', N'KH0018', N'nguyenkhanhson', CAST(115120000 AS Decimal(18, 0)), CAST(N'2023-06-17T23:41:00.427' AS DateTime), CAST(0 AS Decimal(18, 0)), N'')
INSERT [dbo].[BILL] ([BillID], [CustomerID], [Account], [Total], [CreateDateOfBill], [Discount], [Description]) VALUES (N'HÐ0008', N'KH0017', N'nguyenkhanhson', CAST(62270000 AS Decimal(18, 0)), CAST(N'2023-06-18T15:28:19.407' AS DateTime), CAST(0 AS Decimal(18, 0)), N'')
INSERT [dbo].[BILL] ([BillID], [CustomerID], [Account], [Total], [CreateDateOfBill], [Discount], [Description]) VALUES (N'HÐ0009', N'KH0018', N'nguyenkhanhson', CAST(36980000 AS Decimal(18, 0)), CAST(N'2023-06-18T16:43:21.563' AS DateTime), CAST(0 AS Decimal(18, 0)), N'')
INSERT [dbo].[BILL] ([BillID], [CustomerID], [Account], [Total], [CreateDateOfBill], [Discount], [Description]) VALUES (N'HÐ0010', N'KH0016', N'nguyenkhanhson', CAST(99460000 AS Decimal(18, 0)), CAST(N'2023-06-18T16:48:50.043' AS DateTime), CAST(0 AS Decimal(18, 0)), N'')
INSERT [dbo].[BILL] ([BillID], [CustomerID], [Account], [Total], [CreateDateOfBill], [Discount], [Description]) VALUES (N'HÐ0011', N'KH0016', N'nguyenkhanhson', CAST(15490000 AS Decimal(18, 0)), CAST(N'2023-06-18T16:49:38.057' AS DateTime), CAST(0 AS Decimal(18, 0)), N'')
INSERT [dbo].[BILL] ([BillID], [CustomerID], [Account], [Total], [CreateDateOfBill], [Discount], [Description]) VALUES (N'HÐ0012', N'KH0013', N'nguyenkhanhson', CAST(492480000 AS Decimal(18, 0)), CAST(N'2023-06-18T23:41:28.977' AS DateTime), CAST(0 AS Decimal(18, 0)), N'')
INSERT [dbo].[BILL] ([BillID], [CustomerID], [Account], [Total], [CreateDateOfBill], [Discount], [Description]) VALUES (N'HÐ0013', N'KH0009', N'nguyenkhanhson', CAST(28000000 AS Decimal(18, 0)), CAST(N'2023-06-19T00:05:14.007' AS DateTime), CAST(0 AS Decimal(18, 0)), N'')
INSERT [dbo].[BILL] ([BillID], [CustomerID], [Account], [Total], [CreateDateOfBill], [Discount], [Description]) VALUES (N'HÐ0014', N'KH0018', N'nguyenkhanhson', CAST(62396600 AS Decimal(18, 0)), CAST(N'2023-06-19T00:06:28.957' AS DateTime), CAST(1273400 AS Decimal(18, 0)), N'')
INSERT [dbo].[BILL] ([BillID], [CustomerID], [Account], [Total], [CreateDateOfBill], [Discount], [Description]) VALUES (N'HÐ0015', N'KH0014', N'nguyenkhanhson', CAST(22990000 AS Decimal(18, 0)), CAST(N'2023-06-19T00:56:29.610' AS DateTime), CAST(0 AS Decimal(18, 0)), N'')
INSERT [dbo].[BILL] ([BillID], [CustomerID], [Account], [Total], [CreateDateOfBill], [Discount], [Description]) VALUES (N'HÐ0016', N'KH0013', N'nguyenkhanhson', CAST(107270800 AS Decimal(18, 0)), CAST(N'2023-06-19T00:57:23.960' AS DateTime), CAST(2189200 AS Decimal(18, 0)), N'')
INSERT [dbo].[BILL] ([BillID], [CustomerID], [Account], [Total], [CreateDateOfBill], [Discount], [Description]) VALUES (N'HÐ0017', N'KH0016', N'nguyenkhanhson', CAST(138294660 AS Decimal(18, 0)), CAST(N'2023-06-19T00:58:45.360' AS DateTime), CAST(2822340 AS Decimal(18, 0)), N'2')
INSERT [dbo].[BILL] ([BillID], [CustomerID], [Account], [Total], [CreateDateOfBill], [Discount], [Description]) VALUES (N'HÐ0018', N'KH0009', N'sontruong', CAST(225929200 AS Decimal(18, 0)), CAST(N'2023-06-19T01:12:21.017' AS DateTime), CAST(4610800 AS Decimal(18, 0)), N'')
INSERT [dbo].[BILL] ([BillID], [CustomerID], [Account], [Total], [CreateDateOfBill], [Discount], [Description]) VALUES (N'HÐ0019', N'KH0019', N'sontruong', CAST(28000000 AS Decimal(18, 0)), CAST(N'2023-06-19T01:12:34.703' AS DateTime), CAST(0 AS Decimal(18, 0)), N'')
INSERT [dbo].[BILL] ([BillID], [CustomerID], [Account], [Total], [CreateDateOfBill], [Discount], [Description]) VALUES (N'HÐ0020', N'KH0013', N'nguyenkhanhson', CAST(261838890 AS Decimal(18, 0)), CAST(N'2023-06-19T01:27:02.920' AS DateTime), CAST(8098110 AS Decimal(18, 0)), N'')
INSERT [dbo].[BILL] ([BillID], [CustomerID], [Account], [Total], [CreateDateOfBill], [Discount], [Description]) VALUES (N'HÐ0021', N'KH0022', N'nguyenkhanhson', CAST(18990000 AS Decimal(18, 0)), CAST(N'2023-06-19T20:28:41.173' AS DateTime), CAST(0 AS Decimal(18, 0)), N'')
INSERT [dbo].[BILL] ([BillID], [CustomerID], [Account], [Total], [CreateDateOfBill], [Discount], [Description]) VALUES (N'HÐ0022', N'KH0017', N'nguyenkhanhson', CAST(56000000 AS Decimal(18, 0)), CAST(N'2023-06-19T20:28:59.653' AS DateTime), CAST(0 AS Decimal(18, 0)), N'')
INSERT [dbo].[BILL] ([BillID], [CustomerID], [Account], [Total], [CreateDateOfBill], [Discount], [Description]) VALUES (N'HÐ0023', N'KH0014', N'nguyenkhanhson', CAST(226328160 AS Decimal(18, 0)), CAST(N'2023-06-21T01:55:05.810' AS DateTime), CAST(6999840 AS Decimal(18, 0)), N'')
INSERT [dbo].[BILL] ([BillID], [CustomerID], [Account], [Total], [CreateDateOfBill], [Discount], [Description]) VALUES (N'HÐ0024', N'KH0018', N'nguyenkhanhson', CAST(287876600 AS Decimal(18, 0)), CAST(N'2023-06-22T00:12:55.533' AS DateTime), CAST(8903400 AS Decimal(18, 0)), N'')
INSERT [dbo].[BILL] ([BillID], [CustomerID], [Account], [Total], [CreateDateOfBill], [Discount], [Description]) VALUES (N'HÐ0025', N'KH0006', N'nguyenkhanhson', CAST(15490000 AS Decimal(18, 0)), CAST(N'2023-06-22T00:13:18.870' AS DateTime), CAST(0 AS Decimal(18, 0)), N'')
INSERT [dbo].[BILL] ([BillID], [CustomerID], [Account], [Total], [CreateDateOfBill], [Discount], [Description]) VALUES (N'HÐ0026', N'KH0005', N'nguyenkhanhson', CAST(3990000 AS Decimal(18, 0)), CAST(N'2023-06-22T00:20:33.787' AS DateTime), CAST(0 AS Decimal(18, 0)), N'')
INSERT [dbo].[BILL] ([BillID], [CustomerID], [Account], [Total], [CreateDateOfBill], [Discount], [Description]) VALUES (N'HÐ0027', N'KH0021', N'nguyenkhanhson', CAST(25490000 AS Decimal(18, 0)), CAST(N'2023-06-22T00:35:07.530' AS DateTime), CAST(0 AS Decimal(18, 0)), N'')
INSERT [dbo].[BILL] ([BillID], [CustomerID], [Account], [Total], [CreateDateOfBill], [Discount], [Description]) VALUES (N'HÐ0028', N'KH0016', N'nguyenkhanhson', CAST(11490000 AS Decimal(18, 0)), CAST(N'2023-06-23T21:12:16.000' AS DateTime), CAST(0 AS Decimal(18, 0)), N'')
INSERT [dbo].[BILL] ([BillID], [CustomerID], [Account], [Total], [CreateDateOfBill], [Discount], [Description]) VALUES (N'HÐ0029', N'KH0007', N'nguyenkhanhson', CAST(31280000 AS Decimal(18, 0)), CAST(N'2023-06-23T21:12:37.653' AS DateTime), CAST(0 AS Decimal(18, 0)), N'')
INSERT [dbo].[BILL] ([BillID], [CustomerID], [Account], [Total], [CreateDateOfBill], [Discount], [Description]) VALUES (N'HÐ0030', N'KH0004', N'nguyenkhanhson', CAST(28000000 AS Decimal(18, 0)), CAST(N'2023-06-23T21:13:20.170' AS DateTime), CAST(0 AS Decimal(18, 0)), N'')
INSERT [dbo].[BILL] ([BillID], [CustomerID], [Account], [Total], [CreateDateOfBill], [Discount], [Description]) VALUES (N'HÐ0031', N'KH0005', N'nguyenkhanhson', CAST(42290000 AS Decimal(18, 0)), CAST(N'2023-06-25T15:59:07.270' AS DateTime), CAST(0 AS Decimal(18, 0)), N'')
INSERT [dbo].[BILL] ([BillID], [CustomerID], [Account], [Total], [CreateDateOfBill], [Discount], [Description]) VALUES (N'HÐ0032', N'KH0020', N'nguyenkhanhson', CAST(136900000 AS Decimal(18, 0)), CAST(N'2023-06-25T15:59:35.270' AS DateTime), CAST(0 AS Decimal(18, 0)), N'')
INSERT [dbo].[BILL] ([BillID], [CustomerID], [Account], [Total], [CreateDateOfBill], [Discount], [Description]) VALUES (N'HÐ0033', N'KH0018', N'nguyenkhanhson', CAST(461500500 AS Decimal(18, 0)), CAST(N'2023-06-26T03:22:08.923' AS DateTime), CAST(24289500 AS Decimal(18, 0)), N'')
INSERT [dbo].[BILL] ([BillID], [CustomerID], [Account], [Total], [CreateDateOfBill], [Discount], [Description]) VALUES (N'HÐ0034', N'KH0015', N'nguyenkhanhson', CAST(82750220 AS Decimal(18, 0)), CAST(N'2023-06-26T03:22:51.397' AS DateTime), CAST(1688780 AS Decimal(18, 0)), N'')
INSERT [dbo].[BILL] ([BillID], [CustomerID], [Account], [Total], [CreateDateOfBill], [Discount], [Description]) VALUES (N'HÐ0035', N'KH0008', N'nguyenkhanhson', CAST(71853210 AS Decimal(18, 0)), CAST(N'2023-06-27T01:13:07.910' AS DateTime), CAST(725790 AS Decimal(18, 0)), N'')
INSERT [dbo].[BILL] ([BillID], [CustomerID], [Account], [Total], [CreateDateOfBill], [Discount], [Description]) VALUES (N'HÐ0036', N'KH0006', N'nguyenkhanhson', CAST(649879800 AS Decimal(18, 0)), CAST(N'2023-06-27T01:15:15.840' AS DateTime), CAST(34204200 AS Decimal(18, 0)), N'')
INSERT [dbo].[BILL] ([BillID], [CustomerID], [Account], [Total], [CreateDateOfBill], [Discount], [Description]) VALUES (N'HÐ0037', N'KH0017', N'nguyenkhanhson', CAST(537237350 AS Decimal(18, 0)), CAST(N'2023-06-29T02:00:02.820' AS DateTime), CAST(28275650 AS Decimal(18, 0)), N'')
INSERT [dbo].[BILL] ([BillID], [CustomerID], [Account], [Total], [CreateDateOfBill], [Discount], [Description]) VALUES (N'HÐ0038', N'KH0005', N'nguyenkhanhson', CAST(779487350 AS Decimal(18, 0)), CAST(N'2023-06-29T02:00:56.143' AS DateTime), CAST(41025650 AS Decimal(18, 0)), N'')
INSERT [dbo].[BILL] ([BillID], [CustomerID], [Account], [Total], [CreateDateOfBill], [Discount], [Description]) VALUES (N'HÐ0039', N'KH0015', N'nguyenkhanhson', CAST(568280000 AS Decimal(18, 0)), CAST(N'2023-06-29T02:02:13.713' AS DateTime), CAST(0 AS Decimal(18, 0)), N'')
INSERT [dbo].[BILL] ([BillID], [CustomerID], [Account], [Total], [CreateDateOfBill], [Discount], [Description]) VALUES (N'HÐ0040', N'KH0021', N'nguyenkhanhson', CAST(36990000 AS Decimal(18, 0)), CAST(N'2023-07-01T17:40:32.097' AS DateTime), CAST(0 AS Decimal(18, 0)), N'')
INSERT [dbo].[BILL] ([BillID], [CustomerID], [Account], [Total], [CreateDateOfBill], [Discount], [Description]) VALUES (N'HÐ0041', N'KH0019', N'nguyenkhanhson', CAST(685023700 AS Decimal(18, 0)), CAST(N'2023-07-01T17:42:33.473' AS DateTime), CAST(21186300 AS Decimal(18, 0)), N'')
INSERT [dbo].[BILL] ([BillID], [CustomerID], [Account], [Total], [CreateDateOfBill], [Discount], [Description]) VALUES (N'HÐ0042', N'KH0006', N'nguyenkhanhson', CAST(334504500 AS Decimal(18, 0)), CAST(N'2023-07-01T17:43:20.610' AS DateTime), CAST(10345500 AS Decimal(18, 0)), N'')
INSERT [dbo].[BILL] ([BillID], [CustomerID], [Account], [Total], [CreateDateOfBill], [Discount], [Description]) VALUES (N'HÐ0043', N'KH0017', N'nguyenkhanhson', CAST(287380000 AS Decimal(18, 0)), CAST(N'2023-07-02T05:34:59.023' AS DateTime), CAST(0 AS Decimal(18, 0)), N'')
INSERT [dbo].[BILL] ([BillID], [CustomerID], [Account], [Total], [CreateDateOfBill], [Discount], [Description]) VALUES (N'HÐ0044', N'KH0022', N'nguyenkhanhson', CAST(36990000 AS Decimal(18, 0)), CAST(N'2023-07-02T05:37:10.880' AS DateTime), CAST(0 AS Decimal(18, 0)), N'')
INSERT [dbo].[BILL] ([BillID], [CustomerID], [Account], [Total], [CreateDateOfBill], [Discount], [Description]) VALUES (N'HÐ0045', N'KH0004', N'nguyenkhanhson', CAST(709729600 AS Decimal(18, 0)), CAST(N'2023-07-02T05:39:55.757' AS DateTime), CAST(21950400 AS Decimal(18, 0)), N'')
INSERT [dbo].[BILL] ([BillID], [CustomerID], [Account], [Total], [CreateDateOfBill], [Discount], [Description]) VALUES (N'HÐ0046', N'KH0020', N'nguyenkhanhson', CAST(370879500 AS Decimal(18, 0)), CAST(N'2023-07-05T08:28:03.723' AS DateTime), CAST(11470500 AS Decimal(18, 0)), N'')
INSERT [dbo].[BILL] ([BillID], [CustomerID], [Account], [Total], [CreateDateOfBill], [Discount], [Description]) VALUES (N'HÐ0047', N'KH0018', N'nguyenkhanhson', CAST(253558000 AS Decimal(18, 0)), CAST(N'2023-07-05T08:28:26.797' AS DateTime), CAST(7842000 AS Decimal(18, 0)), N'')
INSERT [dbo].[BILL] ([BillID], [CustomerID], [Account], [Total], [CreateDateOfBill], [Discount], [Description]) VALUES (N'HÐ0048', N'KH0011', N'nguyenkhanhson', CAST(77970000 AS Decimal(18, 0)), CAST(N'2023-07-06T02:36:29.167' AS DateTime), CAST(0 AS Decimal(18, 0)), N'')
INSERT [dbo].[BILL] ([BillID], [CustomerID], [Account], [Total], [CreateDateOfBill], [Discount], [Description]) VALUES (N'HÐ0049', N'KH0006', N'nguyenkhanhson', CAST(99960000 AS Decimal(18, 0)), CAST(N'2023-07-06T02:36:43.687' AS DateTime), CAST(0 AS Decimal(18, 0)), N'')
INSERT [dbo].[BILL] ([BillID], [CustomerID], [Account], [Total], [CreateDateOfBill], [Discount], [Description]) VALUES (N'HÐ0050', N'KH0018', N'nguyenkhanhson', CAST(25490000 AS Decimal(18, 0)), CAST(N'2023-07-06T02:36:58.343' AS DateTime), CAST(0 AS Decimal(18, 0)), N'')
INSERT [dbo].[BILL] ([BillID], [CustomerID], [Account], [Total], [CreateDateOfBill], [Discount], [Description]) VALUES (N'HÐ0051', N'KH0013', N'nguyenkhanhson', CAST(470062000 AS Decimal(18, 0)), CAST(N'2023-07-07T11:36:25.053' AS DateTime), CAST(14538000 AS Decimal(18, 0)), N'')
INSERT [dbo].[BILL] ([BillID], [CustomerID], [Account], [Total], [CreateDateOfBill], [Discount], [Description]) VALUES (N'HÐ0052', N'KH0009', N'nguyenkhanhson', CAST(298009800 AS Decimal(18, 0)), CAST(N'2023-07-07T11:38:22.970' AS DateTime), CAST(3010200 AS Decimal(18, 0)), N'')
INSERT [dbo].[BILL] ([BillID], [CustomerID], [Account], [Total], [CreateDateOfBill], [Discount], [Description]) VALUES (N'HÐ0053', N'KH0015', N'nguyenkhanhson', CAST(641550000 AS Decimal(18, 0)), CAST(N'2023-07-19T19:50:40.580' AS DateTime), CAST(0 AS Decimal(18, 0)), N'')
GO
SET IDENTITY_INSERT [dbo].[BILLDETAIL] ON 

INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0001', 2, 1, N'27490000', 72)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0001', 5, 1, N'25990000', 71)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0002', 1, 3, N'28000000', 73)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0003', 2, 1, N'27490000', 75)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0003', 3, 1, N'22990000', 74)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0003', 7, 1, N'36990000', 76)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0003', 12, 1, N'26990000', 77)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0004', 10, 3, N'9450000', 78)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0004', 12, 3, N'26990000', 79)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0004', 13, 3, N'18990000', 81)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0004', 29, 3, N'18690000', 80)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0005', 1, 1, N'28000000', 82)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0006', 9, 1, N'24990000', 83)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0007', 10, 1, N'9450000', 84)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0007', 29, 1, N'18690000', 85)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0007', 33, 1, N'17990000', 86)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0007', 35, 1, N'68990000', 87)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0008', 21, 1, N'15490000', 88)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0008', 28, 1, N'27290000', 89)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0008', 37, 1, N'19490000', 90)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0009', 13, 1, N'18990000', 91)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0009', 33, 1, N'17990000', 92)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0010', 2, 1, N'27490000', 95)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0010', 3, 2, N'22990000', 93)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0010', 5, 1, N'25990000', 94)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0011', 21, 1, N'15490000', 96)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0012', 9, 3, N'24990000', 97)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0012', 27, 3, N'23190000', 100)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0012', 34, 3, N'46990000', 98)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0012', 35, 3, N'68990000', 99)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0013', 1, 1, N'28000000', 101)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0014', 12, 1, N'26990000', 102)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0014', 29, 1, N'18690000', 103)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0014', 33, 1, N'17990000', 104)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0015', 3, 1, N'22990000', 105)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0016', 10, 2, N'9450000', 106)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0016', 28, 2, N'27290000', 108)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0016', 33, 2, N'17990000', 107)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0017', 10, 3, N'9450000', 109)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0017', 30, 3, N'18999000', 111)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0017', 40, 3, N'18590000', 110)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0018', 13, 2, N'18990000', 112)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0018', 28, 2, N'27290000', 113)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0018', 35, 2, N'68990000', 114)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0019', 1, 1, N'28000000', 115)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0020', 1, 3, N'28000000', 119)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0020', 2, 3, N'27490000', 116)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0020', 21, 3, N'15490000', 118)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0020', 30, 3, N'18999000', 117)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0021', 13, 1, N'18990000', 120)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0022', 1, 2, N'28000000', 121)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0023', 11, 3, N'11490000', 122)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0023', 26, 2, N'28900000', 124)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0023', 29, 3, N'18690000', 125)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0023', 35, 1, N'68990000', 126)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0023', 39, 2, N'7999000', 123)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0024', 3, 5, N'22990000', 127)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0024', 9, 4, N'24990000', 128)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0024', 28, 3, N'27290000', 129)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0025', 21, 1, N'15490000', 130)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0026', 17, 1, N'3990000', 131)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0027', 4, 1, N'25490000', 132)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0028', 11, 1, N'11490000', 133)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0029', 17, 1, N'3990000', 135)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0029', 28, 1, N'27290000', 134)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0030', 1, 1, N'28000000', 136)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0031', 26, 1, N'28900000', 137)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0031', 36, 1, N'13390000', 138)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0032', 4, 5, N'25490000', 139)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0032', 10, 1, N'9450000', 140)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0033', 2, 3, N'27490000', 141)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0033', 17, 3, N'3990000', 145)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0033', 28, 3, N'27290000', 142)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0033', 29, 3, N'18690000', 143)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0033', 33, 3, N'17990000', 146)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0033', 34, 3, N'46990000', 144)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0033', 37, 3, N'19490000', 147)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0034', 19, 1, N'6590000', 148)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0034', 20, 5, N'8190000', 149)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0034', 26, 1, N'28900000', 150)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0034', 39, 1, N'7999000', 151)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0035', 12, 1, N'26990000', 152)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0035', 15, 1, N'8690000', 155)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0035', 26, 1, N'28900000', 153)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0035', 39, 1, N'7999000', 154)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0036', 3, 5, N'22990000', 156)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0036', 5, 5, N'25990000', 161)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0036', 19, 7, N'6590000', 160)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0036', 21, 4, N'15490000', 158)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0036', 27, 6, N'23190000', 159)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0036', 30, 6, N'18999000', 157)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0036', 37, 4, N'19490000', 162)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0037', 28, 5, N'27290000', 163)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0037', 29, 4, N'18690000', 164)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0037', 30, 7, N'18999000', 167)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0037', 34, 3, N'46990000', 165)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0037', 36, 6, N'13390000', 166)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0038', 26, 6, N'28900000', 168)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0038', 27, 5, N'23190000', 172)
GO
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0038', 30, 7, N'18999000', 171)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0038', 32, 4, N'28190000', 170)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0038', 34, 4, N'46990000', 173)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0038', 37, 5, N'19490000', 169)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0039', 1, 5, N'28000000', 175)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0039', 2, 4, N'27490000', 174)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0039', 5, 6, N'25990000', 176)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0039', 11, 5, N'11490000', 177)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0039', 14, 7, N'14990000', 178)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0040', 7, 1, N'36990000', 179)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0041', 1, 4, N'28000000', 180)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0041', 3, 4, N'22990000', 184)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0041', 7, 5, N'36990000', 181)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0041', 11, 4, N'11490000', 182)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0041', 12, 5, N'26990000', 186)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0041', 15, 5, N'8690000', 183)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0041', 21, 6, N'15490000', 185)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0042', 3, 15, N'22990000', 187)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0043', 1, 3, N'28000000', 188)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0043', 8, 3, N'20590000', 190)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0043', 10, 4, N'9450000', 191)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0043', 19, 4, N'6590000', 189)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0043', 21, 5, N'15490000', 192)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0044', 7, 1, N'36990000', 193)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0045', 2, 8, N'27490000', 195)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0045', 5, 8, N'25990000', 196)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0045', 13, 8, N'18990000', 194)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0045', 16, 8, N'18990000', 197)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0046', 4, 15, N'25490000', 198)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0047', 9, 5, N'24990000', 200)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0047', 28, 5, N'27290000', 199)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0048', 5, 3, N'25990000', 201)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0049', 9, 4, N'24990000', 202)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0050', 4, 1, N'25490000', 203)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0051', 1, 5, N'28000000', 204)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0051', 4, 5, N'25490000', 205)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0051', 10, 5, N'9450000', 206)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0051', 14, 5, N'14990000', 207)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0051', 16, 5, N'18990000', 208)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0052', 12, 6, N'26990000', 210)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0052', 14, 6, N'14990000', 209)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0052', 20, 6, N'8190000', 211)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0053', 10, 5, N'9450000', 212)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0053', 28, 5, N'27290000', 214)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0053', 34, 5, N'46990000', 213)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0053', 38, 5, N'25990000', 215)
INSERT [dbo].[BILLDETAIL] ([BillID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0053', 40, 5, N'18590000', 216)
SET IDENTITY_INSERT [dbo].[BILLDETAIL] OFF
GO
INSERT [dbo].[BRAND] ([BrandID], [BName], [BrandDescription]) VALUES (N'TH0001', N'Apple', N'








')
INSERT [dbo].[BRAND] ([BrandID], [BName], [BrandDescription]) VALUES (N'TH0002', N'Samsung', N'









')
INSERT [dbo].[BRAND] ([BrandID], [BName], [BrandDescription]) VALUES (N'TH0003', N'Oppo', N'








')
INSERT [dbo].[BRAND] ([BrandID], [BName], [BrandDescription]) VALUES (N'TH0004', N'IPad ', N'








')
INSERT [dbo].[BRAND] ([BrandID], [BName], [BrandDescription]) VALUES (N'TH0005', N'Xiaomi', N'...')
INSERT [dbo].[BRAND] ([BrandID], [BName], [BrandDescription]) VALUES (N'TH0006', N'Redmi', N'...')
INSERT [dbo].[BRAND] ([BrandID], [BName], [BrandDescription]) VALUES (N'TH0007', N'Huawei', N'...')
INSERT [dbo].[BRAND] ([BrandID], [BName], [BrandDescription]) VALUES (N'TH0008', N'1', N'...')
GO
INSERT [dbo].[CUSTOMER] ([CustomerID], [Name], [Phone], [Address], [Email], [Description]) VALUES (N'KH0002', N'Nguyễn Khánh Sơn', 943217, N'Hà Tĩnh', N'nguyenkhanhsonzero@gmail.com', N'dggvhjhgfgf
')
INSERT [dbo].[CUSTOMER] ([CustomerID], [Name], [Phone], [Address], [Email], [Description]) VALUES (N'KH0004', N'Nguyễn Văn A', 2939390, N'Hà Nội', N'info@gmail.com', N'

')
INSERT [dbo].[CUSTOMER] ([CustomerID], [Name], [Phone], [Address], [Email], [Description]) VALUES (N'KH0005', N'Nguyễn Thị Huỳnh Như', 3848303, N'Tp Hồ Chí Minh', N'info@gmail.com', N'')
INSERT [dbo].[CUSTOMER] ([CustomerID], [Name], [Phone], [Address], [Email], [Description]) VALUES (N'KH0006', N'Nguyễn Xuân Thành', 393938833, N'Hà Tĩnh', N'info@gmai.com', N'')
INSERT [dbo].[CUSTOMER] ([CustomerID], [Name], [Phone], [Address], [Email], [Description]) VALUES (N'KH0007', N'Trần Khánh Như', 94993302, N'Nghệ An', N'Nhu@gmai.com', N'')
INSERT [dbo].[CUSTOMER] ([CustomerID], [Name], [Phone], [Address], [Email], [Description]) VALUES (N'KH0008', N'Võ Tá Khánh', 303949492, N'Hà Tĩnh', N'Khanh@gmail.com', N'')
INSERT [dbo].[CUSTOMER] ([CustomerID], [Name], [Phone], [Address], [Email], [Description]) VALUES (N'KH0009', N'Bùi Thị Khánh Huyền', 93948939, N'Nghệ An', N'Huyen@gmail.com', N'')
INSERT [dbo].[CUSTOMER] ([CustomerID], [Name], [Phone], [Address], [Email], [Description]) VALUES (N'KH0011', N'Hoàng Văn Nam', 888888963, N'Vinh', N'', N'')
INSERT [dbo].[CUSTOMER] ([CustomerID], [Name], [Phone], [Address], [Email], [Description]) VALUES (N'KH0012', N'Nguyễn Văn Huỳnh', 993939392, N'Hà tĩnh', N'', N'')
INSERT [dbo].[CUSTOMER] ([CustomerID], [Name], [Phone], [Address], [Email], [Description]) VALUES (N'KH0013', N'Huỳnh Tấn Sang', 9939584, N'TP Hồ Chí Minh', N'tansang@gmail.com', N'Khách hàng đặc biết')
INSERT [dbo].[CUSTOMER] ([CustomerID], [Name], [Phone], [Address], [Email], [Description]) VALUES (N'KH0014', N'Nguyễn Thị Khánh Huyền', 83959493, N'Hà Nội', N'huyen@gmail.com', N'khách hàng đặc biệt')
INSERT [dbo].[CUSTOMER] ([CustomerID], [Name], [Phone], [Address], [Email], [Description]) VALUES (N'KH0015', N'Nguyễn Xuân Khang', 39843992, N'Hà Tĩnh', N'khang@gmail.com', N'
')
INSERT [dbo].[CUSTOMER] ([CustomerID], [Name], [Phone], [Address], [Email], [Description]) VALUES (N'KH0016', N'Nguyễn Xuân Sang', 9387284, N'Đà Nẵng', N'sang@gmail.com', N'')
INSERT [dbo].[CUSTOMER] ([CustomerID], [Name], [Phone], [Address], [Email], [Description]) VALUES (N'KH0017', N'Nguyễn Thị Khánh Huyền', 8384822, N'Hà Nội', N'', N'')
INSERT [dbo].[CUSTOMER] ([CustomerID], [Name], [Phone], [Address], [Email], [Description]) VALUES (N'KH0018', N'Trần Đình Văn Nam', 3884732, N'Thanh Hóa', N'', N'
')
INSERT [dbo].[CUSTOMER] ([CustomerID], [Name], [Phone], [Address], [Email], [Description]) VALUES (N'KH0019', N'Trần Văn Nam', 38494922, N'Hải phòng', N'', N'')
INSERT [dbo].[CUSTOMER] ([CustomerID], [Name], [Phone], [Address], [Email], [Description]) VALUES (N'KH0020', N'Hoàng Thị Quỳnh Vân', 388273, N'Đà Nẵng', N'', N'
')
INSERT [dbo].[CUSTOMER] ([CustomerID], [Name], [Phone], [Address], [Email], [Description]) VALUES (N'KH0021', N'Trương Văn Khang', 27384843, N'Vinh', N'Khang@gmail.com', N'')
INSERT [dbo].[CUSTOMER] ([CustomerID], [Name], [Phone], [Address], [Email], [Description]) VALUES (N'KH0022', N'Huỳnh Văn Võ', 93939393, N'Hà Tĩnh', N'', N'
')
GO
INSERT [dbo].[IMPORT] ([ImportID], [SupplierID], [Account], [Total], [CreateDateOfBill]) VALUES (N'HÐ0001', N'CC0007', N'nguyenkhanhson', CAST(8198000000 AS Decimal(18, 0)), CAST(N'2023-06-17T04:23:50.103' AS DateTime))
INSERT [dbo].[IMPORT] ([ImportID], [SupplierID], [Account], [Total], [CreateDateOfBill]) VALUES (N'HÐ0002', N'CC0004', N'nguyenkhanhson', CAST(6250000000 AS Decimal(18, 0)), CAST(N'2023-06-17T04:28:03.663' AS DateTime))
INSERT [dbo].[IMPORT] ([ImportID], [SupplierID], [Account], [Total], [CreateDateOfBill]) VALUES (N'HÐ0003', N'CC0006', N'nguyenkhanhson', CAST(6810000000 AS Decimal(18, 0)), CAST(N'2023-06-17T17:51:10.020' AS DateTime))
INSERT [dbo].[IMPORT] ([ImportID], [SupplierID], [Account], [Total], [CreateDateOfBill]) VALUES (N'HÐ0004', N'CC0006', N'nguyenkhanhson', CAST(2900000000 AS Decimal(18, 0)), CAST(N'2023-06-17T18:16:34.780' AS DateTime))
INSERT [dbo].[IMPORT] ([ImportID], [SupplierID], [Account], [Total], [CreateDateOfBill]) VALUES (N'HÐ0005', N'CC0004', N'nguyenkhanhson', CAST(4250000000 AS Decimal(18, 0)), CAST(N'2023-06-18T15:27:12.210' AS DateTime))
INSERT [dbo].[IMPORT] ([ImportID], [SupplierID], [Account], [Total], [CreateDateOfBill]) VALUES (N'HÐ0006', N'CC0003', N'nguyenkhanhson', CAST(5450000000 AS Decimal(18, 0)), CAST(N'2023-06-21T01:52:59.880' AS DateTime))
INSERT [dbo].[IMPORT] ([ImportID], [SupplierID], [Account], [Total], [CreateDateOfBill]) VALUES (N'HÐ0007', N'CC0006', N'nguyenkhanhson', CAST(10450000000 AS Decimal(18, 0)), CAST(N'2023-06-29T01:57:16.060' AS DateTime))
INSERT [dbo].[IMPORT] ([ImportID], [SupplierID], [Account], [Total], [CreateDateOfBill]) VALUES (N'HÐ0008', N'CC0003', N'nguyenkhanhson', CAST(9500000000 AS Decimal(18, 0)), CAST(N'2023-06-29T01:59:08.097' AS DateTime))
INSERT [dbo].[IMPORT] ([ImportID], [SupplierID], [Account], [Total], [CreateDateOfBill]) VALUES (N'HÐ0009', N'CC0004', N'nguyenkhanhson', CAST(3000000000 AS Decimal(18, 0)), CAST(N'2023-07-05T08:27:19.767' AS DateTime))
GO
SET IDENTITY_INSERT [dbo].[IMPORT_DETAIL] ON 

INSERT [dbo].[IMPORT_DETAIL] ([ImportID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0001', 1, 100, CAST(22990000 AS Decimal(18, 0)), 95)
INSERT [dbo].[IMPORT_DETAIL] ([ImportID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0001', 3, 100, CAST(18990000 AS Decimal(18, 0)), 96)
INSERT [dbo].[IMPORT_DETAIL] ([ImportID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0001', 4, 100, CAST(20000000 AS Decimal(18, 0)), 97)
INSERT [dbo].[IMPORT_DETAIL] ([ImportID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0001', 12, 100, CAST(20000000 AS Decimal(18, 0)), 98)
INSERT [dbo].[IMPORT_DETAIL] ([ImportID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0002', 2, 50, CAST(20000000 AS Decimal(18, 0)), 99)
INSERT [dbo].[IMPORT_DETAIL] ([ImportID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0002', 4, 50, CAST(20000000 AS Decimal(18, 0)), 100)
INSERT [dbo].[IMPORT_DETAIL] ([ImportID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0002', 5, 50, CAST(20000000 AS Decimal(18, 0)), 101)
INSERT [dbo].[IMPORT_DETAIL] ([ImportID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0002', 7, 50, CAST(25000000 AS Decimal(18, 0)), 102)
INSERT [dbo].[IMPORT_DETAIL] ([ImportID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0002', 9, 50, CAST(20000000 AS Decimal(18, 0)), 103)
INSERT [dbo].[IMPORT_DETAIL] ([ImportID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0002', 12, 50, CAST(20000000 AS Decimal(18, 0)), 104)
INSERT [dbo].[IMPORT_DETAIL] ([ImportID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0003', 3, 50, CAST(15000000 AS Decimal(18, 0)), 105)
INSERT [dbo].[IMPORT_DETAIL] ([ImportID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0003', 15, 50, CAST(300000 AS Decimal(18, 0)), 114)
INSERT [dbo].[IMPORT_DETAIL] ([ImportID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0003', 17, 50, CAST(300000 AS Decimal(18, 0)), 115)
INSERT [dbo].[IMPORT_DETAIL] ([ImportID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0003', 19, 50, CAST(300000 AS Decimal(18, 0)), 116)
INSERT [dbo].[IMPORT_DETAIL] ([ImportID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0003', 20, 50, CAST(300000 AS Decimal(18, 0)), 113)
INSERT [dbo].[IMPORT_DETAIL] ([ImportID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0003', 26, 50, CAST(25000000 AS Decimal(18, 0)), 106)
INSERT [dbo].[IMPORT_DETAIL] ([ImportID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0003', 29, 50, CAST(20000000 AS Decimal(18, 0)), 108)
INSERT [dbo].[IMPORT_DETAIL] ([ImportID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0003', 33, 50, CAST(30000000 AS Decimal(18, 0)), 109)
INSERT [dbo].[IMPORT_DETAIL] ([ImportID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0003', 34, 50, CAST(20000000 AS Decimal(18, 0)), 107)
INSERT [dbo].[IMPORT_DETAIL] ([ImportID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0003', 37, 50, CAST(20000000 AS Decimal(18, 0)), 112)
INSERT [dbo].[IMPORT_DETAIL] ([ImportID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0003', 40, 50, CAST(3000000 AS Decimal(18, 0)), 111)
INSERT [dbo].[IMPORT_DETAIL] ([ImportID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0003', 41, 50, CAST(2000000 AS Decimal(18, 0)), 110)
INSERT [dbo].[IMPORT_DETAIL] ([ImportID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0004', 10, 50, CAST(3000000 AS Decimal(18, 0)), 120)
INSERT [dbo].[IMPORT_DETAIL] ([ImportID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0004', 11, 50, CAST(4000000 AS Decimal(18, 0)), 117)
INSERT [dbo].[IMPORT_DETAIL] ([ImportID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0004', 13, 50, CAST(15000000 AS Decimal(18, 0)), 118)
INSERT [dbo].[IMPORT_DETAIL] ([ImportID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0004', 16, 50, CAST(10000000 AS Decimal(18, 0)), 121)
INSERT [dbo].[IMPORT_DETAIL] ([ImportID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0004', 35, 50, CAST(20000000 AS Decimal(18, 0)), 122)
INSERT [dbo].[IMPORT_DETAIL] ([ImportID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0004', 37, 50, CAST(6000000 AS Decimal(18, 0)), 119)
INSERT [dbo].[IMPORT_DETAIL] ([ImportID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0005', 3, 50, CAST(15000000 AS Decimal(18, 0)), 123)
INSERT [dbo].[IMPORT_DETAIL] ([ImportID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0005', 21, 50, CAST(5000000 AS Decimal(18, 0)), 124)
INSERT [dbo].[IMPORT_DETAIL] ([ImportID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0005', 27, 50, CAST(20000000 AS Decimal(18, 0)), 125)
INSERT [dbo].[IMPORT_DETAIL] ([ImportID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0005', 28, 50, CAST(20000000 AS Decimal(18, 0)), 126)
INSERT [dbo].[IMPORT_DETAIL] ([ImportID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0005', 30, 50, CAST(25000000 AS Decimal(18, 0)), 127)
INSERT [dbo].[IMPORT_DETAIL] ([ImportID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0006', 11, 50, CAST(20000000 AS Decimal(18, 0)), 130)
INSERT [dbo].[IMPORT_DETAIL] ([ImportID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0006', 16, 50, CAST(4000000 AS Decimal(18, 0)), 134)
INSERT [dbo].[IMPORT_DETAIL] ([ImportID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0006', 20, 50, CAST(5000000 AS Decimal(18, 0)), 133)
INSERT [dbo].[IMPORT_DETAIL] ([ImportID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0006', 21, 50, CAST(20000000 AS Decimal(18, 0)), 129)
INSERT [dbo].[IMPORT_DETAIL] ([ImportID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0006', 27, 50, CAST(20000000 AS Decimal(18, 0)), 128)
INSERT [dbo].[IMPORT_DETAIL] ([ImportID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0006', 28, 50, CAST(20000000 AS Decimal(18, 0)), 132)
INSERT [dbo].[IMPORT_DETAIL] ([ImportID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0006', 36, 50, CAST(15000000 AS Decimal(18, 0)), 135)
INSERT [dbo].[IMPORT_DETAIL] ([ImportID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0006', 39, 50, CAST(5000000 AS Decimal(18, 0)), 131)
INSERT [dbo].[IMPORT_DETAIL] ([ImportID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0007', 1, 50, CAST(20000000 AS Decimal(18, 0)), 138)
INSERT [dbo].[IMPORT_DETAIL] ([ImportID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0007', 2, 50, CAST(15000000 AS Decimal(18, 0)), 136)
INSERT [dbo].[IMPORT_DETAIL] ([ImportID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0007', 3, 50, CAST(15000000 AS Decimal(18, 0)), 137)
INSERT [dbo].[IMPORT_DETAIL] ([ImportID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0007', 4, 50, CAST(20000000 AS Decimal(18, 0)), 139)
INSERT [dbo].[IMPORT_DETAIL] ([ImportID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0007', 5, 50, CAST(20000000 AS Decimal(18, 0)), 140)
INSERT [dbo].[IMPORT_DETAIL] ([ImportID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0007', 7, 50, CAST(20000000 AS Decimal(18, 0)), 148)
INSERT [dbo].[IMPORT_DETAIL] ([ImportID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0007', 8, 50, CAST(20000000 AS Decimal(18, 0)), 141)
INSERT [dbo].[IMPORT_DETAIL] ([ImportID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0007', 9, 50, CAST(20000000 AS Decimal(18, 0)), 149)
INSERT [dbo].[IMPORT_DETAIL] ([ImportID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0007', 10, 50, CAST(5000000 AS Decimal(18, 0)), 142)
INSERT [dbo].[IMPORT_DETAIL] ([ImportID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0007', 11, 50, CAST(2000000 AS Decimal(18, 0)), 150)
INSERT [dbo].[IMPORT_DETAIL] ([ImportID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0007', 13, 50, CAST(20000000 AS Decimal(18, 0)), 144)
INSERT [dbo].[IMPORT_DETAIL] ([ImportID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0007', 14, 50, CAST(15000000 AS Decimal(18, 0)), 143)
INSERT [dbo].[IMPORT_DETAIL] ([ImportID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0007', 15, 50, CAST(5000000 AS Decimal(18, 0)), 145)
INSERT [dbo].[IMPORT_DETAIL] ([ImportID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0007', 17, 50, CAST(2000000 AS Decimal(18, 0)), 147)
INSERT [dbo].[IMPORT_DETAIL] ([ImportID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0007', 19, 50, CAST(10000000 AS Decimal(18, 0)), 146)
INSERT [dbo].[IMPORT_DETAIL] ([ImportID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0008', 29, 50, CAST(20000000 AS Decimal(18, 0)), 151)
INSERT [dbo].[IMPORT_DETAIL] ([ImportID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0008', 30, 50, CAST(20000000 AS Decimal(18, 0)), 152)
INSERT [dbo].[IMPORT_DETAIL] ([ImportID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0008', 31, 50, CAST(20000000 AS Decimal(18, 0)), 153)
INSERT [dbo].[IMPORT_DETAIL] ([ImportID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0008', 32, 50, CAST(20000000 AS Decimal(18, 0)), 155)
INSERT [dbo].[IMPORT_DETAIL] ([ImportID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0008', 33, 50, CAST(20000000 AS Decimal(18, 0)), 154)
INSERT [dbo].[IMPORT_DETAIL] ([ImportID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0008', 34, 50, CAST(20000000 AS Decimal(18, 0)), 156)
INSERT [dbo].[IMPORT_DETAIL] ([ImportID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0008', 35, 50, CAST(20000000 AS Decimal(18, 0)), 157)
INSERT [dbo].[IMPORT_DETAIL] ([ImportID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0008', 36, 50, CAST(20000000 AS Decimal(18, 0)), 158)
INSERT [dbo].[IMPORT_DETAIL] ([ImportID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0008', 37, 50, CAST(20000000 AS Decimal(18, 0)), 159)
INSERT [dbo].[IMPORT_DETAIL] ([ImportID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0008', 38, 50, CAST(10000000 AS Decimal(18, 0)), 160)
INSERT [dbo].[IMPORT_DETAIL] ([ImportID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0009', 40, 50, CAST(20000000 AS Decimal(18, 0)), 163)
INSERT [dbo].[IMPORT_DETAIL] ([ImportID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0009', 42, 50, CAST(20000000 AS Decimal(18, 0)), 162)
INSERT [dbo].[IMPORT_DETAIL] ([ImportID], [ProductID], [Quantity], [Price], [ID]) VALUES (N'HÐ0009', 43, 50, CAST(20000000 AS Decimal(18, 0)), 161)
SET IDENTITY_INSERT [dbo].[IMPORT_DETAIL] OFF
GO
INSERT [dbo].[KINDOFPRODUCT] ([KindOfProductID], [KName], [KindOfProductDescription]) VALUES (N'MH0001', N'Điện thoại ', N'
')
INSERT [dbo].[KINDOFPRODUCT] ([KindOfProductID], [KName], [KindOfProductDescription]) VALUES (N'MH0002', N'Laptop', N'

')
INSERT [dbo].[KINDOFPRODUCT] ([KindOfProductID], [KName], [KindOfProductDescription]) VALUES (N'MH0003', N'Máy tính bảng', N'


')
INSERT [dbo].[KINDOFPRODUCT] ([KindOfProductID], [KName], [KindOfProductDescription]) VALUES (N'MH0004', N'Tai nghe', N'



')
INSERT [dbo].[KINDOFPRODUCT] ([KindOfProductID], [KName], [KindOfProductDescription]) VALUES (N'MH0005', N'Cáp/sạc', N'





')
INSERT [dbo].[KINDOFPRODUCT] ([KindOfProductID], [KName], [KindOfProductDescription]) VALUES (N'MH0006', N'Sạc dự phòng', N'






')
INSERT [dbo].[KINDOFPRODUCT] ([KindOfProductID], [KName], [KindOfProductDescription]) VALUES (N'MH0007', N'Thẻ nhớ', N'







')
INSERT [dbo].[KINDOFPRODUCT] ([KindOfProductID], [KName], [KindOfProductDescription]) VALUES (N'MH0008', N'IPad', N'...')
GO
SET IDENTITY_INSERT [dbo].[PRODUCTS] ON 

INSERT [dbo].[PRODUCTS] ([ProductID], [Name], [KindOfProductID], [BrandID], [DateOfProduction], [Guarantee], [Price], [Description], [Inventory]) VALUES (1, N'iPhone 14 Pro 256GB', N'MH0001', N'TH0001', CAST(N'2023-05-04T23:14:40.000' AS DateTime), 12, CAST(28000000 AS Decimal(18, 0)), N'', 121)
INSERT [dbo].[PRODUCTS] ([ProductID], [Name], [KindOfProductID], [BrandID], [DateOfProduction], [Guarantee], [Price], [Description], [Inventory]) VALUES (2, N'iPhone 13 Pro Max 128GB | Chính hãng VN/A', N'MH0001', N'TH0001', CAST(N'2023-05-04T23:14:40.000' AS DateTime), 12, CAST(27490000 AS Decimal(18, 0)), N'', 79)
INSERT [dbo].[PRODUCTS] ([ProductID], [Name], [KindOfProductID], [BrandID], [DateOfProduction], [Guarantee], [Price], [Description], [Inventory]) VALUES (3, N'iPhone 11 64GB | Chính hãng VN/A', N'MH0001', N'TH0001', CAST(N'2023-05-04T23:14:40.000' AS DateTime), 12, CAST(22990000 AS Decimal(18, 0)), N'
', 217)
INSERT [dbo].[PRODUCTS] ([ProductID], [Name], [KindOfProductID], [BrandID], [DateOfProduction], [Guarantee], [Price], [Description], [Inventory]) VALUES (4, N'iPhone 12 Pro Max 128GB', N'MH0001', N'TH0001', CAST(N'2023-05-04T23:14:40.000' AS DateTime), 12, CAST(25490000 AS Decimal(18, 0)), N'', 173)
INSERT [dbo].[PRODUCTS] ([ProductID], [Name], [KindOfProductID], [BrandID], [DateOfProduction], [Guarantee], [Price], [Description], [Inventory]) VALUES (5, N'iPhone 14 Plus 128GB', N'MH0001', N'TH0001', CAST(N'2023-05-04T23:14:40.000' AS DateTime), 12, CAST(25990000 AS Decimal(18, 0)), N'', 76)
INSERT [dbo].[PRODUCTS] ([ProductID], [Name], [KindOfProductID], [BrandID], [DateOfProduction], [Guarantee], [Price], [Description], [Inventory]) VALUES (7, N'Samsung Galaxy Z Fold4', N'MH0001', N'TH0002', CAST(N'2023-05-04T23:14:40.000' AS DateTime), 12, CAST(36990000 AS Decimal(18, 0)), N'', 92)
INSERT [dbo].[PRODUCTS] ([ProductID], [Name], [KindOfProductID], [BrandID], [DateOfProduction], [Guarantee], [Price], [Description], [Inventory]) VALUES (8, N'Samsung Galaxy Z Flip4 128GB', N'MH0001', N'TH0002', CAST(N'2023-05-04T23:14:40.000' AS DateTime), 12, CAST(20590000 AS Decimal(18, 0)), N'', 47)
INSERT [dbo].[PRODUCTS] ([ProductID], [Name], [KindOfProductID], [BrandID], [DateOfProduction], [Guarantee], [Price], [Description], [Inventory]) VALUES (9, N'Samsung Galaxy S22 Ultra (8GB - 128GB)', N'MH0001', N'TH0002', CAST(N'2023-05-04T23:14:40.000' AS DateTime), 12, CAST(24990000 AS Decimal(18, 0)), N'', 83)
INSERT [dbo].[PRODUCTS] ([ProductID], [Name], [KindOfProductID], [BrandID], [DateOfProduction], [Guarantee], [Price], [Description], [Inventory]) VALUES (10, N'Samsung Galaxy A53 (5G)', N'MH0001', N'TH0002', CAST(N'2023-05-04T23:14:40.000' AS DateTime), 12, CAST(9450000 AS Decimal(18, 0)), N'', 76)
INSERT [dbo].[PRODUCTS] ([ProductID], [Name], [KindOfProductID], [BrandID], [DateOfProduction], [Guarantee], [Price], [Description], [Inventory]) VALUES (11, N'Samsung Galaxy A73 (5G) 256GB', N'MH0001', N'TH0002', CAST(N'2023-05-04T23:14:40.000' AS DateTime), 12, CAST(11490000 AS Decimal(18, 0)), N'', 137)
INSERT [dbo].[PRODUCTS] ([ProductID], [Name], [KindOfProductID], [BrandID], [DateOfProduction], [Guarantee], [Price], [Description], [Inventory]) VALUES (12, N'Samsung Galaxy Z Fold3 5G', N'MH0001', N'TH0002', CAST(N'2023-05-04T23:14:40.000' AS DateTime), 12, CAST(26990000 AS Decimal(18, 0)), N'', 133)
INSERT [dbo].[PRODUCTS] ([ProductID], [Name], [KindOfProductID], [BrandID], [DateOfProduction], [Guarantee], [Price], [Description], [Inventory]) VALUES (13, N'Samsung Galaxy Note 20 Ultra 5G', N'MH0001', N'TH0002', CAST(N'2023-05-15T23:14:40.000' AS DateTime), 12, CAST(18990000 AS Decimal(18, 0)), N'', 85)
INSERT [dbo].[PRODUCTS] ([ProductID], [Name], [KindOfProductID], [BrandID], [DateOfProduction], [Guarantee], [Price], [Description], [Inventory]) VALUES (14, N'Samsung Galaxy Z Flip3 5G', N'MH0001', N'TH0002', CAST(N'2023-05-04T23:14:40.000' AS DateTime), 12, CAST(14990000 AS Decimal(18, 0)), N'', 32)
INSERT [dbo].[PRODUCTS] ([ProductID], [Name], [KindOfProductID], [BrandID], [DateOfProduction], [Guarantee], [Price], [Description], [Inventory]) VALUES (15, N'OPPO Reno8', N'MH0001', N'TH0003', CAST(N'2023-05-04T23:14:40.000' AS DateTime), 12, CAST(8690000 AS Decimal(18, 0)), N'', 94)
INSERT [dbo].[PRODUCTS] ([ProductID], [Name], [KindOfProductID], [BrandID], [DateOfProduction], [Guarantee], [Price], [Description], [Inventory]) VALUES (16, N'OPPO Reno8 Pro 5G 12GB 256GB', N'MH0001', N'TH0003', CAST(N'2023-05-04T23:14:40.000' AS DateTime), 12, CAST(18990000 AS Decimal(18, 0)), N'', 87)
INSERT [dbo].[PRODUCTS] ([ProductID], [Name], [KindOfProductID], [BrandID], [DateOfProduction], [Guarantee], [Price], [Description], [Inventory]) VALUES (17, N'OPPO A57', N'MH0001', N'TH0003', CAST(N'2023-05-04T23:14:40.000' AS DateTime), 12, CAST(3990000 AS Decimal(18, 0)), N'', 95)
INSERT [dbo].[PRODUCTS] ([ProductID], [Name], [KindOfProductID], [BrandID], [DateOfProduction], [Guarantee], [Price], [Description], [Inventory]) VALUES (19, N'OPPO Reno6 Z 5G', N'MH0001', N'TH0003', CAST(N'2023-05-04T23:14:40.000' AS DateTime), 12, CAST(6590000 AS Decimal(18, 0)), N'', 88)
INSERT [dbo].[PRODUCTS] ([ProductID], [Name], [KindOfProductID], [BrandID], [DateOfProduction], [Guarantee], [Price], [Description], [Inventory]) VALUES (20, N'iPad 10.2 2021 WiFi 64GB | Chính hãng Apple Việt N', N'MH0003', N'TH0004', CAST(N'2023-05-04T23:14:40.000' AS DateTime), 12, CAST(8190000 AS Decimal(18, 0)), N'', 89)
INSERT [dbo].[PRODUCTS] ([ProductID], [Name], [KindOfProductID], [BrandID], [DateOfProduction], [Guarantee], [Price], [Description], [Inventory]) VALUES (21, N'iPad Air 5 (2022) 64GB I Chính hãng Apple Việt Nam', N'MH0003', N'TH0004', CAST(N'2023-05-04T23:14:40.000' AS DateTime), 12, CAST(15490000 AS Decimal(18, 0)), N'', 79)
INSERT [dbo].[PRODUCTS] ([ProductID], [Name], [KindOfProductID], [BrandID], [DateOfProduction], [Guarantee], [Price], [Description], [Inventory]) VALUES (26, N'Apple Macbook Air M2 2022 8GB 256GB I Chính hãng A', N'MH0002', N'TH0001', CAST(N'2023-05-04T23:14:40.000' AS DateTime), 12, CAST(28900000 AS Decimal(18, 0)), N'', 39)
INSERT [dbo].[PRODUCTS] ([ProductID], [Name], [KindOfProductID], [BrandID], [DateOfProduction], [Guarantee], [Price], [Description], [Inventory]) VALUES (27, N'Apple MacBook Air M1 256GB 2020 I Chính hãng Apple', N'MH0002', N'TH0001', CAST(N'2023-05-04T23:14:40.000' AS DateTime), 12, CAST(23190000 AS Decimal(18, 0)), N'', 86)
INSERT [dbo].[PRODUCTS] ([ProductID], [Name], [KindOfProductID], [BrandID], [DateOfProduction], [Guarantee], [Price], [Description], [Inventory]) VALUES (28, N'iMac 24 2021 M1 7GPU 8GB 256GB I Chính hãng Apple ', N'MH0002', N'TH0001', CAST(N'2023-05-04T23:14:40.000' AS DateTime), 12, CAST(27290000 AS Decimal(18, 0)), N'', 73)
INSERT [dbo].[PRODUCTS] ([ProductID], [Name], [KindOfProductID], [BrandID], [DateOfProduction], [Guarantee], [Price], [Description], [Inventory]) VALUES (29, N'Laptop Asus Gaming Rog Strix G15 G513IH HN015W', N'MH0002', N'TH0001', CAST(N'2023-05-04T23:14:40.000' AS DateTime), 12, CAST(18690000 AS Decimal(18, 0)), N'', 85)
INSERT [dbo].[PRODUCTS] ([ProductID], [Name], [KindOfProductID], [BrandID], [DateOfProduction], [Guarantee], [Price], [Description], [Inventory]) VALUES (30, N'Laptop Gaming Acer Nitro 5 AN515 45 R6EV', N'MH0002', N'TH0001', CAST(N'2023-05-04T23:14:40.000' AS DateTime), 12, CAST(18999000 AS Decimal(18, 0)), N'', 74)
INSERT [dbo].[PRODUCTS] ([ProductID], [Name], [KindOfProductID], [BrandID], [DateOfProduction], [Guarantee], [Price], [Description], [Inventory]) VALUES (31, N'Apple Macbook Pro 13 M2 2022  8GB 256GB I Chính hã', N'MH0002', N'TH0001', CAST(N'2023-05-04T23:14:40.000' AS DateTime), 12, CAST(31590000 AS Decimal(18, 0)), N'', 50)
INSERT [dbo].[PRODUCTS] ([ProductID], [Name], [KindOfProductID], [BrandID], [DateOfProduction], [Guarantee], [Price], [Description], [Inventory]) VALUES (32, N'Apple MacBook Pro 13 Touch Bar M1 256GB 2020 I Chí', N'MH0002', N'TH0001', CAST(N'2023-05-04T23:14:40.000' AS DateTime), 12, CAST(28190000 AS Decimal(18, 0)), N'', 46)
INSERT [dbo].[PRODUCTS] ([ProductID], [Name], [KindOfProductID], [BrandID], [DateOfProduction], [Guarantee], [Price], [Description], [Inventory]) VALUES (33, N'Apple Mac mini M1 256GB 2020 I Chính hãng Apple Vi', N'MH0002', N'TH0001', CAST(N'2023-05-04T23:14:40.000' AS DateTime), 12, CAST(17990000 AS Decimal(18, 0)), N'', 92)
INSERT [dbo].[PRODUCTS] ([ProductID], [Name], [KindOfProductID], [BrandID], [DateOfProduction], [Guarantee], [Price], [Description], [Inventory]) VALUES (34, N'Macbook Pro 14 inch 2021 | Chính hãng Apple Việt N', N'MH0002', N'TH0001', CAST(N'2023-05-04T23:14:40.000' AS DateTime), 12, CAST(46990000 AS Decimal(18, 0)), N'', 82)
INSERT [dbo].[PRODUCTS] ([ProductID], [Name], [KindOfProductID], [BrandID], [DateOfProduction], [Guarantee], [Price], [Description], [Inventory]) VALUES (35, N'Macbook Pro 16 inch 2021 10 CPU - 16 GPU 32GB 512G', N'MH0002', N'TH0001', CAST(N'2023-05-04T23:14:40.000' AS DateTime), 12, CAST(68990000 AS Decimal(18, 0)), N'', 93)
INSERT [dbo].[PRODUCTS] ([ProductID], [Name], [KindOfProductID], [BrandID], [DateOfProduction], [Guarantee], [Price], [Description], [Inventory]) VALUES (36, N'Apple iPad mini 6 WiFi 64GB | Chính hãng Apple Việ', N'MH0008', N'TH0001', CAST(N'2023-05-04T23:14:40.000' AS DateTime), 12, CAST(13390000 AS Decimal(18, 0)), N'', 93)
INSERT [dbo].[PRODUCTS] ([ProductID], [Name], [KindOfProductID], [BrandID], [DateOfProduction], [Guarantee], [Price], [Description], [Inventory]) VALUES (37, N'Apple iPad Pro 11 2021 M1 WiFi 128GB I Chính hãng ', N'MH0008', N'TH0001', CAST(N'2023-05-04T23:14:40.000' AS DateTime), 12, CAST(19490000 AS Decimal(18, 0)), N'', 137)
INSERT [dbo].[PRODUCTS] ([ProductID], [Name], [KindOfProductID], [BrandID], [DateOfProduction], [Guarantee], [Price], [Description], [Inventory]) VALUES (38, N'Samsung Galaxy Tab S8 Ultra 5G', N'MH0003', N'TH0002', CAST(N'2023-05-04T23:14:40.000' AS DateTime), 12, CAST(25990000 AS Decimal(18, 0)), N'', 45)
INSERT [dbo].[PRODUCTS] ([ProductID], [Name], [KindOfProductID], [BrandID], [DateOfProduction], [Guarantee], [Price], [Description], [Inventory]) VALUES (39, N'Xiaomi Pad 5', N'MH0008', N'TH0005', CAST(N'2023-05-04T23:14:40.000' AS DateTime), 12, CAST(7999000 AS Decimal(18, 0)), N'', 46)
INSERT [dbo].[PRODUCTS] ([ProductID], [Name], [KindOfProductID], [BrandID], [DateOfProduction], [Guarantee], [Price], [Description], [Inventory]) VALUES (40, N'iPad Air 10.9 2020 4G 256GB I Chính hãng Apple Việ', N'MH0008', N'TH0001', CAST(N'2023-05-04T23:14:40.000' AS DateTime), 12, CAST(18590000 AS Decimal(18, 0)), N'', 92)
INSERT [dbo].[PRODUCTS] ([ProductID], [Name], [KindOfProductID], [BrandID], [DateOfProduction], [Guarantee], [Price], [Description], [Inventory]) VALUES (41, N'Redmi Pad 3GB 64GB', N'MH0008', N'TH0006', CAST(N'2023-05-04T23:14:40.000' AS DateTime), 12, CAST(5790000 AS Decimal(18, 0)), N'', 50)
INSERT [dbo].[PRODUCTS] ([ProductID], [Name], [KindOfProductID], [BrandID], [DateOfProduction], [Guarantee], [Price], [Description], [Inventory]) VALUES (42, N'iPad 10.9 inch 2022 Wifi 64GB', N'MH0008', N'TH0001', CAST(N'2023-05-04T23:14:40.000' AS DateTime), 12, CAST(7490000 AS Decimal(18, 0)), N'', 50)
INSERT [dbo].[PRODUCTS] ([ProductID], [Name], [KindOfProductID], [BrandID], [DateOfProduction], [Guarantee], [Price], [Description], [Inventory]) VALUES (43, N'Máy Tính Bảng Huawei Matepad 2022 4GB 128GB', N'MH0008', N'TH0007', CAST(N'2023-05-04T23:14:40.000' AS DateTime), 12, CAST(6490000 AS Decimal(18, 0)), N'', 50)
SET IDENTITY_INSERT [dbo].[PRODUCTS] OFF
GO
INSERT [dbo].[STAFF] ([Account], [Password], [Name], [Phone], [CCCD], [Address], [Email], [BirthDay], [Role], [Descirption]) VALUES (N'duynguyen', N'1', N'Nguyễn Duy Nguyên', 9838282, 9838282, N'Nghệ An', N'nguyen@gmail.com', CAST(N'2003-05-17T04:05:10.000' AS DateTime), N'Quản lý', N'')
INSERT [dbo].[STAFF] ([Account], [Password], [Name], [Phone], [CCCD], [Address], [Email], [BirthDay], [Role], [Descirption]) VALUES (N'Nguyenkhanhson', N'1', N'Nguyễn Khánh Sơn', 943217670, 943217670, N'ha tinh', N'nguyenkhanhsonzero@gmail.com', CAST(N'2003-05-17T04:05:10.000' AS DateTime), N'Quản lý', N'còn')
INSERT [dbo].[STAFF] ([Account], [Password], [Name], [Phone], [CCCD], [Address], [Email], [BirthDay], [Role], [Descirption]) VALUES (N'sontruong', N'1', N'Trương Minh Sơn', 393993939, 393993939, N'Nghệ An', N'Sontruong@gmail.com', CAST(N'2003-05-16T17:57:17.000' AS DateTime), N'Nhân viên', N'')
GO
INSERT [dbo].[SUPPLIER] ([SupplierID], [NameCompany], [Phone], [Address], [Representative], [Email], [Description]) VALUES (N'CC0001', N'Công ty công nghệ FPT', 943217670, N'Hà Tĩnh', N'Nguyen khanh son', N'nguyenkhanhson@gmail.com', N'')
INSERT [dbo].[SUPPLIER] ([SupplierID], [NameCompany], [Phone], [Address], [Representative], [Email], [Description]) VALUES (N'CC0003', N'Hệ thống phân phối hàng chính hãng XiaoMi', 944329844, N'269 Lê Lợi , P.Lê Lợi , Ngô Quyền , TP Hải Phòng', N'TTHT', N'info@gmail.comdd', N'
')
INSERT [dbo].[SUPPLIER] ([SupplierID], [NameCompany], [Phone], [Address], [Representative], [Email], [Description]) VALUES (N'CC0004', N'Công ty Cung Cấp Điện Thoại Thông Min', 49493838, N'Bạch Liêu , TP Vinh , Nghệ An', N'DDTM', N'info@gmail.com', N'
')
INSERT [dbo].[SUPPLIER] ([SupplierID], [NameCompany], [Phone], [Address], [Representative], [Email], [Description]) VALUES (N'CC0006', N'Công ty cổ phần công nghệ PHU SANG', 943883833, N'Hà tĩnh', N'Nguyễn Văn A', N'phusang@gmail.com', N'
')
INSERT [dbo].[SUPPLIER] ([SupplierID], [NameCompany], [Phone], [Address], [Representative], [Email], [Description]) VALUES (N'CC0007', N'Hệ thông cung cấp thiết bị di động chính hãng', 292929939, N'Hà Nội', N'Nguyễn Văn Thanh', N'vanthanh@gmail.com', N'
')
GO
/****** Object:  Index [UQ__BILLDETA__3214EC266F4A8121]    Script Date: 06/08/2023 2:17:11 am ******/
ALTER TABLE [dbo].[BILLDETAIL] ADD UNIQUE NONCLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_BILLDETAIL]    Script Date: 06/08/2023 2:17:11 am ******/
CREATE NONCLUSTERED INDEX [IX_BILLDETAIL] ON [dbo].[BILLDETAIL]
(
	[BillID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [UQ__IMPORT_D__3214EC267226EDCC]    Script Date: 06/08/2023 2:17:11 am ******/
ALTER TABLE [dbo].[IMPORT_DETAIL] ADD UNIQUE NONCLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  FullTextIndex     Script Date: 06/08/2023 2:17:11 am ******/
CREATE FULLTEXT INDEX ON [dbo].[BRAND](
[BName] LANGUAGE 'English', 
[BrandDescription] LANGUAGE 'English', 
[BrandID] LANGUAGE 'English')
KEY INDEX [PK__BRAND__DAD4F3BE0425A276]ON ([FullText_Staff], FILEGROUP [PRIMARY])
WITH (CHANGE_TRACKING = AUTO, STOPLIST = SYSTEM)

GO
/****** Object:  FullTextIndex     Script Date: 06/08/2023 2:17:11 am ******/
CREATE FULLTEXT INDEX ON [dbo].[CUSTOMER](
[Address] LANGUAGE 'English', 
[CustomerID] LANGUAGE 'English', 
[Description] LANGUAGE 'English', 
[Email] LANGUAGE 'English', 
[Name] LANGUAGE 'English')
KEY INDEX [PK__CUSTOMER__A4AE64B82A4B4B5E]ON ([FullText_Staff], FILEGROUP [PRIMARY])
WITH (CHANGE_TRACKING = AUTO, STOPLIST = SYSTEM)

GO
/****** Object:  FullTextIndex     Script Date: 06/08/2023 2:17:11 am ******/
CREATE FULLTEXT INDEX ON [dbo].[KINDOFPRODUCT](
[KindOfProductDescription] LANGUAGE 'English', 
[KindOfProductID] LANGUAGE 'English', 
[KName] LANGUAGE 'English')
KEY INDEX [PK__KINDOFPR__264DC4F207F6335A]ON ([FullText_Staff], FILEGROUP [PRIMARY])
WITH (CHANGE_TRACKING = AUTO, STOPLIST = SYSTEM)

GO
/****** Object:  FullTextIndex     Script Date: 06/08/2023 2:17:11 am ******/
CREATE FULLTEXT INDEX ON [dbo].[PRODUCTS](
[BrandID] LANGUAGE 'English', 
[Description] LANGUAGE 'English', 
[KindOfProductID] LANGUAGE 'English', 
[Name] LANGUAGE 'English')
KEY INDEX [PK_PRODUCTS]ON ([FullText_Staff], FILEGROUP [PRIMARY])
WITH (CHANGE_TRACKING = AUTO, STOPLIST = SYSTEM)

GO
/****** Object:  FullTextIndex     Script Date: 06/08/2023 2:17:11 am ******/
CREATE FULLTEXT INDEX ON [dbo].[STAFF](
[Account] LANGUAGE 'English', 
[Address] LANGUAGE 'English', 
[Descirption] LANGUAGE 'English', 
[Email] LANGUAGE 'English', 
[Name] LANGUAGE 'English', 
[Password] LANGUAGE 'English', 
[Role] LANGUAGE 'English')
KEY INDEX [PK_STAFF]ON ([FullText_Staff], FILEGROUP [PRIMARY])
WITH (CHANGE_TRACKING = AUTO, STOPLIST = SYSTEM)

GO
/****** Object:  FullTextIndex     Script Date: 06/08/2023 2:17:11 am ******/
CREATE FULLTEXT INDEX ON [dbo].[SUPPLIER](
[NameCompany] LANGUAGE 'English')
KEY INDEX [PK__tmp_ms_x__4BE666946A30C649]ON ([FullText_Staff], FILEGROUP [PRIMARY])
WITH (CHANGE_TRACKING = AUTO, STOPLIST = SYSTEM)

GO
/****** Object:  FullTextIndex     Script Date: 06/08/2023 2:17:11 am ******/
CREATE FULLTEXT INDEX ON [dbo].[ViewBillExport](
[Giá] LANGUAGE 'English', 
[Mã hóa đơn] LANGUAGE 'English', 
[mô tả] LANGUAGE 'English', 
[Nhân viên tiếp nhận] LANGUAGE 'English', 
[Tên khách hàng] LANGUAGE 'English', 
[Tên sản phẩm] LANGUAGE 'English')
KEY INDEX [ViewBillExport]ON ([FullText_Staff], FILEGROUP [PRIMARY])
WITH (CHANGE_TRACKING = AUTO, STOPLIST = SYSTEM)

GO
/****** Object:  FullTextIndex     Script Date: 06/08/2023 2:17:11 am ******/
CREATE FULLTEXT INDEX ON [dbo].[ViewBillImport](
[Mã hóa đơn] LANGUAGE 'English', 
[Nhân viên tiếp nhân] LANGUAGE 'English', 
[Tên công ty] LANGUAGE 'English', 
[Tên sản phẩm] LANGUAGE 'English')
KEY INDEX [ViewBillImport]ON ([FullText_Staff], FILEGROUP [PRIMARY])
WITH (CHANGE_TRACKING = AUTO, STOPLIST = SYSTEM)

GO
/****** Object:  FullTextIndex     Script Date: 06/08/2023 2:17:11 am ******/
CREATE FULLTEXT INDEX ON [dbo].[ViewInventory](
[Loại sản phẩm] LANGUAGE 'English', 
[Tên sản phẩm] LANGUAGE 'English', 
[Thương hiệu] LANGUAGE 'English')
KEY INDEX [IX_ViewInventory]ON ([FullText_Staff], FILEGROUP [PRIMARY])
WITH (CHANGE_TRACKING = AUTO, STOPLIST = SYSTEM)

GO
/****** Object:  FullTextIndex     Script Date: 06/08/2023 2:17:11 am ******/
CREATE FULLTEXT INDEX ON [dbo].[ViewPersonallBill](
[Tài khoản nhân viên] LANGUAGE 'English')
KEY INDEX [ViewPersonallBill]ON ([FullText_Staff], FILEGROUP [PRIMARY])
WITH (CHANGE_TRACKING = AUTO, STOPLIST = SYSTEM)

GO
USE [QLDIENTHOAI]
GO
ALTER FULLTEXT INDEX ON [dbo].[ViewPersonallBill] DISABLE
GO
/****** Object:  FullTextIndex     Script Date: 06/08/2023 2:17:11 am ******/
CREATE FULLTEXT INDEX ON [dbo].[ViewPRODUCTS](
[Tên sản phẩm] LANGUAGE 'English', 
[Thương hiệu] LANGUAGE 'English')
KEY INDEX [ViewProducts]ON ([FullText_Staff], FILEGROUP [PRIMARY])
WITH (CHANGE_TRACKING = AUTO, STOPLIST = SYSTEM)

GO
/****** Object:  FullTextIndex     Script Date: 06/08/2023 2:17:11 am ******/
CREATE FULLTEXT INDEX ON [dbo].[ViewSTAFF](
[Chức vụ] LANGUAGE 'English', 
[Họ tên] LANGUAGE 'English', 
[Tên tài khoản] LANGUAGE 'English')
KEY INDEX [ViewStaff]ON ([FullText_Staff], FILEGROUP [PRIMARY])
WITH (CHANGE_TRACKING = AUTO, STOPLIST = SYSTEM)

GO
ALTER TABLE [dbo].[BILL]  WITH CHECK ADD FOREIGN KEY([CustomerID])
REFERENCES [dbo].[CUSTOMER] ([CustomerID])
GO
ALTER TABLE [dbo].[BILL]  WITH CHECK ADD  CONSTRAINT [FK_BILL_STAFF] FOREIGN KEY([Account])
REFERENCES [dbo].[STAFF] ([Account])
GO
ALTER TABLE [dbo].[BILL] CHECK CONSTRAINT [FK_BILL_STAFF]
GO
ALTER TABLE [dbo].[BILLDETAIL]  WITH CHECK ADD FOREIGN KEY([BillID])
REFERENCES [dbo].[BILL] ([BillID])
GO
ALTER TABLE [dbo].[BILLDETAIL]  WITH CHECK ADD FOREIGN KEY([ProductID])
REFERENCES [dbo].[PRODUCTS] ([ProductID])
GO
ALTER TABLE [dbo].[IMPORT]  WITH CHECK ADD FOREIGN KEY([SupplierID])
REFERENCES [dbo].[SUPPLIER] ([SupplierID])
GO
ALTER TABLE [dbo].[IMPORT]  WITH CHECK ADD  CONSTRAINT [FK_IMPORT_STAFF] FOREIGN KEY([Account])
REFERENCES [dbo].[STAFF] ([Account])
GO
ALTER TABLE [dbo].[IMPORT] CHECK CONSTRAINT [FK_IMPORT_STAFF]
GO
ALTER TABLE [dbo].[IMPORT_DETAIL]  WITH CHECK ADD FOREIGN KEY([ImportID])
REFERENCES [dbo].[IMPORT] ([ImportID])
GO
ALTER TABLE [dbo].[IMPORT_DETAIL]  WITH CHECK ADD FOREIGN KEY([ProductID])
REFERENCES [dbo].[PRODUCTS] ([ProductID])
GO
ALTER TABLE [dbo].[PRODUCTS]  WITH CHECK ADD FOREIGN KEY([BrandID])
REFERENCES [dbo].[BRAND] ([BrandID])
GO
ALTER TABLE [dbo].[PRODUCTS]  WITH CHECK ADD FOREIGN KEY([KindOfProductID])
REFERENCES [dbo].[KINDOFPRODUCT] ([KindOfProductID])
GO
/****** Object:  StoredProcedure [dbo].[PR_checkLogin]    Script Date: 06/08/2023 2:17:11 am ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[PR_checkLogin]
    @Account varchar(30),
    @Password varchar(30),
    @name nvarchar(50) OUTPUT,
	@role nvarchar(50) OUTPUT
AS
BEGIN
    DECLARE @count int;
    SELECT @count = COUNT(*) FROM STAFF WHERE Account = @Account AND [Password] = @Password;
    IF (@count > 0)
    BEGIN
        SELECT @name = Name FROM STAFF WHERE Account = @Account;
        SELECT @role = Role FROM STAFF WHERE Account = @Account;
    END
END
GO
/****** Object:  StoredProcedure [dbo].[PR_deleteBRAND]    Script Date: 06/08/2023 2:17:11 am ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [dbo].[PR_deleteBRAND]
@ID varchar(6)
as
	BEGIN
		if exists( select * from BRAND where BrandID = @ID)
			BEGIN
				DELETE BRAND where BrandID = @ID
			END
	END
GO
/****** Object:  StoredProcedure [dbo].[PR_deleteCUSTOMER]    Script Date: 06/08/2023 2:17:11 am ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [dbo].[PR_deleteCUSTOMER]
@ID varchar(6)
as
	BEGIN
		if exists( select * from CUSTOMER where CustomerID = @ID)
			BEGIN
				DELETE CUSTOMER where CustomerID = @ID
			END
	END
GO
/****** Object:  StoredProcedure [dbo].[PR_deleteKINDOFPRODUCT]    Script Date: 06/08/2023 2:17:11 am ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [dbo].[PR_deleteKINDOFPRODUCT]
@ID varchar(6)
as
	BEGIN
		if exists( select * from KINDOFPRODUCT where KindOfProductID = @ID)
			BEGIN
				DELETE KINDOFPRODUCT where KindOfProductID = @ID
			END
	END
GO
/****** Object:  StoredProcedure [dbo].[PR_deletePRODUCTS]    Script Date: 06/08/2023 2:17:11 am ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc [dbo].[PR_deletePRODUCTS]
@ID int 
AS
BEGIN
	if exists (SELECT * from PRODUCTS where ProductID = @ID)
		BEGIN
			DELETE PRODUCTS where ProductID = @ID;
		END
END
GO
/****** Object:  StoredProcedure [dbo].[PR_deleteSTAFF]    Script Date: 06/08/2023 2:17:11 am ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc [dbo].[PR_deleteSTAFF]
@Account varchar(30)
AS
BEGIN
	if exists(select Account from STAFF where Account = @Account)
		BEGIN 
			DELETE STAFF where Account = @Account
		END
END
GO
/****** Object:  StoredProcedure [dbo].[PR_deleteSUPPLIER]    Script Date: 06/08/2023 2:17:11 am ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [dbo].[PR_deleteSUPPLIER]
@ID varchar(6)
as
	BEGIN
		if exists( select * from SUPPLIER where SupplierID = @ID)
			BEGIN
				DELETE SUPPLIER where SupplierID = @ID
			END
	END
GO
/****** Object:  StoredProcedure [dbo].[PR_insertBILL]    Script Date: 06/08/2023 2:17:11 am ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[PR_insertBILL]
@Account varchar(30),
@CustomerID varchar(6),
@Total decimal , 
@Discount decimal ,
@Description nvarchar(100),
@BillID varchar(6) OUTPUT
AS
BEGIN
	if exists (select * from STAFF where Account = @Account ) and EXISTS
	 		  (  select * from CUSTOMER where CustomerID = @CustomerID)
		BEGIN 
			declare @NewID char(6)
			select @NewID = BillID
			from BILL
			SELECT @NewID = 'HĐ' + RIGHT('0000' + CAST((ISNULL(MAX(SUBSTRING(@NewID, 3, 4)), 0) + 1) AS VARCHAR(3)), 4)
			insert into BILL
			VALUES (@NewID  ,@CustomerID , @Account , @Total , GETDATE() , @Discount ,@Description);
			set @BillID = @NewID
		END
	else set @BillID = null
END
GO
/****** Object:  StoredProcedure [dbo].[PR_insertBILLDETAIL]    Script Date: 06/08/2023 2:17:11 am ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[PR_insertBILLDETAIL]
@BillID varchar(30), 
@ProductID int ,
@Quantity int,
@Price decimal,
@check int OUTPUT
AS
BEGIN 
	declare @inventory int ;
	select @inventory = Inventory from PRODUCTS where ProductID = @ProductID;
	if(@inventory < @Quantity) set @check = 0
	else 
	begin
		insert into BILLDETAIL values (@BillID , @ProductID , @Quantity , @Price)
		set @check = 1;
	end
END
GO
/****** Object:  StoredProcedure [dbo].[PR_insertBRAND]    Script Date: 06/08/2023 2:17:11 am ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[PR_insertBRAND]
	@BrandName nvarchar(50) ,
	@Description nvarchar(100) = null,
	@check int out
as 
	BEGIN
	if not exists (select * from BRAND where BName = @BrandName)
	begin
		declare @NewID char(6)
		select @NewID = BRANDID
		from BRAND
		SELECT @NewID = 'TH' + RIGHT('0000' + CAST((ISNULL(MAX(SUBSTRING(@NewID, 3, 4)), 0) + 1) AS VARCHAR(3)), 4)
		insert into BRAND
		VALUES
			(@NewID  , @BrandName , @Description)
	end
	else set @check = 0;
END
GO
/****** Object:  StoredProcedure [dbo].[PR_insertCUSTOMER]    Script Date: 06/08/2023 2:17:11 am ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [dbo].[PR_insertCUSTOMER]
	@name nvarchar(50) ,
	@Phone int,
	@Address nvarchar(50) ,
	@Email varchar(50) ,
	@Description nvarchar(100),
	@check int out
as 
	BEGIN
	if not exists (select * from CUSTOMER where Phone = @Phone)
	begin
		declare @NewID char(6)
		select @NewID = CustomerID
		from CUSTOMER
		SELECT @NewID = 'KH' + RIGHT('0000' + CAST((ISNULL(MAX(SUBSTRING(@NewID, 3, 4)), 0) + 1) AS VARCHAR(3)), 4)
		insert into CUSTOMER
		VALUES
			(@NewID , @name , @Phone , @Address  , @Email  , @Description)
			set @check = 1;
	End
	else set @check = 0;
END


GO
/****** Object:  StoredProcedure [dbo].[PR_insertIMPORT]    Script Date: 06/08/2023 2:17:11 am ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[PR_insertIMPORT]
@Account varchar(30),
@SupplierID varchar(6),
@BillID varchar(6) OUTPUT
AS
BEGIN
	declare @NewID char(6)
		BEGIN try
			select @NewID = ImportID
			from IMPORT
			SELECT @NewID = 'HĐ' + RIGHT('0000' + CAST((ISNULL(MAX(SUBSTRING(@NewID, 3, 4)), 0) + 1) AS VARCHAR(3)), 4)
			insert into IMPORT
			VALUES (@NewID  ,@SupplierID , @Account , 0 , GETDATE());
			set @BillID = @NewID
		END try
		begin catch
			set @BillID = null;
		end catch
END
GO
/****** Object:  StoredProcedure [dbo].[PR_insertIMPORTDETAIL]    Script Date: 06/08/2023 2:17:11 am ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[PR_insertIMPORTDETAIL]
@id varchar(6),
@idsp int ,
@quantity int,
@price DECIMAL,
@totalbill DECIMAL
As
BEGIN
    insert into IMPORT_DETAIL VALUES (@id , @idsp , @quantity , @price);

    update IMPORT
    set Total = @totalbill
    where ImportID = @id;
END
GO
/****** Object:  StoredProcedure [dbo].[PR_insertKINDOFPRODUCT]    Script Date: 06/08/2023 2:17:11 am ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[PR_insertKINDOFPRODUCT]
	@kindOfProductName nvarchar(50) ,
	@Description nvarchar(100) = null,
	@check int out
as 
	BEGIN
	if not exists (select * from KINDOFPRODUCT where KName = @kindOfProductName)
	begin
		declare @NewID char(6)
		select @NewID = KindOfProductID
		from KINDOFPRODUCT
		SELECT @NewID = 'MH' + RIGHT('0000' + CAST((ISNULL(MAX(SUBSTRING(@NewID, 3, 4)), 0) + 1) AS VARCHAR(3)), 4)
		insert into KINDOFPRODUCT
		VALUES
			(@NewID  , @kindOfProductName , @Description)
	end
	else set @check = 0
END
GO
/****** Object:  StoredProcedure [dbo].[PR_insertPRODUCTS]    Script Date: 06/08/2023 2:17:11 am ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[PR_insertPRODUCTS]
@Name nvarchar(50),
@KindOfProduct varchar(6) ,
@Brand varchar(6),
@DateOfProduction datetime ,
@Guarantee int , 
@Price DECIMAL , 
@des nvarchar(100) = null,
@check int out
AS
BEGIN
	if not exists(select * from PRODUCTS where Name = @Name)
		BEGIN
			insert into PRODUCTS VALUES (@Name , @KindOfProduct , @Brand , @DateOfProduction ,@Guarantee, @Price , @des , 0)
			set @check = 1;
		END
	else set @check = 0;
END
GO
/****** Object:  StoredProcedure [dbo].[pr_insertSTAFF]    Script Date: 06/08/2023 2:17:11 am ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[pr_insertSTAFF]
@Account varchar(30),
@Password varchar(30),
@Name nvarchar(50),
@phone int ,
@CCCD int,
@Address nvarchar(50),
@Email varchar(50),
@Birthday DATETIME, 
@Role nvarchar(50) ,
@Description nvarchar(100) = '',
@check int out
as
BEGIN
	if not exists (select Account from STAFF where Account = @Account)
		BEGIN
			insert into STAFF VALUES (@Account , @Password , @Name , @phone , @CCCD , @Address , @Email , @Birthday , @Role , @Description)
			set @check = 1;
		END
	else set @check = 0;
END
GO
/****** Object:  StoredProcedure [dbo].[PR_insertSUPPLIER]    Script Date: 06/08/2023 2:17:11 am ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[PR_insertSUPPLIER]
	@NameCompany nvarchar(50) ,
	@Phone int,
	@Address nvarchar(50) ,
	@Representative nvarchar(50) ,
	@Email varchar(50) ,
	@Description nvarchar(100) = '',
	@check int out
as 
	BEGIN
		if not exists (select * from SUPPLIER where NameCompany = @NameCompany)
		begin
			declare @NewID char(6)
			select @NewID = SupplierID
			from SUPPLIER
			SELECT @NewID = 'CC' + RIGHT('0000' + CAST((ISNULL(MAX(SUBSTRING(@NewID, 3, 4)), 0) + 1) AS VARCHAR(3)), 4)
			insert into SUPPLIER
			VALUES
				(@NewID , @NameCompany , @Phone , @Address , @Representative , @Email  , @Description)
			set @check = 1;
		end
		ELSE SET @check = 0;
	END
GO
/****** Object:  StoredProcedure [dbo].[PR_OnChangePassWord]    Script Date: 06/08/2023 2:17:11 am ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[PR_OnChangePassWord]
@account varchar(30),
@passwordOld varchar(30),
@passwordNew varchar(30),
@check int out
as
begin
	if exists (select * from staff where Account = @account and Password = @passwordOld)
	begin
		update STAFF
		set Password = @passwordNew
		where Account = @account 
		set @check = 1;
	end
	else set @check = 0;
end
GO
/****** Object:  StoredProcedure [dbo].[PR_parameter]    Script Date: 06/08/2023 2:17:11 am ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[PR_parameter]
@dateStart datetime , 
@dateEnd datetime ,
@qP int out , 
@cP int out , 
@TotalQ int out , 
@TotalC int out
as
begin
	select @qP= sum(bb.Quantity) from billdetail bb
	join bill b on b.BillID = bb.BillID
	where b.CreateDateOfBill between @dateStart and @dateEnd

	select @TotalQ = sum(bb.Quantity) from billdetail bb
	join bill b on b.BillID = bb.BillID
	

	select @cP=count(billID) from bill
	where CreateDateOfBill between @dateStart and @dateEnd

	select @TotalC =  count(billID) from bill

end
GO
/****** Object:  StoredProcedure [dbo].[PR_updateBRAND]    Script Date: 06/08/2023 2:17:11 am ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PR_updateBRAND]
	@BrandID varchar(6),
	@BrandName nvarchar(50),
	@Description nvarchar(100)
AS
BEGIN
	if exists(select * from BRAND where BrandID = @BrandID)
		BEGIN
			update BRAND
			set BName = @BrandName, BrandDescription = @Description
			where BrandID = @BrandID;
		END
END
GO
/****** Object:  StoredProcedure [dbo].[PR_updateCUSTOMER]    Script Date: 06/08/2023 2:17:11 am ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [dbo].[PR_updateCUSTOMER]
	@ID varchar(6),
	@name nvarchar(50) ,
	@Phone int,
	@Address nvarchar(50) ,
	@Email varchar(50) ,
	@Description nvarchar(100) = null
as 
	BEGIN
		if exists(select CustomerID from CUSTOMER where CustomerID = @ID)
			BEGIN
				UPDATE CUSTOMER 
				set Name = @name,
				Phone = @Phone,
				Address = @Address,
				Email = @Email,
				Description = @Description
				where CustomerID = @ID;
			END
	END
GO
/****** Object:  StoredProcedure [dbo].[PR_updateKINDOFPRODUCT]    Script Date: 06/08/2023 2:17:11 am ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[PR_updateKINDOFPRODUCT]
	@ID varchar(6),
	@Name nvarchar(50),
	@Description nvarchar(100)
AS
BEGIN
	if exists(select * from KINDOFPRODUCT where KindOfProductID = @ID)
		BEGIN
			update KINDOFPRODUCT
			set KName = @Name, KindOfProductDescription = @Description
			where KindOfProductID = @ID;
		END
END
GO
/****** Object:  StoredProcedure [dbo].[PR_updatePRODUCTS]    Script Date: 06/08/2023 2:17:11 am ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Proc [dbo].[PR_updatePRODUCTS]
@ID int,
@Name nvarchar(50),
@KindOfProduct varchar(6) ,
@Brand varchar(6),
@DateOfProduction datetime ,
@Guarantee int , 
@Price DECIMAL , 
@des nvarchar(100)
AS
BEGIN
	if exists( select ProductID from PRODUCTS where ProductID = @ID)
		BEGIN 
			UPDATE PRODUCTS
			set
			Name = @Name , 
			KindOfProductID = @KindOfProduct , 
			BrandID = @Brand , 
			DateOfProduction = @DateOfProduction , 
			Guarantee = @Guarantee,
			Price = @Price , 
			[Description] = @des
			where ProductID = @ID
		END
END
GO
/****** Object:  StoredProcedure [dbo].[PR_updateSTAFF]    Script Date: 06/08/2023 2:17:11 am ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Proc [dbo].[PR_updateSTAFF]
@Account varchar(30),
@Password varchar(30),
@Name nvarchar(50),
@phone int ,
@CCCD int,
@Address nvarchar(50),
@Email varchar(50),
@Birthday datetime, 
@Role nvarchar(50) ,
@Description nvarchar(100)
AS
BEGIN
	if exists(select Account from STAFF where Account = @Account)
		BEGIN 
			UPDATE STAFF
			set Account = @Account,
			Password = @Password , 
			Name = @Name , 
			Phone = @phone , 
			CCCD = @CCCD , 
			Address = @Address , 
			Email = @Email , 
			BirthDay = @Birthday , 
			Role = @Role , 
			Descirption = @Description
			where Account = @Account
		END
	ELSE print N'Không tồn tại thông tin người dùng này'
END
GO
/****** Object:  StoredProcedure [dbo].[PR_updateSUPPLIER]    Script Date: 06/08/2023 2:17:11 am ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[PR_updateSUPPLIER]
	@ID varchar(6),
	@NameCompany nvarchar(50) ,
	@Phone int,
	@Address nvarchar(50) ,
	@Representative nvarchar(50) ,
	@Email varchar(50) ,
	@Description nvarchar(100) = null
as 
	BEGIN
		if exists(select SupplierID from SUPPLIER where SupplierID = @ID)
			BEGIN
				UPDATE SUPPLIER 
				set NameCompany = @NameCompany,
				Phone = @Phone,
				Address = @Address,
				Representative = @Representative,
				Email = @Email,
				Description = @Description
				where SupplierID = @ID;
			END
	END
GO
/****** Object:  Trigger [dbo].[TG_Bill]    Script Date: 06/08/2023 2:17:12 am ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create TRIGGER [dbo].[TG_Bill]
on [dbo].[BILLDETAIL]
after INSERT
As
BEGIN
    declare @quantityOld int;
    declare @quantityNew int;
    DECLARE @idsp int;
    SELECT @idsp = inserted.ProductID  from inserted
    SELECT @quantityOld = PRODUCTS.Inventory from PRODUCTS where  ProductID = @idsp;

    select @quantityNew = @quantityOld - inserted.Quantity from BILLDETAIL
    JOIN inserted on inserted.ProductID = BILLDETAIL.ProductID;
    
	update PRODUCTS
	set Inventory = @quantityNew
	where ProductID = @idsp
END
GO
ALTER TABLE [dbo].[BILLDETAIL] ENABLE TRIGGER [TG_Bill]
GO
/****** Object:  Trigger [dbo].[TG_Import]    Script Date: 06/08/2023 2:17:12 am ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].[TG_Import]
on [dbo].[IMPORT_DETAIL]
after INSERT
As
BEGIN
    declare @quantityOld int;
    declare @quantityNew int;
    DECLARE @idsp int;
    SELECT @idsp = inserted.ProductID  from inserted
    SELECT @quantityOld = PRODUCTS.Inventory from PRODUCTS where  ProductID = @idsp;

    select @quantityNew = @quantityOld + inserted.Quantity from IMPORT_DETAIL
    JOIN inserted on inserted.ProductID = IMPORT_DETAIL.ProductID;
    
	print @quantityOld
	print @quantityNew
	print @idsp

	update PRODUCTS
	set Inventory = @quantityNew
	where ProductID = @idsp
    -- select @quantityNew = @quantityOld + inserted.Quantity from inserted

  
END
GO
ALTER TABLE [dbo].[IMPORT_DETAIL] ENABLE TRIGGER [TG_Import]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "CUSTOMER"
            Begin Extent = 
               Top = 7
               Left = 48
               Bottom = 170
               Right = 242
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1176
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1356
         SortOrder = 1416
         GroupBy = 1350
         Filter = 1356
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'ViewCUSTOMER'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'ViewCUSTOMER'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "PRODUCTS"
            Begin Extent = 
               Top = 7
               Left = 48
               Bottom = 170
               Right = 263
            End
            DisplayFlags = 280
            TopColumn = 4
         End
         Begin Table = "KINDOFPRODUCT"
            Begin Extent = 
               Top = 175
               Left = 48
               Bottom = 316
               Right = 316
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "BRAND"
            Begin Extent = 
               Top = 322
               Left = 48
               Bottom = 463
               Right = 258
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'ViewPRODUCTS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'ViewPRODUCTS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "SUPPLIER"
            Begin Extent = 
               Top = 7
               Left = 48
               Bottom = 170
               Right = 246
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'ViewSUPPLIER'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'ViewSUPPLIER'
GO
