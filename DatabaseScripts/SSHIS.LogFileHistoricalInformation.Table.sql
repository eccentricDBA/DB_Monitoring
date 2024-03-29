USE [TFS_DB_Monitoring]
GO
/****** Object:  Table [SSHIS].[LogFileHistoricalInformation]    Script Date: 12/04/2013 16:37:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SSHIS].[LogFileHistoricalInformation](
	[DateReviewed] [datetime] NOT NULL,
	[LogFileGUID] [uniqueidentifier] NOT NULL,
	[Size_KB] [bigint] NULL,
	[MaxSize_MB] [bigint] NULL,
	[UsedSpace_KB] [bigint] NULL,
 CONSTRAINT [PK_LogFileHistoricalInformation] PRIMARY KEY CLUSTERED 
(
	[DateReviewed] ASC,
	[LogFileGUID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [SSHIS].[LogFileHistoricalInformation]  WITH CHECK ADD  CONSTRAINT [FK_LogFileHistoricalInformation_LogFileInformation] FOREIGN KEY([LogFileGUID])
REFERENCES [SSHIS].[LogFileInformation] ([LogFileGUID])
GO
ALTER TABLE [SSHIS].[LogFileHistoricalInformation] CHECK CONSTRAINT [FK_LogFileHistoricalInformation_LogFileInformation]
GO
