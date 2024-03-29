USE [TFS_DB_Monitoring]
GO
/****** Object:  StoredProcedure [SSHIS].[PurgeHistoricalInformation]    Script Date: 12/04/2013 16:37:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [SSHIS].[PurgeHistoricalInformation](@NoofMonthstoKeep int)
AS
	BEGIN
		SET ROWCOUNT 10000
		WHILE(1=1)
			BEGIN	
				DELETE FROM SSHIS.LogFileHistoricalInformation WHERE DATEDIFF(m,[DateReviewed], getdate())  < @NoofMonthstoKeep;
				IF @@ROWCOUNT = 0
					BEGIN
						BREAK
					END;
			END;

		WHILE(1=1)
			BEGIN
				DELETE FROM SSHIS.DataFileHistoricalInformation WHERE DATEDIFF(m,[DateReviewed], getdate()) < @NoofMonthstoKeep;
				IF @@ROWCOUNT = 0
					BEGIN
						BREAK
					END;
			END;

		WHILE(1=1)
			BEGIN
			DELETE FROM SSHIS.DatabaseHistoricalInformation WHERE DATEDIFF(m,[DateReviewed], getdate()) < @NoofMonthstoKeep;
				IF @@ROWCOUNT = 0
					BEGIN
						BREAK
					END;
			END;

		SET ROWCOUNT 0
	END
;
GO
