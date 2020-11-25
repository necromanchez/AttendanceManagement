USE [Brother_AMSDB]
GO
/****** Object:  StoredProcedure [dbo].[TT_NoInChecker]    Script Date: 2020-11-25 1:46:09 pm ******/
DROP PROCEDURE [dbo].[TT_NoInChecker]
GO
/****** Object:  StoredProcedure [dbo].[TT_EmployeeTaps]    Script Date: 2020-11-25 1:46:09 pm ******/
DROP PROCEDURE [dbo].[TT_EmployeeTaps]
GO
/****** Object:  StoredProcedure [dbo].[GET_RPMonitoring_Graphv2ALLShift]    Script Date: 2020-11-25 1:46:09 pm ******/
DROP PROCEDURE [dbo].[GET_RPMonitoring_Graphv2ALLShift]
GO
/****** Object:  StoredProcedure [dbo].[GET_RPMonitoring_Graphv2]    Script Date: 2020-11-25 1:46:09 pm ******/
DROP PROCEDURE [dbo].[GET_RPMonitoring_Graphv2]
GO
/****** Object:  StoredProcedure [dbo].[GET_RP_MPCMonitoringv2ALLShift]    Script Date: 2020-11-25 1:46:09 pm ******/
DROP PROCEDURE [dbo].[GET_RP_MPCMonitoringv2ALLShift]
GO
/****** Object:  StoredProcedure [dbo].[GET_RP_MPCMonitoringv2]    Script Date: 2020-11-25 1:46:09 pm ******/
DROP PROCEDURE [dbo].[GET_RP_MPCMonitoringv2]
GO
/****** Object:  StoredProcedure [dbo].[GET_RP_AttendanceMonitoring_TimeINOUT]    Script Date: 2020-11-25 1:46:09 pm ******/
DROP PROCEDURE [dbo].[GET_RP_AttendanceMonitoring_TimeINOUT]
GO
/****** Object:  StoredProcedure [dbo].[GET_RP_AttendanceMonitoring_Shift]    Script Date: 2020-11-25 1:46:09 pm ******/
DROP PROCEDURE [dbo].[GET_RP_AttendanceMonitoring_Shift]
GO
/****** Object:  StoredProcedure [dbo].[GET_RP_AttendanceMonitoring_COUNT]    Script Date: 2020-11-25 1:46:09 pm ******/
DROP PROCEDURE [dbo].[GET_RP_AttendanceMonitoring_COUNT]
GO
/****** Object:  StoredProcedure [dbo].[GET_RP_AttendanceMonitoring]    Script Date: 2020-11-25 1:46:09 pm ******/
DROP PROCEDURE [dbo].[GET_RP_AttendanceMonitoring]
GO
/****** Object:  StoredProcedure [dbo].[GET_Position_Dropdown]    Script Date: 2020-11-25 1:46:09 pm ******/
DROP PROCEDURE [dbo].[GET_Position_Dropdown]
GO
/****** Object:  StoredProcedure [dbo].[GET_EmployeeShift_Process]    Script Date: 2020-11-25 1:46:09 pm ******/
DROP PROCEDURE [dbo].[GET_EmployeeShift_Process]
GO
/****** Object:  StoredProcedure [dbo].[GET_Employee_OTFiling]    Script Date: 2020-11-25 1:46:09 pm ******/
DROP PROCEDURE [dbo].[GET_Employee_OTFiling]
GO
/****** Object:  StoredProcedure [dbo].[GET_Employee_Details_Count]    Script Date: 2020-11-25 1:46:09 pm ******/
DROP PROCEDURE [dbo].[GET_Employee_Details_Count]
GO
/****** Object:  StoredProcedure [dbo].[GET_Employee_Details]    Script Date: 2020-11-25 1:46:09 pm ******/
DROP PROCEDURE [dbo].[GET_Employee_Details]
GO
/****** Object:  StoredProcedure [dbo].[GET_AF_CSSummary]    Script Date: 2020-11-25 1:46:09 pm ******/
DROP PROCEDURE [dbo].[GET_AF_CSSummary]
GO
/****** Object:  StoredProcedure [dbo].[Dashboard_ManpowerAttendanceRate]    Script Date: 2020-11-25 1:46:09 pm ******/
DROP PROCEDURE [dbo].[Dashboard_ManpowerAttendanceRate]
GO
/****** Object:  StoredProcedure [dbo].[Dashboard_LeaveBreakDown]    Script Date: 2020-11-25 1:46:09 pm ******/
DROP PROCEDURE [dbo].[Dashboard_LeaveBreakDown]
GO
/****** Object:  StoredProcedure [dbo].[Dashboard_LeaveBreakDown]    Script Date: 2020-11-25 1:46:09 pm ******/
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
	TimeIn DATETIME,
	TimeOut DATETIME,
	ScheduleID INT,
	LineID INT,
	ProcessID INT,
	EmpNo NVARCHAR(MAX)
	
)


IF @Shift = 'Night'
BEGIN
INSERT INTO #tmpBus(TimeIn,TimeOut,ScheduleID,LineID,ProcessID,EmpNo)
	SELECT	CASE WHEN (TT.DTR_RefNo IS NOT NULL) THEN TT.DTR_TimeIn ELSE TT.TimeIn END AS TimeIn
		, CASE WHEN (TT.DTR_RefNo IS NOT NULL) THEN TT.DTR_TimeOut ELSE TT.TimeOut END AS TimeOut
		, CASE WHEN (TT.CSRef_No IS NULL) THEN TT.ScheduleID ELSE TT.CS_ScheduleID END AS ScheduleID
		, TT.LineID
		, TT.ProcessID
		, MEL.EmpNo
		
FROM T_TimeInOut TT
JOIN M_Employee_Master_List MEL
ON TT.EmpNo = MEL.EmpNo
WHERE TT.TimeIn BETWEEN @DateFrom AND @DateTo
AND (TT.TimeIn <= MEL.Date_Resigned OR MEL.Date_Resigned IS NULL)
	AND  ((SELECT top 1 MEC.Status FROM M_Employee_Status MEC WHERE MEC.EmployNo = MEL.EmpNo ORDER BY MEC.ID DESC) = 'ACTIVE' OR ((SELECT top 1 MEC.UpdateDate FROM M_Employee_Status MEC WHERE MEC.EmployNo = MEL.EmpNo AND Status = 'ACTIVE' ORDER BY MEC.ID DESC) <= TT.TimeIn)	AND (SELECT top 1 MEC.UpdateDate FROM M_Employee_Status MEC WHERE MEC.EmployNo = MEL.EmpNo AND Status <> 'ACTIVE' ORDER BY MEC.ID DESC) >= TT.TimeIn)
	AND (SELECT TOP 1 MEC.CostCenter_AMS FROM M_Employee_CostCenter MEC WHERE MEC.EmployNo = MEL.EmpNo AND MEC.UpdateDate_AMS <= TT.TimeIn ORDER BY UpdateDate_AMS DESC) IN (SELECT Cost_Center
																																		 FROM M_Cost_Center_List
																																		 WHERE GroupSection = @SectionGroup
																																		 OR @SectionGroup= ''
																																		 OR @SectionGroup IS NULL)
--AND MEL.EmpNo = 'AMI2020-09721'
AND Employee_RFID IS NOT NULL
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
--AND MEL.EmpNo = 'BIPH2014-00725'
GROUP BY  TT.TimeIn
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
	
	

END


ELSE
BEGIN

INSERT INTO #tmpBus(TimeIn,TimeOut,ScheduleID,LineID,ProcessID,EmpNo)
	SELECT CASE WHEN (TT.DTR_RefNo IS NOT NULL) THEN TT.DTR_TimeIn ELSE TT.TimeIn END AS TimeIn
		, CASE WHEN (TT.DTR_RefNo IS NOT NULL) THEN TT.DTR_TimeOut ELSE TT.TimeOut END AS TimeOut
		, CASE WHEN (TT.CSRef_No IS NULL) THEN TT.ScheduleID ELSE TT.CS_ScheduleID END AS ScheduleID
		, TT.LineID
		, TT.ProcessID
		, MEL.EmpNo
		
