/*
EXEC msdb.dbo.sp_delete_database_backuphistory
	@database_name = N'ViewWithCheckOptionDb'
GO

USE [master]
GO

ALTER DATABASE [ViewWithCheckOptionDb]
	SET SINGLE_USER WITH ROLLBACK IMMEDIATE
GO

USE [master]
GO

DROP DATABASE [ViewWithCheckOptionDb]
GO
*/
USE [master]
GO

CREATE DATABASE [ViewWithCheckOptionDb]
GO

USE [ViewWithCheckOptionDb]
GO

CREATE SCHEMA [Members]
GO

CREATE TABLE [Members].[MemberMains]
(
	[No]			INT,
	[Name]			NVARCHAR(50),
	[Email]			VARCHAR(150),
	[IsDeleted]		BIT DEFAULT(0),
	[whenCreated]	SMALLDATETIME DEFAULT (GETDATE()),

	CONSTRAINT [pk_Members] PRIMARY KEY ([No])
)
GO

INSERT INTO [Members].[MemberMains]([No],[Name],[Email],[IsDeleted]) VALUES (1,'William Wang','william-wang@txstudio.com',0)
INSERT INTO [Members].[MemberMains]([No],[Name],[Email],[IsDeleted]) VALUES (2,'Peter Chang','peter-chang@txstudio.com',0)
INSERT INTO [Members].[MemberMains]([No],[Name],[Email],[IsDeleted]) VALUES (3,'Trevor Fu','trevor-fu@txstudio.com',1)
INSERT INTO [Members].[MemberMains]([No],[Name],[Email],[IsDeleted]) VALUES (4,'Lucas Lee','lucas-lee@txstudio.com',0)
INSERT INTO [Members].[MemberMains]([No],[Name],[Email],[IsDeleted]) VALUES (5,'Marry Wang','marry-wang@txstudio.com',1)
GO

--建立使用 WITH CHECK OPTION 的檢視 (VIEW)
CREATE VIEW [Members].[ValidMembers]
AS
	SELECT [No]
		,[Name]
		,[Email]
		,[IsDeleted]
		,[whenCreated]
	FROM [Members].[MemberMains]
	WHERE [IsDeleted] = 0
	WITH CHECK OPTION
GO

CREATE SCHEMA [Products]
GO

CREATE TABLE [Products].[ProductMains]
(
	[No]			INT NOT NULL,
	[Name]			NVARCHAR(50),

	[UnitPrice]		SMALLMONEY,
	[IsStock]		BIT,

	[whenCreated]	SMALLDATETIME DEFAULT (GETDATE()),

	CONSTRAINT [pk_ProductMains] PRIMARY KEY ([No])
)
GO

INSERT INTO [Products].[ProductMains] ([No],[Name],[UnitPrice],[IsStock])
	VALUES (1,N'Google Pixel 3 64GB',27700,1)
INSERT INTO [Products].[ProductMains] ([No],[Name],[UnitPrice],[IsStock])
	VALUES (2,N'Google Pixel 3 128GB',30700,1)
INSERT INTO [Products].[ProductMains] ([No],[Name],[UnitPrice],[IsStock])
	VALUES (3,N'Google Pixel 3 XL 64GB',31100,1)
INSERT INTO [Products].[ProductMains] ([No],[Name],[UnitPrice],[IsStock])
	VALUES (4,N'Google Pixel 3 XL 128GB',34100,1)
GO

--建立商品價格 > 0 的商品清單
CREATE VIEW [Products].[Products]
AS
	SELECT [No]
		,[Name]
		,[UnitPrice]
		,[IsStock]
	FROM [Products].[ProductMains]
	WHERE [UnitPrice] > 0
	WITH CHECK OPTION
GO

--檢視原始資料表內容
SELECT * FROM [Members].[MemberMains]
GO

SELECT * FROM [Products].[ProductMains]
GO

--取得檢視表內容
SELECT * FROM [Members].[ValidMembers]
GO

SELECT * FROM [Products].[Products]
GO

RETURN

--------------------------------------
-- 進行 WITH CHECK OPTION 限制設定
--------------------------------------

--透過檢視表新增 IsDeleted = 1 的資料的時候會出現
--	WITH CHECK OPTION 錯誤訊息
--
--	新增的資料並不會影響 [Members].[ValidMembers] 檢視表的結果
--
INSERT INTO [Members].[ValidMembers] ([No],[Name],[Email],[IsDeleted])
	VALUES (-999,'Mark Kuo','mark-kuo@outlook.com',1)
GO

--新增 IsDeleted = 0 的資料時就不會出現錯誤訊息
INSERT INTO [Members].[ValidMembers] ([No],[Name],[Email],[IsDeleted])
	VALUES (-999,'Mark Kuo','mark-kuo@outlook.com',0)
GO

--無法透過檢視表 Products.Products 建立單價小於等於零的商品
INSERT INTO [Products].[Products] ([No],[Name],[UnitPrice],[IsStock])
	VALUES (-999,N'iPhone XS',0,1)
GO