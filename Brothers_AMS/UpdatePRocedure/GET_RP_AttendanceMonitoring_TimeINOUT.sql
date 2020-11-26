USE [Brother_AMSDB]
GO
/****** Object:  StoredProcedure [dbo].[GET_RP_AttendanceMonitoring_TimeINOUT]    Script Date: 11/26/2020 6:12:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[GET_RP_AttendanceMonitoring_TimeINOUT]
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




