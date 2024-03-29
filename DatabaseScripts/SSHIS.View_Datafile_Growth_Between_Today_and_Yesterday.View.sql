USE [TFS_DB_Monitoring]
GO
/****** Object:  View [SSHIS].[View_Datafile_Growth_Between_Today_and_Yesterday]    Script Date: 12/04/2013 16:37:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [SSHIS].[View_Datafile_Growth_Between_Today_and_Yesterday]
AS
WITH FileSizeToday AS
(SELECT DataFileGUID, UsedSpace_KB UsedSpace_KB_Today
  FROM SSHIS.DataFileHistoricalInformation
WHERE DATEDIFF(d, DateReviewed, GETDATE()) = 0),
FileSizeYesterDay AS
(SELECT DataFileGUID, UsedSpace_KB UsedSpace_KB_Yesterday
  FROM SSHIS.DataFileHistoricalInformation
WHERE DATEDIFF(d, DateReviewed, GETDATE()) = 1)
SELECT ServerName, DatabaseName, FileGroupName, FileFullName, FileSizeToday.DataFileGUID,
      CAST(CAST([UsedSpace_KB_Today] AS DECIMAL (12,2)) /1024 /1024 AS DECIMAL(12,2)) UsedSpace_GB_Today
      ,CAST(CAST([UsedSpace_KB_Yesterday] AS DECIMAL (12,2)) /1024 / 1024 AS DECIMAL(12,2)) UsedSpace_GB_Yesterday
      ,CAST(CAST(UsedSpace_KB_Today-UsedSpace_KB_Yesterday AS DECIMAL (12,2)) / 1024 / 1024 AS DECIMAL(12,2)) GrowthGB
      ,CAST((CAST(UsedSpace_KB_Today AS DECIMAL (12,2))- CAST(UsedSpace_KB_Yesterday AS DECIMAL (12,2)))/ CAST(UsedSpace_KB_Today AS DECIMAL (12,2)) AS DECIMAL(8,3)) Percent_of_Growth
  FROM SSHIS.ServerInformation
INNER JOIN SSHIS.DatabaseInformation
ON ServerInformation.ServerGUID = DatabaseInformation.ServerGUID
INNER JOIN SSHIS.FileGroupInformation
ON FileGroupInformation.DatabaseGUID = DatabaseInformation.DatabaseGUID
INNER JOIN SSHIS.DataFileInformation
ON DataFileInformation.FileGroupGUID = FileGroupInformation.FileGroupGUID
INNER JOIN FileSizeToday
ON DataFileInformation.DataFileGUID = FileSizeToday.DataFileGUID
INNER JOIN FileSizeYesterDay
ON FileSizeToday.DataFileGUID = FileSizeYesterDay.DataFileGUID;
GO
