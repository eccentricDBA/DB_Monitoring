USE [TFS_DB_Monitoring]
GO
/****** Object:  UserDefinedFunction [SSHIS].[getServerGUID]    Script Date: 12/04/2013 16:37:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [SSHIS].[getServerGUID](@ServerName nvarchar(128))
	   RETURNS uniqueidentifier
AS
	BEGIN
		DECLARE @ServerGUID uniqueidentifier;
		SELECT @ServerGUID = ServerGUID
		  FROM SSHIS.ServerInformation
		 WHERE ServerName = @ServerName;
		RETURN @ServerGUID
	END;
GO
