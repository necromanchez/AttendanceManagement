USE [Brother_AMSDB]
GO
/****** Object:  StoredProcedure [dbo].[GET_RP_WrongShiftV2]    Script Date: 2020-12-13 11:12:46 am ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[GET_RP_WrongShiftV2]
	--DECLARE 
	@DateFrom DATE = '2020-11-01',
	@DateTo DATE = '2020-11-30',
	@Month INT = 11,
	@Year INT = 2020,
	@Section NVARCHAR(50) = 'BPS',
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
AND (SELECT TOP 1 MEC.CostCenter_AMS FROM M_Employee_CostCenter MEC WHERE MEC.EmployNo = MEL.EmpNo AND MEC.UpdateDate_AMS <= CAST((CAST(@Year AS VARCHAR(4)) + '-' + CAST(@Month AS VARCHAR(2)) + '-' + CAST(@EndofMonthDays AS VARCHAR(2))) AS DATETIME) ORDER BY MEC.ID DESC) IN (SELECT Cost_Center
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

;WITH ranked_messages AS (
  SELECT M.*, ROW_NUMBER() OVER (PARTITION BY EmpNo ORDER BY ID ASC) AS rn
 FROM #TTFilter M
 WHERE TimeIn BETWEEN @Daynum AND @Daynum+' 23:59:59'
 AND ISNULL(CS_ScheduleID,ScheduleID) IN (SELECT ID FROM M_Schedule WHERE Type LIKE 'Night%')
 AND convert(char(5), TimeIn, 108) > '12:00:00 PM'
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
 AND ISNULL(CS_ScheduleID,ScheduleID) IN (SELECT ID FROM M_Schedule WHERE Type LIKE 'Day%')
)

INSERT INTO #DayIn(ID,EmpNo,RFID,ScheduleID,TimeIn,Daynum,Monthnum,Yearnum)
SELECT  ID,
		EmpNo,
		Employee_RFID, 
		ISNULL(CS_ScheduleID,ScheduleID) AS ScheduleID, 
		ISNULL(CONVERT(VARCHAR(5),TimeIn,108),'NoIn') AS TimeIn, 
		DAY(TimeIn) AS Daynum,
		MONTH(TimeIn) AS Monthnum,
		YEAR(TimeIn) AS Yearnum
FROM ranked_messages WHERE rn = 1
ORDER BY DAY(TimeIn);



IF OBJECT_ID('tempdb..#DayOutTime') IS NOT NULL
		DROP TABLE #DayOutTime;

;WITH ranked_messages AS (
  SELECT M.*, ROW_NUMBER() OVER (PARTITION BY EmpNo ORDER BY ID DESC) AS rn
 FROM #TTFilter M
 WHERE Timeout BETWEEN @Daynum AND @Daynum+' 23:59:59'
 AND ISNULL(CS_ScheduleID,ScheduleID) IN (SELECT ID FROM M_Schedule WHERE Type LIKE 'Day%')
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
--AND a.Daynum = b.Daynum-1
--AND a.Monthnum = b.Monthnum
--AND a.Yearnum = b.Yearnum
AND CAST(CAST(a.Monthnum AS VARCHAR(2)) +'/' +CAST(a.Daynum AS VARCHAR(2)) + '/' + CAST(a.Yearnum AS VARCHAR(4)) AS DATE) = DATEADD(day,-1,CAST(CAST(b.Monthnum AS VARCHAR(2)) +'/' +CAST(b.Daynum AS VARCHAR(2)) + '/' + CAST(b.Yearnum AS VARCHAR(4)) AS DATE))

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
SET @Daystart = '05:30:00.0000000';
				--(SELECT TimeIn
				--FROM #MStable
				--WHERE Rownum = 1)

--Dayshift to
SET @DayEnd	=	'09:00:00.0000000';
				--(SELECT TimeIn
				--FROM #MStable
				--WHERE Rownum = 6)


--Nightshift from
SET @Nightstart = '18:00:00.0000000';
					--(SELECT TimeIn
					--FROM #MStable
					--WHERE Rownum = 7)

--Nightshift to
SET @NightEnd =  '20:00:00.0000000';
					--(SELECT TimeIn
					--FROM #MStable
					--WHERE Rownum = 11)


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





