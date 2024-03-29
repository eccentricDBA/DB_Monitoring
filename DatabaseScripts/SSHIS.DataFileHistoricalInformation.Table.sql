USE [TFS_DB_Monitoring]
GO
/****** Object:  Table [SSHIS].[DataFileHistoricalInformation]    Script Date: 12/04/2013 16:37:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SSHIS].[DataFileHistoricalInformation](
	[DateReviewed] [datetime] NOT NULL,
	[DataFileGUID] [uniqueidentifier] NOT NULL,
	[AvailableSpace_KB] [bigint] NULL,
	[Size_KB] [bigint] NULL,
	[MaxSize_MB] [bigint] NULL,
	[UsedSpace_KB] [bigint] NULL,
 CONSTRAINT [PK_DataFileHistoricalInformation] PRIMARY KEY CLUSTERED 
(
	[DateReviewed] ASC,
	[DataFileGUID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [SSHIS].[DataFileHistoricalInformation]  WITH CHECK ADD  CONSTRAINT [FK_DataFileHistoricalInformation_DataFileInformation] FOREIGN KEY([DataFileGUID])
REFERENCES [SSHIS].[DataFileInformation] ([DataFileGUID])
GO
ALTER TABLE [SSHIS].[DataFileHistoricalInformation] CHECK CONSTRAINT [FK_DataFileHistoricalInformation_DataFileInformation]
GO
