USE [TFS_DB_Monitoring]
GO
/****** Object:  StoredProcedure [SSHIS].[UpdateDataFileHistoricalInformation]    Script Date: 12/04/2013 16:37:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [SSHIS].[UpdateDataFileHistoricalInformation](	 @ServerName			nvarchar(128)
															 ,@DatabaseName			nvarchar(128)
															,@FileGroupName		nvarchar(128)
															,@FileName				nvarchar(128)
															,@AvailableSpace_KB	bigint
															,@Size_KB				bigint
															,@MaxSize_MB			bigint
															,@UsedSpace_KB			bigint)
AS
	BEGIN
		DECLARE	@ServerGUID	uniqueidentifier
				,@DatabaseGUID	uniqueidentifier
				,@FileGroupGUID	uniqueidentifier
				,@DataFileGUID	uniqueidentifier
				,@CurrentDate	datetime;

		SET @ServerGUID = SSHIS.getServerGUID(@ServerName);
		SET @DatabaseGUID = SSHIS.getDatabaseGUID(@ServerGUID, @DatabaseName);
		SET @FileGroupGUID = SSHIS.getFileGroupGUID(@DatabaseGUID, @FileGroupName)
		SET @DataFileGUID = SSHIS.getDataFileGUID(@FileGroupGUID, @FileName);
		SET @CurrentDate = Cast(CONVERT(VARCHAR(10), GETDATE(), 101) as datetime);

		UPDATE [SSHIS].[DataFileHistoricalInformation]
		   SET [AvailableSpace_KB] = @AvailableSpace_KB
			  ,[Size_KB] = @Size_KB
			  ,[MaxSize_MB] = @MaxSize_MB
			  ,[UsedSpace_KB] = @UsedSpace_KB
		 WHERE [DateReviewed] = @CurrentDate
		   AND [DataFileGUID] = @DataFileGUID;
		IF @@ROWCOUNT = 0
			BEGIN
				INSERT INTO [SSHIS].[DataFileHistoricalInformation]
						   ([DateReviewed]
						   ,[DataFileGUID]
						   ,[AvailableSpace_KB]
						   ,[Size_KB]
						   ,[MaxSize_MB]
						   ,[UsedSpace_KB])
					 VALUES
						   (@CurrentDate
						   ,@DataFileGUID
						   ,@AvailableSpace_KB
						   ,@Size_KB
						   ,@MaxSize_MB
						   ,@UsedSpace_KB);
			END;
	END;
GO
