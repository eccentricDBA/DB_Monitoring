USE [TFS_DB_Monitoring]
GO
/****** Object:  Table [SSHIS].[ServerInformation]    Script Date: 12/04/2013 16:37:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SSHIS].[ServerInformation](
	[ServerGUID] [uniqueidentifier] NOT NULL,
	[ServerName] [nvarchar](128) NOT NULL,
	[NetName] [nvarchar](128) NOT NULL,
	[InstanceName] [nvarchar](128) NULL,
	[Product] [nvarchar](128) NULL,
	[Version] [nvarchar](128) NULL,
	[Edition] [nvarchar](128) NULL,
	[Platform] [nvarchar](128) NULL,
	[OSVersion] [nvarchar](128) NULL,
	[Processors] [int] NULL,
	[PhysicalMemory] [bigint] NULL,
	[RootDirectory] [nvarchar](260) NULL,
	[MasterDBPath] [nvarchar](260) NULL,
	[MasterDBLogPath] [nvarchar](260) NULL,
	[ErrorLogPath] [nvarchar](260) NULL,
 CONSTRAINT [PK_ServerInformation] PRIMARY KEY CLUSTERED 
(
	[ServerName] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY],
 CONSTRAINT [UX_ServerInformation_ServerGUID] UNIQUE NONCLUSTERED 
(
	[ServerGUID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [SSHIS].[ServerInformation] ADD  DEFAULT (newsequentialid()) FOR [ServerGUID]
GO
