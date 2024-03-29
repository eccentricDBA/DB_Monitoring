USE [TFS_DB_Monitoring]
GO
/****** Object:  StoredProcedure [SSHIS].[RemoveDatabase]    Script Date: 12/04/2013 16:37:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* SSHIS Database Cleanup Script
   Created by Carlton B Ramsey on 7/16/2009
   This script will remove a database from the SQL Server Historical Information System (SSHIS) */
CREATE PROCEDURE [SSHIS].[RemoveDatabase] (@ServerName nvarchar(128), @DatabaseName nvarchar(128))
AS 
BEGIN
DECLARE 
	@ServerGUID uniqueidentifier
	,@DatabaseGUID uniqueidentifier
	,@LogFileName nvarchar(128)
	,@LogFileGUID uniqueidentifier
	,@FileGroupName nvarchar(128)
	,@FileGroupGUID uniqueidentifier
	,@DataFileName nvarchar(128)
	,@DataFileGUID uniqueidentifier;

SET @ServerGUID = SSHIS.getServerGUID(@ServerName);
SET @DatabaseGUID = SSHIS.getDatabaseGUID(@ServerGUID, @DatabaseName);

DECLARE @tblLogFileLists TABLE(LogFileName nvarchar(128), LogFileGUID uniqueidentifier);
DECLARE @tblFileGroupLists TABLE(FileGroupName nvarchar(128), FileGroupGUID uniqueidentifier);
DECLARE @tblDataFileLists TABLE(DataFileName nvarchar(128), DataFileGUID uniqueidentifier);


DECLARE CLogFileLists CURSOR FAST_FORWARD FOR 
		SELECT FileName, LogFileGUID 
		  FROM SSHIS.LogFileInformation LFI
		 WHERE DatabaseGUID = @DatabaseGUID;

OPEN CLogFileLists;
FETCH NEXT FROM CLogFileLists INTO @LogFileName, @LogFileGUID
WHILE @@FETCH_STATUS = 0
	BEGIN
		IF @@FETCH_STATUS = 0
		BEGIN
			INSERT INTO @tblLogFileLists(LogFileName, LogFileGUID)
			VALUES (@LogFileName, @LogFileGUID);			
		END
		FETCH NEXT FROM CLogFileLists INTO @LogFileName, @LogFileGUID
	END

CLOSE CLogFileLists;
DEALLOCATE CLogFileLists;

DECLARE CFileGroupLists CURSOR FAST_FORWARD FOR 
		SELECT FileGroupName, FileGroupGUID 
		  FROM SSHIS.FileGroupInformation LFI
		 WHERE DatabaseGUID = @DatabaseGUID;

OPEN CFileGroupLists;
FETCH NEXT FROM CFileGroupLists INTO @FileGroupName, @FileGroupGUID
WHILE @@FETCH_STATUS = 0
	BEGIN
		IF @@FETCH_STATUS = 0
		BEGIN
			INSERT INTO @tblFileGroupLists(FileGroupName, FileGroupGUID)
			VALUES (@FileGroupName, @FileGroupGUID);			
		END
		FETCH NEXT FROM CFileGroupLists INTO @FileGroupName, @FileGroupGUID
	END

CLOSE CFileGroupLists;
DEALLOCATE CFileGroupLists;

DECLARE CDataFileLists CURSOR FAST_FORWARD FOR 
		SELECT FileName, DataFileGUID 
		  FROM SSHIS.DataFileInformation DFI
		 WHERE EXISTS (SELECT 1 
						 FROM @tblFileGroupLists FGL 
						WHERE FGL.FileGroupGUID = DFI.FileGroupGUID);
OPEN CDataFileLists;
FETCH NEXT FROM CDataFileLists INTO @DataFileName, @DataFileGUID
WHILE @@FETCH_STATUS = 0
	BEGIN
		IF @@FETCH_STATUS = 0
		BEGIN
			INSERT INTO @tblDataFileLists(DataFileName, DataFileGUID)
			VALUES (@DataFileName, @DataFileGUID);			
		END
		FETCH NEXT FROM CDataFileLists INTO @DataFileName, @DataFileGUID
	END

CLOSE CDataFileLists;
DEALLOCATE CDataFileLists;


/*
SELECT * FROM @tblLogFileLists
SELECT * FROM @tblFileGroupLists
SELECT * FROM @tblDataFileLists
*/

BEGIN TRANSACTION 
	DELETE FROM SSHIS.DataFileHistoricalInformation WHERE DataFileGUID IN (SELECT DataFileGUID FROM @tblDatafileLists);
	DELETE FROM SSHIS.DataFileInformation WHERE DataFileGUID IN (SELECT DataFileGUID FROM @tblDatafileLists);
	DELETE FROM SSHIS.FileGroupInformation WHERE FileGroupGUID IN (SELECT FileGroupGUID FROM @tblFileGroupLists);
	DELETE FROM SSHIS.LogFileHistoricalInformation WHERE LogFileGUID IN (SELECT LogFileGUID FROM @tblLogfileLists);
	DELETE FROM SSHIS.LogFileInformation WHERE LogFileGUID IN (SELECT LogFileGUID FROM @tblLogfileLists);
	DELETE FROM SSHIS.DatabaseHistoricalInformation WHERE DatabaseGUID = @DatabaseGUID;
	DELETE FROM SSHIS.DatabaseInformation WHERE DatabaseGUID = @DatabaseGUID;
COMMIT TRANSACTION
END
GO
