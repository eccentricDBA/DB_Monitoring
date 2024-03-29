USE [TFS_DB_Monitoring]
GO
/****** Object:  StoredProcedure [SSHIS].[UpdateLogFileHistoricalInformation]    Script Date: 12/04/2013 16:37:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [SSHIS].[UpdateLogFileHistoricalInformation](	@ServerName			nvarchar(128)
															,@DatabaseName		nvarchar(128)
															,@FileName			nvarchar(128)
															,@Size_KB			bigint
															,@MaxSize_MB		bigint
															,@UsedSpace_KB		bigint)
AS
	BEGIN
		DECLARE	@LogFileGUID uniqueidentifier
				,@ServerGUID	uniqueidentifier
				,@DatabaseGUID	uniqueidentifier
				,@CurrentDate	datetime;

		SET @ServerGUID = SSHIS.getServerGUID(@ServerName);
		SET @DatabaseGUID = SSHIS.getDatabaseGUID(@ServerGUID, @DatabaseName);
		SET @LogFileGUID = SSHIS.getLogFileGUID(@DatabaseGUID, @FileName);
		SET @CurrentDate = Cast(CONVERT(VARCHAR(10), GETDATE(), 101) as datetime);

		UPDATE [SSHIS].[LogFileHistoricalInformation]
		   SET [Size_KB] = @Size_KB
			  ,[MaxSize_MB] = @MaxSize_MB
			  ,[UsedSpace_KB] = @UsedSpace_KB
		 WHERE [DateReviewed] = @CurrentDate
		   AND [LogFileGUID] = @LogFileGUID;
		IF @@ROWCOUNT = 0
			BEGIN
				INSERT INTO [SSHIS].[LogFileHistoricalInformation]
						   ([DateReviewed]
						   ,[LogFileGUID]
						   ,[Size_KB]
						   ,[MaxSize_MB]
						   ,[UsedSpace_KB])
					 VALUES
						   (@CurrentDate
						   ,@LogFileGUID
						   ,@Size_KB
						   ,@MaxSize_MB
						   ,@UsedSpace_KB);
			END;
	END;
GO
