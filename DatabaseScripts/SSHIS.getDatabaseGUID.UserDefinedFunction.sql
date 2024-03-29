USE [TFS_DB_Monitoring]
GO
/****** Object:  UserDefinedFunction [SSHIS].[getDatabaseGUID]    Script Date: 12/04/2013 16:37:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [SSHIS].[getDatabaseGUID](@ServerGUID uniqueidentifier, @DatabaseName nvarchar(128))
	   RETURNS uniqueidentifier
AS
	BEGIN
		DECLARE @DatabaseGUID uniqueidentifier;
		SELECT @DatabaseGUID = DatabaseGUID
		  FROM SSHIS.DatabaseInformation
		 WHERE ServerGUID = @ServerGUID
		   AND DatabaseName = @DatabaseName;
		RETURN @DatabaseGUID
	END;
GO
