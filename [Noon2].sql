USE [Perfume]
GO

/****** Object:  Table [dbo].[Noon2]    Script Date: 15/12/2025 7:13:30 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Noon2](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[title] [nvarchar](max) NULL,
	[brand] [nvarchar](200) NULL,
	[perfume_type] [nvarchar](100) NULL,
	[size_ml] [int] NULL,
	[rating] [float] NULL,
	[rating_count] [int] NULL,
	[price_new] [decimal](18, 2) NULL,
	[price_old] [decimal](18, 2) NULL,
	[product_url] [nvarchar](max) NULL,
	[category_rank] [int] NULL,
	[category_name] [nvarchar](200) NULL,
	[selling_fast] [bit] NULL,
	[page_no] [int] NULL,
	[scraped_at] [datetime2](7) NULL,
	[brand_cleaned] [varchar](500) NULL,
	[size_status] [varchar](30) NULL,
	[size_oz] [int] NULL,
	[has_discount] [bit] NULL,
	[discount_amount] [decimal](10, 2) NULL,
	[discount_pct] [decimal](5, 2) NULL,
	[price_per_ml] [decimal](10, 4) NULL,
	[demand_score] [decimal](6, 3) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO


