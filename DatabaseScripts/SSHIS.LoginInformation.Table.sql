USE [TFS_DB_Monitoring]
GO
/****** Object:  Table [SSHIS].[LoginInformation]    Script Date: 12/04/2013 16:37:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SSHIS].[LoginInformation](
	[LoginGUID] [uniqueidentifier] NOT NULL,
	[ServerGUID] [uniqueidentifier] NOT NULL,
	[LoginName] [nvarchar](128) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
	[DateLastModified] [datetime] NOT NULL,
	[DefaultDatabase] [nvarchar](128) NOT NULL,
	[DenyWindowsLogin] [bit] NOT NULL,
	[HasAccess] [bit] NOT NULL,
	[IsDisabled] [bit] NOT NULL,
	[IsSystemObject] [bit] NOT NULL,
	[Language] [nvarchar](128) NOT NULL,
	[LanguageAlias] [nvarchar](128) NOT NULL,
	[LoginType] [nvarchar](128) NOT NULL,
	[PasswordPolicyEnforced] [bit] NULL,
	[IsLocked] [bit] NULL,
	[IsPasswordExpired] [bit] NULL,
	[MustChangePassword] [bit] NULL,
	[PasswordExpirationEnabled] [bit] NULL,
	[ReviewDate] [datetime] NOT NULL,
 CONSTRAINT [PK_LoginInformation] PRIMARY KEY CLUSTERED 
(
	[ServerGUID] ASC,
	[LoginGUID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY],
 CONSTRAINT [UX_LoginInformation_LoginGUID] UNIQUE NONCLUSTERED 
(
	[LoginGUID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [SSHIS].[LoginInformation]  WITH CHECK ADD  CONSTRAINT [FK_LoginInformation_ServerInformation] FOREIGN KEY([ServerGUID])
REFERENCES [SSHIS].[ServerInformation] ([ServerGUID])
GO
ALTER TABLE [SSHIS].[LoginInformation] CHECK CONSTRAINT [FK_LoginInformation_ServerInformation]
GO
ALTER TABLE [SSHIS].[LoginInformation] ADD  DEFAULT (newsequentialid()) FOR [LoginGUID]
GO
