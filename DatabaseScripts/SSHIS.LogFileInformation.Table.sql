USE [TFS_DB_Monitoring]
GO
/****** Object:  Table [SSHIS].[LogFileInformation]    Script Date: 12/04/2013 16:37:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SSHIS].[LogFileInformation](
	[LogFileGUID] [uniqueidentifier] NOT NULL,
	[DatabaseGUID] [uniqueidentifier] NOT NULL,
	[FileName] [nvarchar](128) NOT NULL,
	[FileFullName] [nvarchar](260) NULL,
	[GrowthType] [nvarchar](260) NULL,
	[Growth_KB] [bigint] NULL,
	[Growth_Percent] [int] NULL,
 CONSTRAINT [PK_LogFileInformation] PRIMARY KEY CLUSTERED 
(
	[DatabaseGUID] ASC,
	[FileName] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY],
 CONSTRAINT [UX_LogFileInformation_LogFileGUID] UNIQUE NONCLUSTERED 
(
	[LogFileGUID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [SSHIS].[LogFileInformation]  WITH CHECK ADD  CONSTRAINT [FK_LogFileInformation_DatabaseInformation] FOREIGN KEY([DatabaseGUID])
REFERENCES [SSHIS].[DatabaseInformation] ([DatabaseGUID])
GO
ALTER TABLE [SSHIS].[LogFileInformation] CHECK CONSTRAINT [FK_LogFileInformation_DatabaseInformation]
GO
ALTER TABLE [SSHIS].[LogFileInformation] ADD  DEFAULT (newsequentialid()) FOR [LogFileGUID]
GO
