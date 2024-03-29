USE [TFS_DB_Monitoring]
GO
/****** Object:  UserDefinedFunction [SSHIS].[getDataFileGUID]    Script Date: 12/04/2013 16:37:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [SSHIS].[getDataFileGUID](@FileGroupGUID uniqueidentifier, @DataFileName nvarchar(128))
	   RETURNS uniqueidentifier
AS
	BEGIN
		DECLARE @DataFileGUID uniqueidentifier;
		SELECT @DataFileGUID = DataFileGUID
		  FROM SSHIS.DataFileInformation
		 WHERE FileGroupGUID = @FileGroupGUID
		   AND FileName = @DataFileName;
		RETURN @DataFileGUID
	END;
GO
