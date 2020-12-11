USE [Brother_AMSDB]
GO
/****** Object:  StoredProcedure [dbo].[GET_RP_AttendanceMonitoring_TimeINOUT_HRFormatV2]    Script Date: 2020-12-10 7:44:15 am ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[GET_RP_AttendanceMonitoring_TimeINOUT_HRFormatV2]
	--DECLARE 
	@DateFrom DATE = '2020-11-01',
	@DateTo DATE = '2020-11-30',
	@Month INT = 11,
	@Year INT = 2020,
	@Section NVARCHAR(50) = '',
	@Agency NVARCHAR(50) = '',
	@PageCount INT = 0,
	@RowCount INT = 100000,
	@Searchvalue NVARCHAR(50) ='BIPH2019-04480'--

AS

BEGIN

--FOR DAYS GENERATOR --
SET NOCOUNT ON;
SET FMTONLY OFF

SET @DateFrom = DATEADD(day,-1,@DateFrom)

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
ID BIGINT,
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
ID BIGINT,
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
ID BIGINT,
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
ID BIGINT,
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

--SELECT @Daynum,DATEADD(day,-1,@Daynum);

;WITH ranked_messages AS (
  SELECT M.*, ROW_NUMBER() OVER (PARTITION BY EmpNo ORDER BY ID DESC) AS rn
 FROM #TTFilter M
 WHERE TimeIn BETWEEN @Daynum AND @Daynum +' 23:59:59'
 AND ISNULL(CS_ScheduleID,ScheduleID) IN (SELECT ID FROM M_Schedule WHERE Type LIKE 'Night%')
 AND convert(char(5), Timeout, 108) < '12:00:00 PM'
 
)

INSERT INTO #NightIn(ID,EmpNo,RFID,ScheduleID,TimeIn,Daynum,Monthnum,Yearnum)
SELECT  ID,
		EmpNo,
		Employee_RFID, 
		ISNULL(CS_ScheduleID,ScheduleID) AS ScheduleID, 
		ISNULL(CONVERT(VARCHAR(5),TimeIn,108),'NoIn') AS TimeIn, 
		DAY(TimeIn) AS Daynum,
		MONTH(TimeIn) AS Monthnum,
		YEAR(TimeIn) AS Yearnum
FROM ranked_messages 
WHERE rn = 1
ORDER BY DAY(TimeIn);

--SELECT * FROM #NightIn
--SELECT @Daynum
IF DAY(@Daynum) < @EndofMonthDays
BEGIN
;WITH ranked_messages AS (
  SELECT M.*, ROW_NUMBER() OVER (PARTITION BY EmpNo ORDER BY ID DESC) AS rn
 FROM #TTFilter M
 WHERE Timeout BETWEEN DATEADD(day,1,@Daynum) AND DATEADD(day,1,@Daynum) +' 23:59:59'
 AND ISNULL(CS_ScheduleID,ScheduleID) IN (SELECT ID FROM M_Schedule WHERE Type LIKE 'Night%')
 AND convert(char(5), Timeout, 108) < '12:00:00 PM'
)

INSERT INTO #NightOut(ID,EmpNo,RFID,ScheduleID,TimeOut,Daynum,Monthnum,Yearnum)
SELECT  ID,
		EmpNo,
		Employee_RFID, 
		ISNULL(CS_ScheduleID,ScheduleID) AS ScheduleID, 
		ISNULL(CONVERT(VARCHAR(5),TimeOut,108),'NoOut') AS TimeOut,
		DAY(TimeOut) AS Daynum,
		MONTH(TimeOut) AS Monthnum,
		YEAR(TimeOut) AS Yearnum
FROM ranked_messages 
WHERE rn = 1
ORDER BY DAY(TimeOut);


END

ELSE
BEGIN

;WITH ranked_messages AS (
  SELECT M.*, ROW_NUMBER() OVER (PARTITION BY EmpNo ORDER BY ID DESC) AS rn
 FROM #TTFilter M
 WHERE Timeout BETWEEN DATEADD(day,1,@Daynum) AND DATEADD(day,1,@Daynum) +' 23:59:59'
 AND ISNULL(CS_ScheduleID,ScheduleID) IN (SELECT ID FROM M_Schedule WHERE Type LIKE 'Night%')
 AND convert(char(5), Timeout, 108) < '12:00:00 PM'
 
)

INSERT INTO #NightOut(ID,EmpNo,RFID,ScheduleID,TimeOut,Daynum,Monthnum,Yearnum)
SELECT  ID,
		EmpNo,
		Employee_RFID, 
		ISNULL(CS_ScheduleID,ScheduleID) AS ScheduleID, 
		ISNULL(CONVERT(VARCHAR(5),TimeOut,108),'NoOut') AS TimeOut, 
		1 AS Daynum,
		MONTH(TimeOut) AS Monthnum,
		YEAR(TimeOut) AS Yearnum
FROM ranked_messages 
WHERE rn = 1
ORDER BY DAY(TimeOut);



END





;WITH ranked_messages AS (
  SELECT M.*, ROW_NUMBER() OVER (PARTITION BY EmpNo ORDER BY ID ASC) AS rn
 FROM #TTFilter M
 WHERE ISNULL(ISNULL(DTR_TimeIn,DTR_TimeOut),ISNULL(TimeIn,Timeout)) BETWEEN @Daynum AND @Daynum+' 23:59:59'
 AND (ISNULL(CS_ScheduleID,ScheduleID) IN (SELECT ID FROM M_Schedule WHERE Type LIKE 'Day%') OR ISNULL(CS_ScheduleID,ScheduleID) IS NULL)
)

INSERT INTO #DayIn(ID,EmpNo,RFID,ScheduleID,TimeIn,Daynum,Monthnum,Yearnum)
SELECT  ID,
		EmpNo,
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
 WHERE Timeout BETWEEN @Daynum AND @Daynum+' 23:59:59'
 AND (ISNULL(CS_ScheduleID,ScheduleID) IN (SELECT ID FROM M_Schedule WHERE Type LIKE 'Day%') OR ISNULL(CS_ScheduleID,ScheduleID) IS NULL)
)

INSERT INTO #DayOut(ID,EmpNo,RFID,ScheduleID,TimeOut,Daynum,Monthnum,Yearnum)
SELECT  ID,
		EmpNo,
		Employee_RFID, 
		ISNULL(CS_ScheduleID,ScheduleID) AS ScheduleID, 
		CASE WHEN YEAR(TimeOut) <> '1900' THEN ISNULL(CONVERT(VARCHAR(5),TimeOut,108),'NoOut') ELSE 'NoOut' END AS TimeOut, 
		DAY(TimeOut) AS Daynum,
		MONTH(TimeOut) AS Monthnum,
		YEAR(TimeOut) AS Yearnum
FROM ranked_messages 
WHERE rn = 1
ORDER BY DAY(TimeIn);


FETCH NEXT FROM MY_CURSOR INTO @Daynum

END
CLOSE MY_CURSOR
DEALLOCATE MY_CURSOR


DECLARE @NightInCout INT;
DECLARE @NightOutCount INT;


SET @NightInCout = (SELECT COUNT(*) FROM #NightIn)
SET @NightOutCount = (SELECT COUNT(*) FROM #NightOut)

--SELECT *
--FROM #NightIn

--SELECT *
--FROM #NightOut


IF @NightInCout <> @NightOutCount
BEGIN
	INSERT INTO #NightIn(ID,EmpNo,RFID,ScheduleID,TimeIn,Daynum,Monthnum,Yearnum)
	SELECT ID,EmpNo,RFID,ScheduleID,'NoIn',Daynum,Monthnum,Yearnum
	FROM #NightOut
	WHERE Daynum-1 NOT IN (SELECT Daynum FROM #NightIn) AND Daynum <> 1


	INSERT INTO #NightIn(ID,EmpNo,RFID,ScheduleID,TimeIn,Daynum,Monthnum,Yearnum)
	SELECT  ID,
			EmpNo,
			RFID,
			ScheduleID,
			'NoIn',
			DAY(DATEADD(day,-1,CAST((CAST(Monthnum AS VARCHAR(2)) +'/' +CAST(Daynum AS VARCHAR(2)) + '/' + CAST(Yearnum AS VARCHAR(4))) AS DATE))) AS Daynum,
			MONTH(DATEADD(day,-1,CAST((CAST(Monthnum AS VARCHAR(2)) +'/' +CAST(Daynum AS VARCHAR(2)) + '/' + CAST(Yearnum AS VARCHAR(4))) AS DATE))) AS Monthnum,
			YEAR(DATEADD(day,-1,CAST((CAST(Monthnum AS VARCHAR(2)) +'/' +CAST(Daynum AS VARCHAR(2)) + '/' + CAST(Yearnum AS VARCHAR(4))) AS DATE))) AS Yearnum5
	FROM #NightOut
	WHERE Daynum = 1
END


IF OBJECT_ID('tempdb..#FinalLogs') IS NOT NULL
		DROP TABLE #FinalLogs;

CREATE TABLE #FinalLogs(
ID BIGINT,
EmpNo NVARCHAR(50),
ScheduleID BIGINT,
LogType NVARCHAR(10),
TimeTap NVARCHAR(10),
Date DATE
)

--SELECT * FROM #DayIn

IF OBJECT_ID('tempdb..#DayLogs') IS NOT NULL
		DROP TABLE #DayLogs;


SELECT * INTO #DayLogs FROM (
SELECT  a.ID,
		a.EmpNo,
		CAST((CAST(a.Monthnum AS VARCHAR(2)) +'/' +CAST(a.Daynum AS VARCHAR(2)) + '/' + CAST(a.Yearnum AS VARCHAR(4))) AS DATE) AS Date,
		a.ScheduleID,
		a.TimeIn,
		'i' AS LogType
FROM #DayIn a
LEFT JOIN #DayOut b
ON a.EmpNo = b.EmpNo
AND a.Daynum = b.Daynum
AND a.Monthnum = b.Monthnum
AND a.Yearnum = b.Yearnum
UNION 
SELECT  b.ID,
		a.EmpNo,
		CAST((CAST(a.Monthnum AS VARCHAR(2)) +'/' +CAST(a.Daynum AS VARCHAR(2)) + '/' + CAST(a.Yearnum AS VARCHAR(4))) AS DATE) AS Date,
		a.ScheduleID,
		b.TimeOut AS TimeIn,
		'o' AS LogType
FROM #DayIn a
LEFT JOIN #DayOut b
ON a.EmpNo = b.EmpNo
AND a.Daynum = b.Daynum
AND a.Monthnum = b.Monthnum
AND a.Yearnum = b.Yearnum
) as tmp

INSERT INTO #FinalLogs(ID,EmpNo,Date,LogType,TimeTap,ScheduleID)
SELECT  ID,
		EmpNo,
		Date,--CAST((CAST(Monthnum AS VARCHAR(2)) +'/' +CAST(Daynum AS VARCHAR(2)) + '/' + CAST(Yearnum AS VARCHAR(4))) AS DATE),
		LogType,
		TimeIn,
		ScheduleID
FROM #DayLogs

IF OBJECT_ID('tempdb..#NightLogs') IS NOT NULL
		DROP TABLE #NightLogs;


SELECT * INTO #NightLogs FROM (
SELECT  a.ID,
		a.EmpNo,
		CAST((CAST(a.Monthnum AS VARCHAR(2)) +'/' +CAST(a.Daynum AS VARCHAR(2)) + '/' + CAST(a.Yearnum AS VARCHAR(4))) AS DATE) AS Date,
		a.ScheduleID,
		a.TimeIn,
		'i' AS LogType
FROM #NightIn a
LEFT JOIN #NightOut b
ON a.EmpNo = b.EmpNo
AND a.Daynum = b.Daynum
AND a.Monthnum = b.Monthnum
AND a.Yearnum = b.Yearnum
UNION 
SELECT  b.ID,
		a.EmpNo,
		CAST((CAST(a.Monthnum AS VARCHAR(2)) +'/' +CAST(a.Daynum AS VARCHAR(2)) + '/' + CAST(a.Yearnum AS VARCHAR(4))) AS DATE) AS Date,
		a.ScheduleID,
		b.TimeOut AS TimeIn,
		'o' AS LogType
FROM #NightIn a
LEFT JOIN #NightOut b
ON a.EmpNo = b.EmpNo
--AND a.Daynum = b.Daynum-1
--AND a.Monthnum = b.Monthnum
--AND a.Yearnum = b.Yearnum
AND CAST(CAST(a.Monthnum AS VARCHAR(2)) +'/' +CAST(a.Daynum AS VARCHAR(2)) + '/' + CAST(a.Yearnum AS VARCHAR(4)) AS DATE) = DATEADD(day,-1,CAST(CAST(b.Monthnum AS VARCHAR(2)) +'/' +CAST(b.Daynum AS VARCHAR(2)) + '/' + CAST(b.Yearnum AS VARCHAR(4)) AS DATE))
) as tmp



INSERT INTO #FinalLogs(ID,EmpNo,Date,LogType,TimeTap,ScheduleID)
SELECT  ID,
		EmpNo,
		Date,
		LogType,
		TimeIn,
		ScheduleID
FROM #NightLogs

--SELECT * FROM #FinalLogs

IF OBJECT_ID('tempdb..#Finalnato') IS NOT NULL
		DROP TABLE #Finalnato;


SELECT  ID,
		CASE WHEN EmpNo LIKE 'BIPH%' THEN 1 ELSE 2 END AS Prio,
		CASE WHEN LogType = 'i' THEN 1 ELSE 2 END AS LogPrio,
		EmpNo,
		(SELECT TOP 1 s.Type + ' (' + s.TimeIn + ' - ' + s.TimeOut +')' FROM M_Schedule s WHERE s.ID = ScheduleID) AS Shift,
		LogType,
		CAST(CONVERT(VARCHAR(10), Date, 101) AS VARCHAR(10)) AS DateLog,
		TimeTap
INTO #Finalnato
FROM #FinalLogs
WHERE Date BETWEEN @DateFrom AND @DateTo
ORDER BY CASE WHEN EmpNo LIKE 'BIPH%' THEN 1 ELSE 2 END,
		 --CASE WHEN LogType = 'o' AND (SELECT TOP 1 s.Type + ' (' + s.TimeIn + ' - ' + s.TimeOut +')' FROM M_Schedule s WHERE s.ID = ScheduleID) LIKE 'Night%' THEN CAST(CONVERT(VARCHAR(10), DATEADD(day,1,Date), 101) AS VARCHAR(10)) ELSE CAST(CONVERT(VARCHAR(10), Date, 101) AS VARCHAR(10)) END,
		
		 
		 --CASE WHEN LogType = 'o' AND (SELECT TOP 1 s.Type + ' (' + s.TimeIn + ' - ' + s.TimeOut +')' FROM M_Schedule s WHERE s.ID = ScheduleID) LIKE 'Night%' THEN CAST(CONVERT(VARCHAR(10), DATEADD(day,1,Date), 101) AS VARCHAR(10)) ELSE CAST(CONVERT(VARCHAR(10), Date, 101) AS VARCHAR(10)) END,
		 --TimeTap,
		 ID


SELECT  1 AS Prio,
		1 AS LogPrio,
		EmpNo,
		Shift,
		LogType,
		CASE WHEN LogType = 'o' AND Shift LIKE 'Night%' THEN CAST(CONVERT(VARCHAR(10), DATEADD(day,1,DateLog), 101) AS VARCHAR(10)) ELSE CAST(CONVERT(VARCHAR(10), DateLog, 101) AS VARCHAR(10)) END AS DateLog,
		ISNULL(TimeTap,'NoOut') AS TimeTap
FROM #Finalnato
--WHERE DateLog = '11/30/2020'
ORDER BY CASE WHEN EmpNo LIKE 'BIPH%' THEN 1 ELSE 2 END,
		 EmpNo,
		 DateLog,
		 ID,
		CASE WHEN LogType = 'i' THEN 1 ELSE 2 END
		 
--OFFSET 1 ROWS;


--########################################################----------------------------##########################################################


END





