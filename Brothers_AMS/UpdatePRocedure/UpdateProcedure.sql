USE [Brother_AMSDB]
GO
/****** Object:  StoredProcedure [dbo].[GET_RPMonitoring_Graphv2ALLShift]    Script Date: 2020-11-27 2:40:56 pm ******/
DROP PROCEDURE [dbo].[GET_RPMonitoring_Graphv2ALLShift]
GO
/****** Object:  StoredProcedure [dbo].[GET_RP_WrongShiftV2]    Script Date: 2020-11-27 2:40:56 pm ******/
DROP PROCEDURE [dbo].[GET_RP_WrongShiftV2]
GO
/****** Object:  StoredProcedure [dbo].[GET_RP_MPCMonitoringv2ALLShift]    Script Date: 2020-11-27 2:40:56 pm ******/
DROP PROCEDURE [dbo].[GET_RP_MPCMonitoringv2ALLShift]
GO
/****** Object:  StoredProcedure [dbo].[GET_RP_AttendanceMonitoring_TimeINOUT_HRFormatV2]    Script Date: 2020-11-27 2:40:56 pm ******/
DROP PROCEDURE [dbo].[GET_RP_AttendanceMonitoring_TimeINOUT_HRFormatV2]
GO
/****** Object:  StoredProcedure [dbo].[GET_RP_AttendanceMonitoring_TimeINOUT]    Script Date: 2020-11-27 2:40:56 pm ******/
DROP PROCEDURE [dbo].[GET_RP_AttendanceMonitoring_TimeINOUT]
GO
/****** Object:  StoredProcedure [dbo].[GET_RP_AttendanceMonitoring_Shift]    Script Date: 2020-11-27 2:40:56 pm ******/
DROP PROCEDURE [dbo].[GET_RP_AttendanceMonitoring_Shift]
GO
/****** Object:  StoredProcedure [dbo].[GET_RP_AttendanceMonitoring_COUNT]    Script Date: 2020-11-27 2:40:56 pm ******/
DROP PROCEDURE [dbo].[GET_RP_AttendanceMonitoring_COUNT]
GO
/****** Object:  StoredProcedure [dbo].[GET_RP_AttendanceMonitoring]    Script Date: 2020-11-27 2:40:56 pm ******/
DROP PROCEDURE [dbo].[GET_RP_AttendanceMonitoring]
GO
/****** Object:  StoredProcedure [dbo].[GET_Employee_Skills]    Script Date: 2020-11-27 2:40:56 pm ******/
DROP PROCEDURE [dbo].[GET_Employee_Skills]
GO
/****** Object:  StoredProcedure [dbo].[GET_Employee_OTFiling]    Script Date: 2020-11-27 2:40:56 pm ******/
DROP PROCEDURE [dbo].[GET_Employee_OTFiling]
GO
/****** Object:  StoredProcedure [dbo].[GET_AF_CSRequest_Detail]    Script Date: 2020-11-27 2:40:56 pm ******/
DROP PROCEDURE [dbo].[GET_AF_CSRequest_Detail]
GO
/****** Object:  StoredProcedure [dbo].[Dashboard_ManpowerAttendanceRate]    Script Date: 2020-11-27 2:40:56 pm ******/
DROP PROCEDURE [dbo].[Dashboard_ManpowerAttendanceRate]
GO
/****** Object:  StoredProcedure [dbo].[Dashboard_LeaveBreakDown]    Script Date: 2020-11-27 2:40:56 pm ******/
DROP PROCEDURE [dbo].[Dashboard_LeaveBreakDown]
GO
/****** Object:  StoredProcedure [dbo].[Dashboard_LeaveBreakDown]    Script Date: 2020-11-27 2:40:56 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDuRE [dbo].[Dashboard_LeaveBreakDown]
--DECLARE
	@Month INT = 11,
	@Year INT = 2020,
	@Agency NVARCHAR(50) = '',
	@Shift NVARCHAR(20) = '',
	@Line BIGINT = NULL,
	@CostCode NVARCHAR(50) ='6110'
AS


SET NOCOUNT ON;
SET FMTONLY OFF;

IF @Shift = 'NoSched'
BEGIN
	SET @Shift = ''
END

BEGIN
--###############################LEAVE TYPE HERE #########################################

DECLARE @SectionGroup NVARCHAR(50)
SET @SectionGroup = (SELECT GroupSection FROM M_Cost_Center_List WHERE Cost_Center = @CostCode);
IF OBJECT_ID('tempdb..#DaysMonth') IS NOT NULL
		DROP TABLE #DaysMonth;
IF OBJECT_ID('tempdb..#EmpList_Leave') IS NOT NULL
		DROP TABLE #EmpList_Leave
IF OBJECT_ID('tempdb..#RPLeaveCounter_Leave') IS NOT NULL
		DROP TABLE #RPLeaveCounter_Leave;
IF OBJECT_ID('tempdb..#RPLeaveCounterFinished_Leave') IS NOT NULL
		DROP TABLE #RPLeaveCounterFinished_Leave;
IF OBJECT_ID('tempdb..#LeaveExcessCountGroup_Leave') IS NOT NULL
		DROP TABLE #LeaveExcessCountGroup_Leave;
		

;WITH N(N)AS 
(SELECT 1 FROM(VALUES(1),(1),(1),(1),(1),(1))M(N)),
tally(N)AS(SELECT ROW_NUMBER()OVER(ORDER BY N.N)FROM N,N a)
SELECT datefromparts(@Year,@Month,N) date 
INTO #DaysMonth
FROM tally
WHERE N <= day(EOMONTH(datefromparts(@Year,@Month,1)))

SELECT  MEL.EmpNo,
		RFID,
		MEL.First_Name + ' ' + MEL.Family_Name AS EmployeeName,
		(SELECT TOP 1 S.Type FROM M_Schedule S WHERE S.ID = (SELECT TOP 1 MES.ScheduleID FROM M_Employee_Master_List_Schedule MES WHERE MEL.EmpNo = MES.EmployeeNo ORDER BY ID DESC)) AS Schedule,
		MEL.Position,
		(SELECT TOP 1 MEC.CostCenter_AMS FROM M_Employee_CostCenter MEC WHERE MEC.EmployNo = MEL.EmpNo ORDER BY UpdateDate_AMS DESC) AS CostCode
INTO #EmpList_Leave
FROM M_Employee_Master_List MEL
WHERE ((SELECT top 1 MEC.UpdateDate FROM M_Employee_Status MEC WHERE MEC.EmployNo = MEL.EmpNo AND MEC.Status <> 'ACTIVE' ORDER BY MEC.UpdateDate DESC) IS NULL OR (SELECT top 1 MEC.UpdateDate FROM M_Employee_Status MEC WHERE MEC.EmployNo = MEL.EmpNo AND MEC.Status <> 'ACTIVE' ORDER BY MEC.UpdateDate DESC) > GETDATE() OR (SELECT TOP 1 s.Status FROM M_Employee_Status s WHERE s.EmployNo = MEL.EmpNo ORDER BY ID DESC) = 'ACTIVE')
			AND EmpNo <> '&nbsp;' AND Status IS NOT NULL
			AND (SELECT TOP 1 MEC.CostCenter_AMS FROM M_Employee_CostCenter MEC WHERE MEC.EmployNo = MEL.EmpNo AND MEC.UpdateDate_AMS <= GETDATE() ORDER BY UpdateDate_AMS DESC) IN (SELECT Cost_Center
																																	 FROM M_Cost_Center_List
																																	 WHERE GroupSection = @SectionGroup
																																	 OR @SectionGroup = ''
																																	 OR @SectionGroup IS NULL)
						
AND MEL.EmpNo IN (SELECT s.EmpNo FROM M_Employee_Skills s WHERE s.LineID = @Line OR @Line IS NULL OR @Line = 0)
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

SELECT  RP.Date, 
		RP.LeaveType,
		RP.EmployeeNo,
		(SELECT Type FROM M_Schedule MS WHERE ID = (SELECT TOP 1 ScheduleID FROM M_Employee_Master_List_Schedule MES WHERE MES.EmployeeNo = RP.EmployeeNo AND MES.EffectivityDate <= RP.Date ORDER BY MES.ID DESC)) AS Schedule
INTO #RPLeaveCounter_Leave
FROM RP_AttendanceMonitoring RP
LEFT JOIN #EmpList_Leave EL
ON RP.EmployeeNo = EL.EmpNo
WHERE LeaveType <> 'NW'
AND RP.EmployeeNo IN (SELECT EmpNo FROM #EmpList_Leave)
AND (SELECT TOP 1 ISNULL(s.TimeIn,s.TimeOut) FROM T_TimeInOut s WHERE s.EmpNo = RP.EmployeeNo AND CONVERT(VARCHAR(10),ISNULL(s.TimeIn,s.TimeOut),120) = CONVERT(VARCHAR(10),RP.Date,120) ) IS NULL
AND ((SELECT top 1 MEC.UpdateDate FROM M_Employee_Status MEC WHERE MEC.EmployNo = RP.EmployeeNo AND MEC.Status <> 'ACTIVE' ORDER BY MEC.UpdateDate DESC) IS NULL OR (SELECT top 1 MEC.UpdateDate FROM M_Employee_Status MEC WHERE MEC.EmployNo = RP.EmployeeNo AND MEC.Status <> 'ACTIVE' ORDER BY MEC.UpdateDate DESC) > GETDATE() OR (SELECT TOP 1 s.Status FROM M_Employee_Status s WHERE s.EmployNo = RP.EmployeeNo ORDER BY ID DESC) = 'ACTIVE')		 
AND (SELECT TOP 1 MEC.CostCenter_AMS FROM M_Employee_CostCenter MEC WHERE MEC.EmployNo = RP.EmployeeNo AND MEC.UpdateDate_AMS <= date ORDER BY UpdateDate_AMS DESC) IN (SELECT Cost_Center
																															FROM M_Cost_Center_List
																															WHERE GroupSection = @SectionGroup
																															OR @SectionGroup = ''
																															OR @SectionGroup IS NULL)
					
--SELECT * FROM #RPLeaveCounter_Leave

SELECT  Date,
		LeaveType,
		Count(LeaveType) AS LeaveCount
INTO #RPLeaveCounterFinished_Leave
FROM #RPLeaveCounter_Leave
WHERE Schedule LIKE @Shift+'%' OR @Shift = '' OR @Shift IS NULL
GROUP BY Date,LeaveType
ORDER BY Date


--SELECT * FROM #RPLeaveCounterFinished_Leave

--SELECT * FROM #RPLeaveCounter_Leave

SELECT  @Year AS Year,
		@Month AS Monthnum,
		CONVERT(Date, a.Date) AS DateSet, 
		a.LeaveType, 
		SUM(LeaveCount) AS HeadCount
INTO #LeaveExcessCountGroup_Leave
FROM #RPLeaveCounterFinished_Leave a
Group BY Date, LeaveType

--SELECT * FROM #LeaveExcessCountGroup_Leave


IF OBJECT_ID('tempdb..#JOINDays') IS NOT NULL
		DROP TABLE #JOINDays;
IF OBJECT_ID('tempdb..#JOINDays_LEave') IS NOT NULL
		DROP TABLE #JOINDays_LEave;

SELECT DISTINCT LeaveType
INTO #JOINDays
FROM #LeaveExcessCountGroup_Leave


SELECT *
INTO #JOINDays_LEave
FROM #JOINDays
CROSS JOIN #DaysMonth



--######################### GET ABSENT FROM MAN POWER ATTENDANCE RATE ########################
IF OBJECT_ID('tempdb..#GetAttendanceRate') IS NOT NULL
		DROP TABLE #GetAttendanceRate;
IF OBJECT_ID('tempdb..#GetAttendanceRate2') IS NOT NULL
		DROP TABLE #GetAttendanceRate2;
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

	IF OBJECT_ID('tempdb..#MinusMP_ML') IS NOT NULL
		DROP TABLE #MinusMP_ML

	IF OBJECT_ID('tempdb..#MinusMP_NW') IS NOT NULL
	DROP TABLE #MinusMP_NW
	

	
	

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
WHERE (CAST((CAST(@Year AS VARCHAR(4)) + '-' + CAST(@Month AS VARCHAR(2)) + '-' + CAST(@EndofMonthDay AS VARCHAR(2))) AS DATETIME) <= MEL.Date_Resigned OR MEL.Date_Resigned IS NULL)
AND  ((SELECT top 1 MEC.Status FROM M_Employee_Status MEC WHERE MEC.EmployNo = MEL.EmpNo ORDER BY MEC.ID DESC) = 'ACTIVE' OR ((SELECT top 1 MEC.UpdateDate FROM M_Employee_Status MEC WHERE MEC.EmployNo = MEL.EmpNo AND Status = 'ACTIVE' ORDER BY MEC.ID DESC) <= CAST((CAST(@Year AS VARCHAR(4)) + '-' + CAST(@Month AS VARCHAR(2)) + '-' + CAST(@EndofMonthDay AS VARCHAR(2))) AS DATETIME))	AND (SELECT top 1 MEC.UpdateDate FROM M_Employee_Status MEC WHERE MEC.EmployNo = MEL.EmpNo AND Status <> 'ACTIVE' ORDER BY MEC.ID DESC) >= CAST((CAST(@Year AS VARCHAR(4)) + '-' + CAST(@Month AS VARCHAR(2)) + '-' + CAST(1 AS VARCHAR(2))) AS DATETIME))
AND (SELECT TOP 1 MEC.CostCenter_AMS FROM M_Employee_CostCenter MEC WHERE MEC.EmployNo = MEL.EmpNo AND MEC.UpdateDate_AMS <= CAST((CAST(@Year AS VARCHAR(4)) + '-' + CAST(@Month AS VARCHAR(2)) + '-' + CAST(@EndofMonthDay AS VARCHAR(2))) AS DATETIME) ORDER BY UpdateDate_AMS DESC) IN (SELECT Cost_Center
																																	 FROM M_Cost_Center_List
																																	 WHERE GroupSection = @SectionGroup
																																	 OR @SectionGroup= ''
																																	 OR @SectionGroup IS NULL)


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
AND RP.EmployeeNo IN (SELECT EmpNo FROM #EmpList)
AND  ((SELECT top 1 MEC.Status FROM M_Employee_Status MEC WHERE MEC.EmployNo = RP.EmployeeNo ORDER BY MEC.ID DESC) = 'ACTIVE' OR ((SELECT top 1 MEC.UpdateDate FROM M_Employee_Status MEC WHERE MEC.EmployNo = RP.EmployeeNo AND Status = 'ACTIVE' ORDER BY MEC.ID DESC) <= CAST((CAST(@Year AS VARCHAR(4)) + '-' + CAST(@Month AS VARCHAR(2)) + '-' + CAST(@EndofMonthDay AS VARCHAR(2))) AS DATETIME))	AND (SELECT top 1 MEC.UpdateDate FROM M_Employee_Status MEC WHERE MEC.EmployNo = RP.EmployeeNo AND Status <> 'ACTIVE' ORDER BY MEC.ID DESC) >= CAST((CAST(@Year AS VARCHAR(4)) + '-' + CAST(@Month AS VARCHAR(2)) + '-' + CAST(1 AS VARCHAR(2))) AS DATETIME))
AND (SELECT TOP 1 MEC.CostCenter_AMS FROM M_Employee_CostCenter MEC WHERE MEC.EmployNo = RP.EmployeeNo AND MEC.UpdateDate_AMS <= RP.Date ORDER BY UpdateDate_AMS DESC) IN (SELECT Cost_Center
																																	 FROM M_Cost_Center_List
																																	 WHERE GroupSection = @SectionGroup
																																	 OR @SectionGroup= ''
																																	 OR @SectionGroup IS NULL)


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
WHERE (ISNULL(TimeIn,TimeOut) <= MEL.Date_Resigned OR MEL.Date_Resigned IS NULL)
AND ISNULL(TT.TimeIn,TT.TimeOut) BETWEEN @DateFrom AND @DateTo
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
		
	INTO #GetAttendanceRate
	FROM #FinalTABLE2
	ORDER BY MonthDay


END

--############################################################################################

--SELECT * FROM #GetAttendanceRate

IF OBJECT_ID('tempdb..#JOINDays_LEavesum') IS NOT NULL
		DROP TABLE #JOINDays_LEavesum;
IF OBJECT_ID('tempdb..#GET_UNK') IS NOT NULL
		DROP TABLE #GET_UNK;
IF OBJECT_ID('tempdb..#GET_UNKData') IS NOT NULL
		DROP TABLE #GET_UNKData;

SELECT  CAST(CAST(@Year AS VARCHAR(4)) + '-' + CAST(@Month AS VARCHAR(2)) + '-' + CAST(MonthDay AS VARCHAR(2)) AS Date) AS DateSet,
		'UNK' AS LeaveType,
		Absent+MLCount AS HeadCount
		
INTO #GetAttendanceRate2
FROM #GetAttendanceRate

--SELECT * FROM #GetAttendanceRate2

SELECT  @Year AS Year,
		@Month AS Monthnum,
		JL.date AS DateSet,
		JL.LeaveType,
		ISNULL(LCL.HeadCount,0) AS HeadCount
INTO #JOINDays_LEavesum
FROM #JOINDays_LEave JL
LEFT JOIN #LeaveExcessCountGroup_Leave LCL
ON JL.date = LCL.DateSet AND JL.LeaveType = LCL.LeaveType
WHERE JL.LeaveType IN ('UNK','AB','SL','VL','EL','ML','OB')




SELECT DateSet, SUM(HeadCount) AS SUMHeadCount
INTO #GET_UNK
FROM #JOINDays_LEavesum
GROUP BY DateSet


SELECT a.DateSet, 'UNK' AS LeaveType, (a.HeadCount - b.SUMHeadCount) AS HeadCount
INTO #GET_UNKData
FROM #GetAttendanceRate2 a
LEFT JOIN #GET_UNK b
ON a.DateSet = b.DateSet


IF OBJECT_ID('tempdb..#FinalTableFinaly') IS NOT NULL
		DROP TABLE #FinalTableFinaly;

IF OBJECT_ID('tempdb..#FinalTableFinaly2') IS NOT NULL
		DROP TABLE #FinalTableFinaly2;

SELECT * INTO #FinalTableFinaly FROM(
SELECT  @Year AS Year,
		@Month AS Monthnum,
		JL.date AS DateSet,
		JL.LeaveType,
		ISNULL(LCL.HeadCount,0) AS HeadCount
FROM #JOINDays_LEave JL
LEFT JOIN #LeaveExcessCountGroup_Leave LCL
ON JL.date = LCL.DateSet AND (JL.LeaveType = LCL.LeaveType)
UNION
SELECT @Year AS Year,
	   @Month AS Monthnum,
	   DateSet,
	   LeaveType,
	   ISNULL(CASE WHEN HeadCount <= 0 THEN 0 ELSE HeadCount END,0) AS HeadCount
FROM #GET_UNKData
) AS tmp


SELECT  Year,
		Monthnum,
		DateSet,
		CASE WHEN LeaveType = 'AB' OR LeaveType = 'UNK' THEN 'UNK' ELSE LeaveType END AS LeaveType,
		HeadCount
INTO #FinalTableFinaly2
FROM #FinalTableFinaly


SELECT  Year, 
		Monthnum,
		DateSet,
		LeaveType,
		SUM(HeadCount) AS HeadCount
FROM #FinalTableFinaly2
WHERE LeaveType IN ('UNK','AB','SL','VL','EL','ML','OB')
GROUP BY  Year,
		Monthnum,
		DateSet,
		LeaveType

--############################## END LEAVE TYPE #######################################







GO
/****** Object:  StoredProcedure [dbo].[Dashboard_ManpowerAttendanceRate]    Script Date: 2020-11-27 2:40:56 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		Chester R.
-- Create date: 01-06-2020
-- Description:	GET Manpower Change Monitoring
-- =============================================

CREATE PROCEDURE [dbo].[Dashboard_ManpowerAttendanceRate] 
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



















GO
/****** Object:  StoredProcedure [dbo].[GET_AF_CSRequest_Detail]    Script Date: 2020-11-27 2:40:56 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Chester R.
-- Create date: 10-10-2019
-- Description:	GET OT Change Schedule Details
-- =============================================
-- 
CREATE PROCEDURE [dbo].[GET_AF_CSRequest_Detail] 
	--DECLARE
	@CSRefNo NVARCHAR(50) = 'CS-ProductionEngineering_20201127100423'
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET FMTONLY OFF

    SELECT  ROW_NUMBER() OVER(ORDER BY (select 0)) AS Rownum,
			CS.ID,
			MEM.Family_Name,
			MEM.First_Name,
			(SELECT TOP 1 Section FROM M_Cost_Center_List WHERE Cost_Center = CS.Section) AS SectionName,
			ML.Line AS LineName,
			CS.Reason,
			CS.DateFrom,
			CS.DateTo,
			CS.CSin,
			CS.CSout,
			CS.CS_RefNo,
			CS.EmployeeNo,
			CS.CSType,
			(SELECT TOP 1 FirstName + ' ' + LastName FROM M_Users WHERE UserName = CS.CreateID AND IsDeleted <> 1) AS Requestor
			,CS.CreateID
	FROM AF_ChangeSchedulefiling CS
	LEFT JOIN M_LineTeam ML
	ON CS.Line_Team = ML.ID
	LEFT JOIN M_Cost_Center_List MS
	ON CS.Section = MS.Section
	LEFT JOIN M_Employee_Master_List MEM
	ON CS.EmployeeNo = MEM.EmpNo
	WHERE CS.CS_RefNo = @CSRefNo
	AND CS.Status > -1

END









GO
/****** Object:  StoredProcedure [dbo].[GET_Employee_OTFiling]    Script Date: 2020-11-27 2:40:56 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Chester
-- Create date: 10-08-2019
-- Description:	Get Employee details for OT
-- =============================================

CREATE PROCEDURE [dbo].[GET_Employee_OTFiling]
	--DECLARE
	@Agency NVARCHAR(20)  = 'BIPH',
	@CostCode NVARCHAR(50) = '6110',
	@LINEID BIGINT = NULL,
	@EmployeeNo NVARCHAR(50) = '',
	@PageCount INT = 0,
	@RowCount INT = 10,
	@Searchvalue NVARCHAR(50) = 'BIPH2013-0016',
	@TotalCount INT --OUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET FMTONLY OFF;
	IF OBJECT_ID('tempdb..#TempEmployeeTBL') IS NOT NULL
		DROP TABLE #TempEmployeeTBL
	IF OBJECT_ID('tempdb..#Skill') IS NOT NULL
		DROP TABLE #Skill
	IF OBJECT_ID('tempdb..#SkillEmp') IS NOT NULL
		DROP TABLE #SkillEmp
	DECLARE @SectionGroup NVARCHAR(50)

		SET @SectionGroup = (SELECT GroupSection FROM M_Cost_Center_List WHERE Cost_Center = @CostCode);


SELECT *
INTO #Skill
FROM M_LineTeam
WHERE Section IN (SELECT Cost_Center FROM M_Cost_Center_List WHERE GroupSection = @SectionGroup)
AND IsDeleted <> 1
AND (@LINEID = '' OR @LINEID IS NULL OR ID = @LINEID)	

SELECT MES.EmpNo
INTO #SkillEmp
FROM M_Employee_Skills MES
WHERE LineID IN (

SELECT ID FROM #Skill
)

--SELECT * FROM #SkillEmp



SELECT	 CASE WHEN EmpNo LIKE 'BIPH%' THEN 1 ELSE 2 END AS Prio
		,MEL.EmpNo
		, MEL.Family_Name
		, MEL.First_Name
		, MEL.Date_Hired
		, (SELECT top 1 MEC.Status FROM M_Employee_Status MEC WHERE MEC.EmployNo = MEL.EmpNo ORDER BY MEC.ID DESC) as Status
		, MEL.Company
		,(SELECT TOP 1 CostCenter_AMS FROM M_Employee_CostCenter WHERE EmployNo = MEL.EmpNo AND UpdateDate_AMS <= GETDATE() ORDER BY UpdateDate_AMS DESC) AS CostCenter_AMS
		--, MEC.CostCenter_AMS
INTO #TempEmployeeTBL
FROM M_Employee_Master_List MEL 
WHERE (SELECT top 1 MEC.Status FROM M_Employee_Status MEC WHERE MEC.EmployNo = MEL.EmpNo ORDER BY MEC.ID DESC) = 'ACTIVE'
AND (MEL.EmpNo IN (SELECT EmpNo FROM #SkillEmp) OR @LINEID IS NULL OR @LINEID = '')
AND (SELECT TOP 1 MEC.CostCenter_AMS FROM M_Employee_CostCenter MEC WHERE MEC.EmployNo = MEL.EmpNo AND MEC.UpdateDate_AMS <= GETDATE() ORDER BY UpdateDate_AMS DESC) IN (SELECT Cost_Center
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
AND (  MEL.EmpNo LIKE '%'+@Searchvalue+'%' 
	OR MEL.First_Name LIKE '%'+@Searchvalue+'%' 
	OR MEL.Family_Name LIKE '%'+@Searchvalue+'%'
	)
ORDER BY CASE WHEN EmpNo LIKE 'BIPH%' THEN 1 ELSE 2 END
OFFSET @PageCount * (@RowCount) ROWS
FETCH NEXT @RowCount ROWS ONLY	

SELECT  TB.EmpNo,
		TB.Family_Name,
		TB.First_Name,
		TB.Company AS Agency,
		TB.CostCenter_AMS,
		@SectionGroup AS Section,
		(SELECT TimeIn + ' - ' + TimeOut 
			 FROM M_Schedule 
			 WHERE ID = (SELECT TOP 1 ScheduleID
						 FROM M_Employee_Master_List_Schedule 
						 WHERE EmployeeNo = TB.EmpNo 
						 ORDER BY ID DESC)) AS Schedule,
			(SELECT SUM(OTHours) FROM AF_OTfiling_Cumulative WHERE EmployeeNo = TB.EmpNo AND MONTH(OTDate) = MONTH(GETDATE()) AND YEAR(OTDate) = YEAR(GETDATE())) AS CumulativeOT
		
--INTO #checkCer
FROM #TempEmployeeTBL TB
ORDER BY Prio, EmpNo
END



SET @TotalCount = (


SELECT COUNT(MEL.EmpNo)
FROM M_Employee_Master_List MEL 
WHERE (SELECT top 1 MEC.Status FROM M_Employee_Status MEC WHERE MEC.EmployNo = MEL.EmpNo ORDER BY MEC.ID DESC) = 'ACTIVE'	
AND (MEL.EmpNo IN (SELECT EmpNo FROM #SkillEmp) OR @LINEID IS NULL OR @LINEID = '')
AND (SELECT TOP 1 MEC.CostCenter_AMS FROM M_Employee_CostCenter MEC WHERE MEC.EmployNo = MEL.EmpNo AND MEC.UpdateDate_AMS <= GETDATE() ORDER BY UpdateDate_AMS DESC) IN (SELECT Cost_Center
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



)






GO
/****** Object:  StoredProcedure [dbo].[GET_Employee_Skills]    Script Date: 2020-11-27 2:40:56 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Chester
-- Create date: 10-04-2019
-- Description:	Get Employee Skills
-- =============================================
-- [dbo].[GET_Employee_Skills] 'SRI2015-01443'
CREATE PROCEDURE [dbo].[GET_Employee_Skills]
	--DECLARE
	@EmployeeNo NVARCHAR(50) = 'BIPH2013-00166'

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	DECLARE @SectionGroup NVARCHAR(MAX),
			@CostCodenow NVARCHAR(10)

	SET @CostCodenow = (SELECT TOP 1 CostCenter_AMS FROM M_Employee_CostCenter WHERE EmployNo = @EmployeeNo ORDER BY UpdateDate_AMS DESC)
	SET @SectionGroup = (SELECT TOP 1 GroupSection FROM M_Cost_Center_List WHERE Cost_Center = @CostCodenow)

    SELECT  MS.EmpNo,
			MS.LineID,
			MS.SkillID,
			LT.Line, 
			S.Skill,
			S.SkillLogo,
			(SELECT FirstName + ' '+ LastName FROM M_Users WHERE UserName = MS.UpdateID) AS UpdateBy,
			MS.UpdateDate
			FROM M_Employee_Skills MS
			LEFT JOIN M_LineTeam LT
			ON MS.LineID = LT.ID
			LEFT JOIN M_Skills S
			ON MS.SkillID = S.ID
			WHERE MS.EmpNo = @EmployeeNo
			AND S.IsDeleted <> 1
			AND LT.IsDeleted <> 1
			AND LT.Section IN (SELECT Cost_Center FROM M_Cost_Center_List WHERE GroupSection = @SectionGroup)
END











GO
/****** Object:  StoredProcedure [dbo].[GET_RP_AttendanceMonitoring]    Script Date: 2020-11-27 2:40:56 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[GET_RP_AttendanceMonitoring]
	--DECLARE 
	@Month INT = '11',
	@Year INT = '2020',
	@Section NVARCHAR(50) = 'BPS',
	@Agency NVARCHAR(50) = '',
	@PageCount INT = 0,
	@RowCount INT = 300,
	@Searchvalue NVARCHAR(50) = ''

AS
BEGIN

--FOR DAYS GENERATOR --

IF OBJECT_ID('tempdb..#DaysMonth') IS NOT NULL
		DROP TABLE #DaysMonth;

	;WITH
	CTE_Days AS
	(
	SELECT DATEADD(month, @Month, DATEADD(month, -MONTH(GETDATE()), DATEADD(day, -DAY(GETDATE()) + 1, CAST(FLOOR(CAST(GETDATE() AS FLOAT)) AS DATETIME)))) D
	UNION ALL
	SELECT DATEADD(day, 1, D)
	FROM CTE_Days
	WHERE D < DATEADD(day, -1, DATEADD(month, 1, DATEADD(month, @Month, DATEADD(month, -MONTH(GETDATE()), DATEADD(day, -DAY(GETDATE()) + 1, CAST(FLOOR(CAST(GETDATE() AS FLOAT)) AS DATETIME))))))
	)

	SELECT D AS DayOfMonth
	INTO #DaysMonth
	FROM CTE_Days




--########## GET INITIAL List #############--
DECLARE @EndofMonthDays INT
	SET @EndofMonthDays = (SELECT TOP 1 Day(DayOfMonth) FROM #DaysMonth ORDER BY DayOfMonth DESC)
DECLARE @EndofMonth DATETIME
	SET @EndofMonth = (SELECT TOP 1 DayOfMonth FROM #DaysMonth ORDER BY DayOfMonth DESC)
DECLARE @StartofMonth DATETIME
	SET @StartofMonth = (SELECT TOP 1 DayOfMonth FROM #DaysMonth ORDER BY DayOfMonth ASC)
IF OBJECT_ID('tempdb..#EmpList') IS NOT NULL
		DROP TABLE #EmpList;
SELECT  CASE WHEN MEL.EmpNo LIKE 'BIPH%' THEN 1 ELSE 2 END AS Prio,
		MEL.EmpNo,
		MEL.Family_Name +', ' + MEL.First_Name AS EmployeeName,
		ISNULL((SELECT Type +  ' (' + TimeIn + ' - ' + TimeOut +')'
					 FROM M_Schedule 
					 WHERE ID = ISNULL((SELECT TOP 1 s.Schedule FROM AF_ChangeSchedulefiling s
						 WHERE s.EmployeeNo = MEL.EmpNo
						 AND GETDATE() BETWEEN s.DateFrom AND s.DateTo
						 AND s.Status = s.StatusMax
						 ORDER BY s.ID DESC),(SELECT TOP 1 ScheduleID
						 FROM M_Employee_Master_List_Schedule 
						 WHERE EmployeeNo = MEL.EmpNo 
						 AND ScheduleID IS NOT NULL
						 AND EffectivityDate <= GETDATE()
						 ORDER BY ID DESC))),'') AS Schedule,
		 (SELECT TOP 1 p.Position FROM M_Employee_Position p WHERE p.EmployNo = MEL.EmpNo ORDER BY ID DESC) AS Position,
		 (SELECT TOP 1 ss.CostCenter_AMS FROM M_Employee_CostCenter ss 
		 WHERE ss.EmployNo = MEL.EmpNo 
		 AND LEN(CostCenter_AMS) > 0
		 ORDER BY ID DESC) AS CostCode,
		 MEL.Date_Resigned,
		 MEL.Date_Hired
		
INTO #EmpList
FROM M_Employee_Master_List MEL
WHERE MEL.EmpNo IN (
	SELECT EmployNo
	FROM M_Employee_CostCenter
	WHERE CostCenter_AMS IN (SELECT Cost_Center
							FROM M_Cost_Center_List
							WHERE GroupSection = @Section
							OR @Section = ''
							OR @Section IS NULL)
)
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
AND (CAST((CAST(@Year AS VARCHAR(4)) + '-' + CAST(@Month AS VARCHAR(2)) + '-' + CAST(1 AS VARCHAR(2))) AS DATETIME) <= MEL.Date_Resigned OR MEL.Date_Resigned IS NULL)
AND  ((SELECT top 1 MEC.Status FROM M_Employee_Status MEC WHERE MEC.EmployNo = MEL.EmpNo ORDER BY MEC.ID DESC) = 'ACTIVE' OR ((SELECT top 1 MEC.UpdateDate FROM M_Employee_Status MEC WHERE MEC.EmployNo = MEL.EmpNo AND Status = 'ACTIVE' ORDER BY MEC.ID DESC) <= CAST((CAST(@Year AS VARCHAR(4)) + '-' + CAST(@Month AS VARCHAR(2)) + '-' + CAST(@EndofMonthDays AS VARCHAR(2))) AS DATETIME))	AND (SELECT top 1 MEC.UpdateDate FROM M_Employee_Status MEC WHERE MEC.EmployNo = MEL.EmpNo AND Status <> 'ACTIVE' ORDER BY MEC.ID DESC) >= CAST((CAST(@Year AS VARCHAR(4)) + '-' + CAST(@Month AS VARCHAR(2)) + '-' + CAST(1 AS VARCHAR(2))) AS DATETIME))
--AND (SELECT TOP 1 MEC.CostCenter_AMS FROM M_Employee_CostCenter MEC WHERE MEC.EmployNo = MEL.EmpNo AND MEC.UpdateDate_AMS <= CAST((CAST(@Year AS VARCHAR(4)) + '-' + CAST(@Month AS VARCHAR(2)) + '-' + CAST(@EndofMonthDays AS VARCHAR(2))) AS DATETIME) ORDER BY MEC.ID DESC) IN (SELECT Cost_Center
--																																													 FROM M_Cost_Center_List
--																																													 WHERE GroupSection = @Section
--																																													 OR @Section= ''
--																																													 OR @Section IS NULL)
AND (  MEL.EmpNo LIKE '%'+@Searchvalue+'%' 
	OR MEL.First_Name LIKE '%'+@Searchvalue+'%' 
	OR MEL.Family_Name LIKE '%'+@Searchvalue+'%'
	)
--AND MEL.EmpNo =  'BIPH2015-00805'
ORDER BY CASE WHEN MEL.EmpNo LIKE 'BIPH%' THEN 1 ELSE 2 END, MEL.EmpNo			
OFFSET @PageCount * (@RowCount) ROWS
FETCH NEXT @RowCount ROWS ONLY	



--SELECT * FROM #EmpList WHERE EmpNo = 'BIPH2012-00028'

--########## END INITIAL List #############--
IF OBJECT_ID('tempdb..#RPLeave') IS NOT NULL
		DROP TABLE #RPLeave;

SELECT *
INTO #RPLeave
FROM RP_AttendanceMonitoring
WHERE Date BETWEEN @StartofMonth AND @EndofMonth+' 23:59:59'
AND LeaveType <> '-'

IF OBJECT_ID('tempdb..#TTFilter') IS NOT NULL
		DROP TABLE #TTFilter;

SELECT a.*
INTO #TTFilter
FROM T_TimeInOut a
LEFT JOIN #EmpList b
ON a.EmpNo = b.EmpNo
WHERE ISNULL(TimeIn,Timeout) BETWEEN @StartofMonth AND @EndofMonth+' 23:59:59'
AND a.EmpNo IN (SELECT a.EmpNo FROM #EmpList a)

IF OBJECT_ID('tempdb..#TimeinOutRecord') IS NOT NULL
		DROP TABLE #TimeinOutRecord;

CREATE TABLE #TimeinOutRecord
(
EmpNo NVARCHAR(50),
RFID NVARCHAR(50),
ScheduleID INT,
TimeIn NVARCHAR(20),
Date DATETIME,
LeaveHere NVARCHAR(20)

)



--########################################################--------Timein and out-----------------##########################################################
IF OBJECT_ID('tempdb..#NightInTime') IS NOT NULL
		DROP TABLE #NightInTime;
DECLARE @Daynum DATETIME;

IF OBJECT_ID('tempdb..#NightIn') IS NOT NULL
		DROP TABLE #NightIn;

CREATE TABLE #NightIn
(
EmpNo NVARCHAR(50),
RFID NVARCHAR(50),
ScheduleID INT,
TimeIn NVARCHAR(20),
Date DATETIME
)


IF OBJECT_ID('tempdb..#DayInTime') IS NOT NULL
		DROP TABLE #DayInTime;

IF OBJECT_ID('tempdb..#DayIn') IS NOT NULL
		DROP TABLE #DayIn;


CREATE TABLE #DayIn
(
EmpNo NVARCHAR(50),
RFID NVARCHAR(50),
ScheduleID INT,
TimeIn NVARCHAR(20),
Date DATETIME
)



DECLARE MY_CURSOR CURSOR 
  LOCAL STATIC READ_ONLY FORWARD_ONLY
FOR 

	SELECT DayOfMonth
	FROM #DaysMonth

OPEN MY_CURSOR
FETCH  FROM MY_CURSOR INTO @Daynum
WHILE @@FETCH_STATUS = 0
BEGIN

;WITH ranked_messages AS (
  SELECT M.*, ROW_NUMBER() OVER (PARTITION BY EmpNo ORDER BY ID ASC) AS rn
 FROM #TTFilter M
 WHERE ISNULL(ISNULL(DTR_TimeIn,DTR_TimeOut),ISNULL(TimeIn,Timeout)) BETWEEN @Daynum AND @Daynum+' 23:59:59'
 AND ISNULL(CS_ScheduleID,ScheduleID) IN (SELECT ID FROM M_Schedule WHERE Type LIKE 'Night%')
 AND (convert(char(5), ISNULL(DTR_TimeIn,TimeIn), 108) > '12:00:00 PM')
)

INSERT INTO #NightIn(EmpNo,RFID,ScheduleID,TimeIn,Date)
SELECT  EmpNo,
		Employee_RFID, 
		ISNULL(CS_ScheduleID,ScheduleID) AS ScheduleID, 
		ISNULL(CONVERT(VARCHAR(5),TimeIn,108),'NoIn') AS TimeIn, 
		@Daynum
--INTO #NightInTime
FROM ranked_messages WHERE rn = 1
ORDER BY DAY(ISNULL(TimeIn,TimeOut));




;WITH ranked_messages AS (
  SELECT M.*, ROW_NUMBER() OVER (PARTITION BY EmpNo ORDER BY ID ASC) AS rn
 FROM #TTFilter M
 WHERE ISNULL(ISNULL(DTR_TimeIn,DTR_TimeOut),ISNULL(TimeIn,Timeout)) BETWEEN @Daynum AND @Daynum+' 23:59:59'
 AND (ISNULL(CS_ScheduleID,ScheduleID) IN (SELECT ID FROM M_Schedule WHERE Type LIKE 'Day%') OR ISNULL(CS_ScheduleID,ScheduleID) IS NULL)
)

INSERT INTO #DayIn(EmpNo,RFID,ScheduleID,TimeIn,Date)
SELECT  EmpNo,
		Employee_RFID, 
		ISNULL(CS_ScheduleID,ScheduleID) AS ScheduleID, 
		ISNULL(CONVERT(VARCHAR(5),TimeIn,108),'NoIn') AS TimeIn,
		@Daynum
		--DAY(ISNULL(TimeIn,TimeOut)) AS Daynum,
		--MONTH(ISNULL(TimeIn,TimeOut)) AS Monthnum,
		--YEAR(ISNULL(TimeIn,TimeOut)) AS Yearnum
--INTO #DayInTime
FROM ranked_messages WHERE rn = 1
ORDER BY DAY(ISNULL(TimeIn,TimeOut));





FETCH NEXT FROM MY_CURSOR INTO @Daynum

END
CLOSE MY_CURSOR
DEALLOCATE MY_CURSOR

INSERT INTO #TimeinOutRecord(EmpNo,RFID,ScheduleID,TimeIn,Date,LeaveHere)
SELECT  a.EmpNo,
		a.RFID,
		a.ScheduleID,
		a.TimeIn,
		a.Date,
		a.TimeIn
FROM #DayIn a

--WHERE a.EmpNo =  'BIPH2017-01795'

INSERT INTO #TimeinOutRecord(EmpNo,RFID,ScheduleID,TimeIn,Date,LeaveHere)
SELECT  a.EmpNo,
		a.RFID,
		a.ScheduleID,
		a.TimeIn,
		a.Date,
		a.TimeIn
FROM #NightIn a


--############### INSERT LEAVE ##################
INSERT INTO #TimeinOutRecord(EmpNo,RFID,ScheduleID,TimeIn,Date,LeaveHere)
SELECT RP.EmployeeNo, MEL.RFID, 2,'00:00',RP.Date,RP.LeaveType
FROM #RPLeave RP
LEFT JOIN M_Employee_Master_List MEL
ON RP.EmployeeNo = MEL.EmpNo
WHERE MEL.EmpNo IN (SELECT a.EmpNo FROM #EmpList a)
AND LeaveType <> 'AB'



--###############################################



--########################################################----------------------------##########################################################

IF OBJECT_ID('tempdb..#CostCodeList') IS NOT NULL
		DROP TABLE #CostCodeList;

SELECT Cost_Center
INTO #CostCodeList
FROM M_Cost_Center_List
WHERE (GroupSection = @Section OR @Section = '' OR @Section IS NULL)

IF OBJECT_ID('tempdb..#PresentAbsent') IS NOT NULL
		DROP TABLE #PresentAbsent;


SELECT  MEL.EmpNo,
		MEL.RFID,
		MEL.ScheduleID,
		--CASE WHEN (SELECT TOP 1 s.Type FROM M_Schedule s WHERE s.ID = MEL.ScheduleID) LIKE 'Night%' 
		--	 THEN 'P(N)'
		--	 ELSE 'P(D)'
		--	 END AS Result,
		CASE WHEN (SELECT TOP 1 s.Type FROM M_Schedule s WHERE s.ID = MEL.ScheduleID) LIKE 'Night%' 
			 THEN (CASE WHEN (SELECT TOP 1 ss.CostCenter_AMS FROM M_Employee_CostCenter ss 
								 WHERE ss.EmployNo = MEL.EmpNo 
								 AND ss.UpdateDate_AMS<= MEL.Date
								 AND LEN(CostCenter_AMS) > 0
								 ORDER BY ID DESC) IN (SELECT Cost_Center FROM #CostCodeList) THEN 'P(N)' ELSE 'TR(N)' END)
			 ELSE (CASE WHEN (SELECT TOP 1 ss.CostCenter_AMS FROM M_Employee_CostCenter ss 
								 WHERE ss.EmployNo = MEL.EmpNo 
								 AND ss.UpdateDate_AMS<= MEL.Date
								 AND LEN(CostCenter_AMS) > 0
								 ORDER BY ID DESC) IN (SELECT Cost_Center FROM #CostCodeList) THEN 'P(D)' ELSE 'TR(D)' END) 
			 END AS Result,
		MEL.Date,
		MEL2.Date_Resigned,
		CASE WHEN LEN(MEL.LeaveHere) > 2 THEN '' ELSE MEL.LeaveHere END AS LeaveHere,
		(SELECT TOP 1 ss.CostCenter_AMS FROM M_Employee_CostCenter ss 
		 WHERE ss.EmployNo = MEL.EmpNo 
		 AND ss.UpdateDate_AMS<= MEL.Date
		 AND LEN(CostCenter_AMS) > 0
		 ORDER BY ID DESC) AS CostCode
		
INTO #PresentAbsent
FROM #TimeinOutRecord MEL
LEFT JOIN M_Employee_Master_List MEL2
ON MEL.EmpNo = MEL2.EmpNo

--SELECT * FROM #PresentAbsent-- WHERE EmpNo = 'BIPH2012-00028'




--SELECT * FROM #PresentAbsent
--############## START DRAWING #############



DECLARE @SQLf NVARCHAR(MAX);
SET @SQLf ='

IF OBJECT_ID(''tempdb..#EmpListwithDate'') IS NOT NULL
		DROP TABLE #EmpListwithDate
IF OBJECT_ID(''tempdb..#FinishTable'') IS NOT NULL
		DROP TABLE #FinishTable

SELECT  CASE WHEN ('+CAST(@PageCount AS VARCHAR(10))+') = 0 THEN ROW_NUMBER() OVER(ORDER BY (select 0)) ELSE ROW_NUMBER() OVER(ORDER BY (select 0))+ ('+CAST(@RowCount AS VARCHAR(10))+') * ('+CAST(@PageCount AS VARCHAR(10))+') END AS Rownum,
		pvt.EmpNo,
		pvt.Schedule,
		pvt.EmployeeName,
		pvt.Position,
		pvt.CostCode,
		'
		+ REPLACE(REPLACE(REPLACE((SELECT STUFF( (SELECT ',  (CASE WHEN (''' + CONVERT(VARCHAR(10),DayOfMonth,120) + ''' <= GETDATE() AND pvt.Date_Hired <= ''' + CONVERT(VARCHAR(10),DayOfMonth,120) + ''' AND (pvt.Date_Resigned >= ''' + CONVERT(VARCHAR(10),DayOfMonth,120) + ''' OR pvt.Date_Resigned IS NULL OR pvt.Date_Resigned = '''' ))
																	THEN
																	ISNULL((SELECT TOP 1 CASE WHEN ((s.LeaveHere = '''' OR s.LeaveHere = ''AB'') AND s.Result IS NOT NULL) THEN s.Result
																							  
																							  ELSE s.LeaveHere END 
																	 FROM #PresentAbsent s
																	 WHERE s.EmpNo = pvt.EmpNo
																	 AND (CAST(DAY(s.[Date]) AS VARCHAR(2)) = ''' + CAST(DAY(DayOfMonth) AS VARCHAR(2)) + '''
																	      )
																		),(
																		CASE WHEN (SELECT TOP 1 ss.CostCenter_AMS FROM M_Employee_CostCenter ss 
																				 WHERE ss.EmployNo = pvt.EmpNo 
																				 AND ss.UpdateDate_AMS<= ''' + CONVERT(VARCHAR(10),DayOfMonth,120) + '''
																				 AND LEN(pvt.CostCode) > 0
																				 ORDER BY ID DESC) IN (SELECT Cost_Center FROM #CostCodeList)

																				 THEN CASE WHEN (''' + CAST(DATENAME(dw,DayOfMonth) AS VARCHAR(20)) + ''' <> ''Saturday'' AND ''' + CAST(DATENAME(dw,DayOfMonth) AS VARCHAR(20)) + ''' <> ''Sunday'') THEN ''AB'' ELSE ''NW'' END
																				 ELSE ''TR''
																				 END
																		
																		
																		))
																				

																	ELSE
																	''-''
																	END)

															
												  AS [' + CAST(DAY(DayOfMonth) AS VARCHAR(2)) + ']'
										   FROM #DaysMonth  
											 FOR XML PATH('')), 1, 2, '')),'&lt;', '<'),'&gt;', '>'), '&#x0D;','')
		+
		'

FROM #EmpList pvt
ORDER BY Prio, EmpNo
'

--SELECT @SQLf
EXECUTE(@SQLf)
--############# END DRAWING ###################


END





GO
/****** Object:  StoredProcedure [dbo].[GET_RP_AttendanceMonitoring_COUNT]    Script Date: 2020-11-27 2:40:56 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Chester R.
-- Create date: 10-31-2019
-- Description:	Email Approvers OVERTIME
-- =============================================

CREATE PROCEDURE [dbo].[GET_RP_AttendanceMonitoring_COUNT] 
--DECLARE 
	@Month INT = '11',
	@Year INT = '2020',
	@Section NVARCHAR(50) = 'Development Engineering',
	@Agency NVARCHAR(50) = 'BIPH',
	@Searchvalue NVARCHAR(50) = ''
AS
BEGIN
SET NOCOUNT ON;
SET FMTONLY OFF;
IF OBJECT_ID('tempdb..#DaysMonth2') IS NOT NULL
		DROP TABLE #DaysMonth2;
IF OBJECT_ID('tempdb..#DaysMonth') IS NOT NULL
		DROP TABLE #DaysMonth;

	;WITH
	CTE_Days AS
	(
	SELECT DATEADD(month, @Month, DATEADD(month, -MONTH(GETDATE()), DATEADD(day, -DAY(GETDATE()) + 1, CAST(FLOOR(CAST(GETDATE() AS FLOAT)) AS DATETIME)))) D
	UNION ALL
	SELECT DATEADD(day, 1, D)
	FROM CTE_Days
	WHERE D < DATEADD(day, -1, DATEADD(month, 1, DATEADD(month, @Month, DATEADD(month, -MONTH(GETDATE()), DATEADD(day, -DAY(GETDATE()) + 1, CAST(FLOOR(CAST(GETDATE() AS FLOAT)) AS DATETIME))))))
	)

	SELECT D AS DayOfMonth
	INTO #DaysMonth
	FROM CTE_Days


	;WITH
	CTE_Days AS
	(
	SELECT DATEADD(month, @Month, DATEADD(month, -MONTH(GETDATE()), DATEADD(day, -DAY(GETDATE()) + 1, CAST(FLOOR(CAST(GETDATE() AS FLOAT)) AS DATETIME)))) D
	UNION ALL
	SELECT DATEADD(day, 1, D)
	FROM CTE_Days
	WHERE D < DATEADD(day, -1, DATEADD(month, 1, DATEADD(month, @Month, DATEADD(month, -MONTH(GETDATE()), DATEADD(day, -DAY(GETDATE()) + 1, CAST(FLOOR(CAST(GETDATE() AS FLOAT)) AS DATETIME))))))
	)

	SELECT Day(D) AS DayOfMonth
	INTO #DaysMonth2
	FROM CTE_Days;


--END OF DAY GENERATOR--
DECLARE @EndofMonthDay INT
	SET @EndofMonthDay = (SELECT TOP 1 Day(DayOfMonth) FROM #DaysMonth ORDER BY DayOfMonth DESC)

SELECT 'Result' AS result,COUNT(MEL.EmpNo) AS TotalCount
FROM M_Employee_Master_List MEL
WHERE MEL.EmpNo IN (
	SELECT EmployNo
	FROM M_Employee_CostCenter
	WHERE CostCenter_AMS IN (SELECT Cost_Center
							FROM M_Cost_Center_List
							WHERE GroupSection = @Section
							OR @Section = ''
							OR @Section IS NULL)
)
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
AND (CAST((CAST(@Year AS VARCHAR(4)) + '-' + CAST(@Month AS VARCHAR(2)) + '-' + CAST(1 AS VARCHAR(2))) AS DATETIME) <= MEL.Date_Resigned OR MEL.Date_Resigned IS NULL)
AND  ((SELECT top 1 MEC.Status FROM M_Employee_Status MEC WHERE MEC.EmployNo = MEL.EmpNo ORDER BY MEC.ID DESC) = 'ACTIVE' OR ((SELECT top 1 MEC.UpdateDate FROM M_Employee_Status MEC WHERE MEC.EmployNo = MEL.EmpNo AND Status = 'ACTIVE' ORDER BY MEC.ID DESC) <= CAST((CAST(@Year AS VARCHAR(4)) + '-' + CAST(@Month AS VARCHAR(2)) + '-' + CAST(@EndofMonthDay AS VARCHAR(2))) AS DATETIME))	AND (SELECT top 1 MEC.UpdateDate FROM M_Employee_Status MEC WHERE MEC.EmployNo = MEL.EmpNo AND Status <> 'ACTIVE' ORDER BY MEC.ID DESC) >= CAST((CAST(@Year AS VARCHAR(4)) + '-' + CAST(@Month AS VARCHAR(2)) + '-' + CAST(1 AS VARCHAR(2))) AS DATETIME))
--AND (SELECT TOP 1 MEC.CostCenter_AMS FROM M_Employee_CostCenter MEC WHERE MEC.EmployNo = MEL.EmpNo AND MEC.UpdateDate_AMS <= CAST((CAST(@Year AS VARCHAR(4)) + '-' + CAST(@Month AS VARCHAR(2)) + '-' + CAST(@EndofMonthDay AS VARCHAR(2))) AS DATETIME) ORDER BY UpdateDate_AMS DESC) IN (SELECT Cost_Center
--																																													 FROM M_Cost_Center_List
--																																													 WHERE GroupSection = @Section
--																																											 OR @Section= ''
--																																													 OR @Section IS NULL)

AND (  MEL.EmpNo LIKE '%'+@Searchvalue+'%' 
	OR MEL.First_Name LIKE '%'+@Searchvalue+'%' 
	OR MEL.Family_Name LIKE '%'+@Searchvalue+'%'
	)

--SELECT 'result' AS Result, 1 AS TotalCount

END










GO
/****** Object:  StoredProcedure [dbo].[GET_RP_AttendanceMonitoring_Shift]    Script Date: 2020-11-27 2:40:56 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[GET_RP_AttendanceMonitoring_Shift]
	--DECLARE 
	@Month INT = '10',
	@Year INT = '2020',
	@Section NVARCHAR(50) = 'Production Engineering',
	@Agency NVARCHAR(50) = '',
	@PageCount INT = 0,
	@RowCount INT = 10000,
	@Searchvalue NVARCHAR(50) = ''

AS
BEGIN

--FOR DAYS GENERATOR --

IF OBJECT_ID('tempdb..#DaysMonth') IS NOT NULL
		DROP TABLE #DaysMonth;

	;WITH
	CTE_Days AS
	(
	SELECT DATEADD(month, @Month, DATEADD(month, -MONTH(GETDATE()), DATEADD(day, -DAY(GETDATE()) + 1, CAST(FLOOR(CAST(GETDATE() AS FLOAT)) AS DATETIME)))) D
	UNION ALL
	SELECT DATEADD(day, 1, D)
	FROM CTE_Days
	WHERE D < DATEADD(day, -1, DATEADD(month, 1, DATEADD(month, @Month, DATEADD(month, -MONTH(GETDATE()), DATEADD(day, -DAY(GETDATE()) + 1, CAST(FLOOR(CAST(GETDATE() AS FLOAT)) AS DATETIME))))))
	)

	SELECT D AS DayOfMonth
	INTO #DaysMonth
	FROM CTE_Days




--########## GET INITIAL List #############--
DECLARE @EndofMonthDays INT
	SET @EndofMonthDays = (SELECT TOP 1 Day(DayOfMonth) FROM #DaysMonth ORDER BY DayOfMonth DESC)
DECLARE @EndofMonth DATETIME
	SET @EndofMonth = (SELECT TOP 1 DayOfMonth FROM #DaysMonth ORDER BY DayOfMonth DESC)
DECLARE @StartofMonth DATETIME
	SET @StartofMonth = (SELECT TOP 1 DayOfMonth FROM #DaysMonth ORDER BY DayOfMonth ASC)
IF OBJECT_ID('tempdb..#EmpList') IS NOT NULL
		DROP TABLE #EmpList;
SELECT  CASE WHEN MEL.EmpNo LIKE 'BIPH%' THEN 1 ELSE 2 END AS Prio,
		MEL.EmpNo,
		MEL.Family_Name +', ' + MEL.First_Name AS EmployeeName,
		ISNULL((SELECT Type
					 FROM M_Schedule 
					 WHERE ID = ISNULL((SELECT TOP 1 s.Schedule FROM AF_ChangeSchedulefiling s
						 WHERE s.EmployeeNo = MEL.EmpNo
						 AND GETDATE() BETWEEN s.DateFrom AND s.DateTo
						 AND s.Status = s.StatusMax
						 ORDER BY s.ID DESC),(SELECT TOP 1 ScheduleID
						 FROM M_Employee_Master_List_Schedule 
						 WHERE EmployeeNo = MEL.EmpNo 
						 AND ScheduleID IS NOT NULL
						 AND EffectivityDate <= GETDATE()
						 ORDER BY ID DESC))),'') AS Schedule,
		 (SELECT TOP 1 p.Position FROM M_Employee_Position p WHERE p.EmployNo = MEL.EmpNo ORDER BY ID DESC) AS Position,
		 (SELECT TOP 1 ss.CostCenter_AMS FROM M_Employee_CostCenter ss 
		 WHERE ss.EmployNo = MEL.EmpNo 
		 AND LEN(CostCenter_AMS) > 0
		 ORDER BY ID DESC) AS CostCode,
		 MEL.Date_Resigned,
		 MEL.Date_Hired
		
INTO #EmpList
FROM M_Employee_Master_List MEL
WHERE MEL.EmpNo IN (
	SELECT EmployNo
	FROM M_Employee_CostCenter
	WHERE CostCenter_AMS IN (SELECT Cost_Center
							FROM M_Cost_Center_List
							WHERE GroupSection = @Section
							OR @Section = ''
							OR @Section IS NULL)
)
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
AND (CAST((CAST(@Year AS VARCHAR(4)) + '-' + CAST(@Month AS VARCHAR(2)) + '-' + CAST(1 AS VARCHAR(2))) AS DATETIME) <= MEL.Date_Resigned OR MEL.Date_Resigned IS NULL)
AND  ((SELECT top 1 MEC.Status FROM M_Employee_Status MEC WHERE MEC.EmployNo = MEL.EmpNo ORDER BY MEC.ID DESC) = 'ACTIVE' OR ((SELECT top 1 MEC.UpdateDate FROM M_Employee_Status MEC WHERE MEC.EmployNo = MEL.EmpNo AND Status = 'ACTIVE' ORDER BY MEC.ID DESC) <= CAST((CAST(@Year AS VARCHAR(4)) + '-' + CAST(@Month AS VARCHAR(2)) + '-' + CAST(@EndofMonthDays AS VARCHAR(2))) AS DATETIME))	AND (SELECT top 1 MEC.UpdateDate FROM M_Employee_Status MEC WHERE MEC.EmployNo = MEL.EmpNo AND Status <> 'ACTIVE' ORDER BY MEC.ID DESC) >= CAST((CAST(@Year AS VARCHAR(4)) + '-' + CAST(@Month AS VARCHAR(2)) + '-' + CAST(1 AS VARCHAR(2))) AS DATETIME))

AND (  MEL.EmpNo LIKE '%'+@Searchvalue+'%' 
	OR MEL.First_Name LIKE '%'+@Searchvalue+'%' 
	OR MEL.Family_Name LIKE '%'+@Searchvalue+'%'
	)
--AND MEL.EmpNo = 'AMI2020-09924'
ORDER BY CASE WHEN MEL.EmpNo LIKE 'BIPH%' THEN 1 ELSE 2 END, MEL.EmpNo			
OFFSET @PageCount * (@RowCount) ROWS
FETCH NEXT @RowCount ROWS ONLY	


IF OBJECT_ID('tempdb..#ScheduleGetter') IS NOT NULL
		DROP TABLE #ScheduleGetter;
IF OBJECT_ID('tempdb..#ScheduleGetterPVT') IS NOT NULL
		DROP TABLE #ScheduleGetterPVT;

SELECT a.EmpNo,da.DayOfMonth
INTO #ScheduleGetter
FROM #EmpList a
CROSS JOIN #DaysMonth da


SELECT *,ISNULL((SELECT Type +  ' (' + TimeIn + ' - ' + TimeOut +')'
					 FROM M_Schedule 
					 WHERE ID = ISNULL((SELECT TOP 1 s.Schedule FROM AF_ChangeSchedulefiling s
						 WHERE s.EmployeeNo = MEL.EmpNo
						 AND DayOfMonth BETWEEN s.DateFrom AND s.DateTo
						 AND s.Status = s.StatusMax),(SELECT TOP 1 ScheduleID
						 FROM M_Employee_Master_List_Schedule 
						 WHERE EmployeeNo = MEL.EmpNo 
						 AND ScheduleID IS NOT NULL
						 AND EffectivityDate <= DayOfMonth
						 ORDER BY ID DESC))),'') AS Schedule
INTO #ScheduleGetterPVT
FROM #ScheduleGetter MEL



--########## END INITIAL List #############--



--############## START DRAWING #############

DECLARE @SQLf NVARCHAR(MAX);
SET @SQLf ='

IF OBJECT_ID(''tempdb..#EmpListwithDate'') IS NOT NULL
		DROP TABLE #EmpListwithDate
IF OBJECT_ID(''tempdb..#FinishTable'') IS NOT NULL
		DROP TABLE #FinishTable

SELECT  CASE WHEN ('+CAST(@PageCount AS VARCHAR(10))+') = 0 THEN ROW_NUMBER() OVER(ORDER BY (select 0)) ELSE ROW_NUMBER() OVER(ORDER BY (select 0))+ ('+CAST(@RowCount AS VARCHAR(10))+') * ('+CAST(@PageCount AS VARCHAR(10))+') END AS Rownum,
		pvt.EmpNo,
		pvt.Schedule,
		pvt.EmployeeName,
		pvt.Position,
		pvt.CostCode,
		'
		+ REPLACE(REPLACE(REPLACE((SELECT STUFF( (SELECT ',  ISNULL((SELECT TOP 1 Schedule
																	 FROM #ScheduleGetterPVT s
																	 WHERE s.EmpNo = pvt.EmpNo
																	 AND (CAST(DAY(s.[DayOfMonth]) AS VARCHAR(2)) = ''' + CAST(DAY(DayOfMonth) AS VARCHAR(2)) + '''
																	      )
																		),''-'')

															
												  AS [' + CAST(DAY(DayOfMonth) AS VARCHAR(2)) + ']'
										   FROM #DaysMonth  
											 FOR XML PATH('')), 1, 2, '')),'&lt;', '<'),'&gt;', '>'), '&#x0D;','')
		+
		'

FROM #EmpList pvt
ORDER BY Prio, EmpNo
'

--SELECT @SQLf
EXECUTE(@SQLf)
--############# END DRAWING ###################


END





GO
/****** Object:  StoredProcedure [dbo].[GET_RP_AttendanceMonitoring_TimeINOUT]    Script Date: 2020-11-27 2:40:56 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[GET_RP_AttendanceMonitoring_TimeINOUT]
	--DECLARE 
	@Month INT = '11',
	@Year INT = '2020',
	@Section NVARCHAR(50) = '',
	@Agency NVARCHAR(50) = '',
	@PageCount INT = 0,
	@RowCount INT = 10000,
	@Searchvalue NVARCHAR(50) = ''

AS
BEGIN

--FOR DAYS GENERATOR --

IF OBJECT_ID('tempdb..#DaysMonth') IS NOT NULL
		DROP TABLE #DaysMonth;

	;WITH
	CTE_Days AS
	(
	SELECT DATEADD(month, @Month, DATEADD(month, -MONTH(GETDATE()), DATEADD(day, -DAY(GETDATE()) + 1, CAST(FLOOR(CAST(GETDATE() AS FLOAT)) AS DATETIME)))) D
	UNION ALL
	SELECT DATEADD(day, 1, D)
	FROM CTE_Days
	WHERE D < DATEADD(day, -1, DATEADD(month, 1, DATEADD(month, @Month, DATEADD(month, -MONTH(GETDATE()), DATEADD(day, -DAY(GETDATE()) + 1, CAST(FLOOR(CAST(GETDATE() AS FLOAT)) AS DATETIME))))))
	)

	SELECT D AS DayOfMonth
	INTO #DaysMonth
	FROM CTE_Days




--########## GET INITIAL List #############--
DECLARE @EndofMonthDays INT
	SET @EndofMonthDays = (SELECT TOP 1 Day(DayOfMonth) FROM #DaysMonth ORDER BY DayOfMonth DESC)
IF OBJECT_ID('tempdb..#EmpList') IS NOT NULL
		DROP TABLE #EmpList;
SELECT  CASE WHEN MEL.EmpNo LIKE 'BIPH%' THEN 1 ELSE 2 END AS Prio,
		MEL.EmpNo,
		MEL.Family_Name +', ' + MEL.First_Name AS EmployeeName,
		ISNULL((SELECT Type
					 FROM M_Schedule 
					 WHERE ID = ISNULL((SELECT TOP 1 s.Schedule FROM AF_ChangeSchedulefiling s
						 WHERE s.EmployeeNo = MEL.EmpNo
						 AND GETDATE() BETWEEN s.DateFrom AND s.DateTo
						 AND s.Status = s.StatusMax
						 ORDER BY s.ID DESC),(SELECT TOP 1 ScheduleID
						 FROM M_Employee_Master_List_Schedule 
						 WHERE EmployeeNo = MEL.EmpNo 
						 AND ScheduleID IS NOT NULL
						 AND EffectivityDate <= GETDATE()
						 ORDER BY ID DESC))),'') AS Schedule,
		(SELECT TOP 1 p.Position FROM M_Employee_Position p WHERE p.EmployNo = MEL.EmpNo ORDER BY ID DESC) AS Position,
		(SELECT TOP 1 s.UpdateDate 
		 FROM M_Employee_Status s
		 WHERE s.EmployNo = MEL.EmpNo
		 AND s.Status = 'ACTIVE'
		 ORDER BY s.UpdateDate DESC) AS DateStillActive,
		 MEL.Date_Resigned,
		 (
			SELECT TOP 1 MEC.CostCenter_AMS
			FROM M_Employee_CostCenter MEC
			WHERE MEC.EmployNo = MEL.EmpNo
			ORDER BY MEC.UpdateDate_AMS DESC
		) AS EmployeeCurrentCostCode,
		 (
			SELECT TOP 1 MEC.CostCenter_AMS
			FROM M_Employee_CostCenter MEC
			WHERE MEC.CostCenter_AMS IN (SELECT Cost_Center
										FROM M_Cost_Center_List
										WHERE GroupSection = @Section
										OR @Section = ''
										OR @Section IS NULL)
			AND MEC.EmployNo = MEL.EmpNo
			ORDER BY MEC.UpdateDate_AMS DESC
		) AS DateStillSectionCostCode,
		(
			SELECT TOP 1 MEC.UpdateDate_AMS
			FROM M_Employee_CostCenter MEC
			WHERE MEC.CostCenter_AMS IN (SELECT Cost_Center
										FROM M_Cost_Center_List
										WHERE GroupSection = @Section
										OR @Section = ''
										OR @Section IS NULL)
			AND MEC.EmployNo = MEL.EmpNo
			ORDER BY MEC.UpdateDate_AMS DESC
		) AS DateStillSection,
		(
			SELECT TOP 1 MEC.UpdateDate_AMS
			FROM M_Employee_CostCenter MEC
			WHERE MEC.CostCenter_AMS NOT IN (SELECT Cost_Center
										FROM M_Cost_Center_List
										WHERE GroupSection = @Section
										OR @Section = ''
										OR @Section IS NULL)
			AND MEC.EmployNo = MEL.EmpNo
			ORDER BY MEC.UpdateDate_AMS ASC
		) AS DateStillOutSection,
		(
			SELECT TOP 1 MEC.CostCenter_AMS
			FROM M_Employee_CostCenter MEC
			WHERE MEC.CostCenter_AMS NOT IN (SELECT Cost_Center
										FROM M_Cost_Center_List
										WHERE GroupSection = @Section
										OR @Section = ''
										OR @Section IS NULL)
			AND MEC.EmployNo = MEL.EmpNo
			ORDER BY MEC.UpdateDate_AMS ASC
		) AS DateStillOutSectionCostCode
INTO #EmpList
FROM M_Employee_Master_List MEL
WHERE MEL.EmpNo IN (
	SELECT EmployNo
	FROM M_Employee_CostCenter
	WHERE CostCenter_AMS IN (SELECT Cost_Center
							FROM M_Cost_Center_List
							WHERE GroupSection = @Section
							OR @Section = ''
							OR @Section IS NULL)
)
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
AND (CAST((CAST(@Year AS VARCHAR(4)) + '-' + CAST(@Month AS VARCHAR(2)) + '-' + CAST(1 AS VARCHAR(2))) AS DATETIME) <= MEL.Date_Resigned OR MEL.Date_Resigned IS NULL)
AND  ((SELECT top 1 MEC.Status FROM M_Employee_Status MEC WHERE MEC.EmployNo = MEL.EmpNo ORDER BY MEC.ID DESC) = 'ACTIVE' OR ((SELECT top 1 MEC.UpdateDate FROM M_Employee_Status MEC WHERE MEC.EmployNo = MEL.EmpNo AND Status = 'ACTIVE' ORDER BY MEC.ID DESC) <= CAST((CAST(@Year AS VARCHAR(4)) + '-' + CAST(@Month AS VARCHAR(2)) + '-' + CAST(@EndofMonthDays AS VARCHAR(2))) AS DATETIME))	AND (SELECT top 1 MEC.UpdateDate FROM M_Employee_Status MEC WHERE MEC.EmployNo = MEL.EmpNo AND Status <> 'ACTIVE' ORDER BY MEC.ID DESC) >= CAST((CAST(@Year AS VARCHAR(4)) + '-' + CAST(@Month AS VARCHAR(2)) + '-' + CAST(1 AS VARCHAR(2))) AS DATETIME))

AND (  MEL.EmpNo LIKE '%'+@Searchvalue+'%' 
	OR MEL.First_Name LIKE '%'+@Searchvalue+'%' 
	OR MEL.Family_Name LIKE '%'+@Searchvalue+'%'
	)
--AND MEL.EmpNo ='BIPH2014-00485'
ORDER BY CASE WHEN MEL.EmpNo LIKE 'BIPH%' THEN 1 ELSE 2 END, MEL.EmpNo			
OFFSET @PageCount * (@RowCount) ROWS
FETCH NEXT @RowCount ROWS ONLY	

--AND MEL.EmpNo = 'BIPH2017-01795'
--########## END INITIAL List #############--


IF OBJECT_ID('tempdb..#TTFilter') IS NOT NULL
		DROP TABLE #TTFilter;

SELECT *
INTO #TTFilter
FROM T_TimeInOut
WHERE YEAR(ISNULL(TimeIn,Timeout)) = @Year
AND MONTH(ISNULL(TimeIn,Timeout)) = @Month
AND EmpNo IN (SELECT a.EmpNo FROM #EmpList a)

IF OBJECT_ID('tempdb..#TimeinOutRecord') IS NOT NULL
		DROP TABLE #TimeinOutRecord;

CREATE TABLE #TimeinOutRecord
(
EmpNo NVARCHAR(50),
RFID NVARCHAR(50),
ScheduleID INT,
TimeIn NVARCHAR(20),
TimeOut NVARCHAR(20),
Daynum INT,
Monthnum INT,
Yearnum INT

)


--########################################################--------Timein and out-----------------##########################################################
IF OBJECT_ID('tempdb..#NightInTime') IS NOT NULL
		DROP TABLE #NightInTime;
DECLARE @Daynum DATETIME;

IF OBJECT_ID('tempdb..#NightIn') IS NOT NULL
		DROP TABLE #NightIn;
IF OBJECT_ID('tempdb..#NightOut') IS NOT NULL
		DROP TABLE #NightOut;

CREATE TABLE #NightIn
(
EmpNo NVARCHAR(50),
RFID NVARCHAR(50),
ScheduleID INT,
TimeIn NVARCHAR(20),
Daynum INT,
Monthnum INT,
Yearnum INT
)

CREATE TABLE #NightOut
(
EmpNo NVARCHAR(50),
RFID NVARCHAR(50),
ScheduleID INT,
TimeOut NVARCHAR(20),
Daynum INT,
Monthnum INT,
Yearnum INT
)

IF OBJECT_ID('tempdb..#DayInTime') IS NOT NULL
		DROP TABLE #DayInTime;


IF OBJECT_ID('tempdb..#DayIn') IS NOT NULL
		DROP TABLE #DayIn;
IF OBJECT_ID('tempdb..#DayOut') IS NOT NULL
		DROP TABLE #DayOut;

CREATE TABLE #DayIn
(
EmpNo NVARCHAR(50),
RFID NVARCHAR(50),
ScheduleID INT,
TimeIn NVARCHAR(20),
Daynum INT,
Monthnum INT,
Yearnum INT
)

CREATE TABLE #DayOut
(
EmpNo NVARCHAR(50),
RFID NVARCHAR(50),
ScheduleID INT,
TimeOut NVARCHAR(20),
Daynum INT,
Monthnum INT,
Yearnum INT
)


DECLARE MY_CURSOR CURSOR 
  LOCAL STATIC READ_ONLY FORWARD_ONLY
FOR 

SELECT DayOfMonth
FROM #DaysMonth
--WHERE DayOfMonth BETWEEN 6 AND 9
OPEN MY_CURSOR
FETCH  FROM MY_CURSOR INTO @Daynum
WHILE @@FETCH_STATUS = 0
BEGIN

;WITH ranked_messages AS (
  SELECT M.*, ROW_NUMBER() OVER (PARTITION BY EmpNo ORDER BY ID ASC) AS rn
 FROM #TTFilter M
 WHERE ISNULL(ISNULL(DTR_TimeIn,DTR_TimeOut),ISNULL(TimeIn,Timeout)) BETWEEN @Daynum AND @Daynum+' 23:59:59'
 AND ISNULL(CS_ScheduleID,ScheduleID) IN (SELECT ID FROM M_Schedule WHERE Type LIKE 'Night%')
 AND convert(char(5), TimeIn, 108) > '12:00:00 PM'
)

INSERT INTO #NightIn(EmpNo,RFID,ScheduleID,TimeIn,Daynum,Monthnum,Yearnum)
SELECT  EmpNo,
		Employee_RFID, 
		ISNULL(CS_ScheduleID,ScheduleID) AS ScheduleID, 
		ISNULL(CONVERT(VARCHAR(5),TimeIn,108),'NoIn') AS TimeIn, 
		DAY(ISNULL(TimeIn,TimeOut)) AS Daynum,
		MONTH(ISNULL(TimeIn,TimeOut)) AS Monthnum,
		YEAR(ISNULL(TimeIn,TimeOut)) AS Yearnum
--INTO #NightInTime
FROM ranked_messages WHERE rn = 1
ORDER BY DAY(ISNULL(TimeIn,TimeOut));



IF OBJECT_ID('tempdb..#DayOutTime') IS NOT NULL
		DROP TABLE #DayOutTime;

;WITH ranked_messages AS (
  SELECT M.*, ROW_NUMBER() OVER (PARTITION BY EmpNo ORDER BY ID ASC) AS rn
 FROM #TTFilter M
 WHERE ISNULL(ISNULL(DTR_TimeIn,DTR_TimeOut),ISNULL(TimeIn,Timeout)) BETWEEN @Daynum AND @Daynum+' 23:59:59'
 AND ISNULL(CS_ScheduleID,ScheduleID) IN (SELECT ID FROM M_Schedule WHERE Type LIKE 'Night%')
 AND convert(char(5), Timeout, 108) < '12:00:00 PM'
)

INSERT INTO #NightOut(EmpNo,RFID,ScheduleID,TimeOut,Daynum,Monthnum,Yearnum)
SELECT  EmpNo,
		Employee_RFID, 
		ISNULL(CS_ScheduleID,ScheduleID) AS ScheduleID, 
		ISNULL(CONVERT(VARCHAR(5),TimeOut,108),'NoOut') AS TimeOut, 
		DAY(ISNULL(TimeIn,TimeOut)) AS Daynum,
		MONTH(ISNULL(TimeIn,TimeOut)) AS Monthnum,
		YEAR(ISNULL(TimeIn,TimeOut)) AS Yearnum
--INTO #DayOutTime
FROM ranked_messages WHERE rn = 1
ORDER BY DAY(ISNULL(TimeIn,TimeOut));








;WITH ranked_messages AS (
  SELECT M.*, ROW_NUMBER() OVER (PARTITION BY EmpNo ORDER BY ID ASC) AS rn
 FROM #TTFilter M
 WHERE ISNULL(ISNULL(DTR_TimeIn,DTR_TimeOut),ISNULL(TimeIn,Timeout)) BETWEEN @Daynum AND @Daynum+' 23:59:59'
 AND ISNULL(CS_ScheduleID,ScheduleID) IN (SELECT ID FROM M_Schedule WHERE Type LIKE 'Day%')
)

INSERT INTO #DayIn(EmpNo,RFID,ScheduleID,TimeIn,Daynum,Monthnum,Yearnum)
SELECT  EmpNo,
		Employee_RFID, 
		ISNULL(CS_ScheduleID,ScheduleID) AS ScheduleID, 
		ISNULL(CONVERT(VARCHAR(5),TimeIn,108),'NoIn') AS TimeIn, 
		DAY(ISNULL(TimeIn,TimeOut)) AS Daynum,
		MONTH(ISNULL(TimeIn,TimeOut)) AS Monthnum,
		YEAR(ISNULL(TimeIn,TimeOut)) AS Yearnum
--INTO #DayInTime
FROM ranked_messages WHERE rn = 1
ORDER BY DAY(ISNULL(TimeIn,TimeOut));



IF OBJECT_ID('tempdb..#DayOutTime') IS NOT NULL
		DROP TABLE #DayOutTime;

;WITH ranked_messages AS (
  SELECT M.*, ROW_NUMBER() OVER (PARTITION BY EmpNo ORDER BY ID ASC) AS rn
 FROM #TTFilter M
 WHERE ISNULL(ISNULL(DTR_TimeIn,DTR_TimeOut),ISNULL(TimeIn,Timeout)) BETWEEN @Daynum AND @Daynum+' 23:59:59'
 AND ISNULL(CS_ScheduleID,ScheduleID) IN (SELECT ID FROM M_Schedule WHERE Type LIKE 'Day%')
)

INSERT INTO #DayOut(EmpNo,RFID,ScheduleID,TimeOut,Daynum,Monthnum,Yearnum)
SELECT  EmpNo,
		Employee_RFID, 
		ISNULL(CS_ScheduleID,ScheduleID) AS ScheduleID, 
		ISNULL(CONVERT(VARCHAR(5),TimeOut,108),'NoOut') AS TimeOut, 
		DAY(ISNULL(TimeIn,TimeOut)) AS Daynum,
		MONTH(ISNULL(TimeIn,TimeOut)) AS Monthnum,
		YEAR(ISNULL(TimeIn,TimeOut)) AS Yearnum
--INTO #DayOutTime
FROM ranked_messages WHERE rn = 1
ORDER BY DAY(ISNULL(TimeIn,TimeOut));











FETCH NEXT FROM MY_CURSOR INTO @Daynum

END
CLOSE MY_CURSOR
DEALLOCATE MY_CURSOR

INSERT INTO #TimeinOutRecord(EmpNo,RFID,ScheduleID,TimeIn,TimeOut,Daynum,Monthnum,Yearnum)
SELECT  a.EmpNo,
		a.RFID,
		a.ScheduleID,
		a.TimeIn,
		b.TimeOut,
		a.Daynum,
		a.Monthnum,
		a.Yearnum
FROM #DayIn a
LEFT JOIN #DayOut b
ON a.EmpNo = b.EmpNo 
AND a.Daynum = b.Daynum
AND a.Monthnum = b.Monthnum
AND a.Yearnum = b.Yearnum
--WHERE a.EmpNo =  'BIPH2017-01795'

INSERT INTO #TimeinOutRecord(EmpNo,RFID,ScheduleID,TimeIn,TimeOut,Daynum,Monthnum,Yearnum)
SELECT  a.EmpNo,
		a.RFID,
		a.ScheduleID,
		a.TimeIn,
		ISNULL(b.TimeOut,'NoOut'),
		a.Daynum,
		a.Monthnum,
		a.Yearnum
FROM #NightIn a
LEFT JOIN #NightOut b
ON a.EmpNo = b.EmpNo 
AND a.Daynum = b.Daynum
AND a.Monthnum = b.Monthnum
AND a.Yearnum = b.Yearnum
--WHERE a.EmpNo =  'BIPH2017-01795'

--########################################################----------------------------##########################################################



--SELECT * FROM #TimeinOutRecord WHERE EmpNo = 'BIPH2014-00485'

--############## START DRAWING #############

DECLARE @SQLf NVARCHAR(MAX);
SET @SQLf ='

IF OBJECT_ID(''tempdb..#EmpListwithDate'') IS NOT NULL
		DROP TABLE #EmpListwithDate
IF OBJECT_ID(''tempdb..#FinishTable'') IS NOT NULL
		DROP TABLE #FinishTable

SELECT  Prio,
		EmpNo,
		EmployeeName,
		Schedule,
		Position,
		DateStillActive,
		Date_Resigned,
		DateStillSectionCostCode,
		DateStillSection,
		DateStillOutSectionCostCode,
		DateStillOutSection,
		EmployeeCurrentCostCode,
		'+(SELECT STUFF( (SELECT ', ' + CAST(DAY(DayOfMonth) AS VARCHAR(2)) + 'AS [' + CAST(DAY(DayOfMonth) AS VARCHAR(2)) + ']'
		   FROM #DaysMonth  
		   FOR XML PATH('')), 1, 2, ''))+'
INTO #EmpListwithDate
FROM #EmpList


SELECT  CASE WHEN ('+CAST(@PageCount AS VARCHAR(10))+') = 0 THEN ROW_NUMBER() OVER(ORDER BY (select 0)) ELSE ROW_NUMBER() OVER(ORDER BY (select 0))+ ('+CAST(@RowCount AS VARCHAR(10))+') * ('+CAST(@PageCount AS VARCHAR(10))+') END AS Rownum,
		EL.EmpNo,
		EL.EmployeeName,
		EL.Schedule,
		EL.Position,
		EL.DateStillActive,
		EL.Date_Resigned,
		EL.DateStillSectionCostCode,
		EL.DateStillSection,
		EL.DateStillOutSectionCostCode,
		EL.DateStillOutSection,
		EL.EmployeeCurrentCostCode AS CostCode,
		'+(SELECT STUFF( (SELECT ', ISNULL((SELECT TOP 1 TimeIn + ''-'' + TimeOut FROM #TimeinOutRecord a WHERE a.EmpNo = EL.EmpNo AND a.Daynum = ' + CAST(DAY(DayOfMonth) AS VARCHAR(2)) + '),''-'') AS [' + CAST(DAY(DayOfMonth) AS VARCHAR(2)) + ']'
		   FROM #DaysMonth  
		   FOR XML PATH('')), 1, 2, ''))+'
FROM #EmpListwithDate EL
ORDER BY Prio,EmpNo

'

--SELECT @SQLf
EXECUTE(@SQLf)
--############# END DRAWING ###################


END





GO
/****** Object:  StoredProcedure [dbo].[GET_RP_AttendanceMonitoring_TimeINOUT_HRFormatV2]    Script Date: 2020-11-27 2:40:56 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[GET_RP_AttendanceMonitoring_TimeINOUT_HRFormatV2]
	--DECLARE 
	@DateFrom DATE = '2020-11-03',
	@DateTo DATE = '2020-11-30',
	@Month INT = 11,
	@Year INT = 2020,
	@Section NVARCHAR(50) = '',
	@Agency NVARCHAR(50) = '',
	@PageCount INT = 0,
	@RowCount INT = 100000,
	@Searchvalue NVARCHAR(50) = ''

AS

--BEGIN

--SELECT  1 AS Prio,
--		1 AS LogPrio,
--		'123' AS EmpNo,
--		'asd' AS Shift,
--		'123' AS LogType,
--		'2020/10/10' AS DateLog,
--		'00:00' AS TimeTap

--END



BEGIN

--FOR DAYS GENERATOR --
SET NOCOUNT ON;
SET FMTONLY OFF
IF OBJECT_ID('tempdb..#DaysMonth') IS NOT NULL
		DROP TABLE #DaysMonth;

	;WITH
	CTE_Days AS
	(
	SELECT DATEADD(month, @Month, DATEADD(month, -MONTH(GETDATE()), DATEADD(day, -DAY(GETDATE()) + 1, CAST(FLOOR(CAST(GETDATE() AS FLOAT)) AS DATETIME)))) D
	UNION ALL
	SELECT DATEADD(day, 1, D)
	FROM CTE_Days
	WHERE D < DATEADD(day, -1, DATEADD(month, 1, DATEADD(month, @Month, DATEADD(month, -MONTH(GETDATE()), DATEADD(day, -DAY(GETDATE()) + 1, CAST(FLOOR(CAST(GETDATE() AS FLOAT)) AS DATETIME))))))
	)

	SELECT D AS DayOfMonth
	INTO #DaysMonth
	FROM CTE_Days




--########## GET INITIAL List #############--
DECLARE @EndofMonthDays INT
	SET @EndofMonthDays = (SELECT TOP 1 Day(DayOfMonth) FROM #DaysMonth ORDER BY DayOfMonth DESC)
IF OBJECT_ID('tempdb..#EmpList') IS NOT NULL
		DROP TABLE #EmpList;
SELECT  CASE WHEN MEL.EmpNo LIKE 'BIPH%' THEN 1 ELSE 2 END AS Prio,
		MEL.EmpNo,
		MEL.Family_Name +', ' + MEL.First_Name AS EmployeeName,
		ISNULL((SELECT Type
					 FROM M_Schedule 
					 WHERE ID = ISNULL((SELECT TOP 1 s.Schedule FROM AF_ChangeSchedulefiling s
						 WHERE s.EmployeeNo = MEL.EmpNo
						 AND GETDATE() BETWEEN s.DateFrom AND s.DateTo
						 AND s.Status = s.StatusMax
						 ORDER BY s.ID DESC),(SELECT TOP 1 ScheduleID
						 FROM M_Employee_Master_List_Schedule 
						 WHERE EmployeeNo = MEL.EmpNo 
						 AND ScheduleID IS NOT NULL
						 AND EffectivityDate <= GETDATE()
						 ORDER BY ID DESC))),'') AS Schedule,
		(SELECT TOP 1 p.Position FROM M_Employee_Position p WHERE p.EmployNo = MEL.EmpNo ORDER BY ID DESC) AS Position,
		(SELECT TOP 1 s.UpdateDate 
		 FROM M_Employee_Status s
		 WHERE s.EmployNo = MEL.EmpNo
		 AND s.Status = 'ACTIVE'
		 ORDER BY s.UpdateDate DESC) AS DateStillActive,
		 MEL.Date_Resigned,
		 (
			SELECT TOP 1 MEC.CostCenter_AMS
			FROM M_Employee_CostCenter MEC
			WHERE MEC.EmployNo = MEL.EmpNo
			ORDER BY MEC.UpdateDate_AMS DESC
		) AS EmployeeCurrentCostCode,
		 (
			SELECT TOP 1 MEC.CostCenter_AMS
			FROM M_Employee_CostCenter MEC
			WHERE MEC.CostCenter_AMS IN (SELECT Cost_Center
										FROM M_Cost_Center_List
										WHERE GroupSection = @Section
										OR @Section = ''
										OR @Section IS NULL)
			AND MEC.EmployNo = MEL.EmpNo
			ORDER BY MEC.UpdateDate_AMS DESC
		) AS DateStillSectionCostCode,
		(
			SELECT TOP 1 MEC.UpdateDate_AMS
			FROM M_Employee_CostCenter MEC
			WHERE MEC.CostCenter_AMS IN (SELECT Cost_Center
										FROM M_Cost_Center_List
										WHERE GroupSection = @Section
										OR @Section = ''
										OR @Section IS NULL)
			AND MEC.EmployNo = MEL.EmpNo
			ORDER BY MEC.UpdateDate_AMS DESC
		) AS DateStillSection,
		(
			SELECT TOP 1 MEC.UpdateDate_AMS
			FROM M_Employee_CostCenter MEC
			WHERE MEC.CostCenter_AMS NOT IN (SELECT Cost_Center
										FROM M_Cost_Center_List
										WHERE GroupSection = @Section
										OR @Section = ''
										OR @Section IS NULL)
			AND MEC.EmployNo = MEL.EmpNo
			ORDER BY MEC.UpdateDate_AMS ASC
		) AS DateStillOutSection,
		(
			SELECT TOP 1 MEC.CostCenter_AMS
			FROM M_Employee_CostCenter MEC
			WHERE MEC.CostCenter_AMS NOT IN (SELECT Cost_Center
										FROM M_Cost_Center_List
										WHERE GroupSection = @Section
										OR @Section = ''
										OR @Section IS NULL)
			AND MEC.EmployNo = MEL.EmpNo
			ORDER BY MEC.UpdateDate_AMS ASC
		) AS DateStillOutSectionCostCode
INTO #EmpList
FROM M_Employee_Master_List MEL
WHERE MEL.EmpNo IN (
	SELECT EmployNo
	FROM M_Employee_CostCenter
	WHERE CostCenter_AMS IN (SELECT Cost_Center
							FROM M_Cost_Center_List
							WHERE GroupSection = @Section
							OR @Section = ''
							OR @Section IS NULL)
)
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
AND (CAST((CAST(@Year AS VARCHAR(4)) + '-' + CAST(@Month AS VARCHAR(2)) + '-' + CAST(1 AS VARCHAR(2))) AS DATETIME) <= MEL.Date_Resigned OR MEL.Date_Resigned IS NULL)
AND  ((SELECT top 1 MEC.Status FROM M_Employee_Status MEC WHERE MEC.EmployNo = MEL.EmpNo ORDER BY MEC.ID DESC) = 'ACTIVE' OR ((SELECT top 1 MEC.UpdateDate FROM M_Employee_Status MEC WHERE MEC.EmployNo = MEL.EmpNo AND Status = 'ACTIVE' ORDER BY MEC.ID DESC) <= CAST((CAST(@Year AS VARCHAR(4)) + '-' + CAST(@Month AS VARCHAR(2)) + '-' + CAST(@EndofMonthDays AS VARCHAR(2))) AS DATETIME))	AND (SELECT top 1 MEC.UpdateDate FROM M_Employee_Status MEC WHERE MEC.EmployNo = MEL.EmpNo AND Status <> 'ACTIVE' ORDER BY MEC.ID DESC) >= CAST((CAST(@Year AS VARCHAR(4)) + '-' + CAST(@Month AS VARCHAR(2)) + '-' + CAST(1 AS VARCHAR(2))) AS DATETIME))

AND (  MEL.EmpNo LIKE '%'+@Searchvalue+'%' 
	OR MEL.First_Name LIKE '%'+@Searchvalue+'%' 
	OR MEL.Family_Name LIKE '%'+@Searchvalue+'%'
	)
ORDER BY CASE WHEN MEL.EmpNo LIKE 'BIPH%' THEN 1 ELSE 2 END, MEL.EmpNo			
OFFSET @PageCount * (@RowCount) ROWS
FETCH NEXT @RowCount ROWS ONLY	

--AND MEL.EmpNo = 'BIPH2017-01795'
--########## END INITIAL List #############--


IF OBJECT_ID('tempdb..#TTFilter') IS NOT NULL
		DROP TABLE #TTFilter;

SELECT *
INTO #TTFilter
FROM T_TimeInOut
WHERE YEAR(ISNULL(TimeIn,Timeout)) = @Year
AND MONTH(ISNULL(TimeIn,Timeout)) = @Month
AND EmpNo IN (SELECT a.EmpNo FROM #EmpList a)

IF OBJECT_ID('tempdb..#TimeinOutRecord') IS NOT NULL
		DROP TABLE #TimeinOutRecord;

CREATE TABLE #TimeinOutRecord
(
EmpNo NVARCHAR(50),
RFID NVARCHAR(50),
ScheduleID INT,
TimeIn NVARCHAR(20),
TimeOut NVARCHAR(20),
Daynum INT,
Monthnum INT,
Yearnum INT

)


--########################################################--------Timein and out-----------------##########################################################
IF OBJECT_ID('tempdb..#NightInTime') IS NOT NULL
		DROP TABLE #NightInTime;
DECLARE @Daynum DATETIME;

IF OBJECT_ID('tempdb..#NightIn') IS NOT NULL
		DROP TABLE #NightIn;
IF OBJECT_ID('tempdb..#NightOut') IS NOT NULL
		DROP TABLE #NightOut;

CREATE TABLE #NightIn
(
EmpNo NVARCHAR(50),
RFID NVARCHAR(50),
ScheduleID INT,
TimeIn NVARCHAR(20),
Daynum INT,
Monthnum INT,
Yearnum INT
)

CREATE TABLE #NightOut
(
EmpNo NVARCHAR(50),
RFID NVARCHAR(50),
ScheduleID INT,
TimeOut NVARCHAR(20),
Daynum INT,
Monthnum INT,
Yearnum INT
)

IF OBJECT_ID('tempdb..#DayInTime') IS NOT NULL
		DROP TABLE #DayInTime;


IF OBJECT_ID('tempdb..#DayIn') IS NOT NULL
		DROP TABLE #DayIn;
IF OBJECT_ID('tempdb..#DayOut') IS NOT NULL
		DROP TABLE #DayOut;

CREATE TABLE #DayIn
(
EmpNo NVARCHAR(50),
RFID NVARCHAR(50),
ScheduleID INT,
TimeIn NVARCHAR(20),
Daynum INT,
Monthnum INT,
Yearnum INT
)

CREATE TABLE #DayOut
(
EmpNo NVARCHAR(50),
RFID NVARCHAR(50),
ScheduleID INT,
TimeOut NVARCHAR(20),
Daynum INT,
Monthnum INT,
Yearnum INT
)


DECLARE MY_CURSOR CURSOR 
  LOCAL STATIC READ_ONLY FORWARD_ONLY
FOR 

SELECT DayOfMonth
FROM #DaysMonth
OPEN MY_CURSOR
FETCH  FROM MY_CURSOR INTO @Daynum
WHILE @@FETCH_STATUS = 0
BEGIN

;WITH ranked_messages AS (
  SELECT M.*, ROW_NUMBER() OVER (PARTITION BY EmpNo ORDER BY ID ASC) AS rn
 FROM #TTFilter M
 WHERE ISNULL(ISNULL(DTR_TimeIn,DTR_TimeOut),ISNULL(TimeIn,Timeout)) BETWEEN @Daynum AND @Daynum+' 23:59:59'
 AND ISNULL(CS_ScheduleID,ScheduleID) IN (SELECT ID FROM M_Schedule WHERE Type LIKE 'Night%')
 AND convert(char(5), TimeIn, 108) > '12:00:00 PM'
)

INSERT INTO #NightIn(EmpNo,RFID,ScheduleID,TimeIn,Daynum,Monthnum,Yearnum)
SELECT  EmpNo,
		Employee_RFID, 
		ISNULL(CS_ScheduleID,ScheduleID) AS ScheduleID, 
		ISNULL(CONVERT(VARCHAR(5),TimeIn,108),'NoIn') AS TimeIn, 
		DAY(ISNULL(TimeIn,TimeOut)) AS Daynum,
		MONTH(ISNULL(TimeIn,TimeOut)) AS Monthnum,
		YEAR(ISNULL(TimeIn,TimeOut)) AS Yearnum
FROM ranked_messages WHERE rn = 1
ORDER BY DAY(ISNULL(TimeIn,TimeOut));



IF OBJECT_ID('tempdb..#DayOutTime') IS NOT NULL
		DROP TABLE #DayOutTime;

;WITH ranked_messages AS (
  SELECT M.*, ROW_NUMBER() OVER (PARTITION BY EmpNo ORDER BY ID ASC) AS rn
 FROM #TTFilter M
 WHERE ISNULL(ISNULL(DTR_TimeIn,DTR_TimeOut),ISNULL(TimeIn,Timeout)) BETWEEN @Daynum AND @Daynum+' 23:59:59'
 AND ISNULL(CS_ScheduleID,ScheduleID) IN (SELECT ID FROM M_Schedule WHERE Type LIKE 'Night%')
 AND convert(char(5), Timeout, 108) < '12:00:00 PM'
)

INSERT INTO #NightOut(EmpNo,RFID,ScheduleID,TimeOut,Daynum,Monthnum,Yearnum)
SELECT  EmpNo,
		Employee_RFID, 
		ISNULL(CS_ScheduleID,ScheduleID) AS ScheduleID, 
		ISNULL(CONVERT(VARCHAR(5),TimeOut,108),'NoOut') AS TimeOut, 
		DAY(ISNULL(TimeIn,TimeOut)) AS Daynum,
		MONTH(ISNULL(TimeIn,TimeOut)) AS Monthnum,
		YEAR(ISNULL(TimeIn,TimeOut)) AS Yearnum
FROM ranked_messages WHERE rn = 1
ORDER BY DAY(ISNULL(TimeIn,TimeOut));








;WITH ranked_messages AS (
  SELECT M.*, ROW_NUMBER() OVER (PARTITION BY EmpNo ORDER BY ID ASC) AS rn
 FROM #TTFilter M
 WHERE ISNULL(ISNULL(DTR_TimeIn,DTR_TimeOut),ISNULL(TimeIn,Timeout)) BETWEEN @Daynum AND @Daynum+' 23:59:59'
 AND ISNULL(CS_ScheduleID,ScheduleID) IN (SELECT ID FROM M_Schedule WHERE Type LIKE 'Day%')
)

INSERT INTO #DayIn(EmpNo,RFID,ScheduleID,TimeIn,Daynum,Monthnum,Yearnum)
SELECT  EmpNo,
		Employee_RFID, 
		ISNULL(CS_ScheduleID,ScheduleID) AS ScheduleID, 
		ISNULL(CONVERT(VARCHAR(5),TimeIn,108),'NoIn') AS TimeIn, 
		DAY(ISNULL(TimeIn,TimeOut)) AS Daynum,
		MONTH(ISNULL(TimeIn,TimeOut)) AS Monthnum,
		YEAR(ISNULL(TimeIn,TimeOut)) AS Yearnum
FROM ranked_messages WHERE rn = 1
ORDER BY DAY(ISNULL(TimeIn,TimeOut));



IF OBJECT_ID('tempdb..#DayOutTime') IS NOT NULL
		DROP TABLE #DayOutTime;

;WITH ranked_messages AS (
  SELECT M.*, ROW_NUMBER() OVER (PARTITION BY EmpNo ORDER BY ID ASC) AS rn
 FROM #TTFilter M
 WHERE ISNULL(ISNULL(DTR_TimeIn,DTR_TimeOut),ISNULL(TimeIn,Timeout)) BETWEEN @Daynum AND @Daynum+' 23:59:59'
 AND ISNULL(CS_ScheduleID,ScheduleID) IN (SELECT ID FROM M_Schedule WHERE Type LIKE 'Day%')
)

INSERT INTO #DayOut(EmpNo,RFID,ScheduleID,TimeOut,Daynum,Monthnum,Yearnum)
SELECT  EmpNo,
		Employee_RFID, 
		ISNULL(CS_ScheduleID,ScheduleID) AS ScheduleID, 
		ISNULL(CONVERT(VARCHAR(5),TimeOut,108),'NoOut') AS TimeOut, 
		DAY(ISNULL(TimeIn,TimeOut)) AS Daynum,
		MONTH(ISNULL(TimeIn,TimeOut)) AS Monthnum,
		YEAR(ISNULL(TimeIn,TimeOut)) AS Yearnum
FROM ranked_messages WHERE rn = 1
ORDER BY DAY(ISNULL(TimeIn,TimeOut));











FETCH NEXT FROM MY_CURSOR INTO @Daynum

END
CLOSE MY_CURSOR
DEALLOCATE MY_CURSOR

INSERT INTO #TimeinOutRecord(EmpNo,RFID,ScheduleID,TimeIn,TimeOut,Daynum,Monthnum,Yearnum)
SELECT  a.EmpNo,
		a.RFID,
		a.ScheduleID,
		a.TimeIn,
		b.TimeOut,
		a.Daynum,
		a.Monthnum,
		a.Yearnum
FROM #DayIn a
LEFT JOIN #DayOut b
ON a.EmpNo = b.EmpNo 
AND a.Daynum = b.Daynum
AND a.Monthnum = b.Monthnum
AND a.Yearnum = b.Yearnum


INSERT INTO #TimeinOutRecord(EmpNo,RFID,ScheduleID,TimeIn,TimeOut,Daynum,Monthnum,Yearnum)
SELECT  a.EmpNo,
		a.RFID,
		a.ScheduleID,
		a.TimeIn,
		b.TimeOut,
		a.Daynum,
		a.Monthnum,
		a.Yearnum
FROM #NightIn a
LEFT JOIN #NightOut b
ON a.EmpNo = b.EmpNo 
AND a.Daynum = b.Daynum
AND a.Monthnum = b.Monthnum
AND a.Yearnum = b.Yearnum


IF OBJECT_ID('tempdb..#FinalLogs') IS NOT NULL
		DROP TABLE #FinalLogs;

CREATE TABLE #FinalLogs(
EmpNo NVARCHAR(50),
ScheduleID BIGINT,
LogType NVARCHAR(10),
TimeTap NVARCHAR(10),
Date DATE
)



IF OBJECT_ID('tempdb..#DayLogs') IS NOT NULL
		DROP TABLE #DayLogs;

SELECT * INTO #DayLogs FROM (
SELECT *,'i' AS LogType
FROM #DayIn
UNION 
SELECT *,'o' AS LogType
FROM #DayOut
) as tmp

INSERT INTO #FinalLogs(EmpNo,Date,LogType,TimeTap,ScheduleID)
SELECT  EmpNo,
		CAST((CAST(Monthnum AS VARCHAR(2)) +'/' +CAST(Daynum AS VARCHAR(2)) + '/' + CAST(Yearnum AS VARCHAR(4))) AS DATE),
		LogType,
		TimeIn,
		ScheduleID
FROM #DayLogs

IF OBJECT_ID('tempdb..#NightLogs') IS NOT NULL
		DROP TABLE #NightLogs;

SELECT * INTO #NightLogs FROM (
SELECT *,'i' AS LogType
FROM #NightIn
UNION 
SELECT *,'o' AS LogType
FROM #NightOut
) as tmp


INSERT INTO #FinalLogs(EmpNo,Date,LogType,TimeTap,ScheduleID)
SELECT  EmpNo,
		CAST((CAST(Monthnum AS VARCHAR(2)) +'/' +CAST(Daynum AS VARCHAR(2)) + '/' + CAST(Yearnum AS VARCHAR(4))) AS DATE),
		LogType,
		TimeIn,
		ScheduleID
FROM #NightLogs




SELECT  CASE WHEN EmpNo LIKE 'BIPH%' THEN 1 ELSE 2 END AS Prio,
		CASE WHEN LogType = 'i' THEN 1 ELSE 2 END AS LogPrio,
		EmpNo,
		(SELECT TOP 1 s.Type + ' (' + s.TimeIn + ' - ' + s.TimeOut +')' FROM M_Schedule s WHERE s.ID = ScheduleID) AS Shift,
		LogType,
		CAST(CONVERT(VARCHAR(10), Date, 101) AS VARCHAR(10)) AS DateLog,
		TimeTap
FROM #FinalLogs
--WHERE (@Shift = '' OR (SELECT TOP 1 s.Type + ' (' + s.TimeIn + ' - ' + s.TimeOut +')' FROM M_Schedule s WHERE s.ID = ScheduleID) LIKE @Shift+'%')
WHERE Date BETWEEN @DateFrom AND @DateTo
ORDER BY CASE WHEN EmpNo LIKE 'BIPH%' THEN 1 ELSE 2 END,
		 EmpNo, 
		 Date,
		 CASE WHEN LogType = 'i' THEN 1 ELSE 2 END


--########################################################----------------------------##########################################################


END





GO
/****** Object:  StoredProcedure [dbo].[GET_RP_MPCMonitoringv2ALLShift]    Script Date: 2020-11-27 2:40:56 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[GET_RP_MPCMonitoringv2ALLShift]
	--DECLARE
	@DateFrom DATETIME = '11/21/2020',
	@DateTo DATETIME = '11/21/2020',
	@Shift NVARCHAR(20) = 'Day',
	@Line BIGINT = '0',
	@Process BIGINT = '0',
	@SectionGroup NVARCHAR(50) = 'Incoming Quality Control',
	@PageCount INT = 0,
	@RowCount INT = 800,
	@Searchvalue NVARCHAR(50) = '',
	@Certified NVARCHAR(50) = '',
	@TotalCount INT OUT
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
		IF OBJECT_ID('tempdb..#FinalTable') IS NOT NULL
		DROP TABLE #FinalTable;

IF OBJECT_ID('tempdb..#ShiftGroup') IS NOT NULL
		DROP TABLE #ShiftGroup;

SELECT ID
INTO #ShiftGroup
FROM M_Schedule MS
WHERE MS.Type LIKE @Shift+'%'

SET @DateTo = @DateTo + ' 23:59:59'


CREATE TABLE #tmpBus(
	RFID NVARCHAR(MAX),
	TimeIn DATETIME,
	TimeOut DATETIME,
	ScheduleID INT,
	ChangeShift NVARCHAR(20),
	OrigShift INT,
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

INSERT INTO #tmpBus(RFID,TimeIn,TimeOut,ScheduleID,ChangeShift,OrigShift,LineID,ProcessID,EmpNo,EmployeeName,Date_Hired,Status,CostCenter_AMS)
	SELECT	  TT.Employee_RFID AS RFID
		, CASE WHEN (TT.DTR_RefNo IS NOT NULL) THEN TT.DTR_TimeIn ELSE TT.TimeIn END AS TimeIn
		, CASE WHEN (TT.DTR_RefNo IS NOT NULL) THEN TT.DTR_TimeOut ELSE TT.TimeOut END AS TimeOut
		, CASE WHEN (TT.CSRef_No IS NULL) THEN TT.ScheduleID ELSE TT.CS_ScheduleID END AS ScheduleID
		, CASE WHEN ((TT.ScheduleID = TT.CS_ScheduleID AND TT.CSRef_No IS NOT NULL) OR TT.CSRef_No IS NULL) THEN 'Black' ELSE 'Green' END AS ChangeShift
		, TT.ScheduleID AS OrigShift
		, TT.LineID
		, TT.ProcessID
		, MEL.EmpNo
		, MEL.Family_Name + ' ' + MEL.First_Name AS EmployeeName
		, MEL.Date_Hired
		, p.Status
		,(SELECT TOP 1 CostCenter_AMS FROM M_Employee_CostCenter WHERE EmployNo = MEL.EmpNo AND UpdateDate_AMS <= ISNULL(TT.TimeIn,TT.TimeOut) ORDER BY UpdateDate_AMS DESC) AS CostCenter_AMS
FROM T_TimeInOut TT
JOIN M_Employee_Master_List MEL
ON TT.EmpNo = MEL.EmpNo
INNER JOIN (SELECT RANK() OVER (PARTITION BY EmployNo ORDER BY ID DESC) r, *
             FROM M_Employee_Status) p
ON (TT.EmpNo = p.EmployNo)

WHERE p.r = 1
AND convert(char(5), TT.TimeIn, 108) > '12:00:00 PM'
AND (ISNULL(TimeIn,TimeOut) <= MEL.Date_Resigned OR MEL.Date_Resigned IS NULL)
AND ISNULL(TimeIn,TimeOut) BETWEEN @DateFrom AND @DateTo
AND  ((SELECT top 1 MEC.Status FROM M_Employee_Status MEC WHERE MEC.EmployNo = MEL.EmpNo ORDER BY MEC.ID DESC) = 'ACTIVE' OR ((SELECT top 1 MEC.UpdateDate FROM M_Employee_Status MEC WHERE MEC.EmployNo = MEL.EmpNo AND Status = 'ACTIVE' ORDER BY MEC.ID DESC) <= ISNULL(TimeIn,TimeOut))	AND (SELECT top 1 MEC.UpdateDate FROM M_Employee_Status MEC WHERE MEC.EmployNo = MEL.EmpNo AND Status <> 'ACTIVE' ORDER BY MEC.ID DESC) >= ISNULL(TimeIn,TimeOut))
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
		, p.Status


END


ELSE
BEGIN
INSERT INTO #tmpBus(RFID,TimeIn,TimeOut,ScheduleID,ChangeShift,OrigShift,LineID,ProcessID,EmpNo,EmployeeName,Date_Hired,Status,CostCenter_AMS)
	SELECT	  TT.Employee_RFID AS RFID
		, CASE WHEN (TT.DTR_RefNo IS NOT NULL) THEN TT.DTR_TimeIn ELSE TT.TimeIn END AS TimeIn
		, CASE WHEN (TT.DTR_RefNo IS NOT NULL) THEN TT.DTR_TimeOut ELSE TT.TimeOut END AS TimeOut
		, CASE WHEN (TT.CSRef_No IS NULL) THEN TT.ScheduleID ELSE TT.CS_ScheduleID END AS ScheduleID
		, CASE WHEN (TT.CSRef_No IS NULL) THEN 'Black' ELSE 'Green' END AS ChangeShift
		, TT.ScheduleID AS OrigShift
		, TT.LineID
		, TT.ProcessID
		, MEL.EmpNo
		, MEL.Family_Name + ' ' + MEL.First_Name AS EmployeeName
		, MEL.Date_Hired
		, p.Status
		,(SELECT TOP 1 CostCenter_AMS FROM M_Employee_CostCenter WHERE EmployNo = MEL.EmpNo AND UpdateDate_AMS <= ISNULL(TT.TimeIn,TT.TimeOut) ORDER BY UpdateDate_AMS DESC) AS CostCenter_AMS
FROM T_TimeInOut TT
JOIN M_Employee_Master_List MEL
ON TT.EmpNo = MEL.EmpNo
INNER JOIN (SELECT RANK() OVER (PARTITION BY EmployNo ORDER BY ID DESC) r, *
             FROM M_Employee_Status) p
ON (TT.EmpNo = p.EmployNo)

WHERE p.r = 1
AND ISNULL(TimeIn,TimeOut) BETWEEN @DateFrom AND @DateTo
AND  ((SELECT top 1 MEC.Status FROM M_Employee_Status MEC WHERE MEC.EmployNo = MEL.EmpNo ORDER BY MEC.ID DESC) = 'ACTIVE' OR ((SELECT top 1 MEC.UpdateDate FROM M_Employee_Status MEC WHERE MEC.EmployNo = MEL.EmpNo AND Status = 'ACTIVE' ORDER BY MEC.ID DESC) <= ISNULL(TimeIn,TimeOut))	AND (SELECT top 1 MEC.UpdateDate FROM M_Employee_Status MEC WHERE MEC.EmployNo = MEL.EmpNo AND Status <> 'ACTIVE' ORDER BY MEC.ID DESC) >= ISNULL(TimeIn,TimeOut))
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
		, p.Status




END

SELECT CAST(CONVERT(Char(16), ISNULL(TB.TimeIn,TB.TimeOut) ,20) AS Date) AS InDate,
		ISNULL(CONVERT(VARCHAR(5),TB.TimeIn,108),'NoIn') AS TimeIn,
		CAST(CONVERT(Char(16), ISNULL(TB.TimeOut,TB.TimeOut) ,20) AS Date) AS InDateOut,
		ISNULL(CONVERT(VARCHAR(5),TB.TimeOut,108),'NoOut') AS TimeOut,
		ISNULL(MSS.Type + ' ('+ MSS.Timein + '-' + MSS.TimeOut +  ')','') AS Shift,
		TB.ChangeShift,
		ISNULL((SELECT TOP 1 aa.Type + ' (' + aa.TimeIn + ' - ' + aa.TimeOut +')'
				FROM M_Schedule aa
				WHERE ID = TB.OrigShift),'') AS OrigShift,
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
WHERE TB.ScheduleID IN (SELECT ID FROM #ShiftGroup)
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
--WHERE EmployeeName = 'Jovelyn Caraan'
--ORDER BY TTID





SELECT CASE WHEN EmpNo LIKE 'BIPH%' THEN 1 ELSE 2 END AS Prio,
	   *
INTO #FinalTable
FROM #OutputTable
WHERE (
				@Certified IS NULL OR
				@Certified = '' OR
				TrueColor = CASE WHEN @Certified = 'Certified'
								 THEN 'Green'
								 ELSE 'Red'
							END
				OR
				TrueColor = CASE WHEN @Certified = 'Certified'
								 THEN 'Black'
								 ELSE 'Red'
							END
				
		)
ORDER BY CASE WHEN EmpNo LIKE 'BIPH%' THEN 1 ELSE 2 END, EmpNo			
OFFSET @PageCount * (@RowCount) ROWS
FETCH NEXT @RowCount ROWS ONLY	

IF OBJECT_ID('tempdb..#TABLEFinal') IS NOT NULL
		DROP TABLE #TABLEFinal;

SELECT Prio,
		CASE WHEN TimeIn = 'NoIn' THEN '-' ELSE convert(varchar, InDate, 23) END AS InDate,
		TimeIn,
		CASE WHEN  convert(varchar, InDateOut, 23) = '1900-01-01' THEN '-' ELSE ISNULL(convert(varchar, InDateOut, 23),'-') END AS InDateOut,
		CASE WHEN  convert(varchar, InDateOut, 23) = '1900-01-01' THEN 'NoOut' ELSE TimeOut END AS TimeOut,
		Shift,
		ChangeShift,
		OrigShift,
		Line,
		Skill,
		EmpNo,
		EmployeeName,
		convert(varchar, Date_Hired, 23) AS Date_Hired,
		convert(varchar, DateCertified, 23) AS DateCertified,
		Status,
		--TTID,
		Certified,
		CountTransfer,
		TrueColor
INTO #TABLEFinal
FROM #FinalTable
ORDER BY Prio, EmpNo, ISNULL(InDate,InDateOut) ASC, TimeIn DESC, TimeOut DESC

SELECT CASE WHEN (@PageCount) = 0 THEN ROW_NUMBER() OVER(ORDER BY Prio, EmpNo, CASE WHEN(InDate = '-') THEN InDateOut ELSE InDate END ASC, TimeIn DESC, TimeOut DESC) ELSE ROW_NUMBER() OVER(ORDER BY (select 0))+ (@RowCount) * (@PageCount) END AS Rownum,
		*
FROM #TABLEFinal


SET @TotalCount = (

SELECT COUNT(*) FROM #tmpBus

)


END





















GO
/****** Object:  StoredProcedure [dbo].[GET_RP_WrongShiftV2]    Script Date: 2020-11-27 2:40:56 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[GET_RP_WrongShiftV2]
	--DECLARE 
	@DateFrom DATE = '2020-11-01',
	@DateTo DATE = '2020-11-30',
	@Month INT = 11,
	@Year INT = 2020,
	@Section NVARCHAR(50) = 'Ink Cartridge',
	@Agency NVARCHAR(50) = '',
	@PageCount INT = 0,
	@RowCount INT = 100000,
	@Searchvalue NVARCHAR(50) = '',
	@Shift NVARCHAR(20) = ''

AS

--BEGIN

--SELECT  
--		'123' AS EmpNo,
--		'123' AS EmployeeName,
--		'asd' AS Shift,
--		'123' AS LogType,
--		'2020/10/10' AS Date,
--		'00:00' AS TimeTap,
--		'00:00' AS Section

--END



BEGIN

--FOR DAYS GENERATOR --
SET NOCOUNT ON;
SET FMTONLY OFF
IF OBJECT_ID('tempdb..#DaysMonth') IS NOT NULL
		DROP TABLE #DaysMonth;

	;WITH
	CTE_Days AS
	(
	SELECT DATEADD(month, @Month, DATEADD(month, -MONTH(GETDATE()), DATEADD(day, -DAY(GETDATE()) + 1, CAST(FLOOR(CAST(GETDATE() AS FLOAT)) AS DATETIME)))) D
	UNION ALL
	SELECT DATEADD(day, 1, D)
	FROM CTE_Days
	WHERE D < DATEADD(day, -1, DATEADD(month, 1, DATEADD(month, @Month, DATEADD(month, -MONTH(GETDATE()), DATEADD(day, -DAY(GETDATE()) + 1, CAST(FLOOR(CAST(GETDATE() AS FLOAT)) AS DATETIME))))))
	)

	SELECT D AS DayOfMonth
	INTO #DaysMonth
	FROM CTE_Days




--########## GET INITIAL List #############--
DECLARE @EndofMonthDays INT
	SET @EndofMonthDays = (SELECT TOP 1 Day(DayOfMonth) FROM #DaysMonth ORDER BY DayOfMonth DESC)
IF OBJECT_ID('tempdb..#EmpList') IS NOT NULL
		DROP TABLE #EmpList;
SELECT  CASE WHEN MEL.EmpNo LIKE 'BIPH%' THEN 1 ELSE 2 END AS Prio,
		MEL.EmpNo,
		MEL.Family_Name +', ' + MEL.First_Name AS EmployeeName
		
		
		
INTO #EmpList
FROM M_Employee_Master_List MEL
--WHERE MEL.EmpNo IN (
--	SELECT EmployNo
--	FROM M_Employee_CostCenter
--	WHERE CostCenter_AMS IN (SELECT Cost_Center
--							FROM M_Cost_Center_List
--							WHERE GroupSection = @Section
--							OR @Section = ''
--							OR @Section IS NULL)
--)
WHERE (
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

AND  ((SELECT top 1 MEC.Status FROM M_Employee_Status MEC WHERE MEC.EmployNo = MEL.EmpNo ORDER BY MEC.ID DESC) = 'ACTIVE' OR ((SELECT top 1 MEC.UpdateDate FROM M_Employee_Status MEC WHERE MEC.EmployNo = MEL.EmpNo AND Status = 'ACTIVE' ORDER BY MEC.ID DESC) <= CAST((CAST(@Year AS VARCHAR(4)) + '-' + CAST(@Month AS VARCHAR(2)) + '-' + CAST(@EndofMonthDays AS VARCHAR(2))) AS DATETIME))	AND (SELECT top 1 MEC.UpdateDate FROM M_Employee_Status MEC WHERE MEC.EmployNo = MEL.EmpNo AND Status <> 'ACTIVE' ORDER BY MEC.ID DESC) >= CAST((CAST(@Year AS VARCHAR(4)) + '-' + CAST(@Month AS VARCHAR(2)) + '-' + CAST(1 AS VARCHAR(2))) AS DATETIME))
AND (SELECT TOP 1 MEC.CostCenter_AMS FROM M_Employee_CostCenter MEC WHERE MEC.EmployNo = MEL.EmpNo AND MEC.UpdateDate_AMS <= CAST((CAST(@Year AS VARCHAR(4)) + '-' + CAST(@Month AS VARCHAR(2)) + '-' + CAST(@EndofMonthDays AS VARCHAR(2))) AS DATETIME) ORDER BY UpdateDate_AMS DESC) IN (SELECT Cost_Center
																																													 FROM M_Cost_Center_List
																																													 WHERE GroupSection = @Section
																																													 OR @Section= ''
																																													 OR @Section IS NULL)
AND (  MEL.EmpNo LIKE '%'+@Searchvalue+'%' 
	OR MEL.First_Name LIKE '%'+@Searchvalue+'%' 
	OR MEL.Family_Name LIKE '%'+@Searchvalue+'%'
	)
ORDER BY CASE WHEN MEL.EmpNo LIKE 'BIPH%' THEN 1 ELSE 2 END, MEL.EmpNo			
OFFSET @PageCount * (@RowCount) ROWS
FETCH NEXT @RowCount ROWS ONLY	

--AND MEL.EmpNo = 'BIPH2017-01795'
--########## END INITIAL List #############--


IF OBJECT_ID('tempdb..#TTFilter') IS NOT NULL
		DROP TABLE #TTFilter;

SELECT *
INTO #TTFilter
FROM T_TimeInOut
WHERE YEAR(ISNULL(TimeIn,Timeout)) = @Year
AND MONTH(ISNULL(TimeIn,Timeout)) = @Month
AND EmpNo IN (SELECT a.EmpNo FROM #EmpList a)

IF OBJECT_ID('tempdb..#TimeinOutRecord') IS NOT NULL
		DROP TABLE #TimeinOutRecord;

CREATE TABLE #TimeinOutRecord
(
EmpNo NVARCHAR(50),
RFID NVARCHAR(50),
ScheduleID INT,
TimeIn NVARCHAR(20),
TimeOut NVARCHAR(20),
Daynum INT,
Monthnum INT,
Yearnum INT

)


--########################################################--------Timein and out-----------------##########################################################
IF OBJECT_ID('tempdb..#NightInTime') IS NOT NULL
		DROP TABLE #NightInTime;
DECLARE @Daynum DATETIME;

IF OBJECT_ID('tempdb..#NightIn') IS NOT NULL
		DROP TABLE #NightIn;
IF OBJECT_ID('tempdb..#NightOut') IS NOT NULL
		DROP TABLE #NightOut;

CREATE TABLE #NightIn
(
EmpNo NVARCHAR(50),
RFID NVARCHAR(50),
ScheduleID INT,
TimeIn NVARCHAR(20),
Daynum INT,
Monthnum INT,
Yearnum INT
)

CREATE TABLE #NightOut
(
EmpNo NVARCHAR(50),
RFID NVARCHAR(50),
ScheduleID INT,
TimeOut NVARCHAR(20),
Daynum INT,
Monthnum INT,
Yearnum INT
)

IF OBJECT_ID('tempdb..#DayInTime') IS NOT NULL
		DROP TABLE #DayInTime;


IF OBJECT_ID('tempdb..#DayIn') IS NOT NULL
		DROP TABLE #DayIn;
IF OBJECT_ID('tempdb..#DayOut') IS NOT NULL
		DROP TABLE #DayOut;

CREATE TABLE #DayIn
(
EmpNo NVARCHAR(50),
RFID NVARCHAR(50),
ScheduleID INT,
TimeIn NVARCHAR(20),
Daynum INT,
Monthnum INT,
Yearnum INT
)

CREATE TABLE #DayOut
(
EmpNo NVARCHAR(50),
RFID NVARCHAR(50),
ScheduleID INT,
TimeOut NVARCHAR(20),
Daynum INT,
Monthnum INT,
Yearnum INT
)


DECLARE MY_CURSOR CURSOR 
  LOCAL STATIC READ_ONLY FORWARD_ONLY
FOR 

SELECT DayOfMonth
FROM #DaysMonth
OPEN MY_CURSOR
FETCH  FROM MY_CURSOR INTO @Daynum
WHILE @@FETCH_STATUS = 0
BEGIN

;WITH ranked_messages AS (
  SELECT M.*, ROW_NUMBER() OVER (PARTITION BY EmpNo ORDER BY ID ASC) AS rn
 FROM #TTFilter M
 WHERE ISNULL(ISNULL(DTR_TimeIn,DTR_TimeOut),ISNULL(TimeIn,Timeout)) BETWEEN @Daynum AND @Daynum+' 23:59:59'
 AND ISNULL(CS_ScheduleID,ScheduleID) IN (SELECT ID FROM M_Schedule WHERE Type LIKE 'Night%')
 AND convert(char(5), TimeIn, 108) > '12:00:00 PM'
)

INSERT INTO #NightIn(EmpNo,RFID,ScheduleID,TimeIn,Daynum,Monthnum,Yearnum)
SELECT  EmpNo,
		Employee_RFID, 
		ISNULL(CS_ScheduleID,ScheduleID) AS ScheduleID, 
		ISNULL(CONVERT(VARCHAR(5),TimeIn,108),'00:00') AS TimeIn, 
		DAY(ISNULL(TimeIn,TimeOut)) AS Daynum,
		MONTH(ISNULL(TimeIn,TimeOut)) AS Monthnum,
		YEAR(ISNULL(TimeIn,TimeOut)) AS Yearnum
FROM ranked_messages WHERE rn = 1
ORDER BY DAY(ISNULL(TimeIn,TimeOut));



IF OBJECT_ID('tempdb..#DayOutTime') IS NOT NULL
		DROP TABLE #DayOutTime;

;WITH ranked_messages AS (
  SELECT M.*, ROW_NUMBER() OVER (PARTITION BY EmpNo ORDER BY ID ASC) AS rn
 FROM #TTFilter M
 WHERE ISNULL(ISNULL(DTR_TimeIn,DTR_TimeOut),ISNULL(TimeIn,Timeout)) BETWEEN @Daynum AND @Daynum+' 23:59:59'
 AND ISNULL(CS_ScheduleID,ScheduleID) IN (SELECT ID FROM M_Schedule WHERE Type LIKE 'Night%')
 AND convert(char(5), Timeout, 108) < '12:00:00 PM'
)

INSERT INTO #NightOut(EmpNo,RFID,ScheduleID,TimeOut,Daynum,Monthnum,Yearnum)
SELECT  EmpNo,
		Employee_RFID, 
		ISNULL(CS_ScheduleID,ScheduleID) AS ScheduleID, 
		ISNULL(CONVERT(VARCHAR(5),TimeOut,108),'00:00') AS TimeOut, 
		DAY(ISNULL(TimeIn,TimeOut)) AS Daynum,
		MONTH(ISNULL(TimeIn,TimeOut)) AS Monthnum,
		YEAR(ISNULL(TimeIn,TimeOut)) AS Yearnum
FROM ranked_messages WHERE rn = 1
ORDER BY DAY(ISNULL(TimeIn,TimeOut));








;WITH ranked_messages AS (
  SELECT M.*, ROW_NUMBER() OVER (PARTITION BY EmpNo ORDER BY ID ASC) AS rn
 FROM #TTFilter M
 WHERE ISNULL(ISNULL(DTR_TimeIn,DTR_TimeOut),ISNULL(TimeIn,Timeout)) BETWEEN @Daynum AND @Daynum+' 23:59:59'
 AND ISNULL(CS_ScheduleID,ScheduleID) IN (SELECT ID FROM M_Schedule WHERE Type LIKE 'Day%')
)

INSERT INTO #DayIn(EmpNo,RFID,ScheduleID,TimeIn,Daynum,Monthnum,Yearnum)
SELECT  EmpNo,
		Employee_RFID, 
		ISNULL(CS_ScheduleID,ScheduleID) AS ScheduleID, 
		ISNULL(CONVERT(VARCHAR(5),TimeIn,108),'00:00') AS TimeIn, 
		DAY(ISNULL(TimeIn,TimeOut)) AS Daynum,
		MONTH(ISNULL(TimeIn,TimeOut)) AS Monthnum,
		YEAR(ISNULL(TimeIn,TimeOut)) AS Yearnum
FROM ranked_messages WHERE rn = 1
ORDER BY DAY(ISNULL(TimeIn,TimeOut));



IF OBJECT_ID('tempdb..#DayOutTime') IS NOT NULL
		DROP TABLE #DayOutTime;

;WITH ranked_messages AS (
  SELECT M.*, ROW_NUMBER() OVER (PARTITION BY EmpNo ORDER BY ID ASC) AS rn
 FROM #TTFilter M
 WHERE ISNULL(ISNULL(DTR_TimeIn,DTR_TimeOut),ISNULL(TimeIn,Timeout)) BETWEEN @Daynum AND @Daynum+' 23:59:59'
 AND ISNULL(CS_ScheduleID,ScheduleID) IN (SELECT ID FROM M_Schedule WHERE Type LIKE 'Day%')
)

INSERT INTO #DayOut(EmpNo,RFID,ScheduleID,TimeOut,Daynum,Monthnum,Yearnum)
SELECT  EmpNo,
		Employee_RFID, 
		ISNULL(CS_ScheduleID,ScheduleID) AS ScheduleID, 
		ISNULL(CONVERT(VARCHAR(5),TimeOut,108),'00:00') AS TimeOut, 
		DAY(ISNULL(TimeIn,TimeOut)) AS Daynum,
		MONTH(ISNULL(TimeIn,TimeOut)) AS Monthnum,
		YEAR(ISNULL(TimeIn,TimeOut)) AS Yearnum
FROM ranked_messages WHERE rn = 1
ORDER BY DAY(ISNULL(TimeIn,TimeOut));











FETCH NEXT FROM MY_CURSOR INTO @Daynum

END
CLOSE MY_CURSOR
DEALLOCATE MY_CURSOR

INSERT INTO #TimeinOutRecord(EmpNo,RFID,ScheduleID,TimeIn,TimeOut,Daynum,Monthnum,Yearnum)
SELECT  a.EmpNo,
		a.RFID,
		a.ScheduleID,
		a.TimeIn,
		b.TimeOut,
		a.Daynum,
		a.Monthnum,
		a.Yearnum
FROM #DayIn a
LEFT JOIN #DayOut b
ON a.EmpNo = b.EmpNo 
AND a.Daynum = b.Daynum
AND a.Monthnum = b.Monthnum
AND a.Yearnum = b.Yearnum


INSERT INTO #TimeinOutRecord(EmpNo,RFID,ScheduleID,TimeIn,TimeOut,Daynum,Monthnum,Yearnum)
SELECT  a.EmpNo,
		a.RFID,
		a.ScheduleID,
		a.TimeIn,
		b.TimeOut,
		a.Daynum,
		a.Monthnum,
		a.Yearnum
FROM #NightIn a
LEFT JOIN #NightOut b
ON a.EmpNo = b.EmpNo 
AND a.Daynum = b.Daynum
AND a.Monthnum = b.Monthnum
AND a.Yearnum = b.Yearnum


IF OBJECT_ID('tempdb..#FinalLogs') IS NOT NULL
		DROP TABLE #FinalLogs;

CREATE TABLE #FinalLogs(
EmpNo NVARCHAR(50),
ScheduleID BIGINT,
LogType NVARCHAR(10),
TimeTap NVARCHAR(10),
Date DATE
)



IF OBJECT_ID('tempdb..#DayLogs') IS NOT NULL
		DROP TABLE #DayLogs;

SELECT * INTO #DayLogs FROM (
SELECT *,'i' AS LogType
FROM #DayIn
UNION 
SELECT *,'o' AS LogType
FROM #DayOut
) as tmp

INSERT INTO #FinalLogs(EmpNo,Date,LogType,TimeTap,ScheduleID)
SELECT  EmpNo,
		CAST((CAST(Monthnum AS VARCHAR(2)) +'/' +CAST(Daynum AS VARCHAR(2)) + '/' + CAST(Yearnum AS VARCHAR(4))) AS DATE),
		LogType,
		TimeIn,
		ScheduleID
FROM #DayLogs

IF OBJECT_ID('tempdb..#NightLogs') IS NOT NULL
		DROP TABLE #NightLogs;

SELECT * INTO #NightLogs FROM (
SELECT *,'i' AS LogType
FROM #NightIn
UNION 
SELECT *,'o' AS LogType
FROM #NightOut
) as tmp


INSERT INTO #FinalLogs(EmpNo,Date,LogType,TimeTap,ScheduleID)
SELECT  EmpNo,
		CAST((CAST(Monthnum AS VARCHAR(2)) +'/' +CAST(Daynum AS VARCHAR(2)) + '/' + CAST(Yearnum AS VARCHAR(4))) AS DATE),
		LogType,
		TimeIn,
		ScheduleID
FROM #NightLogs

IF OBJECT_ID('tempdb..#MStable') IS NOT NULL
	DROP TABLE #MStable
SELECT ROW_NUMBER() OVER(ORDER BY (MS.[Type])) AS Rownum
	,ID
	,MS.[Type]
	,CONVERT(varchar(15),MS.TimeIn ,108) as TimeIn
	,CONVERT(varchar(15),MS.TimeOut ,108) as TimeOut
	,CONVERT(varchar(15),CAST(MS.TimeIn AS TIME),100) as TimeInData
	,CONVERT(varchar(15),CAST(MS.TimeOut AS TIME),100) as TimeOutData
	,Status
	,IsDeleted
	INTO #MStable
	FROM M_Schedule MS
	WHERE IsDeleted <> 1
	ORDER BY MS.[Type]


--SELECT * FROM #MStable


	DECLARE @Daystart TIME;
	DECLARE @DayEnd TIME;
	DECLARE @Nightstart TIME;
	DECLARE @NightEnd TIME;

--Dayshift from
SET @Daystart = (SELECT TimeIn
				FROM #MStable
				WHERE Rownum = 1)

--Dayshift to
SET @DayEnd	=	(SELECT TimeIn
				FROM #MStable
				WHERE Rownum = 6)


--Nightshift from
SET @Nightstart = (SELECT TimeIn
					FROM #MStable
					WHERE Rownum = 7)

--Nightshift to
SET @NightEnd =  (SELECT TimeIn
					FROM #MStable
					WHERE Rownum = 11)







IF OBJECT_ID('tempdb..#WrongShift') IS NOT NULL
		DROP TABLE #WrongShift;

CREATE TABLE #WrongShift(
EmpNo NVARCHAR(50),
EmployeeName NVARCHAR(MAX),
Section NVARCHAR(100),
Shift NVARCHAR(100),
LogType NVARCHAR(10),
TimeTap NVARCHAR(10),
Date NVARCHAR(10)
)



INSERT INTO #WrongShift(EmpNo,EmployeeName,Section,Shift,LogType,TimeTap,Date)
SELECT  a.EmpNo,
		MEL.Family_Name +', ' + MEL.First_Name AS EmployeeName,
		(SELECT TOP 1 s.GroupSection FROM M_Cost_Center_List s WHERE s.Cost_Center = (SELECT TOP 1 MEC.CostCenter_AMS FROM M_Employee_CostCenter MEC WHERE MEC.EmployNo = a.EmpNo AND MEC.UpdateDate_AMS <= a.Date ORDER BY UpdateDate_AMS DESC)) AS Section,
		(SELECT TOP 1 s.Type + ' (' + s.TimeIn + ' - ' + s.TimeOut +')' FROM M_Schedule s WHERE s.ID = a.ScheduleID) AS Shift,
		a.LogType,
		a.TimeTap,
		CAST(CONVERT(VARCHAR(10), a.Date, 101) AS VARCHAR(10)) AS DateLog
		
FROM #FinalLogs a
LEFT JOIN M_Employee_Master_List MEL
ON a.EmpNo = MEL.EmpNo
WHERE Date BETWEEN @DateFrom AND @DateTo
AND (SELECT TOP 1 s.Type + ' (' + s.TimeIn + ' - ' + s.TimeOut +')' FROM M_Schedule s WHERE s.ID = a.ScheduleID) LIKE 'Day%' 
AND a.LogType = 'i'
AND CAST(a.TimeTap AS Time) BETWEEN @Nightstart AND @NightEnd
--ORDER BY CASE WHEN a.EmpNo LIKE 'BIPH%' THEN 1 ELSE 2 END,
--		 a.EmpNo, 
--		 a.Date,
--		 CASE WHEN a.LogType = 'i' THEN 1 ELSE 2 END

INSERT INTO #WrongShift(EmpNo,EmployeeName,Section,Shift,LogType,TimeTap,Date)
SELECT  a.EmpNo,
		MEL.Family_Name +', ' + MEL.First_Name AS EmployeeName,
		(SELECT TOP 1 s.GroupSection FROM M_Cost_Center_List s WHERE s.Cost_Center = (SELECT TOP 1 MEC.CostCenter_AMS FROM M_Employee_CostCenter MEC WHERE MEC.EmployNo = a.EmpNo AND MEC.UpdateDate_AMS <= a.Date ORDER BY UpdateDate_AMS DESC)) AS Section,
		(SELECT TOP 1 s.Type + ' (' + s.TimeIn + ' - ' + s.TimeOut +')' FROM M_Schedule s WHERE s.ID = a.ScheduleID) AS Shift,
		a.LogType,
		a.TimeTap,
		CAST(CONVERT(VARCHAR(10), a.Date, 101) AS VARCHAR(10)) AS DateLog
		
FROM #FinalLogs a
LEFT JOIN M_Employee_Master_List MEL
ON a.EmpNo = MEL.EmpNo
WHERE Date BETWEEN @DateFrom AND @DateTo
AND (SELECT TOP 1 s.Type + ' (' + s.TimeIn + ' - ' + s.TimeOut +')' FROM M_Schedule s WHERE s.ID = a.ScheduleID) LIKE 'Night%' 
AND a.LogType = 'i'
AND CAST(a.TimeTap AS Time) BETWEEN @Daystart AND @DayEnd
--ORDER BY CASE WHEN a.EmpNo LIKE 'BIPH%' THEN 1 ELSE 2 END,
--		 a.EmpNo, 
--		 a.Date,
--		 CASE WHEN a.LogType = 'i' THEN 1 ELSE 2 END

SELECT *
FROM #WrongShift
WHERE Shift LIKE @Shift+'%' OR @Shift = ''
ORDER BY Section,
		 CASE WHEN EmpNo LIKE 'BIPH%' THEN 1 ELSE 2 END,
		 EmpNo, 
		 Date
		

--########################################################----------------------------##########################################################


END





GO
/****** Object:  StoredProcedure [dbo].[GET_RPMonitoring_Graphv2ALLShift]    Script Date: 2020-11-27 2:40:56 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[GET_RPMonitoring_Graphv2ALLShift]
	--DECLARE
	@DateFrom DATETIME = '11/25/2020',
	@DateTo DATETIME = '11/25/2020',
	@Shift NVARCHAR(20) = '',
	@Line BIGINT = '0',
	@Process BIGINT = '0',
	@SectionGroup NVARCHAR(50) = 'BPS',
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

	IF OBJECT_ID('tempdb..#ShiftGroup') IS NOT NULL
		DROP TABLE #ShiftGroup;

	SELECT ID
	INTO #ShiftGroup
	FROM M_Schedule MS
	WHERE MS.Type LIKE @Shift+'%'

	--SET @DateTo = @DateTo + ' 23:59:59'

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
WHERE (ISNULL(TimeIn,TimeOut) <= MEL.Date_Resigned OR MEL.Date_Resigned IS NULL)
AND ISNULL(TT.TimeIn,TT.TimeOut) BETWEEN @DateFrom AND @DateTo
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

--SELECT EmpNo 
--FROM #tmpBus

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
--WHERE TB.ScheduleID IN (SELECT ID FROM #ShiftGroup)
WHERE (@Line = 0 OR @Line IS NULL OR @Line = ML.ID) 
AND (@Process = 0 OR @Process IS NULL OR @Process = MS.ID) 
--AND (@SectionGroup = '' OR @SectionGroup IS NULL OR TB.CostCenter_AMS IN (SELECT Cost_Center FROM M_Cost_Center_List WHERE GroupSection = @SectionGroup)) 

--SELECT EmpNo FROM #tmpBus

SELECT  a.*,
		CASE WHEN (DateCertified IS NOT NULL) THEN 'Green' ELSE 'Red' END AS 'Certified',
		(SELECT COUNT(EmpNo)
		 FROM #checkCer
		 WHERE InDate = a.InDate
		 AND EmpNo = a.EmpNo) AS CountTransfer
INTO #checkCer2
FROM #checkCer a

--SELECT * FROM #checkCer

SELECT *, (CASE WHEN(CountTransfer = 1 AND Certified = 'Green') THEN 'Black'
			    WHEN(CountTransfer = 1 AND Certified = 'Red') THEN 'Red'
				WHEN(CountTransfer > 1 AND Certified = 'Red') THEN 'Red'
				ELSE 'Green' END
		   ) AS TrueColor
INTO #OutputTable
FROM #checkCer2
oRDER BY EmpNo, InDate,TimeIn

--SELECT EmpNo FROM #checkCer2


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


--SELECT EmpNo 
--FROM #OutputTable

SELECT CT.*, (SELECT COUNT(*) FROM #CountTable2 WHERE EmpNo = CT.EmpNo AND InDate = CT.InDate) AS CountTransfer
INTO #CountTable3
FROM #CountTable2 CT
ORDER BY CT.InDate

--SELECT EmpNo FROM #CountTable3

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

	--SELECT InDate, SUM(HeadCount)
	--FROM #OuputTbl
	--GROUP BY InDate

	--SELECT  GETDATE() AS InDate,
	--		'TimeinNew' AS TrueColor,
	--		1 AS HeadCount


	DROP TABLE #OuputTbl

END




















GO
