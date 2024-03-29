USE [TFS_DB_Monitoring]
GO
/****** Object:  UserDefinedFunction [SSHIS].[getFileGroupGUID]    Script Date: 12/04/2013 16:37:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [SSHIS].[getFileGroupGUID](@DatabaseGUID uniqueidentifier, @FileGroupName nvarchar(128))
	   RETURNS uniqueidentifier
AS
	BEGIN
		DECLARE @FileGroupGUID uniqueidentifier;
		SELECT @FileGroupGUID = FileGroupGUID
		  FROM SSHIS.FileGroupInformation
		 WHERE DatabaseGUID = @DatabaseGUID
		   AND FileGroupName = @FileGroupName;
		RETURN @FileGroupGUID
	END;
GO
