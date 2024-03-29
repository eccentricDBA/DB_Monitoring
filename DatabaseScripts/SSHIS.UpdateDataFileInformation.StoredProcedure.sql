USE [TFS_DB_Monitoring]
GO
/****** Object:  StoredProcedure [SSHIS].[UpdateDataFileInformation]    Script Date: 12/04/2013 16:37:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [SSHIS].[UpdateDataFileInformation](	@ServerName			nvarchar(128)
													,@DatabaseName		nvarchar(128)
													,@FileGroupName		nvarchar(128)
													,@FileName			nvarchar(128)
													,@FileFullName		nvarchar(260)
													,@GrowthType		nvarchar(260)
													,@Growth_KB			bigint
													,@Growth_Percent	int)
AS
	BEGIN
		DECLARE	@ServerGUID	uniqueidentifier
				,@DatabaseGUID	uniqueidentifier
				,@FileGroupGUID	uniqueidentifier
				,@DataFileGUID	uniqueidentifier;

		SET @ServerGUID = SSHIS.getServerGUID(@ServerName);
		SET @DatabaseGUID = SSHIS.getDatabaseGUID(@ServerGUID, @DatabaseName);
		SET @FileGroupGUID = SSHIS.getFileGroupGUID(@DatabaseGUID, @FileGroupName)
		SET @DataFileGUID = SSHIS.getDataFileGUID(@FileGroupGUID, @FileName);

		UPDATE [SSHIS].[DataFileInformation]
		   SET [FileGroupGUID] = @FileGroupGUID
			  ,[FileName] = @FileName
			  ,[FileFullName] = @FileFullName
			  ,[GrowthType] = @GrowthType
			  ,[Growth_KB] = @Growth_KB
			  ,[Growth_Percent] = @Growth_Percent
		 WHERE [DataFileGUID] = @DataFileGUID;
		IF @@ROWCOUNT = 0
			BEGIN
				INSERT INTO [SSHIS].[DataFileInformation]
						   ([FileGroupGUID]
						   ,[FileName]
						   ,[FileFullName]
						   ,[GrowthType]
						   ,[Growth_KB]
						   ,[Growth_Percent])
					 VALUES
						   (@FileGroupGUID
						   ,@FileName
						   ,@FileFullName
						   ,@GrowthType
						   ,@Growth_KB
						   ,@Growth_Percent);
			END;
	END;
GO
