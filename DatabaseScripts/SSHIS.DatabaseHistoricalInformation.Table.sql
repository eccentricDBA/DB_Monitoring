USE [TFS_DB_Monitoring]
GO
/****** Object:  Table [SSHIS].[DatabaseHistoricalInformation]    Script Date: 12/04/2013 16:37:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SSHIS].[DatabaseHistoricalInformation](
	[DateReviewed] [datetime] NOT NULL,
	[DatabaseGUID] [uniqueidentifier] NOT NULL,
	[Status] [nvarchar](128) NULL,
	[DataSpaceUsage_KB] [bigint] NULL,
	[IndexSpaceUsage_KB] [bigint] NULL,
	[SpaceAvailable_KB] [bigint] NULL,
	[DatabaseSize_MB] [bigint] NULL,
 CONSTRAINT [PK_DatabaseHistoricalInformation] PRIMARY KEY CLUSTERED 
(
	[DateReviewed] ASC,
	[DatabaseGUID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [SSHIS].[DatabaseHistoricalInformation]  WITH CHECK ADD  CONSTRAINT [FK_DatabaseHistoricalInformation_DatabaseInformation] FOREIGN KEY([DatabaseGUID])
REFERENCES [SSHIS].[DatabaseInformation] ([DatabaseGUID])
GO
ALTER TABLE [SSHIS].[DatabaseHistoricalInformation] CHECK CONSTRAINT [FK_DatabaseHistoricalInformation_DatabaseInformation]
GO
