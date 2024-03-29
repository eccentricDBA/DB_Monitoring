USE [TFS_DB_Monitoring]
GO
/****** Object:  UserDefinedFunction [SSHIS].[getLogFileGUID]    Script Date: 12/04/2013 16:37:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [SSHIS].[getLogFileGUID](@DatabaseGUID uniqueidentifier, @LogFileName nvarchar(128))
	   RETURNS uniqueidentifier
AS
	BEGIN
		DECLARE @LogFileGUID uniqueidentifier;
		SELECT @LogFileGUID = LogFileGUID
		  FROM SSHIS.LogFileInformation
		 WHERE DatabaseGUID = @DatabaseGUID
		   AND FileName = @LogFileName;
		RETURN @LogFileGUID
	END;
GO
