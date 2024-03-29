USE [TFS_DB_Monitoring]
GO
/****** Object:  StoredProcedure [SSHIS].[UpdateFileGroupInformation]    Script Date: 12/04/2013 16:37:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [SSHIS].[UpdateFileGroupInformation](	@ServerName			nvarchar(128),
													@DatabaseName		nvarchar(128),	
													@FileGroupName		nvarchar(128),
													@IsDefault			bit,
													@IsReadOnly			bit)
AS
	BEGIN
		DECLARE @ServerGUID	uniqueidentifier
				,@DatabaseGUID uniqueidentifier
				,@FileGroupGUID uniqueidentifier;
		
		SET @ServerGUID = SSHIS.getServerGUID(@ServerName);
		SET @DatabaseGUID = SSHIS.getDatabaseGUID(@ServerGUID, @DatabaseName);
		SET @FileGroupGUID = SSHIS.getFileGroupGUID(@DatabaseGUID, @FileGroupName)

		UPDATE [SSHIS].[FileGroupInformation]
		   SET [DatabaseGUID] = @DatabaseGUID
			  ,[FileGroupName] = @FileGroupName
			  ,[IsDefault] = @IsDefault
			  ,[IsReadOnly] = @IsReadOnly
		 WHERE [FileGroupGUID] = @FileGroupGUID;
		IF @@ROWCOUNT = 0
			BEGIN
				INSERT INTO [SSHIS].[FileGroupInformation]
						   ([DatabaseGUID]
						   ,[FileGroupName]
						   ,[IsDefault]
						   ,[IsReadOnly])
					 VALUES
						   (@DatabaseGUID
						   ,@FileGroupName
						   ,@IsDefault
						   ,@IsReadOnly);
			END;
	END;
GO
