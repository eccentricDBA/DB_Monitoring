USE [TFS_DB_Monitoring]
GO
/****** Object:  StoredProcedure [SSHIS].[UpdateDatabaseHistoricalInformation]    Script Date: 12/04/2013 16:37:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [SSHIS].[UpdateDatabaseHistoricalInformation](@ServerName			nvarchar(128),
														 @DatabaseName			nvarchar(128),
														 @Status				nvarchar(128),
														 @DataSpaceUsage_KB		bigint,
														 @IndexSpaceUsage_KB	bigint,
														 @SpaceAvailable_KB		bigint,
														 @DatabaseSize_MB		bigint)
AS
	BEGIN
		DECLARE @CurrentDate datetime;
		DECLARE @ServerGUID uniqueidentifier
				,@DatabaseGUID uniqueidentifier;

		SET @CurrentDate = Cast(CONVERT(VARCHAR(10), GETDATE(), 101) as datetime);
		SET @ServerGUID = SSHIS.getServerGUID(@ServerName);
		SET @DatabaseGUID = SSHIS.getDatabaseGUID(@ServerGUID, @DatabaseName);

		UPDATE [SSHIS].[DatabaseHistoricalInformation]
		   SET [Status] = @Status
			  ,[DataSpaceUsage_KB] = @DataSpaceUsage_KB
			  ,[IndexSpaceUsage_KB] = @IndexSpaceUsage_KB
			  ,[SpaceAvailable_KB] = @SpaceAvailable_KB
			  ,[DatabaseSize_MB] = @DatabaseSize_MB
		 WHERE [DateReviewed] = @CurrentDate 
		   AND [DatabaseGUID] = @DatabaseGUID;
		IF @@ROWCOUNT = 0
			BEGIN
				INSERT INTO [SSHIS].[DatabaseHistoricalInformation]
						   ([DateReviewed]
						   ,[DatabaseGUID]
						   ,[Status]
						   ,[DataSpaceUsage_KB]
						   ,[IndexSpaceUsage_KB]
						   ,[SpaceAvailable_KB]
						   ,[DatabaseSize_MB])
					 VALUES
						   (@CurrentDate
						   ,@DatabaseGUID
						   ,@Status
						   ,@DataSpaceUsage_KB
						   ,@IndexSpaceUsage_KB
						   ,@SpaceAvailable_KB
						   ,@DatabaseSize_MB);
			END;
	END;
GO
