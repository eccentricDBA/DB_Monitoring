USE [TFS_DB_Monitoring]
GO
/****** Object:  UserDefinedFunction [SSHIS].[getLoginGUID]    Script Date: 12/04/2013 16:37:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [SSHIS].[getLoginGUID](@ServerGUID uniqueidentifier, @LoginName nvarchar(128))
	   RETURNS uniqueidentifier
AS
	BEGIN
		DECLARE @LoginGUID uniqueidentifier;
		SELECT @LoginGUID = LoginGUID
		  FROM SSHIS.LoginInformation
		 WHERE ServerGUID = @ServerGUID
		   AND LoginName = @LoginName;
		RETURN @LoginGUID
	END;
GO
