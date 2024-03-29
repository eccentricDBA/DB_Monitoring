USE [TFS_DB_Monitoring]
GO
/****** Object:  Table [SSHIS].[DataFileInformation]    Script Date: 12/04/2013 16:37:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SSHIS].[DataFileInformation](
	[DataFileGUID] [uniqueidentifier] NOT NULL,
	[FileGroupGUID] [uniqueidentifier] NOT NULL,
	[FileName] [nvarchar](128) NOT NULL,
	[FileFullName] [nvarchar](260) NULL,
	[GrowthType] [nvarchar](260) NULL,
	[Growth_KB] [bigint] NULL,
	[Growth_Percent] [int] NULL,
 CONSTRAINT [PK_DataFileInformation] PRIMARY KEY CLUSTERED 
(
	[FileGroupGUID] ASC,
	[FileName] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY],
 CONSTRAINT [UX_DataFileInformation_LogFileGUID] UNIQUE NONCLUSTERED 
(
	[DataFileGUID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [SSHIS].[DataFileInformation]  WITH CHECK ADD  CONSTRAINT [FK_DataFileInformation_FileGroupInformation] FOREIGN KEY([FileGroupGUID])
REFERENCES [SSHIS].[FileGroupInformation] ([FileGroupGUID])
GO
ALTER TABLE [SSHIS].[DataFileInformation] CHECK CONSTRAINT [FK_DataFileInformation_FileGroupInformation]
GO
ALTER TABLE [SSHIS].[DataFileInformation] ADD  DEFAULT (newsequentialid()) FOR [DataFileGUID]
GO
