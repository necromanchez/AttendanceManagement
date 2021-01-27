USE [Brother_AMSDB]
GO
/****** Object:  StoredProcedure [dbo].[AF_EmailCSRequestApprovers]    Script Date: 1/27/2021 10:24:35 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[AF_EmailCSRequestApprovers] 
--DECLARE
--@CSRefno NVARCHAR(MAX) = 'CS-ProductionEngineering_20201023134324'
AS

BEGIN

IF OBJECT_ID('tempdb..#GroupCS') IS NOT NULL
		DROP TABLE #GroupCS;

SELECT  (SELECT TOP 1 s.GroupSection FROM M_Cost_Center_List s WHERE s.Cost_Center = a.Section) Section,
		CS_RefNo,
		CONVERT(VARCHAR(10),CreateDate,120) as CreateDate,
		CreateID
INTO #GroupCS
FROM AF_ChangeSchedulefiling a
WHERE a.CS_RefNo NOT IN (
SELECT aa.RefNo
FROM M_Section_ApproverStatus aa
) 
GROUP BY a.CS_RefNo,a.Section,CONVERT(VARCHAR(10),CreateDate,120),CreateID

DECLARE @RefNo NVARCHAR(100), 
		@Section NVARCHAR(100),
		@CreateDate NVARCHAR(100),
		@CreateID NVARCHAR(100)
DECLARE MY_CURSOR CURSOR 
  LOCAL STATIC READ_ONLY FORWARD_ONLY
FOR 

SELECT CS_RefNo,Section,CreateDate,CreateID
FROM #GroupCS
GROUP BY CS_RefNo,Section,CreateDate,CreateID


OPEN MY_CURSOR
FETCH  FROM MY_CURSOR INTO @RefNo, @Section,@CreateDate,@CreateID
WHILE @@FETCH_STATUS = 0
BEGIN

INSERT INTO [dbo].[M_Section_ApproverStatus]
           ([Section]
           ,[RefNo]
           ,[EmployeeNo]
           ,[Position]
           ,[Approved]
           ,[OverTimeType]
           ,[CreateID]
           ,[CreateDate]
           ,[UpdateID]
           ,[UpdateDate]
           ,[ApprovedDate])
SELECT @Section,@RefNo, a.EmployeeNo, a.Position,0,'',@CreateID,@CreateDate,@CreateID,@CreateDate,NULL
FROM M_Section_Approver a
WHERE a.Section = @Section


--EXEC AF_EmailCSRequest @RefNo

FETCH NEXT FROM MY_CURSOR INTO @RefNo,@Section,@CreateDate,@CreateID

END
CLOSE MY_CURSOR
DEALLOCATE MY_CURSOR

END

