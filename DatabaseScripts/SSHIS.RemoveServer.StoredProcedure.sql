USE [TFS_DB_Monitoring]
GO
/****** Object:  StoredProcedure [SSHIS].[RemoveServer]    Script Date: 12/04/2013 16:37:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* SSHIS Server Cleanup Script
   Created by Carlton B Ramsey on 7/16/2009
   This script will remove a server from the SQL Server Historical Information System (SSHIS)

   TO-DO:
   20100929 CBR Need to determine if cleaning up the EAInformation table should be part of this process.   
   20100929 CBR Need to make this a database procedure.   
*/
   
CREATE PROCEDURE [SSHIS].[RemoveServer](@ServerName nvarchar(128))
AS
BEGIN
DECLARE 
	@ServerGUID uniqueidentifier
	,@DatabaseName nvarchar(128)
	,@DatabaseGUID uniqueidentifier
	,@LogFileName nvarchar(128)
	,@LogFileGUID uniqueidentifier
	,@FileGroupName nvarchar(128)
	,@FileGroupGUID uniqueidentifier
	,@DataFileName nvarchar(128)
	,@DataFileGUID uniqueidentifier;

SET @ServerGUID = SSHIS.getServerGUID(@ServerName);

DECLARE @tblDatabaseLists TABLE(DatabaseName nvarchar(128), DatabaseGUID uniqueidentifier);
DECLARE @tblLogFileLists TABLE(LogFileName nvarchar(128), LogFileGUID uniqueidentifier);
DECLARE @tblFileGroupLists TABLE(FileGroupName nvarchar(128), FileGroupGUID uniqueidentifier);
DECLARE @tblDataFileLists TABLE(DataFileName nvarchar(128), DataFileGUID uniqueidentifier);


DECLARE CDatabaseLists CURSOR FAST_FORWARD FOR 
		SELECT DatabaseName, DatabaseGUID 
		  FROM SSHIS.DatabaseInformation
		 WHERE ServerGUID = @ServerGUID;

OPEN CDatabaseLists;
FETCH NEXT FROM CDatabaseLists INTO @DatabaseName, @DatabaseGUID
WHILE @@FETCH_STATUS = 0
	BEGIN
		IF @@FETCH_STATUS = 0
		BEGIN
			INSERT INTO @tblDatabaseLists(DatabaseName, DatabaseGUID)
			VALUES (@DatabaseName, @DatabaseGUID);			
		END
		FETCH NEXT FROM CDatabaseLists INTO @DatabaseName, @DatabaseGUID
	END

CLOSE CDatabaseLists;
DEALLOCATE CDatabaseLists;

DECLARE CLogFileLists CURSOR FAST_FORWARD FOR 
		SELECT FileName, LogFileGUID 
		  FROM SSHIS.LogFileInformation LFI
		 WHERE EXISTS (SELECT 1 
						 FROM @tblDatabaseLists DL 
						WHERE DL.DatabaseGUID = LFI.DatabaseGUID);

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
		 WHERE EXISTS (SELECT 1 
						 FROM @tblDatabaseLists DL 
						WHERE DL.DatabaseGUID = LFI.DatabaseGUID);

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
SELECT * FROM @tblDatabaseLists
SELECT * FROM @tblLogFileLists
SELECT * FROM @tblFileGroupLists
SELECT * FROM @tblDatafileLists
*/

BEGIN TRANSACTION 
	DELETE FROM SSHIS.DataFileHistoricalInformation WHERE DataFileGUID IN (SELECT DataFileGUID FROM @tblDatafileLists);
	DELETE FROM SSHIS.DataFileInformation WHERE DataFileGUID IN (SELECT DataFileGUID FROM @tblDatafileLists);
	DELETE FROM SSHIS.FileGroupInformation WHERE FileGroupGUID IN (SELECT FileGroupGUID FROM @tblFileGroupLists);
	DELETE FROM SSHIS.LogFileHistoricalInformation WHERE LogFileGUID IN (SELECT LogFileGUID FROM @tblLogfileLists);
	DELETE FROM SSHIS.LogFileInformation WHERE LogFileGUID IN (SELECT LogFileGUID FROM @tblLogfileLists);
	DELETE FROM SSHIS.DatabaseHistoricalInformation WHERE DatabaseGUID IN (SELECT DatabaseGUID FROM @tblDatabaseLists);
	DELETE FROM SSHIS.DatabaseInformation WHERE DatabaseGUID IN (SELECT DatabaseGUID FROM @tblDatabaseLists);
	DELETE FROM SSHIS.LoginInformation WHERE ServerGUID = @ServerGUID;
	DELETE FROM SSHIS.ServerInformation WHERE ServerGUID = @ServerGUID;
	DELETE FROM SSHIS.ServerDiskSpace WHERE NetName = @ServerName;
	DELETE FROM SSHIS.EAInformation WHERE NetName = @serverName;
COMMIT TRANSACTION
END
GO
