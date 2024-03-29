USE [TFS_DB_Monitoring]
GO
/****** Object:  StoredProcedure [SSHIS].[UpdateServerInformation]    Script Date: 12/04/2013 16:37:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [SSHIS].[UpdateServerInformation](	@ServerName				nvarchar(128)
												,@NetName				nvarchar(128)
												,@InstanceName			nvarchar(128)
												,@Product				nvarchar(128) = 'Microsoft SQL Server'
												,@Version				nvarchar(128)
												,@Edition				nvarchar(128)
												,@Platform				nvarchar(128)
												,@OSVersion				nvarchar(128)
												,@Processors			int 
												,@PhysicalMemory		bigint
												,@RootDirectory			nvarchar(260)
												,@MasterDBPath			nvarchar(260)
												,@MasterDBLogPath		nvarchar(260)
												,@ErrorLogPath			nvarchar(260))
AS
	BEGIN
		DECLARE @ServerGUID uniqueidentifier;

		SET @ServerGUID = SSHIS.getServerGUID(@ServerName);

		UPDATE [SSHIS].[ServerInformation]
		   SET [NetName] = @NetName
			  ,[InstanceName] = @InstanceName
			  ,[Product] = @Product
			  ,[Version] = @Version
			  ,[Edition] = @Edition
			  ,[Platform] = @Platform
			  ,[OSVersion] = @OSVersion
			  ,[Processors] = @Processors
			  ,[PhysicalMemory] = @PhysicalMemory
			  ,[RootDirectory] = @RootDirectory
			  ,[MasterDBPath] = @MasterDBPath
			  ,[MasterDBLogPath] = @MasterDBLogPath
			  ,[ErrorLogPath] = @ErrorLogPath
		 WHERE [ServerGUID] = @ServerGUID;
		IF @@ROWCOUNT = 0
			BEGIN
				INSERT INTO [SSHIS].[ServerInformation]
				([ServerName]
				 ,[NetName]
				 ,[InstanceName]
				 ,[Product]
				 ,[Version]
				 ,[Edition]
				 ,[Platform]
				 ,[OSVersion]
				 ,[Processors]
				 ,[PhysicalMemory]
				 ,[RootDirectory]
				 ,[MasterDBPath]
				 ,[MasterDBLogPath]
				 ,[ErrorLogPath])
				VALUES
				(@ServerName
				 ,@NetName
				 ,@InstanceName
				 ,@Product
				 ,@Version
				 ,@Edition
				 ,@Platform
				 ,@OSVersion
				 ,@Processors
				 ,@PhysicalMemory
				 ,@RootDirectory
				 ,@MasterDBPath
				 ,@MasterDBLogPath
				 ,@ErrorLogPath);
			END;
	END;
GO
