USE [TFS_DB_Monitoring]
GO
/****** Object:  StoredProcedure [SSHIS].[UpdateLoginInformation]    Script Date: 12/04/2013 16:37:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [SSHIS].[UpdateLoginInformation](	@ServerName					nvarchar(128),
													@LoginName					nvarchar(128),
													@CreateDate					datetime,
													@DateLastModified			datetime,
													@DefaultDatabase			nvarchar(128),
													@DenyWindowsLogin			bit,
													@HasAccess					bit,
													@IsDisabled					bit,
													@IsSystemObject				bit,
													@Language					nvarchar(128),
													@LanguageAlias				nvarchar(128),
													@LoginType					nvarchar(128),
													@PasswordPolicyEnforced		bit,
													@IsLocked					bit,
													@IsPasswordExpired			bit,
													@MustChangePassword			bit,
													@PasswordExpirationEnabled	bit)
AS
	BEGIN
		DECLARE @ServerGUID uniqueidentifier
				,@LoginGUID uniqueidentifier
				,@ReviewDate datetime;

		SET @ReviewDate = GETDATE();
		SET @ServerGUID = SSHIS.getServerGUID(@ServerName);
		SET @LoginGUID = SSHIS.getLoginGUID(@ServerGUID, @LoginName);

		UPDATE [SSHIS].[LoginInformation]
		   SET	[LoginName] = @LoginName
				,[CreateDate] = @CreateDate
				,[DateLastModified] = @DateLastModified
				,[DefaultDatabase] = @DefaultDatabase
				,[DenyWindowsLogin] = @DenyWindowsLogin
				,[HasAccess] = @HasAccess
				,[IsDisabled] = @IsDisabled
				,[IsSystemObject] = @IsSystemObject
				,[Language] = @Language
				,[LanguageAlias] = @LanguageAlias
				,[LoginType] = @LoginType
				,[PasswordPolicyEnforced] = @PasswordPolicyEnforced
				,[IsLocked] = @IsLocked
				,[IsPasswordExpired] = @IsPasswordExpired
				,[MustChangePassword] = @MustChangePassword
				,[PasswordExpirationEnabled] = @PasswordExpirationEnabled
				,[ReviewDate] = @ReviewDate
		WHERE [LoginGUID] = @LoginGUID
		  AND [ServerGUID] = @ServerGUID;
		IF @@ROWCOUNT = 0
			BEGIN
				INSERT INTO [SSHIS].[LoginInformation]
						   ([ServerGUID]
							,[LoginName]
							,[CreateDate]
							,[DateLastModified]
							,[DefaultDatabase]
							,[DenyWindowsLogin]
							,[HasAccess]
							,[IsDisabled]
							,[IsSystemObject]
							,[Language]
							,[LanguageAlias]
							,[LoginType]
							,[PasswordPolicyEnforced]
							,[IsLocked]
							,[IsPasswordExpired]
							,[MustChangePassword]
							,[PasswordExpirationEnabled]
							,[ReviewDate])
					 VALUES
						   (@ServerGUID
							,@LoginName
							,@CreateDate
							,@DateLastModified
							,@DefaultDatabase
							,@DenyWindowsLogin
							,@HasAccess
							,@IsDisabled
							,@IsSystemObject
							,@Language
							,@LanguageAlias
							,@LoginType
							,@PasswordPolicyEnforced
							,@IsLocked
							,@IsPasswordExpired
							,@MustChangePassword
							,@PasswordExpirationEnabled
							,@ReviewDate);
			END;
	END;
GO
