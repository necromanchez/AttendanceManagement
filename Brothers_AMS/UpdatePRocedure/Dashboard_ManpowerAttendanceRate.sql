USE [Brother_AMSDB]
GO
/****** Object:  StoredProcedure [dbo].[Dashboard_ManpowerAttendanceRate]    Script Date: 11/27/2020 12:30:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		Chester R.
-- Create date: 01-06-2020
-- Description:	GET Manpower Change Monitoring
-- =============================================

ALTER PROCEDURE [dbo].[Dashboard_ManpowerAttendanceRate] 
	--DECLARE
	@Month INT =11,
	@Year INT = 2020,
	@Agency NVARCHAR(50) = '',
	@Shift NVARCHAR(20) = '',
	@Line BIGINT = NULL,
	@CostCode NVARCHAR(50) = '6210'
AS

BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;
	SET ARITHABORT ON;
	IF OBJECT_ID('tempdb..#tmpBus') IS NOT NULL
		DROP TABLE #tmpBus;
	IF OBJECT_ID('tempdb..#tmpBus2') IS NOT NULL
		DROP TABLE #tmpBus2;
	IF OBJECT_ID('tempdb..#checkCer') IS NOT NULL
		DROP TABLE #checkCer;
	IF OBJECT_ID('tempdb..#checkCer2') IS NOT NULL
		DROP TABLE #checkCer2;
	IF OBJECT_ID('tempdb..#OutputTable') IS NOT NULL
		DROP TABLE #OutputTable;
	IF OBJECT_ID('tempdb..#EmployeeShift') IS NOT NULL
		DROP TABLE #EmployeeShift;
	IF OBJECT_ID('tempdb..#DaysMonth') IS NOT NULL
		DROP TABLE #DaysMonth;
	IF OBJECT_ID('tempdb..#MinusMP_ML') IS NOT NULL
		DROP TABLE #MinusMP_ML

	IF OBJECT_ID('tempdb..#MinusMP_NW') IS NOT NULL
	DROP TABLE #MinusMP_NW
	;WITH N(N)AS 
	(SELECT 1 FROM(VALUES(1),(1),(1),(1),(1),(1))M(N)),
	tally(N)AS(SELECT ROW_NUMBER()OVER(ORDER BY N.N)FROM N,N a)
	SELECT datefromparts(@Year,@Month,N) date 
	INTO #DaysMonth
	FROM tally
	WHERE N <= day(EOMONTH(datefromparts(@Year,@Month,1)))


	
	DECLARE @SectionGroup NVARCHAR(50)
    SET @SectionGroup = (SELECT GroupSection FROM M_Cost_Center_List WHERE Cost_Center = @CostCode);

	--SELECT @SectionGroup

	DECLARE @DateFrom DATETIME, @DateTo DATETIME;
	SET @DateFrom = (SELECT TOP 1 date FROM #DaysMonth ORDER BY date)
	SET @DateTo = (SELECT TOP 1 date FROM #DaysMonth ORDER BY date DESC)
	SET @DateTo = @DateTo + '23:59:59'
	--SELECT @DateFrom
	--SELECT @DateTo

	DECLARE @EndofMonthDay INT
	SET @EndofMonthDay = (SELECT TOP 1 Day(date) FROM #DaysMonth ORDER BY date DESC)
	--############### FOR Man power COUNT ########################
	BEGIN --MP COUNT
	IF OBJECT_ID('tempdb..#Table1MPCount') IS NOT NULL
		DROP TABLE #Table1MPCount;
	IF OBJECT_ID('tempdb..#Table2MPCount') IS NOT NULL
		DROP TABLE #Table2MPCount;
	IF OBJECT_ID('tempdb..#MPCountTB') IS NOT NULL
		DROP TABLE #MPCountTB;

	CREATE TABLE #MPCountTB(
		InDate DATETIME,
		mpcount INT
	)


	SELECT EmpNo, date,
	ISNULL((SELECT TOP 1 s.Schedule FROM AF_ChangeSchedulefiling s
	WHERE s.EmployeeNo = MEL.EmpNo
	AND date BETWEEN s.DateFrom AND s.DateTo
	AND s.Status = s.StatusMax
	ORDER BY s.ID DESC),(SELECT TOP 1 ScheduleID
	FROM M_Employee_Master_List_Schedule 
	WHERE EmployeeNo = MEL.EmpNo 
	AND ScheduleID IS NOT NULL
	AND EffectivityDate <= date
	ORDER BY ID DESC)) AS Schedule
	
	INTO #Table2MPCount
	FROM #DaysMonth
	CROSS JOIN
	M_Employee_Master_List MEL
	WHERE (date <= MEL.Date_Resigned OR MEL.Date_Resigned IS NULL)
	AND  ((SELECT top 1 MEC.Status FROM M_Employee_Status MEC WHERE MEC.EmployNo = MEL.EmpNo ORDER BY MEC.ID DESC) = 'ACTIVE' OR ((SELECT top 1 MEC.UpdateDate FROM M_Employee_Status MEC WHERE MEC.EmployNo = MEL.EmpNo AND Status = 'ACTIVE' ORDER BY MEC.ID DESC) <= date)	AND (SELECT top 1 MEC.UpdateDate FROM M_Employee_Status MEC WHERE MEC.EmployNo = MEL.EmpNo AND Status <> 'ACTIVE' ORDER BY MEC.ID DESC) >= date)
	AND (SELECT TOP 1 MEC.CostCenter_AMS FROM M_Employee_CostCenter MEC WHERE MEC.EmployNo = MEL.EmpNo AND MEC.UpdateDate_AMS <= date ORDER BY UpdateDate_AMS DESC) IN (SELECT Cost_Center
																																		 FROM M_Cost_Center_List
																																		 WHERE GroupSection = @SectionGroup
																																		 OR @SectionGroup= ''
																																		 OR @SectionGroup IS NULL)
			
				
	AND (
				@Agency IS NULL OR
				@Agency = '' OR
				MEL.EmpNo LIKE CASE WHEN @Agency = 'AGENCY'
						THEN 'SRI%'
						ELSE @Agency+'%'
				END
				OR MEL.EmpNo LIKE CASE WHEN @Agency = 'AGENCY'
						THEN 'AMI%'
						ELSE @Agency+'%'
				END		
				OR MEL.EmpNo LIKE CASE WHEN @Agency = 'AGENCY'
						THEN 'PKIMT%'
						ELSE @Agency+'%'
				END		
				OR MEL.EmpNo LIKE CASE WHEN @Agency = 'AGENCY'
						THEN 'AVANCE%'
						ELSE @Agency+'%'
				END		
				OR MEL.EmpNo LIKE CASE WHEN @Agency = 'AGENCY'
						THEN 'NATCORP%'
						ELSE @Agency+'%'
				END		
				)




IF @Shift = 'NoSched'
BEGIN
	INSERT INTO #MPCountTB(InDate,mpcount)
	SELECT date, COUNT(EmpNo) AS mpco
	FROM #Table2MPCount
	WHERE Schedule NOT IN (SELECT ID FROM M_Schedule WHERE IsDeleted <> 1) OR Schedule IS NULL
	GROUP BY date
	ORDER BY date
END

ELSE IF @Shift = 'Day' OR @Shift = 'Night'
BEGIN
	INSERT INTO #MPCountTB(InDate,mpcount)
	SELECT date, COUNT(EmpNo) AS mpco
	FROM #Table2MPCount
	WHERE Schedule IN (SELECT ID FROM M_Schedule WHERE IsDeleted <> 1 AND Type LIKE @Shift+'%')
	GROUP BY date
	ORDER BY date
END

ELSE
BEGIN
	INSERT INTO #MPCountTB(InDate,mpcount)
	SELECT date, COUNT(EmpNo) AS mpco
	FROM #Table2MPCount
	--WHERE Schedule IN (SELECT ID FROM M_Schedule WHERE IsDeleted <> 1 AND Type LIKE @Shift+'%')
	GROUP BY date
	ORDER BY date

END

--SELECT * FROM #MPCountTB



--SELECT  CAST(CONVERT(Char(16), InDate ,20) AS Date) AS InDate,
--		mpcount 
--FROM #MPCountTB


END
--###################################### END OF MP COUNT #################################



--###############################LEAVE TYPE HERE #########################################
BEGIN

IF OBJECT_ID('tempdb..#EmpList') IS NOT NULL
		DROP TABLE #EmpList
IF OBJECT_ID('tempdb..#RPLeaveCounter') IS NOT NULL
		DROP TABLE #RPLeaveCounter;
IF OBJECT_ID('tempdb..#RPLeaveCounterFinished') IS NOT NULL
		DROP TABLE #RPLeaveCounterFinished;

SELECT  MEL.EmpNo,
		RFID,
		MEL.First_Name + ' ' + MEL.Family_Name AS EmployeeName,
		(SELECT TOP 1 S.Type FROM M_Schedule S WHERE S.ID = (SELECT TOP 1 MES.ScheduleID FROM M_Employee_Master_List_Schedule MES WHERE MEL.EmpNo = MES.EmployeeNo ORDER BY ID DESC)) AS Schedule,
		MEL.Position,
		(SELECT TOP 1 MEC.CostCenter_AMS FROM M_Employee_CostCenter MEC WHERE MEC.EmployNo = MEL.EmpNo ORDER BY UpdateDate_AMS DESC) AS CostCode
INTO #EmpList
FROM M_Employee_Master_List MEL
WHERE MEL.EmpNo IN (SELECT EmpNo FROm #Table2MPCount)
										


SELECT  RP.Date, 
		RP.LeaveType,
		RP.EmployeeNo,
		(SELECT Type FROM M_Schedule MS WHERE ID = (SELECT TOP 1 ScheduleID FROM M_Employee_Master_List_Schedule MES WHERE MES.EmployeeNo = RP.EmployeeNo AND MES.EffectivityDate <= RP.Date ORDER BY MES.ID DESC)) AS Schedule
INTO #RPLeaveCounter
FROM RP_AttendanceMonitoring RP
LEFT JOIN #EmpList EL
ON RP.EmployeeNo = EL.EmpNo
WHERE MONTH(RP.Date) = @Month
AND YEAR(RP.Date) = @Year
AND RP.EmployeeNo IN (SELECT EmpNo FROm #Table2MPCount)

SELECT  Date,
		LeaveType,
		Count(LeaveType) AS LeaveCount
INTO #RPLeaveCounterFinished
FROM #RPLeaveCounter
WHERE Schedule LIKE @Shift+'%' OR @Shift = '' OR @Shift IS NULL
GROUP BY Date,LeaveType
ORDER BY Date



IF OBJECT_ID('tempdb..#MLCountGroup') IS NOT NULL
		DROP TABLE #MLCountGroup
IF OBJECT_ID('tempdb..#NWCountGroup') IS NOT NULL
		DROP TABLE #NWCountGroup;
IF OBJECT_ID('tempdb..#LeaveExcessCountGroup') IS NOT NULL
		DROP TABLE #LeaveExcessCountGroup;

SELECT Date, LeaveCount AS MLCount
INTO #MLCountGroup
FROM #RPLeaveCounterFinished
WHERE LeaveType = 'ML'

SELECT Date, LeaveCount AS NWCount
INTO #NWCountGroup
FROM #RPLeaveCounterFinished
WHERE LeaveType = 'NW'


--SELECT * FROM #NWCountGroup

SELECT Date, SUM(LeaveCount) AS LeaveSum
INTO #LeaveExcessCountGroup
FROM #RPLeaveCounterFinished
WHERE LeaveType <> 'NW' AND LeaveType <> 'ML'
Group BY Date

END
--############################## END LEAVE TYPE #######################################


CREATE TABLE #tmpBus(
	RFID NVARCHAR(MAX),
	TimeIn DATETIME,
	TimeOut DATETIME,
	ScheduleID INT,
	LineID INT,
	ProcessID INT,
	EmpNo NVARCHAR(MAX),
	EmployeeName NVARCHAR(MAX),
	Date_Hired NVARCHAR(MAX),
	Status NVARCHAR(MAX),
	CostCenter_AMS NVARCHAR(MAX)
)


IF @Shift = 'Night'
BEGIN

INSERT INTO #tmpBus(RFID,TimeIn,TimeOut,ScheduleID,LineID,ProcessID,EmpNo,EmployeeName,Date_Hired,Status,CostCenter_AMS)
	SELECT	  TT.Employee_RFID AS RFID
		, CASE WHEN (TT.DTR_RefNo IS NOT NULL) THEN TT.DTR_TimeIn ELSE TT.TimeIn END AS TimeIn
		, CASE WHEN (TT.DTR_RefNo IS NOT NULL) THEN TT.DTR_TimeOut ELSE TT.TimeOut END AS TimeOut
		, CASE WHEN (TT.CSRef_No IS NULL) THEN TT.ScheduleID ELSE TT.CS_ScheduleID END AS ScheduleID
		, TT.LineID
		, TT.ProcessID
		, MEL.EmpNo
		, MEL.Family_Name + ' ' + MEL.First_Name AS EmployeeName
		, MEL.Date_Hired
		, MEL.Status
		,(SELECT TOP 1 CostCenter_AMS FROM M_Employee_CostCenter WHERE EmployNo = MEL.EmpNo AND UpdateDate_AMS <= ISNULL(TT.TimeIn,TT.TimeOut) ORDER BY UpdateDate_AMS DESC) AS CostCenter_AMS
FROM T_TimeInOut TT
JOIN M_Employee_Master_List MEL
ON TT.EmpNo = MEL.EmpNo
WHERE convert(char(5), TT.TimeIn, 108) > '12:00:00 PM'
AND (ISNULL(TimeIn,TimeOut) <= MEL.Date_Resigned OR MEL.Date_Resigned IS NULL)
AND TT.TimeIn BETWEEN @DateFrom AND @DateTo
AND ISNULL(TT.CS_ScheduleID,ScheduleID) IN (SELECT MS.ID
											FROM M_Schedule MS
											WHERE MS.Type LIKE 'Night%')
AND  ((SELECT top 1 MEC.Status FROM M_Employee_Status MEC WHERE MEC.EmployNo = MEL.EmpNo ORDER BY MEC.ID DESC) = 'ACTIVE' OR ((SELECT top 1 MEC.UpdateDate FROM M_Employee_Status MEC WHERE MEC.EmployNo = MEL.EmpNo AND Status = 'ACTIVE' ORDER BY MEC.ID DESC) <= ISNULL(TimeIn,TimeOut))	AND (SELECT top 1 MEC.UpdateDate FROM M_Employee_Status MEC WHERE MEC.EmployNo = MEL.EmpNo AND Status <> 'ACTIVE' ORDER BY MEC.ID DESC) >= ISNULL(TimeIn,TimeOut))
AND (SELECT TOP 1 MEC.CostCenter_AMS FROM M_Employee_CostCenter MEC WHERE MEC.EmployNo = MEL.EmpNo AND MEC.UpdateDate_AMS <= ISNULL(TimeIn,TimeOut) ORDER BY UpdateDate_AMS DESC) IN (SELECT Cost_Center
																																													 FROM M_Cost_Center_List
																																													 WHERE GroupSection = @SectionGroup
																																													 OR @SectionGroup= ''
																																													 OR @SectionGroup IS NULL)
																																	
--AND MEL.EmpNo = 'AMI2020-09721'
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
	
	

END


ELSE IF @Shift = 'Day'
BEGIN

INSERT INTO #tmpBus(RFID,TimeIn,TimeOut,ScheduleID,LineID,ProcessID,EmpNo,EmployeeName,Date_Hired,Status,CostCenter_AMS)
	SELECT	  TT.Employee_RFID AS RFID
		, CASE WHEN (TT.DTR_RefNo IS NOT NULL) THEN TT.DTR_TimeIn ELSE TT.TimeIn END AS TimeIn
		, CASE WHEN (TT.DTR_RefNo IS NOT NULL) THEN TT.DTR_TimeOut ELSE TT.TimeOut END AS TimeOut
		, CASE WHEN (TT.CSRef_No IS NULL) THEN TT.ScheduleID ELSE TT.CS_ScheduleID END AS ScheduleID
		, TT.LineID
		, TT.ProcessID
		, MEL.EmpNo
		, MEL.Family_Name + ' ' + MEL.First_Name AS EmployeeName
		, MEL.Date_Hired
		, MEL.Status
		,(SELECT TOP 1 CostCenter_AMS FROM M_Employee_CostCenter WHERE EmployNo = MEL.EmpNo AND UpdateDate_AMS <= ISNULL(TT.TimeIn,TT.TimeOut) ORDER BY UpdateDate_AMS DESC) AS CostCenter_AMS
FROM T_TimeInOut TT
JOIN M_Employee_Master_List MEL
ON TT.EmpNo = MEL.EmpNo
WHERE ISNULL(TT.TimeIn,TT.TimeOut) BETWEEN @DateFrom AND @DateTo
AND (ISNULL(TT.CS_ScheduleID,ScheduleID) IN (SELECT MS.ID
											FROM M_Schedule MS
											WHERE MS.Type LIKE 'Day%') OR ISNULL(TT.CS_ScheduleID,ScheduleID) IS NULL)
AND  ((SELECT top 1 MEC.Status FROM M_Employee_Status MEC WHERE MEC.EmployNo = MEL.EmpNo ORDER BY MEC.ID DESC) = 'ACTIVE' OR ((SELECT top 1 MEC.UpdateDate FROM M_Employee_Status MEC WHERE MEC.EmployNo = MEL.EmpNo AND Status = 'ACTIVE' ORDER BY MEC.ID DESC) <= ISNULL(TimeIn,TimeOut))	AND (SELECT top 1 MEC.UpdateDate FROM M_Employee_Status MEC WHERE MEC.EmployNo = MEL.EmpNo AND Status <> 'ACTIVE' ORDER BY MEC.ID DESC) >= ISNULL(TimeIn,TimeOut))
AND (SELECT TOP 1 MEC.CostCenter_AMS FROM M_Employee_CostCenter MEC WHERE MEC.EmployNo = MEL.EmpNo AND MEC.UpdateDate_AMS <= ISNULL(TimeIn,TimeOut) ORDER BY UpdateDate_AMS DESC) IN (SELECT Cost_Center
																																													 FROM M_Cost_Center_List
																																													 WHERE GroupSection = @SectionGroup
																																													 OR @SectionGroup= ''
																																													 OR @SectionGroup IS NULL)


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
	

END

ELSE
BEGIN

INSERT INTO #tmpBus(RFID,TimeIn,TimeOut,ScheduleID,LineID,ProcessID,EmpNo,EmployeeName,Date_Hired,Status,CostCenter_AMS)
	SELECT	  TT.Employee_RFID AS RFID
		, CASE WHEN (TT.DTR_RefNo IS NOT NULL) THEN TT.DTR_TimeIn ELSE TT.TimeIn END AS TimeIn
		, CASE WHEN (TT.DTR_RefNo IS NOT NULL) THEN TT.DTR_TimeOut ELSE TT.TimeOut END AS TimeOut
		, CASE WHEN (TT.CSRef_No IS NULL) THEN TT.ScheduleID ELSE TT.CS_ScheduleID END AS ScheduleID
		, TT.LineID
		, TT.ProcessID
		, MEL.EmpNo
		, MEL.Family_Name + ' ' + MEL.First_Name AS EmployeeName
		, MEL.Date_Hired
		, MEL.Status
		,(SELECT TOP 1 CostCenter_AMS FROM M_Employee_CostCenter WHERE EmployNo = MEL.EmpNo AND UpdateDate_AMS <= ISNULL(TT.TimeIn,TT.TimeOut) ORDER BY UpdateDate_AMS DESC) AS CostCenter_AMS
FROM T_TimeInOut TT
JOIN M_Employee_Master_List MEL
ON TT.EmpNo = MEL.EmpNo
WHERE convert(char(5), TT.TimeIn, 108) > '12:00:00 PM'
AND TT.TimeIn BETWEEN @DateFrom AND @DateTo
AND ISNULL(TT.CS_ScheduleID,ScheduleID) IN (SELECT MS.ID
											FROM M_Schedule MS
											WHERE MS.Type LIKE 'Night%')
AND  ((SELECT top 1 MEC.Status FROM M_Employee_Status MEC WHERE MEC.EmployNo = MEL.EmpNo ORDER BY MEC.ID DESC) = 'ACTIVE' OR ((SELECT top 1 MEC.UpdateDate FROM M_Employee_Status MEC WHERE MEC.EmployNo = MEL.EmpNo AND Status = 'ACTIVE' ORDER BY MEC.ID DESC) <= ISNULL(TimeIn,TimeOut))	AND (SELECT top 1 MEC.UpdateDate FROM M_Employee_Status MEC WHERE MEC.EmployNo = MEL.EmpNo AND Status <> 'ACTIVE' ORDER BY MEC.ID DESC) >= ISNULL(TimeIn,TimeOut))
AND (SELECT TOP 1 MEC.CostCenter_AMS FROM M_Employee_CostCenter MEC WHERE MEC.EmployNo = MEL.EmpNo AND MEC.UpdateDate_AMS <= ISNULL(TimeIn,TimeOut) ORDER BY UpdateDate_AMS DESC) IN (SELECT Cost_Center
																																													 FROM M_Cost_Center_List
																																													 WHERE GroupSection = @SectionGroup
																																													 OR @SectionGroup= ''
																																													 OR @SectionGroup IS NULL)
																																	
--AND MEL.EmpNo = 'AMI2020-09721'
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

INSERT INTO #tmpBus(RFID,TimeIn,TimeOut,ScheduleID,LineID,ProcessID,EmpNo,EmployeeName,Date_Hired,Status,CostCenter_AMS)
	SELECT	  TT.Employee_RFID AS RFID
		, CASE WHEN (TT.DTR_RefNo IS NOT NULL) THEN TT.DTR_TimeIn ELSE TT.TimeIn END AS TimeIn
		, CASE WHEN (TT.DTR_RefNo IS NOT NULL) THEN TT.DTR_TimeOut ELSE TT.TimeOut END AS TimeOut
		, CASE WHEN (TT.CSRef_No IS NULL) THEN TT.ScheduleID ELSE TT.CS_ScheduleID END AS ScheduleID
		, TT.LineID
		, TT.ProcessID
		, MEL.EmpNo
		, MEL.Family_Name + ' ' + MEL.First_Name AS EmployeeName
		, MEL.Date_Hired
		, MEL.Status
		,(SELECT TOP 1 CostCenter_AMS FROM M_Employee_CostCenter WHERE EmployNo = MEL.EmpNo AND UpdateDate_AMS <= ISNULL(TT.TimeIn,TT.TimeOut) ORDER BY UpdateDate_AMS DESC) AS CostCenter_AMS
FROM T_TimeInOut TT
JOIN M_Employee_Master_List MEL
ON TT.EmpNo = MEL.EmpNo
WHERE ISNULL(TT.TimeIn,TT.TimeOut) BETWEEN @DateFrom AND @DateTo
AND (ISNULL(TT.CS_ScheduleID,ScheduleID) IN (SELECT MS.ID
											FROM M_Schedule MS
											WHERE MS.Type LIKE 'Day%') OR ISNULL(TT.CS_ScheduleID,ScheduleID) IS NULL)
AND  ((SELECT top 1 MEC.Status FROM M_Employee_Status MEC WHERE MEC.EmployNo = MEL.EmpNo ORDER BY MEC.ID DESC) = 'ACTIVE' OR ((SELECT top 1 MEC.UpdateDate FROM M_Employee_Status MEC WHERE MEC.EmployNo = MEL.EmpNo AND Status = 'ACTIVE' ORDER BY MEC.ID DESC) <= ISNULL(TimeIn,TimeOut))	AND (SELECT top 1 MEC.UpdateDate FROM M_Employee_Status MEC WHERE MEC.EmployNo = MEL.EmpNo AND Status <> 'ACTIVE' ORDER BY MEC.ID DESC) >= ISNULL(TimeIn,TimeOut))
AND (SELECT TOP 1 MEC.CostCenter_AMS FROM M_Employee_CostCenter MEC WHERE MEC.EmployNo = MEL.EmpNo AND MEC.UpdateDate_AMS <= ISNULL(TimeIn,TimeOut) ORDER BY UpdateDate_AMS DESC) IN (SELECT Cost_Center
																																													 FROM M_Cost_Center_List
																																													 WHERE GroupSection = @SectionGroup
																																													 OR @SectionGroup= ''
																																													 OR @SectionGroup IS NULL)

--AND Employee_RFID IS NOT NULL
--AND MEL.EmpNo = 'BIPH2017-01960'
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

END


	CREATE TABLE #checkCer(
		InDate DATETIME,
		EmpNo NVARCHAR(50)
	)

	

IF @Shift = 'NoSched'
BEGIN
	INSERT INTO #checkCer(InDate,EmpNo)
	SELECT CAST(CONVERT(Char(16), ISNULL(TB.TimeIn,TB.TimeOut) ,20) AS Date) AS InDate,
		TB.EmpNo
	--INTO #checkCer
	FROM #tmpBus TB
	LEFT JOIN M_LineTeam ML
	ON TB.LineID = ML.ID
	LEFT JOIN M_Employee_Skills MES
	ON MES.EmpNo = TB.EmpNo AND MES.LineID = TB.LineID AND MES.SkillID = TB.ProcessID
	LEFT JOIN M_Skills MS
	ON MS.ID = TB.ProcessID
	LEFT JOIN M_Schedule MSS
	ON MSS.ID = TB.ScheduleID
	WHERE (@Line = 0 OR @Line IS NULL OR @Line = ML.ID) 
	AND (TB.ScheduleID IS NULL OR TB.ScheduleID NOT IN (SELECT ID FROM M_Schedule WHERE IsDeleted <> 1))
	--AND (@SectionGroup = '' OR @SectionGroup IS NULL OR TB.CostCenter_AMS IN (SELECT Cost_Center FROM M_Cost_Center_List WHERE GroupSection = @SectionGroup OR @SectionGroup IS NULL)) 


END

ELSE IF @Shift = 'Day'
BEGIN
INSERT INTO #checkCer(InDate,EmpNo)
	SELECT CAST(CONVERT(Char(16), ISNULL(TB.TimeIn,TB.TimeOut) ,20) AS Date) AS InDate,
		TB.EmpNo
	FROM #tmpBus TB
	LEFT JOIN M_LineTeam ML
	ON TB.LineID = ML.ID
	LEFT JOIN M_Employee_Skills MES
	ON MES.EmpNo = TB.EmpNo AND MES.LineID = TB.LineID AND MES.SkillID = TB.ProcessID
	LEFT JOIN M_Skills MS
	ON MS.ID = TB.ProcessID
	LEFT JOIN M_Schedule MSS
	ON MSS.ID = TB.ScheduleID
	WHERE (@Line = 0 OR @Line IS NULL OR @Line = ML.ID) 
	AND (TB.ScheduleID IN (SELECT ID FROM M_Schedule WHERE IsDeleted <> 1 AND Type LIKE @Shift+'%'))
	--AND (@SectionGroup = '' OR @SectionGroup IS NULL OR TB.CostCenter_AMS IN (SELECT Cost_Center FROM M_Cost_Center_List WHERE GroupSection = @SectionGroup OR @SectionGroup IS NULL)) 


	
END

ELSE IF @Shift = 'Night'
BEGIN
INSERT INTO #checkCer(InDate,EmpNo)
	SELECT CAST(CONVERT(Char(16), TB.TimeIn ,20) AS Date) AS InDate,
		TB.EmpNo
	FROM #tmpBus TB
	LEFT JOIN M_LineTeam ML
	ON TB.LineID = ML.ID
	LEFT JOIN M_Employee_Skills MES
	ON MES.EmpNo = TB.EmpNo AND MES.LineID = TB.LineID AND MES.SkillID = TB.ProcessID
	LEFT JOIN M_Skills MS
	ON MS.ID = TB.ProcessID
	LEFT JOIN M_Schedule MSS
	ON MSS.ID = TB.ScheduleID
	WHERE (@Line = 0 OR @Line IS NULL OR @Line = ML.ID) 
	AND (TB.ScheduleID IN (SELECT ID FROM M_Schedule WHERE IsDeleted <> 1 AND Type LIKE @Shift+'%'))
	
END


ELSE
BEGIN
INSERT INTO #checkCer(InDate,EmpNo)
	SELECT CAST(CONVERT(Char(16), ISNULL(TB.TimeIn,TB.TimeOut) ,20) AS Date) AS InDate,
		TB.EmpNo
FROM #tmpBus TB
LEFT JOIN M_LineTeam ML
ON TB.LineID = ML.ID
LEFT JOIN M_Employee_Skills MES
ON MES.EmpNo = TB.EmpNo AND MES.LineID = TB.LineID AND MES.SkillID = TB.ProcessID
LEFT JOIN M_Skills MS
ON MS.ID = TB.ProcessID
LEFT JOIN M_Schedule MSS
ON MSS.ID = TB.ScheduleID
--WHERE ML.IsDeleted <> 1 AND MS.IsDeleted <> 1
WHERE (@Line = 0 OR @Line IS NULL OR @Line = ML.ID) 
--AND (@SectionGroup = '' OR @SectionGroup IS NULL OR TB.CostCenter_AMS IN (SELECT Cost_Center FROM M_Cost_Center_List WHERE GroupSection = @SectionGroup OR @SectionGroup IS NULL)) 

--SELECT * FROM #checkCer
--Where InDate ='2020-11-25 00:00:00.000'
END


SELECT *
INTO #OutputTable
FROM #checkCer

--SELECT *
--FROM #OutputTable



IF OBJECT_ID('tempdb..#OutputTable2') IS NOT NULL
DROP TABLE #OutputTable2;
IF OBJECT_ID('tempdb..#Presenttable') IS NOT NULL
DROP TABLE #Presenttable;

SELECT InDate, EmpNo, COUNT(EmpNo) AS DUP
INTO #OutputTable2
FROM #OutputTable
GROUP BY InDate, EmpNo

		
SELECT InDate, COUNT(*) AS Present
INTO #Presenttable
FROM #OutputTable2
GROUP BY InDate
ORDER BY InDate


IF OBJECT_ID('tempdb..#OutputTableFinal_withShift') IS NOT NULL
		DROP TABLE #OutputTableFinal_withShift;
		SELECT   YEAR(DM.date) AS Year
				,MONTH(DM.date) AS Monthnum
				,Day(DM.date) AS MonthDay
				,CASE WHEN (DM.date > GETDATE() AND ISNULL(NW.NWCount,0) = 0) THEN 0 ELSE ISNULL(MTB.mpcount,0) END AS CurrentMP
				,ISNULL(ETT.Present,0) AS Present
				,CASE WHEN (ISNULL(MTB.mpcount,0) - ISNULL(ETT.Present,0) < 0 AND DM.date > GETDATE() AND ISNULL(NW.NWCount,0) = 0) THEN 0 ELSE ISNULL(MTB.mpcount,0) - ISNULL(ETT.Present,0) END AS Absent
				,ISNULL(ML.MLCount,0) AS MLCount
				,ISNULL(NW.NWCount,0) AS NWCount
				,ISNULL(LE.LeaveSum,0) AS LeaveSum
	INTO #OutputTableFinal_withShift
	FROM #DaysMonth DM
	LEFT JOIN #Presenttable ETT
	ON DM.date = ETT.InDate
	LEFT JOIN #MPCountTB MTB
	ON MTB.InDate = DM.date
	LEFT JOIN #NWCountGroup NW
	ON DM.date = NW.Date
	LEFT JOIN #MLCountGroup ML
	ON ML.Date = DM.date
	LEFT JOIN #LeaveExcessCountGroup LE
	ON LE.Date = DM.date
	--WHERE DM.date <= GETDATE()

	--SELECT * FROM #OutputTableFinal_withShift
	--SELECT * FROM #NWCountGroup


IF OBJECT_ID('tempdb..#FinalTABLE') IS NOT NULL
		DROP TABLE #FinalTABLE;
	SELECT  Year,
			Monthnum,
			MonthDay,
			CurrentMP,
			Present,
			CASE WHEN (CAST((CAST(@Year AS VARCHAR(4)) + '-' + CAST(@Month AS VARCHAR(2)) + '-' + CAST(MonthDay AS VARCHAR(2))) AS DATETIME) <= GETDATE()) THEN Absent - MLCount ELSE 0 END AS Absent,
			MLCount,
			NWCount,
			LeaveSum
	INTO #FinalTABLE
	FROM #OutputTableFinal_withShift

	--SELECT * FROM #FinalTABLE


	IF OBJECT_ID('tempdb..#FinalTABLE2') IS NOT NULL
		DROP TABLE #FinalTABLE2;
	SELECT  Year,
			Monthnum,
			MonthDay,
			CurrentMP,
			Present,
			CASE WHEN DATENAME(dw,CAST((CAST(@Year AS VARCHAR(4)) + '-' + CAST(@Month AS VARCHAR(2)) + '-' + CAST(MonthDay AS VARCHAR(2))) AS DATETIME)) = 'Saturday' OR DATENAME(dw,CAST((CAST(@Year AS VARCHAR(4)) + '-' + CAST(@Month AS VARCHAR(2)) + '-' + CAST(MonthDay AS VARCHAR(2))) AS DATETIME)) = 'Sunday' THEN LeaveSum ELSE CASE WHEN (Absent-NWCount) >= 0 THEN Absent-NWCount ELSE 0 END END AS Absent,
			MLCount,
			CASE WHEN DATENAME(dw,CAST((CAST(@Year AS VARCHAR(4)) + '-' + CAST(@Month AS VARCHAR(2)) + '-' + CAST(MonthDay AS VARCHAR(2))) AS DATETIME)) = 'Saturday' OR DATENAME(dw,CAST((CAST(@Year AS VARCHAR(4)) + '-' + CAST(@Month AS VARCHAR(2)) + '-' + CAST(MonthDay AS VARCHAR(2))) AS DATETIME)) = 'Sunday' THEN Absent ELSE NWCount END AS NWCount
			,LeaveSum
			
	INTO #FinalTABLE2
	FROM #FinalTABLE


	SELECT  Year,
			Monthnum,
			MonthDay,
			CurrentMP,
			Present,
			Absent,
			MLCount,
			CASE WHEN DATENAME(dw,CAST((CAST(@Year AS VARCHAR(4)) + '-' + CAST(@Month AS VARCHAR(2)) + '-' + CAST(MonthDay AS VARCHAR(2))) AS DATETIME)) = 'Saturday' OR DATENAME(dw,CAST((CAST(@Year AS VARCHAR(4)) + '-' + CAST(@Month AS VARCHAR(2)) + '-' + CAST(MonthDay AS VARCHAR(2))) AS DATETIME)) = 'Sunday' THEN NWCount - LeaveSum ELSE NWCount END AS NWCount
		
			,CASE WHEN (Present > 0 AND CurrentMP > 0 AND (DATENAME(dw,CAST((CAST(@Year AS VARCHAR(4)) + '-' + CAST(@Month AS VARCHAR(2)) + '-' + CAST(MonthDay AS VARCHAR(2))) AS DATETIME)) = 'Saturday' OR DATENAME(dw,CAST((CAST(@Year AS VARCHAR(4)) + '-' + CAST(@Month AS VARCHAR(2)) + '-' + CAST(MonthDay AS VARCHAR(2))) AS DATETIME)) = 'Sunday'))
					THEN CAST((CAST(Present AS DECIMAL(18,2)) / ISNULL(Present+Absent,0) * 100 )AS DECIMAL(18,2)) 
				 WHEN Present > 0 AND CurrentMP > 0
					THEN CAST((CAST(Present AS DECIMAL(18,2)) / ISNULL(CurrentMP-MLCount-NWCount,0) * 100 )AS DECIMAL(18,2))
				 ELSE 0
				 END AS Percentage

	FROM #FinalTABLE2
	ORDER BY MonthDay

END


















