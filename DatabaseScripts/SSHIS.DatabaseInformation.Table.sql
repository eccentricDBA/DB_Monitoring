USE [TFS_DB_Monitoring]
GO
/****** Object:  Table [SSHIS].[DatabaseInformation]    Script Date: 12/04/2013 16:37:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SSHIS].[DatabaseInformation](
	[DatabaseGUID] [uniqueidentifier] NOT NULL,
	[ServerGUID] [uniqueidentifier] NOT NULL,
	[DatabaseName] [nvarchar](128) NOT NULL,
	[CompatibilityLevel] [nvarchar](128) NULL,
	[PrimaryFilePath] [nvarchar](128) NULL,
	[CreateDate] [datetime] NULL,
	[LastBackupDate] [datetime] NULL,
	[LastLogBackupDate] [datetime] NULL,
	[RecoveryModel] [nvarchar](30) NULL,
 CONSTRAINT [PK_DatabaseInformation] PRIMARY KEY CLUSTERED 
(
	[ServerGUID] ASC,
	[DatabaseName] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY],
 CONSTRAINT [UX_DatabaseInformation_DatabaseGUID] UNIQUE NONCLUSTERED 
(
	[DatabaseGUID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_DatabaseInformation_ServerGUID_DatabaseName] ON [SSHIS].[DatabaseInformation] 
(
	[ServerGUID] ASC,
	[DatabaseName] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
ALTER TABLE [SSHIS].[DatabaseInformation]  WITH CHECK ADD  CONSTRAINT [FK_DatabaseInformation_ServerInformation] FOREIGN KEY([ServerGUID])
REFERENCES [SSHIS].[ServerInformation] ([ServerGUID])
GO
ALTER TABLE [SSHIS].[DatabaseInformation] CHECK CONSTRAINT [FK_DatabaseInformation_ServerInformation]
GO
ALTER TABLE [SSHIS].[DatabaseInformation] ADD  DEFAULT (newsequentialid()) FOR [DatabaseGUID]
GO
