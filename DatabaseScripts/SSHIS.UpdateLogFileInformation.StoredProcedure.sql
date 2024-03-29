USE [TFS_DB_Monitoring]
GO
/****** Object:  StoredProcedure [SSHIS].[UpdateLogFileInformation]    Script Date: 12/04/2013 16:37:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [SSHIS].[UpdateLogFileInformation](@ServerName			nvarchar(128)
												,@DatabaseName		nvarchar(128)
												,@FileName			nvarchar(128)
												,@FileFullName		nvarchar(260)
												,@GrowthType		nvarchar(260)
												,@Growth_KB			bigint
												,@Growth_Percent	int)
AS
	BEGIN
		DECLARE	@LogFileGUID uniqueidentifier
				,@ServerGUID	uniqueidentifier
				,@DatabaseGUID	uniqueidentifier;

		SET @ServerGUID = SSHIS.getServerGUID(@ServerName);
		SET @DatabaseGUID = SSHIS.getDatabaseGUID(@ServerGUID, @DatabaseName);
		SET @LogFileGUID = SSHIS.getLogFileGUID(@DatabaseGUID, @FileName);

		UPDATE [SSHIS].[LogFileInformation]
		   SET [DatabaseGUID] = @DatabaseGUID
			  ,[FileName] = @FileName
			  ,[FileFullName] = @FileFullName
			  ,[GrowthType] = @GrowthType
			  ,[Growth_KB] = @Growth_KB
			  ,[Growth_Percent] = @Growth_Percent
		 WHERE [LogFileGUID] = @LogFileGUID;
		IF @@ROWCOUNT = 0
			BEGIN
				INSERT INTO [SSHIS].[LogFileInformation]
						   ([DatabaseGUID]
						   ,[FileName]
						   ,[FileFullName]
						   ,[GrowthType]
						   ,[Growth_KB]
						   ,[Growth_Percent])
					 VALUES
						   (@DatabaseGUID
						   ,@FileName
						   ,@FileFullName
						   ,@GrowthType
						   ,@Growth_KB
						   ,@Growth_Percent);
			END;
	END;
GO
