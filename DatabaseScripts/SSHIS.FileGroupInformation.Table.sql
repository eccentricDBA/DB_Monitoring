USE [TFS_DB_Monitoring]
GO
/****** Object:  Table [SSHIS].[FileGroupInformation]    Script Date: 12/04/2013 16:37:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SSHIS].[FileGroupInformation](
	[FileGroupGUID] [uniqueidentifier] NOT NULL,
	[DatabaseGUID] [uniqueidentifier] NOT NULL,
	[FileGroupName] [nvarchar](128) NOT NULL,
	[IsDefault] [bit] NULL,
	[IsReadOnly] [bit] NULL,
 CONSTRAINT [PK_FileGroupInformation] PRIMARY KEY CLUSTERED 
(
	[DatabaseGUID] ASC,
	[FileGroupName] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY],
 CONSTRAINT [UX_FileGroupInformation_FileGroupGUID] UNIQUE NONCLUSTERED 
(
	[FileGroupGUID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [SSHIS].[FileGroupInformation]  WITH CHECK ADD  CONSTRAINT [FK_FileGroupInformation_DatabaseInformation] FOREIGN KEY([DatabaseGUID])
REFERENCES [SSHIS].[DatabaseInformation] ([DatabaseGUID])
GO
ALTER TABLE [SSHIS].[FileGroupInformation] CHECK CONSTRAINT [FK_FileGroupInformation_DatabaseInformation]
GO
ALTER TABLE [SSHIS].[FileGroupInformation] ADD  DEFAULT (newsequentialid()) FOR [FileGroupGUID]
GO