FROM T_TimeInOut TT
JOIN M_Employee_Master_List MEL
ON TT.EmpNo = MEL.EmpNo
WHERE (ISNULL(TimeIn,TimeOut) <= MEL.Date_Resigned OR MEL.Date_Resigned IS NULL)
AND ISNULL(TimeIn,TimeOut) BETWEEN @DateFrom AND @DateTo
AND  ((SELECT top 1 MEC.Status FROM M_Employee_Status MEC WHERE MEC.EmployNo = MEL.EmpNo ORDER BY MEC.ID DESC) = 'ACTIVE' OR ((SELECT top 1 MEC.UpdateDate FROM M_Employee_Status MEC WHERE MEC.EmployNo = MEL.EmpNo AND Status = 'ACTIVE' ORDER BY MEC.ID DESC) <= ISNULL(TimeIn,TimeOut))	AND (SELECT top 1 MEC.UpdateDate FROM M_Employee_Status MEC WHERE MEC.EmployNo = MEL.EmpNo AND Status <> 'ACTIVE' ORDER BY MEC.ID DESC) >= ISNULL(TimeIn,TimeOut))
AND (SELECT TOP 1 MEC.CostCenter_AMS FROM M_Employee_CostCenter MEC WHERE MEC.EmployNo = MEL.EmpNo AND MEC.UpdateDate_AMS <= ISNULL(TimeIn,TimeOut) ORDER BY UpdateDate_AMS DESC) IN (SELECT Cost_Center
																																													 FROM M_Cost_Center_List
																																													 WHERE GroupSection = @SectionGroup
																																													 OR @SectionGroup= ''
																																													 OR @SectionGroup IS NULL)

AND Employee_RFID IS NOT NULL
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
--AND MEL.EmpNo = 'BIPH2014-00725'
GROUP BY  TT.TimeIn
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

END


--	SELECT *
--	INTO #tmpBus2
--	FROM #tmpBus
--	WHERE YEAR(ISNULL(TimeIn,Timeout)) = @Year
--	AND MONTH(ISNULL(TimeIn,Timeout)) = @Month
	
