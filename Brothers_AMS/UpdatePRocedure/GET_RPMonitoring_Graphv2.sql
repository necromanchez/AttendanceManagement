USE [Brother_AMSDB]
GO
/****** Object:  StoredProcedure [dbo].[GET_RPMonitoring_Graphv2]    Script Date: 11/26/2020 11:45:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




ALTER PROCEDURE [dbo].[GET_RPMonitoring_Graphv2]
	--DECLARE
	@DateFrom DATETIME = '11/01/2020',
	@DateTo DATETIME = '11/30/2020',
	@Shift BIGINT = '0',
	@Line BIGINT = '0',
	@Process BIGINT = '0',
	@SectionGroup NVARCHAR(50) = 'Printer',
	@Certified NVARCHAR(50) = null
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;
	SET ARITHABORT ON;
	IF OBJECT_ID('tempdb..#tmpBus') IS NOT NULL
		DROP TABLE #tmpBus;
	IF OBJECT_ID('tempdb..#checkCer') IS NOT NULL
		DROP TABLE #checkCer;
	IF OBJECT_ID('tempdb..#checkCer2') IS NOT NULL
		DROP TABLE #checkCer2;
	IF OBJECT_ID('tempdb..#OutputTable') IS NOT NULL
		DROP TABLE #OutputTable;


SELECT	  TT.Employee_RFID AS RFID
		, CASE WHEN (TT.DTR_RefNo IS NOT NULL) THEN TT.DTR_TimeIn ELSE TT.TimeIn END AS TimeIn
		, CASE WHEN (TT.DTR_RefNo IS NOT NULL) THEN TT.DTR_TimeOut ELSE TT.TimeOut END AS TimeOut
		, CASE WHEN (TT.CSRef_No IS NULL) THEN TT.ScheduleID ELSE TT.CS_ScheduleID END AS ScheduleID
		, TT.LineID
		, TT.ProcessID
		, MEL.EmpNo
		, MEL.Family_Name + ' ' + MEL.First_Name AS EmployeeName
		, MEL.Date_Hired
		, (SELECT top 1 MEC.Status FROM M_Employee_Status MEC WHERE MEC.EmployNo = MEL.EmpNo AND MEC.UpdateDate <= ISNULL(TT.TimeIn,TT.TimeOut) ORDER BY MEC.ID DESC) AS Status
		,(SELECT TOP 1 CostCenter_AMS FROM M_Employee_CostCenter WHERE EmployNo = MEL.EmpNo AND UpdateDate_AMS <= ISNULL(TT.TimeIn,TT.TimeOut) ORDER BY UpdateDate_AMS DESC) AS CostCenter_AMS
		--, MEC.CostCenter_AMS
INTO #tmpBus
FROM T_TimeInOut TT
JOIN M_Employee_Master_List MEL
ON TT.EmpNo = MEL.EmpNo
WHERE ISNULL(TT.TimeIn,TT.TimeOut) BETWEEN @DateFrom AND @DateTo + '23:59:59'
AND (SELECT TOP 1 MEC.CostCenter_AMS FROM M_Employee_CostCenter MEC WHERE MEC.EmployNo = MEL.EmpNo AND MEC.UpdateDate_AMS <= ISNULL(TimeIn,TimeOut) ORDER BY UpdateDate_AMS DESC) IN (SELECT Cost_Center
																																													 FROM M_Cost_Center_List
																																													 WHERE GroupSection = @SectionGroup
																																													 OR @SectionGroup= ''
																																													 OR @SectionGroup IS NULL)
		
AND Employee_RFID IS NOT NULL
GROUP BY  TT.Employee_RFID
		, TT.TimeIn
		, TT.TimeOut
		, TT.ScheduleID
		, TT.CSRef_No
		, TT.DTR_RefNo
		, TT.DTR_TimeIn
		, TT.DTR_TimeOut
		, TT.CS_ScheduleID
		, TT.LineID
		, TT.ProcessID
		, MEL.EmpNo
		, MEL.Family_Name
		, MEL.First_Name
		, MEL.Date_Hired
		, MEL.Status
		--, MEC.CostCenter_AMS
		, TT.ProcessID


SELECT CAST(CONVERT(Char(16), ISNULL(TB.TimeIn,TB.TimeOut) ,20) AS Date) AS InDate,
		ISNULL(CONVERT(VARCHAR(5),TB.TimeIn,108),'NoIn') AS TimeIn,
		CAST(CONVERT(Char(16), ISNULL(TB.TimeOut,TB.TimeOut) ,20) AS Date) AS InDateOut,
		CASE WHEN ISNULL(CONVERT(VARCHAR(5),TB.TimeOut,108),'NoOut') = '00:00' THEN 'NoOut' ELSE ISNULL(CONVERT(VARCHAR(5),TB.TimeOut,108),'NoOut') END AS TimeOut,
		ISNULL(MSS.Timein + '-' + MSS.TimeOut + '('+ MSS.Type + ')','') AS Shift,
		ISNULL(ML.Line, 'No Line') AS Line,
		ISNULL(MS.Skill,'No Process') AS Skill,
		TB.EmpNo,
		TB.EmployeeName,
		TB.Date_Hired,
		CASE WHEN (MES.CreateDate IS NULL) THEN NULL ELSE MES.CreateDate END AS DateCertified,
		TB.Status
		--TB.TTID
INTO #checkCer
FROM #tmpBus TB
LEFT JOIN M_LineTeam ML
ON TB.LineID = ML.ID
LEFT JOIN M_Employee_Skills MES
ON MES.EmpNo = TB.EmpNo AND MES.LineID = TB.LineID AND MES.SkillID = TB.ProcessID
LEFT JOIN M_Skills MS
ON MS.ID = TB.ProcessID
LEFT JOIN M_Schedule MSS
ON MSS.ID = TB.ScheduleID
WHERE (@Shift = 0 OR @Shift IS NULL OR @Shift = TB.ScheduleID)
AND (@Line = 0 OR @Line IS NULL OR @Line = ML.ID) 
AND (@Process = 0 OR @Process IS NULL OR @Process = MS.ID) 
--AND (@SectionGroup = '' OR @SectionGroup IS NULL OR TB.CostCenter_AMS IN (SELECT Cost_Center FROM M_Cost_Center_List WHERE GroupSection = @SectionGroup)) 


SELECT  a.*,
		CASE WHEN (DateCertified IS NOT NULL) THEN 'Green' ELSE 'Red' END AS 'Certified',
		(SELECT COUNT(EmpNo)
		 FROM #checkCer
		 WHERE InDate = a.InDate
		 AND EmpNo = a.EmpNo) AS CountTransfer
INTO #checkCer2
FROM #checkCer a

SELECT *, (CASE WHEN(CountTransfer = 1 AND Certified = 'Green') THEN 'Black'
			    WHEN(CountTransfer = 1 AND Certified = 'Red') THEN 'Red'
				WHEN(CountTransfer > 1 AND Certified = 'Red') THEN 'Red'
				ELSE 'Green' END
		   ) AS TrueColor
INTO #OutputTable
FROM #checkCer2
oRDER BY EmpNo, InDate,TimeIn



	IF OBJECT_ID('tempdb..#CountTable') IS NOT NULL
		DROP TABLE #CountTable
		IF OBJECT_ID('tempdb..#CountTable2') IS NOT NULL
		DROP TABLE #CountTable2
		IF OBJECT_ID('tempdb..#CountTable3') IS NOT NULL
		DROP TABLE #CountTable3
		IF OBJECT_ID('tempdb..#CountTable4') IS NOT NULL
		DROP TABLE #CountTable4
		IF OBJECT_ID('tempdb..#CountTable5') IS NOT NULL
		DROP TABLE #CountTable5
		IF OBJECT_ID('tempdb..#FixedTable') IS NOT NULL
		DROP TABLE #FixedTable
		IF OBJECT_ID('tempdb..#DaysinMonth') IS NOT NULL
		DROP TABLE #DaysinMonth


		DECLARE
		@MinDate DATE = @DateFrom,
		@MaxDate DATE = @DateTo
SELECT  TOP (DATEDIFF(DAY, @MinDate, @MaxDate) + 1)
			Date = DATEADD(DAY, ROW_NUMBER() OVER(ORDER BY a.object_id) - 1, @MinDate)
			INTO #DaysinMonth
	FROM    sys.all_objects a
			CROSS JOIN sys.all_objects b;

SELECT InDate, EmpNo, Skill, Certified, TimeIn
INTO #CountTable2
FROM #OutputTable
Group BY InDate, EmpNo, Skill,Certified, TimeIn
--WHERE EmpNo ='biph2019-03060'

--SELECT InDate, EmpNo FROM #OutputTable

SELECT CT.*, (SELECT COUNT(*) FROM #CountTable2 WHERE EmpNo = CT.EmpNo AND InDate = CT.InDate) AS CountTransfer
INTO #CountTable3
FROM #CountTable2 CT
ORDER BY CT.InDate


	SELECT  InDate, EmpNo, (
					SELECT TOP 1 CASE WHEN (CountTransfer = 1 AND Certified = 'Green') THEN 'Black'
						        WHEN (CountTransfer = 1 AND Certified = 'Red') THEN 'Red'
								WHEN (CountTransfer > 1 AND (Certified = 'Red' OR Certified = 'Green')) THEN 'Yellow'
								ELSE 'Green' END 
					FROM #CountTable3
					WHERE EmpNo = CT3.EmpNo
					AND InDate = CT3.InDate
					AND Skill = CT3.Skill
					AND TimeIn = CT3.TimeIn
					AND (@Certified = '' OR @Certified IS NULL OR Certified = @Certified) 
				) AS TrueColor
	INTO #CountTable4
	FROM #CountTable3 CT3
	ORDER BY InDate

	SELECT *
	INTO #FixedTable
	FROM #CountTable4
	GROUP BY InDate, EmpNo, TrueColor

	--SELECT * FROM #FixedTable

	SELECT InDate, TrueColor, Count(*) AS HeadCount
	INTO #CountTable5
	FROM #FixedTable
	GROUP BY InDate, TrueColor
	ORDER BY InDate

	CREATE TABLE #OuputTbl(
			
			InDate DATE NOT NULL,
			TrueColor NVARCHAR(20) NOT NULL,
			HeadCount INT NOT NULL
	
	)



	INSERT INTO #OuputTbl(InDate,TrueColor,HeadCount)
	SELECT  aa.Date AS InDate,
			ISNULL(a.TrueColor,'Red') AS TrueColor,
			ISNULL(a.HeadCount,0) AS HeadCount
	FROM #DaysinMonth aa
	LEFT JOIN #CountTable5 a
	ON a.InDate = aa.Date
	WHERE a.TrueColor IS NOT NULL


	SELECT *
	FROM #OuputTbl
	ORDER BY InDate


	--SELECT  GETDATE() AS InDate,
	--		'TimeinNew' AS TrueColor,
	--		1 AS HeadCount


	DROP TABLE #OuputTbl

END



















