USE [TFS_DB_Monitoring]
GO
/****** Object:  StoredProcedure [SSHIS].[UpdateDatabaseInformation]    Script Date: 12/04/2013 16:37:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [SSHIS].[UpdateDatabaseInformation](	@ServerName			nvarchar(128),
													@DatabaseName		nvarchar(128),
													@CompatibilityLevel	nvarchar(128),
													@PrimaryFilePath	nvarchar(128),
													@CreateDate			datetime,
													@LastBackupDate		datetime,
													@LastLogBackupDate	datetime,
													@RecoveryModel	nvarchar(30))
AS
	BEGIN
		DECLARE @ServerGUID uniqueidentifier
				,@DatabaseGUID uniqueidentifier;

		SET @ServerGUID = SSHIS.getServerGUID(@ServerName);
		SET @DatabaseGUID = SSHIS.getDatabaseGUID(@ServerGUID, @DatabaseName);

		UPDATE [SSHIS].[DatabaseInformation]
		   SET  [DatabaseName] = @DatabaseName
				,[CompatibilityLevel] = @CompatibilityLevel
				,[PrimaryFilePath] = @PrimaryFilePath
				,[CreateDate] = @CreateDate
				,[LastBackupDate] = @LastBackupDate
				,[LastLogBackupDate] = @LastLogBackupDate
				,[RecoveryModel] = @RecoveryModel
		WHERE [DatabaseGUID] = @DatabaseGUID
		  AND [ServerGUID] = @ServerGUID;
		IF @@ROWCOUNT = 0
			BEGIN
				INSERT INTO [SSHIS].[DatabaseInformation]
						   ([ServerGUID]
						   ,[DatabaseName]
						   ,[CompatibilityLevel]
						   ,[PrimaryFilePath]
						   ,[CreateDate]
						   ,[LastBackupDate]
						   ,[LastLogBackupDate]
						   ,[RecoveryModel])
					 VALUES
						   (@ServerGUID
						   ,@DatabaseName
						   ,@CompatibilityLevel
						   ,@PrimaryFilePath
						   ,@CreateDate
						   ,@LastBackupDate
						   ,@LastLogBackupDate
						   ,@RecoveryModel);
			END;
	END;
GO
