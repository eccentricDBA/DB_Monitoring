USE [TFS_DB_Monitoring]
GO
/****** Object:  View [SSHIS].[View_LogFile_Growth_Between_Today_and_Yesterday]    Script Date: 12/04/2013 16:37:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [SSHIS].[View_LogFile_Growth_Between_Today_and_Yesterday]
AS
WITH FileSizeToday AS
(SELECT LogFileGUID, UsedSpace_KB UsedSpace_KB_Today
  FROM SSHIS.LogFileHistoricalInformation
WHERE DATEDIFF(d, DateReviewed, GETDATE()) = 0),

FileSizeYesterDay AS
(SELECT LogFileGUID, UsedSpace_KB UsedSpace_KB_Yesterday
  FROM SSHIS.LogFileHistoricalInformation
WHERE DATEDIFF(d, DateReviewed, GETDATE()) = 1)

SELECT si.ServerName, di.DatabaseName, '' as FileGroupName, lfi.FileFullName, fst.LogFileGUID,
CAST(CAST(fst.[UsedSpace_KB_Today] AS DECIMAL (12,2)) /1024 /1024 AS DECIMAL(12,2)) UsedSpace_GB_Today
,CAST(CAST(fsy.[UsedSpace_KB_Yesterday] AS DECIMAL (12,2)) /1024 / 1024 AS DECIMAL(12,2)) UsedSpace_GB_Yesterday
,CAST(CAST(fst.UsedSpace_KB_Today - fsy.UsedSpace_KB_Yesterday AS DECIMAL (12,2)) / 1024 / 1024 AS DECIMAL(12,2)) GrowthGB
,CAST((CAST(fst.UsedSpace_KB_Today AS DECIMAL (12,2))- CAST(fsy.UsedSpace_KB_Yesterday AS DECIMAL (12,2)))/ CAST(fst.UsedSpace_KB_Today AS DECIMAL (12,2)) AS DECIMAL(8,3)) Percent_of_Growth
FROM SSHIS.ServerInformation as si
INNER JOIN SSHIS.DatabaseInformation as di
ON si.ServerGUID = di.ServerGUID
INNER JOIN SSHIS.LogFileInformation as lfi
ON lfi.DatabaseGUID = di.DatabaseGUID
INNER JOIN FileSizeToday as fst
ON lfi.LogFileGUID = fst.LogFileGUID
INNER JOIN FileSizeYesterDay as fsy
ON fst.LogFileGUID = fsy.LogFileGUID;
GO
