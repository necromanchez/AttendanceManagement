USE [Brother_AMSDB]
GO
/****** Object:  StoredProcedure [dbo].[GET_RP_MPCMonitoringv2ALLShift]    Script Date: 2020-12-02 1:43:18 pm ******/
DROP PROCEDURE [dbo].[GET_RP_MPCMonitoringv2ALLShift]
GO
/****** Object:  StoredProcedure [dbo].[GET_RP_MPCMonitoringv2]    Script Date: 2020-12-02 1:43:18 pm ******/
DROP PROCEDURE [dbo].[GET_RP_MPCMonitoringv2]
GO
/****** Object:  StoredProcedure [dbo].[GET_RP_AttendanceMonitoring_TimeINOUT_HRFormatV2]    Script Date: 2020-12-02 1:43:18 pm ******/
DROP PROCEDURE [dbo].[GET_RP_AttendanceMonitoring_TimeINOUT_HRFormatV2]
GO
/****** Object:  StoredProcedure [dbo].[GET_RP_AttendanceMonitoring_TimeINOUT]    Script Date: 2020-12-02 1:43:18 pm ******/
DROP PROCEDURE [dbo].[GET_RP_AttendanceMonitoring_TimeINOUT]
GO
/****** Object:  StoredProcedure [dbo].[GET_RP_AttendanceMonitoring_TimeINOUT]    Script Date: 2020-12-02 1:43:18 pm ******/
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
	@Searchvalue NVARCHAR(50) = 'BIPH2014-00785'

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
WHERE EmpNo IN (SELECT a.EmpNo FROM #EmpList a)

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


IF DAY(@Daynum) < @EndofMonthDays
BEGIN

;WITH ranked_messages AS (
  SELECT M.*, ROW_NUMBER() OVER (PARTITION BY EmpNo ORDER BY ID DESC) AS rn
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



END

ELSE
BEGIN

;WITH ranked_messages AS (
  SELECT M.*, ROW_NUMBER() OVER (PARTITION BY EmpNo ORDER BY ID DESC) AS rn
 FROM #TTFilter M
 WHERE ISNULL(DTR_TimeOut,Timeout) BETWEEN @Daynum AND DATEADD(day,1,@Daynum)+' 23:59:59'
 AND ISNULL(CS_ScheduleID,ScheduleID) IN (SELECT ID FROM M_Schedule WHERE Type LIKE 'Night%')
 AND convert(char(5), Timeout, 108) < '12:00:00 PM'
 
)

INSERT INTO #NightOut(EmpNo,RFID,ScheduleID,TimeOut,Daynum,Monthnum,Yearnum)
SELECT  EmpNo,
		Employee_RFID, 
		ISNULL(CS_ScheduleID,ScheduleID) AS ScheduleID, 
		ISNULL(CONVERT(VARCHAR(5),TimeOut,108),'NoOut') AS TimeOut, 
		@EndofMonthDays AS Daynum,
		MONTH(ISNULL(TimeIn,TimeOut))-1 AS Monthnum,
		YEAR(ISNULL(TimeIn,TimeOut)) AS Yearnum
FROM ranked_messages WHERE rn = 1
ORDER BY DAY(ISNULL(TimeIn,TimeOut));




END



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
  SELECT M.*, ROW_NUMBER() OVER (PARTITION BY EmpNo ORDER BY ID DESC) AS rn
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
/****** Object:  StoredProcedure [dbo].[GET_RP_AttendanceMonitoring_TimeINOUT_HRFormatV2]    Script Date: 2020-12-02 1:43:18 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[GET_RP_AttendanceMonitoring_TimeINOUT_HRFormatV2]
	--DECLARE 
	@DateFrom DATE = '2020-11-20',
	@DateTo DATE = '2020-11-25',
	@Month INT = 11,
	@Year INT = 2020,
	@Section NVARCHAR(50) = '',
	@Agency NVARCHAR(50) = '',
	@PageCount INT = 0,
	@RowCount INT = 100000,
	@Searchvalue NVARCHAR(50) = ''

AS

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
WHERE EmpNo IN (SELECT a.EmpNo FROM #EmpList a)

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

--SELECT @Daynum
IF DAY(@Daynum) < @EndofMonthDays
BEGIN
;WITH ranked_messages AS (
  SELECT M.*, ROW_NUMBER() OVER (PARTITION BY EmpNo ORDER BY ID DESC) AS rn
 FROM #TTFilter M
 WHERE ISNULL(DTR_TimeOut,Timeout) BETWEEN @Daynum AND @Daynum+' 23:59:59'
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

END

ELSE
BEGIN

;WITH ranked_messages AS (
  SELECT M.*, ROW_NUMBER() OVER (PARTITION BY EmpNo ORDER BY ID DESC) AS rn
 FROM #TTFilter M
 WHERE ISNULL(DTR_TimeOut,Timeout) BETWEEN @Daynum AND DATEADD(day,1,@Daynum)+' 23:59:59'
 AND ISNULL(CS_ScheduleID,ScheduleID) IN (SELECT ID FROM M_Schedule WHERE Type LIKE 'Night%')
 AND convert(char(5), Timeout, 108) < '12:00:00 PM'
 
)

INSERT INTO #NightOut(EmpNo,RFID,ScheduleID,TimeOut,Daynum,Monthnum,Yearnum)
SELECT  EmpNo,
		Employee_RFID, 
		ISNULL(CS_ScheduleID,ScheduleID) AS ScheduleID, 
		ISNULL(CONVERT(VARCHAR(5),TimeOut,108),'NoOut') AS TimeOut, 
		@EndofMonthDays AS Daynum,
		MONTH(ISNULL(TimeIn,TimeOut))-1 AS Monthnum,
		YEAR(ISNULL(TimeIn,TimeOut)) AS Yearnum
FROM ranked_messages WHERE rn = 1
ORDER BY DAY(ISNULL(TimeIn,TimeOut));




END





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
  SELECT M.*, ROW_NUMBER() OVER (PARTITION BY EmpNo ORDER BY ID DESC) AS rn
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
		CASE WHEN LogType = 'o' AND (SELECT TOP 1 s.Type + ' (' + s.TimeIn + ' - ' + s.TimeOut +')' FROM M_Schedule s WHERE s.ID = ScheduleID) LIKE 'Night%' THEN CAST(CONVERT(VARCHAR(10), DATEADD(day,1,Date), 101) AS VARCHAR(10)) ELSE CAST(CONVERT(VARCHAR(10), Date, 101) AS VARCHAR(10)) END AS DateLog,
		TimeTap
FROM #FinalLogs
WHERE Date BETWEEN @DateFrom AND @DateTo
ORDER BY CASE WHEN EmpNo LIKE 'BIPH%' THEN 1 ELSE 2 END,
		 EmpNo, 
		 Date,
		 CASE WHEN LogType = 'i' THEN 1 ELSE 2 END


--########################################################----------------------------##########################################################


END






GO
/****** Object:  StoredProcedure [dbo].[GET_RP_MPCMonitoringv2]    Script Date: 2020-12-02 1:43:18 pm ******/
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
ORDER BY Prio, EmpNo, ISNULL(InDate,InDateOut) DESC, TTID ASC


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
/****** Object:  StoredProcedure [dbo].[GET_RP_MPCMonitoringv2ALLShift]    Script Date: 2020-12-02 1:43:18 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[GET_RP_MPCMonitoringv2ALLShift]
	--DECLARE
	@DateFrom DATETIME = '11/25/2020',
	@DateTo DATETIME = '11/25/2020',
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
	CostCenter_AMS NVARCHAR(MAX),
	TTID BIGINT
)


IF @Shift = 'Night'
BEGIN

INSERT INTO #tmpBus(RFID,TimeIn,TimeOut,ScheduleID,ChangeShift,OrigShift,LineID,ProcessID,EmpNo,EmployeeName,Date_Hired,Status,CostCenter_AMS,TTID)
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
		, TT.ID
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
		, TT.ID

END


ELSE
BEGIN
INSERT INTO #tmpBus(RFID,TimeIn,TimeOut,ScheduleID,ChangeShift,OrigShift,LineID,ProcessID,EmpNo,EmployeeName,Date_Hired,Status,CostCenter_AMS,TTID)
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
		,TT.ID
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
		,TT.ID



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
		TTID,
		Certified,
		CountTransfer,
		TrueColor
INTO #TABLEFinal
FROM #FinalTable
ORDER BY Prio, EmpNo, ISNULL(InDate,InDateOut) DESC, TTID ASC 


SELECT  ROW_NUMBER() OVER(ORDER BY (select 0))+ (@RowCount) * (@PageCount)  AS Rownum,
		*
FROM #TABLEFinal



SET @TotalCount = (

SELECT COUNT(*) FROM #tmpBus

)


END






















GO
