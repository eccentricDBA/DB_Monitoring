USE [TFS_DB_Monitoring]
GO
/****** Object:  StoredProcedure [SSHIS].[usp_LogFileGrowthHistory]    Script Date: 12/04/2013 16:37:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [SSHIS].[usp_LogFileGrowthHistory]
	-- Add the parameters for the stored procedure here
	@servername sysname = '',
	@days_history int = 30
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    
	WITH FileSizeToday AS
	(SELECT LogFileGUID, UsedSpace_KB UsedSpace_KB_Today
	  FROM SSHIS.LogFileHistoricalInformation
	WHERE DATEDIFF(d, DateReviewed, GETDATE()) = 0),
	FileSizeYesterDay AS
	(SELECT LogFileGUID, UsedSpace_KB UsedSpace_KB_Yesterday
	  FROM SSHIS.LogFileHistoricalInformation
	WHERE DATEDIFF(d, DateReviewed, GETDATE()) = @days_history)
	SELECT ServerName, DatabaseName, FileGroupName, FileFullName, FileSizeToday.LogFileGUID,
		  CAST(CAST([UsedSpace_KB_Today] AS DECIMAL (12,2)) /1024 /1024 AS DECIMAL(12,2)) UsedSpace_GB_Today
		  ,CAST(CAST([UsedSpace_KB_Yesterday] AS DECIMAL (12,2)) /1024 / 1024 AS DECIMAL(12,2)) UsedSpace_GB_Yesterday
		  ,CAST(CAST(UsedSpace_KB_Today-UsedSpace_KB_Yesterday AS DECIMAL (12,2)) / 1024 / 1024 AS DECIMAL(12,2)) GrowthGB
		  ,CAST((CAST(UsedSpace_KB_Today AS DECIMAL (12,2))- CAST(UsedSpace_KB_Yesterday AS DECIMAL (12,2)))/ CAST(UsedSpace_KB_Today AS DECIMAL (12,2)) AS DECIMAL(8,3)) Percent_of_Growth
	  FROM SSHIS.ServerInformation
	INNER JOIN SSHIS.DatabaseInformation
	ON ServerInformation.ServerGUID = DatabaseInformation.ServerGUID
	INNER JOIN SSHIS.FileGroupInformation
	ON FileGroupInformation.DatabaseGUID = DatabaseInformation.DatabaseGUID
	INNER JOIN SSHIS.LogFileInformation
	ON LogFileInformation.DatabaseGUID = FileGroupInformation.DatabaseGUID
	INNER JOIN FileSizeToday
	ON LogFileInformation.LogFileGUID = FileSizeToday.LogFileGUID
	INNER JOIN FileSizeYesterDay
	ON FileSizeToday.LogFileGUID = FileSizeYesterDay.LogFileGUID
	where servername = @servername

END
GO