--	--SELECT * FROM #tmpBus2 WHERE Day(ISNULL(TimeIn,Timeout)) = 17

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
/****** Object:  StoredProcedure [dbo].[Dashboard_ManpowerAttendanceRate]    Script Date: 2020-11-25 1:46:09 pm ******/
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
	@Shift NVARCHAR(20) = 'Day',
	@Line BIGINT = NULL,
	@CostCode NVARCHAR(50) = '4130'
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
--WHERE (CAST((CAST(@Year AS VARCHAR(4)) + '-' + CAST(@Month AS VARCHAR(2)) + '-' + CAST(@EndofMonthDay AS VARCHAR(2))) AS DATETIME) <= MEL.Date_Resigned OR MEL.Date_Resigned IS NULL)
--AND  ((SELECT top 1 MEC.Status FROM M_Employee_Status MEC WHERE MEC.EmployNo = MEL.EmpNo ORDER BY MEC.ID DESC) = 'ACTIVE' OR ((SELECT top 1 MEC.UpdateDate FROM M_Employee_Status MEC WHERE MEC.EmployNo = MEL.EmpNo AND Status = 'ACTIVE' ORDER BY MEC.ID DESC) <= CAST((CAST(@Year AS VARCHAR(4)) + '-' + CAST(@Month AS VARCHAR(2)) + '-' + CAST(@EndofMonthDay AS VARCHAR(2))) AS DATETIME))	AND (SELECT top 1 MEC.UpdateDate FROM M_Employee_Status MEC WHERE MEC.EmployNo = MEL.EmpNo AND Status <> 'ACTIVE' ORDER BY MEC.ID DESC) >= CAST((CAST(@Year AS VARCHAR(4)) + '-' + CAST(@Month AS VARCHAR(2)) + '-' + CAST(1 AS VARCHAR(2))) AS DATETIME))
--AND (SELECT TOP 1 MEC.CostCenter_AMS FROM M_Employee_CostCenter MEC WHERE MEC.EmployNo = MEL.EmpNo AND MEC.UpdateDate_AMS <= CAST((CAST(@Year AS VARCHAR(4)) + '-' + CAST(@Month AS VARCHAR(2)) + '-' + CAST(@EndofMonthDay AS VARCHAR(2))) AS DATETIME) ORDER BY UpdateDate_AMS DESC) IN (SELECT Cost_Center
--																																	 FROM M_Cost_Center_List
--																																	 WHERE GroupSection = @SectionGroup
--																																	 OR @SectionGroup= ''
--																																	 OR @SectionGroup IS NULL)


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
--AND RP.EmployeeNo IN (SELECT EmpNo FROM #EmpList)
AND RP.EmployeeNo IN (SELECT EmpNo FROm #Table2MPCount)
--AND  ((SELECT top 1 MEC.Status FROM M_Employee_Status MEC WHERE MEC.EmployNo = RP.EmployeeNo ORDER BY MEC.ID DESC) = 'ACTIVE' OR ((SELECT top 1 MEC.UpdateDate FROM M_Employee_Status MEC WHERE MEC.EmployNo = RP.EmployeeNo AND Status = 'ACTIVE' ORDER BY MEC.ID DESC) <= CAST((CAST(@Year AS VARCHAR(4)) + '-' + CAST(@Month AS VARCHAR(2)) + '-' + CAST(@EndofMonthDay AS VARCHAR(2))) AS DATETIME))	AND (SELECT top 1 MEC.UpdateDate FROM M_Employee_Status MEC WHERE MEC.EmployNo = RP.EmployeeNo AND Status <> 'ACTIVE' ORDER BY MEC.ID DESC) >= CAST((CAST(@Year AS VARCHAR(4)) + '-' + CAST(@Month AS VARCHAR(2)) + '-' + CAST(1 AS VARCHAR(2))) AS DATETIME))
--AND (SELECT TOP 1 MEC.CostCenter_AMS FROM M_Employee_CostCenter MEC WHERE MEC.EmployNo = RP.EmployeeNo AND MEC.UpdateDate_AMS <= RP.Date ORDER BY UpdateDate_AMS DESC) IN (SELECT Cost_Center
--																																	 FROM M_Cost_Center_List
--																																	 WHERE GroupSection = @SectionGroup
--																																	 OR @SectionGroup= ''
--																																	 OR @SectionGroup IS NULL)


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
	TimeIn DATETIME,
	TimeOut DATETIME,
	ScheduleID INT,
	LineID INT,
	ProcessID INT,
	EmpNo NVARCHAR(MAX)
	
)


IF @Shift = 'Night'
BEGIN
INSERT INTO #tmpBus(TimeIn,TimeOut,ScheduleID,LineID,ProcessID,EmpNo)
	SELECT	CASE WHEN (TT.DTR_RefNo IS NOT NULL) THEN TT.DTR_TimeIn ELSE TT.TimeIn END AS TimeIn
		, CASE WHEN (TT.DTR_RefNo IS NOT NULL) THEN TT.DTR_TimeOut ELSE TT.TimeOut END AS TimeOut
		, CASE WHEN (TT.CSRef_No IS NULL) THEN TT.ScheduleID ELSE TT.CS_ScheduleID END AS ScheduleID
		, TT.LineID
		, TT.ProcessID
		, MEL.EmpNo
		
FROM T_TimeInOut TT
JOIN M_Employee_Master_List MEL
ON TT.EmpNo = MEL.EmpNo
WHERE TT.TimeIn BETWEEN @DateFrom AND @DateTo
AND (TT.TimeIn <= MEL.Date_Resigned OR MEL.Date_Resigned IS NULL)
	AND  ((SELECT top 1 MEC.Status FROM M_Employee_Status MEC WHERE MEC.EmployNo = MEL.EmpNo ORDER BY MEC.ID DESC) = 'ACTIVE' OR ((SELECT top 1 MEC.UpdateDate FROM M_Employee_Status MEC WHERE MEC.EmployNo = MEL.EmpNo AND Status = 'ACTIVE' ORDER BY MEC.ID DESC) <= TT.TimeIn)	AND (SELECT top 1 MEC.UpdateDate FROM M_Employee_Status MEC WHERE MEC.EmployNo = MEL.EmpNo AND Status <> 'ACTIVE' ORDER BY MEC.ID DESC) >= TT.TimeIn)
	AND (SELECT TOP 1 MEC.CostCenter_AMS FROM M_Employee_CostCenter MEC WHERE MEC.EmployNo = MEL.EmpNo AND MEC.UpdateDate_AMS <= TT.TimeIn ORDER BY UpdateDate_AMS DESC) IN (SELECT Cost_Center
																																		 FROM M_Cost_Center_List
																																		 WHERE GroupSection = @SectionGroup
																																		 OR @SectionGroup= ''
																																		 OR @SectionGroup IS NULL)
--AND MEL.EmpNo = 'AMI2020-09721'
AND Employee_RFID IS NOT NULL
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
--AND MEL.EmpNo = 'BIPH2014-00725'
GROUP BY  TT.TimeIn
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
	
	

END


ELSE
BEGIN

INSERT INTO #tmpBus(TimeIn,TimeOut,ScheduleID,LineID,ProcessID,EmpNo)
	SELECT CASE WHEN (TT.DTR_RefNo IS NOT NULL) THEN TT.DTR_TimeIn ELSE TT.TimeIn END AS TimeIn
		, CASE WHEN (TT.DTR_RefNo IS NOT NULL) THEN TT.DTR_TimeOut ELSE TT.TimeOut END AS TimeOut
		, CASE WHEN (TT.CSRef_No IS NULL) THEN TT.ScheduleID ELSE TT.CS_ScheduleID END AS ScheduleID
		, TT.LineID
		, TT.ProcessID
		, MEL.EmpNo
		
FROM T_TimeInOut TT
JOIN M_Employee_Master_List MEL
ON TT.EmpNo = MEL.EmpNo
WHERE (ISNULL(TimeIn,TimeOut) <= MEL.Date_Resigned OR MEL.Date_Resigned IS NULL)
AND ISNULL(TimeIn,TimeOut) BETWEEN @DateFrom AND @DateTo
AND  ((SELECT top 1 MEC.Status FROM M_Employee_Status MEC WHERE MEC.EmployNo = MEL.EmpNo ORDER BY MEC.ID DESC) = 'ACTIVE' OR ((SELECT top 1 MEC.UpdateDate FROM M_Employee_Status MEC WHERE MEC.EmployNo = MEL.EmpNo AND Status = 'ACTIVE' ORDER BY MEC.ID DESC) <= ISNULL(TimeIn,TimeOut))	AND (SELECT top 1 MEC.UpdateDate FROM M_Employee_Status MEC WHERE MEC.EmployNo = MEL.EmpNo AND Status <> 'ACTIVE' ORDER BY MEC.ID DESC) >= ISNULL(TimeIn,TimeOut))
AND (SELECT TOP 1 MEC.CostCenter_AMS FROM M_Employee_CostCenter MEC WHERE MEC.EmployNo = MEL.EmpNo AND MEC.UpdateDate_AMS <= ISNULL(TimeIn,TimeOut) ORDER BY UpdateDate_AMS DESC) IN (SELECT Cost_Center
																																													 FROM M_Cost_Center_List
																																													 WHERE GroupSection = @SectionGroup
																																													 OR @SectionGroup= ''
																																													 OR @SectionGroup IS NULL)

AND Employee_RFID IS NOT NULL
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
--AND MEL.EmpNo = 'BIPH2014-00725'
GROUP BY  TT.TimeIn
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

END


--	SELECT *
--	INTO #tmpBus2
--	FROM #tmpBus
--	WHERE YEAR(ISNULL(TimeIn,Timeout)) = @Year
--	AND MONTH(ISNULL(TimeIn,Timeout)) = @Month
	
--	--SELECT * FROM #tmpBus2 WHERE Day(ISNULL(TimeIn,Timeout)) = 17

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
/****** Object:  StoredProcedure [dbo].[GET_AF_CSSummary]    Script Date: 2020-11-25 1:46:09 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Chester R.
-- Create date: 10-16-2019
-- Description:	GET CS Summary
-- =============================================
-- [dbo].[GET_AF_CSSummary] 'CS-Production Engineering_20191127','Production Engineering','1990-01-01','2019-11-29',''
CREATE PROCEDURE [dbo].[GET_AF_CSSummary] 
	--DECLARE
	@CSRefno NVARCHAR(50) = '',
	@Section NVARCHAR(MAX) ='',
	@DateFrom DATETIME = '2020-11-01',
	@DateTo DATETIME = '2020-11-29',
	@Status NVARCHAR(10) = ''
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET FMTONLY OFF

	DECLARE @ExtendStatus INT;

	IF @Status >= 2
	BEGIN 
	SET @Status = 2
	END

	IF @Status = -1
	BEGIN
		SET @ExtendStatus = -2
	END

   IF OBJECT_ID('tempdb..#CStableSUMMARY') IS NOT NULL
		DROP TABLE #CStableSUMMARY;

	SELECT  CS.CS_RefNo,
		(SELECT TOP 1 GroupSection FROM M_Cost_Center_List WHERE Cost_Center = CS.Section) AS Section,
		CONVERT(VARCHAR(20), CS.CreateDate, 23) AS CreateDate,
		CS.Status,
		CS.StatusMax,
		(SELECT TOP 1 (SELECT m.FirstName + ' ' + m.LastName FROM M_Users m WHERE m.UserName = MSA.EmployeeNo) + ' ' + CONVERT(VARCHAR(20), ISNULL(MSA.ApprovedDate,MSA.UpdateDate), 120) FROM M_Section_ApproverStatus MSA WHERE MSA.Approved = 1 AND MSA.RefNo = CS.CS_RefNo AND MSA.Position = 'Supervisor') AS ApprovedSupervisor,
		(SELECT TOP 1 (SELECT m.FirstName + ' ' + m.LastName FROM M_Users m WHERE m.UserName = MSA.EmployeeNo) + ' ' + CONVERT(VARCHAR(20), ISNULL(MSA.ApprovedDate,MSA.UpdateDate), 120) FROM M_Section_ApproverStatus MSA WHERE MSA.Approved = 1 AND MSA.RefNo = CS.CS_RefNo AND MSA.Position = 'Manager') AS ApprovedManager,
		(SELECT TOP 1 (SELECT TOP 1 m.FirstName + ' ' + m.LastName FROM M_Users m WHERE m.UserName = CS.CreateID)) AS Requestor,
		CONVERT(VARCHAR(20), CS.UpdateDate, 23) AS UpdateDate
	INTO #CStableSUMMARY
	FROM AF_ChangeSchedulefiling CS


	SELECT  ROW_NUMBER() OVER(ORDER BY (select 0)) AS Rownum,
			CS_RefNo,
			Section,
			CreateDate,
			Status,
			StatusMax,
			CASE WHEN Status = - 2
				 THEN  'Approved by ' + ApprovedSupervisor
				 WHEN Status = -1
				 THEN 'Rejected by ' + ApprovedSupervisor
				 WHEN Status = -10
				 THEN 'Cancelled by ' + Requestor + ' ' + UpdateDate
				 ELSE 'Approved by ' + ApprovedSupervisor
				 END AS ApprovedSupervisor,
			CASE WHEN Status = - 2
				 THEN  'Rejected by ' + ApprovedManager
				 WHEN Status = -1
				 THEN ''
				 WHEN Status = -10
				 THEN 'Cancelled by ' + Requestor + ' ' + UpdateDate
				 WHEN Status = 1
				 THEN ''
				 ELSE 'Approved by ' + ApprovedManager
				 END AS ApprovedManager
	FROM #CStableSUMMARY
	WHERE CreateDate BETWEEN @DateFrom AND @DateTo
	AND (@Section = '' OR @Section IS NULL OR Section = @Section)
	AND (@Status = '' OR @Status IS NULL OR Status = @Status OR Status = @ExtendStatus)
	AND (@CSRefno = '' OR @CSRefno IS NULL OR CS_RefNo = @CSRefno)
	
	GROUP BY CS_RefNo,
		   Section,
		   CreateDate,
		   UpdateDate,
		   Status,
		   StatusMax,
		  -- Schedule,
		   ApprovedSupervisor,
		   ApprovedManager,
		   Requestor
	ORDER BY CS_RefNo DESC


END











GO
/****** Object:  StoredProcedure [dbo].[GET_Employee_Details]    Script Date: 2020-11-25 1:46:09 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Chester
-- Create date: 10-07-2019
-- Description:	Get Employee details
-- =============================================
CREATE PROCEDURE [dbo].[GET_Employee_Details]
--DECLARE
	@SectionSuperGroup NVARCHAR(50) = 'Shipping',
	@PageCount INT = 0,
	@RowCount INT = 10000,
	@Searchvalue NVARCHAR(50) = '',
	@Status NVARCHAR(10) = '',
	@MStatus NVARCHAR(10) = ''
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

	SET NOCOUNT ON;
	SET FMTONLY OFF;
	SET ARITHABORT ON;


	IF OBJECT_ID('tempdb..#tabl2') IS NOT NULL
	DROP TABLE #tabl2
	IF OBJECT_ID('tempdb..#tabl2_1') IS NOT NULL
	DROP TABLE #tabl2_1

	BEGIN		
		SELECT ME.*,
			(SELECT top 1 Status FROM M_Employee_Status MEC WHERE MEC.EmployNo = ME.EmpNo ORDER BY MEC.ID DESC) AS ModifiedStatus,
			ISNULL((SELECT top 1 Position FROM M_Employee_Position MEC WHERE MEC.EmployNo = ME.EmpNo ORDER BY MEC.UpdateDate DESC),ME.Position) AS ModifiedPosition,
			ISNULL((SELECT top 1 CostCenter_AMS FROM M_Employee_CostCenter MEC WHERE MEC.EmployNo = ME.EmpNo ORDER BY MEC.UpdateDate_AMS DESC), ME.CostCode) AS CostCenter_AMS,
			(SELECT top 1 CostCenter_IT FROM M_Employee_CostCenter MEC WHERE MEC.EmployNo = ME.EmpNo ORDER BY MEC.UpdateDate_IT DESC) AS CostCenter_IT,
			(SELECT top 1 CostCenter_EXPROD FROM M_Employee_CostCenter MEC WHERE MEC.EmployNo = ME.EmpNo ORDER BY MEC.UpdateDate_EXPROD DESC) AS CostCenter_EXPROD,
			(SELECT TOP 1 TimeIn + ' - ' + TimeOut 
			 FROM M_Schedule 
			 WHERE ID = ISNULL((SELECT TOP 1 s.Schedule FROM AF_ChangeSchedulefiling s
						 WHERE s.EmployeeNo = ME.EmpNo
						 AND GETDATE() BETWEEN s.DateFrom AND s.DateTo
						 AND s.Status = s.StatusMax),(SELECT TOP 1 ScheduleID
						 FROM M_Employee_Master_List_Schedule 
						 WHERE EmployeeNo = ME.EmpNo 
						 AND ScheduleID IS NOT NULL
						 AND EffectivityDate <= GETDATE()
						 ORDER BY ID DESC))
			AND IsDeleted <> 1) AS Schedule,
			CASE WHEN  (Company = 'BIPH' AND Status = 'ACTIVE')  THEN 1 ELSE 2 END AS OrderPrio
			INTO #tabl2
			FROM M_Employee_Master_List ME
			WHERE ME.EmpNo <> '&nbsp;' AND ME.Status IS NOT NULL
			AND (SELECT TOP 1 MEC.CostCenter_AMS FROM M_Employee_CostCenter MEC WHERE MEC.EmployNo = ME.EmpNo AND MEC.UpdateDate_AMS <= GETDATE() ORDER BY UpdateDate_AMS DESC) IN (SELECT Cost_Center
																																	 FROM M_Cost_Center_List
																																	 WHERE GroupSection = @SectionSuperGroup
																																	 OR @SectionSuperGroup = ''
																																	 OR @SectionSuperGroup IS NULL)
			AND (  ME.EmpNo LIKE '%'+@Searchvalue+'%' 
			OR ME.First_Name LIKE '%'+@Searchvalue+'%' 
			OR ME.Family_Name LIKE '%'+@Searchvalue+'%'
			)
			AND (ME.Status = @Status OR @Status IS NULL OR  @Status = '')
			AND ((SELECT top 1 Status FROM M_Employee_Status MEC WHERE MEC.EmployNo = ME.EmpNo ORDER BY MEC.ID DESC) = @MStatus OR @MStatus IS NULL OR  @MStatus = '')
			
		--AND MEL.EmpNo = 'AMI2020-09924'
		--ORDER BY CASE WHEN ME.EmpNo LIKE 'BIPH%' THEN 1 ELSE 2 END, ME.EmpNo			
			ORDER BY OrderPrio, (SELECT top 1 Status FROM M_Employee_Status MEC WHERE MEC.EmployNo = ME.EmpNo ORDER BY MEC.ID DESC),Company,EmpNo
			OFFSET @PageCount * (@RowCount) ROWS
			FETCH NEXT @RowCount ROWS ONLY	


			--AND Me.EmpNo = 'BIPH2019-03521'

			--SELECT * FROM #tabl2


			SELECT *,
					(SELECT TOP 1 Section FROM M_Cost_Center_List WHERE Cost_Center = a.CostCenter_AMS) AS ModifiedSection,
					(	SELECT COUNT(*) 
						FROM M_Employee_Skills MS 
						LEFT JOIN M_Skills msa 
						ON MS.SkillID = msa.ID 
						LEFT JOIN M_LineTeam ML
						ON msa.Line = ML.ID
						WHERE MS.EmpNo = a.EmpNo
						AND msa.IsDeleted <> 1
						AND ML.IsDeleted <> 1
						AND a.CostCenter_AMS IN (SELECT Cost_Center FROM M_Cost_Center_List WHERE GroupSection = (SELECT TOP 1 s.GroupSection FROM M_Cost_Center_List s WHERE s.Cost_Center = ML.Section))
					
					) AS SkillCount,
					ISNULL((SELECT Type
					 FROM M_Schedule 
					 WHERE ID = ISNULL((SELECT TOP 1 s.Schedule FROM AF_ChangeSchedulefiling s
						 WHERE s.EmployeeNo = a.EmpNo
						 AND GETDATE() BETWEEN s.DateFrom AND s.DateTo
						 AND s.Status = s.StatusMax),(SELECT TOP 1 ScheduleID
						 FROM M_Employee_Master_List_Schedule 
						 WHERE EmployeeNo = a.EmpNo 
						 AND ScheduleID IS NOT NULL
						 AND EffectivityDate <= GETDATE()
						 ORDER BY ID DESC))),'') AS ScheduleName
			INTO #tabl2_1
			FROM #tabl2 a
			ORDER BY OrderPrio, ModifiedStatus,Company,Family_Name

			SELECT CASE WHEN (@PageCount) = 0 THEN ROW_NUMBER() OVER(ORDER BY (select 0)) ELSE ROW_NUMBER() OVER(ORDER BY (select 0))+ (@RowCount) * (@PageCount) END AS Rownum,
				   *,
				   ISNULL(RFID,'') AS MainRFID
			FROM #tabl2_1
			ORDER BY OrderPrio,EmpNo, ModifiedStatus,Company,Family_Name
			--WHERE ModifiedStatus = 'ACTIVE'
			--AND EmpNo = 'BIPH2020-05243'
			
		END




END















GO
/****** Object:  StoredProcedure [dbo].[GET_Employee_Details_Count]    Script Date: 2020-11-25 1:46:09 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Chester
-- Create date: 10-07-2019
-- Description:	Get Employee details
-- =============================================
CREATE PROCEDURE [dbo].[GET_Employee_Details_Count]
--DECLARE
	@SectionSuperGroup NVARCHAR(50) = '',
	@PageCount INT = 0,
	@RowCount INT = 10,
	@Searchvalue NVARCHAR(50) = '',
	@Status NVARCHAR(10) = '',
	@MStatus NVARCHAR(20) = ''

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

	SET NOCOUNT ON;
	SET FMTONLY OFF;
	SET ARITHABORT ON;


	IF OBJECT_ID('tempdb..#tabl2') IS NOT NULL
	DROP TABLE #tabl2
	IF OBJECT_ID('tempdb..#tabl2_1') IS NOT NULL
	DROP TABLE #tabl2_1

	BEGIN		
		SELECT 'Result' AS Result, COUNT(*) AS TotalCount
			
			
			
			FROM M_Employee_Master_List ME
			WHERE ME.EmpNo <> '&nbsp;' AND ME.Status IS NOT NULL
			AND (SELECT TOP 1 MEC.CostCenter_AMS FROM M_Employee_CostCenter MEC WHERE MEC.EmployNo = ME.EmpNo AND MEC.UpdateDate_AMS <= GETDATE() ORDER BY UpdateDate_AMS DESC) IN (SELECT Cost_Center
																																	 FROM M_Cost_Center_List
																																	 WHERE GroupSection = @SectionSuperGroup
																																	 OR @SectionSuperGroup = ''
																																	 OR @SectionSuperGroup IS NULL)
			AND (  ME.EmpNo LIKE '%'+@Searchvalue+'%' 
			OR ME.First_Name LIKE '%'+@Searchvalue+'%' 
			OR ME.Family_Name LIKE '%'+@Searchvalue+'%'
			)
			AND (ME.Status = @Status OR @Status IS NULL OR  @Status = '')
			AND ((SELECT top 1 Status FROM M_Employee_Status MEC WHERE MEC.EmployNo = ME.EmpNo ORDER BY MEC.ID DESC) = @MStatus OR @MStatus IS NULL OR  @MStatus = '')
			
		--AND MEL.EmpNo = 'AMI2020-09924'
		

		END




END















GO
/****** Object:  StoredProcedure [dbo].[GET_Employee_OTFiling]    Script Date: 2020-11-25 1:46:09 pm ******/
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
	@Agency NVARCHAR(20)  = '',
	@CostCode NVARCHAR(50) = '4130',
	@LINEID BIGINT = '11',
	@EmployeeNo NVARCHAR(50) = '',
	@PageCount INT = 0,
	@RowCount INT = 10,
	@Searchvalue NVARCHAR(50) = '',
	@TotalCount INT OUT
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
--GROUP BY   MEL.EmpNo
--		, MEL.Family_Name
--		, MEL.First_Name
--		, MEL.Date_Hired
--		, MEL.Company
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
/****** Object:  StoredProcedure [dbo].[GET_EmployeeShift_Process]    Script Date: 2020-11-25 1:46:09 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Chester
-- Create date: 10-07-2019
-- Description:	Get Employee details
-- =============================================
CREATE PROCEDURE [dbo].[GET_EmployeeShift_Process]
--DECLARE
	@SectionSuperGroup NVARCHAR(50) =  'Shipping'
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

	SET NOCOUNT ON;
	SET FMTONLY OFF;
	SET ARITHABORT ON;

	IF OBJECT_ID('tempdb..#tabl2Count') IS NOT NULL
	DROP TABLE #tabl2Count
	IF OBJECT_ID('tempdb..#tabl2_1Count') IS NOT NULL
	DROP TABLE #tabl2_1Count
	IF OBJECT_ID('tempdb..#TempTable') IS NOT NULL
	DROP TABLE #TempTable
	IF OBJECT_ID('tempdb..#TempTable_Schedule') IS NOT NULL
	DROP TABLE #TempTable_Schedule
	IF OBJECT_ID('tempdb..#TempTable_Process') IS NOT NULL
	DROP TABLE #TempTable_Process
	IF OBJECT_ID('tempdb..#TempTable_AMSActive') IS NOT NULL
	DROP TABLE #TempTable_AMSActive
	IF OBJECT_ID('tempdb..#TempTable_HRActive') IS NOT NULL
	DROP TABLE #TempTable_HRActive
	IF OBJECT_ID('tempdb..#TempTable_AMSInActive') IS NOT NULL
	DROP TABLE #TempTable_AMSInActive
	IF OBJECT_ID('tempdb..#TempTable_HRInActive') IS NOT NULL
	DROP TABLE #TempTable_HRInActive

	BEGIN
		
		BEGIN
		
		SELECT MEL.*,
			(SELECT top 1 Status FROM M_Employee_Status MEC WHERE MEC.EmployNo = MEL.EmpNo ORDER BY MEC.ID DESC) AS AMSStatus,
			MEL.Status AS HRStatus,
			ISNULL((SELECT top 1 CostCenter_AMS FROM M_Employee_CostCenter MEC WHERE MEC.EmployNo = MEL.EmpNo ORDER BY MEC.ID DESC), MEL.CostCode) AS CostCenter_AMS,
			
			(SELECT TOP 1 TimeIn + ' - ' + TimeOut 
			 FROM M_Schedule 
			 WHERE ID = ISNULL((SELECT TOP 1 s.Schedule FROM AF_ChangeSchedulefiling s
						 WHERE s.EmployeeNo = MEL.EmpNo
						 AND GETDATE() BETWEEN s.DateFrom AND s.DateTo
						 AND s.Status = s.StatusMax),(SELECT TOP 1 ScheduleID
						 FROM M_Employee_Master_List_Schedule 
						 WHERE EmployeeNo = MEL.EmpNo 
						 AND ScheduleID IS NOT NULL
						 AND EffectivityDate <= GETDATE()
						 ORDER BY ID DESC))
			AND IsDeleted <> 1) AS Schedule,
			CASE WHEN  (Company = 'BIPH' AND Status = 'ACTIVE')  THEN 1 ELSE 2 END AS OrderPrio
			INTO #tabl2Count
			FROM M_Employee_Master_List MEL
			WHERE MEL.EmpNo <> '&nbsp;' AND MEL.Status IS NOT NULL
			AND (SELECT TOP 1 MEC.CostCenter_AMS FROM M_Employee_CostCenter MEC WHERE MEC.EmployNo = MEL.EmpNo AND MEC.UpdateDate_AMS <= GETDATE() ORDER BY UpdateDate_AMS DESC) IN (SELECT Cost_Center
																																	 FROM M_Cost_Center_List
																																	 WHERE GroupSection = @SectionSuperGroup
																																	 OR @SectionSuperGroup = ''
																																	 OR @SectionSuperGroup IS NULL)


	--WHERE Me.EmpNo = 'PKIMT2019-09786'

			SELECT *,
					(SELECT TOP 1 Section FROM M_Cost_Center_List WHERE Cost_Center = a.CostCenter_AMS) AS ModifiedSection,
					(	SELECT COUNT(*) 
						FROM M_Employee_Skills MS 
						LEFT JOIN M_Skills msa 
						ON MS.SkillID = msa.ID 
						LEFT JOIN M_LineTeam ML
						ON msa.Line = ML.ID
						WHERE MS.EmpNo = a.EmpNo
						AND msa.IsDeleted <> 1
						AND ML.IsDeleted <> 1
						AND a.CostCenter_AMS IN (SELECT Cost_Center FROM M_Cost_Center_List WHERE GroupSection = (SELECT TOP 1 s.GroupSection FROM M_Cost_Center_List s WHERE s.Cost_Center = ML.Section))
					
					) AS SkillCount,
					ISNULL((SELECT Type
					 FROM M_Schedule 
					 WHERE ID = ISNULL((SELECT TOP 1 s.Schedule FROM AF_ChangeSchedulefiling s
						 WHERE s.EmployeeNo = a.EmpNo
						 AND GETDATE() BETWEEN s.DateFrom AND s.DateTo
						 AND s.Status = s.StatusMax),(SELECT TOP 1 ScheduleID
						 FROM M_Employee_Master_List_Schedule 
						 WHERE EmployeeNo = a.EmpNo 
						 AND ScheduleID IS NOT NULL
						 AND EffectivityDate <= GETDATE()
						 ORDER BY ID DESC))),'') AS ScheduleName
			INTO #tabl2_1Count
			FROM #tabl2Count a
			WHERE EmpNo <> '&nbsp;' AND Status IS NOT NULL
			ORDER BY OrderPrio, Status,Company,Family_Name

			--SELECT COUNT(*) FROM #tabl2_1Count WHERE Status = 'Active'
			--SELECT COUNT(*) FROM #tabl2_1Count WHERE Status <> 'Active'
			--SELECT * FROM #tabl2_1Count

			--SELECT COUNT(*) FROM #tabl2_1Count 
			----WHERE EmpNo <> '&nbsp;' AND Status IS NOT NULL
			--WHERE AMSStatus = 'ACTIVE'

			SELECT ROW_NUMBER() OVER(ORDER BY (select 0)) AS Rownum,*
			INTO #TempTable
			FROM #tabl2_1Count
			ORDER BY OrderPrio, Status,Company,Family_Name
		


		SELECT COUNT(*) AS NoSchedule
		INTO #TempTable_Schedule
		FROM #TempTable
		WHERE Schedule IS NULL
		AND AMSStatus = 'ACTIVE'

	
		SELECT COUNT(*) AS NoProcess
		INTO #TempTable_Process
		FROM #TempTable
		WHERE SkillCount = 0
		AND AMSStatus = 'ACTIVE'
		
		--SELECT * FROM #TempTable WHERE AMSStatus = 'ACTIVE'

		SELECT COUNT(*) AS AMSActive
		INTO #TempTable_AMSActive
		FROM #TempTable
		WHERE AMSStatus = 'ACTIVE'

		SELECT COUNT(*) AS HRActive
		INTO #TempTable_HRActive
		FROM #TempTable
		WHERE HRStatus = 'ACTIVE'

		SELECT COUNT(*) AS AMSInActive
		INTO #TempTable_AMSInActive
		FROM #TempTable
		WHERE AMSStatus <> 'ACTIVE'

		SELECT COUNT(*) AS HRInActive
		INTO #TempTable_HRInActive
		FROM #TempTable
		WHERE HRStatus <> 'ACTIVE'

		SELECT @SectionSuperGroup AS Section,* 
		FROM #TempTable_Schedule a
		CROSS JOIN #TempTable_Process b
		CROSS JOIN #TempTable_AMSActive c
		CROSS JOIN #TempTable_HRActive d
		CROSS JOIN #TempTable_AMSInActive e
		CROSS JOIN #TempTable_HRInActive f

		END
	END
	

END














GO
/****** Object:  StoredProcedure [dbo].[GET_Position_Dropdown]    Script Date: 2020-11-25 1:46:09 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GET_Position_Dropdown]
--DECLARE
	@SectionSuperGroup NVARCHAR(50) = ''
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

	SET NOCOUNT ON;
	SET FMTONLY OFF;
	SET ARITHABORT ON;


	SELECT 'Pos' AS Pos,Position
	FROM M_Employee_Master_List
	WHERE Position IS NOT NULL
	GROUP BY Position
	ORDER BY Position

END
GO
/****** Object:  StoredProcedure [dbo].[GET_RP_AttendanceMonitoring]    Script Date: 2020-11-25 1:46:09 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[GET_RP_AttendanceMonitoring]
	--DECLARE 
	@Month INT = '11',
	@Year INT = '2020',
	@Section NVARCHAR(50) = 'Printer',
	@Agency NVARCHAR(50) = '',
	@PageCount INT = 0,
	@RowCount INT = 10,
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
AND (CAST((CAST(@Year AS VARCHAR(4)) + '-' + CAST(@Month AS VARCHAR(2)) + '-' + CAST(1 AS VARCHAR(2))) AS DATETIME) <= MEL.Date_Resigned OR MEL.Date_Resigned IS NULL)
AND  ((SELECT top 1 MEC.Status FROM M_Employee_Status MEC WHERE MEC.EmployNo = MEL.EmpNo ORDER BY MEC.ID DESC) = 'ACTIVE' OR ((SELECT top 1 MEC.UpdateDate FROM M_Employee_Status MEC WHERE MEC.EmployNo = MEL.EmpNo AND Status = 'ACTIVE' ORDER BY MEC.ID DESC) <= CAST((CAST(@Year AS VARCHAR(4)) + '-' + CAST(@Month AS VARCHAR(2)) + '-' + CAST(@EndofMonthDays AS VARCHAR(2))) AS DATETIME))	AND (SELECT top 1 MEC.UpdateDate FROM M_Employee_Status MEC WHERE MEC.EmployNo = MEL.EmpNo AND Status <> 'ACTIVE' ORDER BY MEC.ID DESC) >= CAST((CAST(@Year AS VARCHAR(4)) + '-' + CAST(@Month AS VARCHAR(2)) + '-' + CAST(1 AS VARCHAR(2))) AS DATETIME))
AND (SELECT TOP 1 MEC.CostCenter_AMS FROM M_Employee_CostCenter MEC WHERE MEC.EmployNo = MEL.EmpNo AND MEC.UpdateDate_AMS <= CAST((CAST(@Year AS VARCHAR(4)) + '-' + CAST(@Month AS VARCHAR(2)) + '-' + CAST(@EndofMonthDays AS VARCHAR(2))) AS DATETIME) ORDER BY MEC.ID DESC) IN (SELECT Cost_Center
																																													 FROM M_Cost_Center_List
																																													 WHERE GroupSection = @Section
																																													 OR @Section= ''
																																													 OR @Section IS NULL)
AND (  MEL.EmpNo LIKE '%'+@Searchvalue+'%' 
	OR MEL.First_Name LIKE '%'+@Searchvalue+'%' 
	OR MEL.Family_Name LIKE '%'+@Searchvalue+'%'
	)
--AND MEL.EmpNo =  'BIPH2017-02237'
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
 AND convert(char(5), TimeIn, 108) > '12:00:00 PM'
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
		+ REPLACE(REPLACE(REPLACE((SELECT STUFF( (SELECT ',  (CASE WHEN (''' + CONVERT(VARCHAR(10),DayOfMonth,120) + ''' <= GETDATE() AND pvt.Date_Hired <= ''' + CONVERT(VARCHAR(10),DayOfMonth,120) + ''' AND (pvt.Date_Resigned >= ''' + CONVERT(VARCHAR(10),DayOfMonth,120) + ''' OR pvt.Date_Resigned IS NULL))
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
/****** Object:  StoredProcedure [dbo].[GET_RP_AttendanceMonitoring_COUNT]    Script Date: 2020-11-25 1:46:09 pm ******/
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
AND (CAST((CAST(@Year AS VARCHAR(4)) + '-' + CAST(@Month AS VARCHAR(2)) + '-' + CAST(1 AS VARCHAR(2))) AS DATETIME) <= MEL.Date_Resigned OR MEL.Date_Resigned IS NULL)
AND  ((SELECT top 1 MEC.Status FROM M_Employee_Status MEC WHERE MEC.EmployNo = MEL.EmpNo ORDER BY MEC.ID DESC) = 'ACTIVE' OR ((SELECT top 1 MEC.UpdateDate FROM M_Employee_Status MEC WHERE MEC.EmployNo = MEL.EmpNo AND Status = 'ACTIVE' ORDER BY MEC.ID DESC) <= CAST((CAST(@Year AS VARCHAR(4)) + '-' + CAST(@Month AS VARCHAR(2)) + '-' + CAST(@EndofMonthDay AS VARCHAR(2))) AS DATETIME))	AND (SELECT top 1 MEC.UpdateDate FROM M_Employee_Status MEC WHERE MEC.EmployNo = MEL.EmpNo AND Status <> 'ACTIVE' ORDER BY MEC.ID DESC) >= CAST((CAST(@Year AS VARCHAR(4)) + '-' + CAST(@Month AS VARCHAR(2)) + '-' + CAST(1 AS VARCHAR(2))) AS DATETIME))
AND (SELECT TOP 1 MEC.CostCenter_AMS FROM M_Employee_CostCenter MEC WHERE MEC.EmployNo = MEL.EmpNo AND MEC.UpdateDate_AMS <= CAST((CAST(@Year AS VARCHAR(4)) + '-' + CAST(@Month AS VARCHAR(2)) + '-' + CAST(@EndofMonthDay AS VARCHAR(2))) AS DATETIME) ORDER BY UpdateDate_AMS DESC) IN (SELECT Cost_Center
																																													 FROM M_Cost_Center_List
																																													 WHERE GroupSection = @Section
																																											 OR @Section= ''
																																													 OR @Section IS NULL)

AND (  MEL.EmpNo LIKE '%'+@Searchvalue+'%' 
	OR MEL.First_Name LIKE '%'+@Searchvalue+'%' 
	OR MEL.Family_Name LIKE '%'+@Searchvalue+'%'
	)

--SELECT 'result' AS Result, 1 AS TotalCount

END









GO
/****** Object:  StoredProcedure [dbo].[GET_RP_AttendanceMonitoring_Shift]    Script Date: 2020-11-25 1:46:09 pm ******/
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
AND (CAST((CAST(@Year AS VARCHAR(4)) + '-' + CAST(@Month AS VARCHAR(2)) + '-' + CAST(1 AS VARCHAR(2))) AS DATETIME) <= MEL.Date_Resigned OR MEL.Date_Resigned IS NULL)
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
/****** Object:  StoredProcedure [dbo].[GET_RP_AttendanceMonitoring_TimeINOUT]    Script Date: 2020-11-25 1:46:09 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[GET_RP_AttendanceMonitoring_TimeINOUT]
	--DECLARE 
	@Month INT = '11',
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
AND (CAST((CAST(@Year AS VARCHAR(4)) + '-' + CAST(@Month AS VARCHAR(2)) + '-' + CAST(1 AS VARCHAR(2))) AS DATETIME) <= MEL.Date_Resigned OR MEL.Date_Resigned IS NULL)
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
--WHERE a.EmpNo =  'BIPH2017-01795'

--########################################################----------------------------##########################################################

--SELECT *
--FROM #NightShiftTT
--WHERE EmpNo = 'BIPH2019-02961'


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
/****** Object:  StoredProcedure [dbo].[GET_RP_MPCMonitoringv2]    Script Date: 2020-11-25 1:46:09 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[GET_RP_MPCMonitoringv2]
	--DECLARE
	@DateFrom DATETIME = '11/01/2020',
	@DateTo DATETIME = '11/20/2020',
	@Shift BIGINT = '0',
	@Line BIGINT = '0',
	@Process BIGINT = '0',
	@SectionGroup NVARCHAR(50) = '',
	@PageCount INT = 0,
	@RowCount INT = 10,
	@Searchvalue NVARCHAR(50) = '',
	@Certified NVARCHAR(50) = 'Uncertified',
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
		, (SELECT TOP 1 CostCenter_AMS FROM M_Employee_CostCenter WHERE EmployNo = MEL.EmpNo AND UpdateDate_AMS <= ISNULL(TT.TimeIn,TT.TimeOut) ORDER BY UpdateDate_AMS DESC) AS CostCenter_AMS
		,TT.ID AS TTID
		--, MEC.CostCenter_AMS
INTO #tmpBus
FROM T_TimeInOut TT
JOIN M_Employee_Master_List MEL
ON TT.EmpNo = MEL.EmpNo
INNER JOIN (SELECT RANK() OVER (PARTITION BY EmployNo ORDER BY ID DESC) r, *
             FROM M_Employee_Status) p
ON (TT.EmpNo = p.EmployNo)

WHERE p.r = 1

AND ISNULL(TT.TimeIn,TT.TimeOut) BETWEEN @DateFrom AND @DateTo + '23:59:59'
--AND  ((SELECT top 1 MEC.Status FROM M_Employee_Status MEC WHERE MEC.EmployNo = MEL.EmpNo ORDER BY MEC.ID DESC) = 'ACTIVE' OR ((SELECT top 1 MEC.UpdateDate FROM M_Employee_Status MEC WHERE MEC.EmployNo = MEL.EmpNo AND Status = 'ACTIVE' ORDER BY MEC.ID DESC) <= ISNULL(TimeIn,TimeOut))	AND (SELECT top 1 MEC.UpdateDate FROM M_Employee_Status MEC WHERE MEC.EmployNo = MEL.EmpNo AND Status <> 'ACTIVE' ORDER BY MEC.ID DESC) >= ISNULL(TimeIn,TimeOut))
AND (SELECT TOP 1 MEC.CostCenter_AMS FROM M_Employee_CostCenter MEC WHERE MEC.EmployNo = MEL.EmpNo AND MEC.UpdateDate_AMS <= ISNULL(TimeIn,TimeOut) ORDER BY UpdateDate_AMS DESC) IN (SELECT Cost_Center
																																													 FROM M_Cost_Center_List
																																													 WHERE GroupSection = @SectionGroup
																																													 OR @SectionGroup= ''
																																													 OR @SectionGroup IS NULL)
		
AND Employee_RFID IS NOT NULL
AND (  MEL.EmpNo LIKE '%'+@Searchvalue+'%' 
	OR MEL.First_Name LIKE '%'+@Searchvalue+'%' 

	OR MEL.Family_Name LIKE '%'+@Searchvalue+'%'
	)
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
		, TT.ID
		, p.Status


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
		TB.Status,
		TB.TTID
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

IF OBJECT_ID('tempdb..#TABLEFinal1') IS NOT NULL
		DROP TABLE #TABLEFinal1;


SELECT  
		Prio,
		CASE WHEN TimeIn = 'NoIn' THEN '-' ELSE convert(varchar, InDate, 23) END AS InDate,
		TimeIn,
		CASE WHEN  convert(varchar, InDateOut, 23) = '1900-01-01' THEN '-' ELSE convert(varchar, InDateOut, 23) END AS InDateOut,
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
		TTID,
		Certified,
		CountTransfer,
		TrueColor
INTO #TABLEFinal1
FROM #FinalTable
ORDER BY Prio, EmpNo, ISNULL(InDate,InDateOut) ASC, TimeIn DESC, TimeOut DESC


SELECT CASE WHEN (@PageCount) = 0 THEN ROW_NUMBER() OVER(ORDER BY Prio, EmpNo, CASE WHEN(InDate = '-') THEN InDateOut ELSE InDate END ASC, TimeIn DESC, TimeOut DESC) ELSE ROW_NUMBER() OVER(ORDER BY (select 0))+ (@RowCount) * (@PageCount) END AS Rownum,
*
FROM #TABLEFinal1

SET @TotalCount = (
	
	
	SELECT COUNT(TT.ID)
	FROM T_TimeInOut TT
	JOIN M_Employee_Master_List MEL
	ON TT.EmpNo = MEL.EmpNo
	INNER JOIN (SELECT RANK() OVER (PARTITION BY EmployNo ORDER BY ID DESC) r, *
             FROM M_Employee_Status) p
	ON (TT.EmpNo = p.EmployNo)

	WHERE p.r = 1
	AND ISNULL(TimeIn,TimeOut) BETWEEN @DateFrom AND @DateTo + '23:59:59'
	AND  ((SELECT top 1 MEC.Status FROM M_Employee_Status MEC WHERE MEC.EmployNo = MEL.EmpNo ORDER BY MEC.ID DESC) = 'ACTIVE' OR ((SELECT top 1 MEC.UpdateDate FROM M_Employee_Status MEC WHERE MEC.EmployNo = MEL.EmpNo AND Status = 'ACTIVE' ORDER BY MEC.ID DESC) <= ISNULL(TimeIn,TimeOut))	AND (SELECT top 1 MEC.UpdateDate FROM M_Employee_Status MEC WHERE MEC.EmployNo = MEL.EmpNo AND Status <> 'ACTIVE' ORDER BY MEC.ID DESC) >= ISNULL(TimeIn,TimeOut))
	AND (SELECT TOP 1 MEC.CostCenter_AMS FROM M_Employee_CostCenter MEC WHERE MEC.EmployNo = MEL.EmpNo AND MEC.UpdateDate_AMS <= ISNULL(TimeIn,TimeOut) ORDER BY UpdateDate_AMS DESC) IN (SELECT Cost_Center
																																														 FROM M_Cost_Center_List
																																														 WHERE GroupSection = @SectionGroup
																																														 OR @SectionGroup= ''
																																														 OR @SectionGroup IS NULL)
		
	AND Employee_RFID IS NOT NULL
	AND (  MEL.EmpNo LIKE '%'+@Searchvalue+'%' 
		OR MEL.First_Name LIKE '%'+@Searchvalue+'%' 
		OR MEL.Family_Name LIKE '%'+@Searchvalue+'%'
		)
	--GROUP BY TT.ID
	)

--SELECT @TotalCount
END




















GO
/****** Object:  StoredProcedure [dbo].[GET_RP_MPCMonitoringv2ALLShift]    Script Date: 2020-11-25 1:46:09 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[GET_RP_MPCMonitoringv2ALLShift]
	--DECLARE
	@DateFrom DATETIME = '11/01/2020',
	@DateTo DATETIME = '11/20/2020',
	@Shift NVARCHAR(20) = 'Day',
	@Line BIGINT = '0',
	@Process BIGINT = '0',
	@SectionGroup NVARCHAR(50) = '',
	@PageCount INT = 0,
	@RowCount INT = 10,
	@Searchvalue NVARCHAR(50) = '',
	@Certified NVARCHAR(50) = 'Uncertified',
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
/****** Object:  StoredProcedure [dbo].[GET_RPMonitoring_Graphv2]    Script Date: 2020-11-25 1:46:09 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[GET_RPMonitoring_Graphv2]
	--DECLARE
	@DateFrom DATETIME = '11/01/2020',
	@DateTo DATETIME = '11/30/2020',
	@Shift BIGINT = '0',
	@Line BIGINT = '0',
	@Process BIGINT = '0',
	@SectionGroup NVARCHAR(50) = 'Production Engineering',
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
		, MEL.Status
		,(SELECT TOP 1 CostCenter_AMS FROM M_Employee_CostCenter WHERE EmployNo = MEL.EmpNo AND UpdateDate_AMS <= ISNULL(TT.TimeIn,TT.TimeOut) ORDER BY UpdateDate_AMS DESC) AS CostCenter_AMS
		--, MEC.CostCenter_AMS
INTO #tmpBus
FROM T_TimeInOut TT
JOIN M_Employee_Master_List MEL
ON TT.EmpNo = MEL.EmpNo
WHERE (ISNULL(TimeIn,TimeOut) <= MEL.Date_Resigned OR MEL.Date_Resigned IS NULL)
AND TimeIn BETWEEN @DateFrom AND @DateTo
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




















GO
/****** Object:  StoredProcedure [dbo].[GET_RPMonitoring_Graphv2ALLShift]    Script Date: 2020-11-25 1:46:09 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[GET_RPMonitoring_Graphv2ALLShift]
	--DECLARE
	@DateFrom DATETIME = '10/01/2020',
	@DateTo DATETIME = '10/20/2020',
	@Shift NVARCHAR(20) = 'Day',
	@Line BIGINT = '0',
	@Process BIGINT = '0',
	@SectionGroup NVARCHAR(50) = 'Molding',
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
WHERE (ISNULL(TimeIn,TimeOut) <= MEL.Date_Resigned OR MEL.Date_Resigned IS NULL)
AND TT.TimeIn BETWEEN @DateFrom AND @DateTo
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

--SELECT * FROM #tmpBus

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

--SELECT * FROM #CountTable2

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



















GO
/****** Object:  StoredProcedure [dbo].[TT_EmployeeTaps]    Script Date: 2020-11-25 1:46:09 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Chester R.
-- Create date: 06-08-2020
-- Description:	GET Current Time
-- =============================================

CREATE PROCEDURE [dbo].[TT_EmployeeTaps] 
--DECLARE
	@SectionGroup NVARCHAR(MAX) = 'BPS',
	@Datechosen DATETIME = '2020-11-01',
	@DatechosenEnd DATETIME = '2020-11-23 23:59:59',
	@Agency NVARCHAR(50) = '',
	@Searchvalue NVARCHAR(50) = '',
	@PageCount INT = 0,
	@RowCount INT = 10,
	@TotalCount INT OUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	IF OBJECT_ID('tempdb..#Taps') IS NOT NULL
	DROP TABLE #Taps;

	SELECT TT.*
		 , ISNULL(MEL.First_Name,'') + ' ' + ISNULL(MEL.Family_Name,'') AS EmployeeName
		 , MC.GroupSection AS SectionGroup
		 , MEL.EmpNo AS EmployeeNo
		 --, (SELECT TOP 1 GroupSection FROM M_Cost_Center_List WHERE Cost_Center = MEL.CostCode) AS SectionGroup
	INTO #Taps
	FROM T_TimeTap TT
	LEFT JOIN M_Employee_Master_List MEL
	ON TT.EmpNo = MEL.EmpNo
	LEFT JOIN M_Cost_Center_List MC
	ON MEL.CostCode = MC.Cost_Center
    WHERE Employee_RFID IS NOT NULL
	AND MC.Cost_Center IN (SELECT s.Cost_Center FROM M_Cost_Center_List s WHERE s.GroupSection = @SectionGroup OR @SectionGroup = '' OR @SectionGroup IS NULL)
	AND (TT.Tap BETWEEN @Datechosen AND @DatechosenEnd)
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
	ORDER BY ID
	OFFSET @PageCount * (@RowCount) ROWS
	FETCH NEXT @RowCount ROWS ONLY	
	
	--SELECT * FROM #Taps


	SELECT  Employee_RFID,
			Type,
			CONVERT(VARCHAR(10), Tap, 23) AS TapDate,
			CONVERT(VARCHAR(8), Tap, 108) AS TapTime,
			Taptype,
			EmployeeNo,
			EmployeeName,
			SectionGroup		
	FROM #Taps
	WHERE SectionGroup = @SectionGroup OR @SectionGroup = null OR @SectionGroup = ''
	ORDER BY TapDate,EmployeeNo, TapTime


	SET @TotalCount = (SELECT COUNT(*) FROM #Taps)
END







GO
/****** Object:  StoredProcedure [dbo].[TT_NoInChecker]    Script Date: 2020-11-25 1:46:09 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Chester R.
-- Create date: 10-31-2019
-- Description:	Email Approvers OVERTIME
-- =============================================

CREATE PROCEDURE [dbo].[TT_NoInChecker] 
--DECLARE
@EmpNo NVARCHAR(MAX) = 'BIPH2013-00166',
@TimeOut DATETIME = GETDATE
AS
BEGIN


SELECT 'Result' AS Result, COUNT(*) AS Value
FROM T_TimeInOut
WHERE EmpNo = @EmpNo
--AND TimeIn IS NULL
AND CONVERT(VARCHAR(10),TimeIn,120) = CONVERT(VARCHAR(10),GETDATE(),120) 
AND TimeOut IS NULL


END









GO
