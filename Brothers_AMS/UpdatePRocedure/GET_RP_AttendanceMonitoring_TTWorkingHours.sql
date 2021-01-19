USE [Brother_AMSDB]
GO
/****** Object:  StoredProcedure [dbo].[GET_RP_AttendanceMonitoring_TTWorkingHours]    Script Date: 2021-01-15 1:02:00 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[GET_RP_AttendanceMonitoring_TTWorkingHours]
	--DECLARE 
	@Month INT = '1',
	@Year INT = '2021',
	@Section NVARCHAR(50) = '',
	@Agency NVARCHAR(50) = '',
	@PageCount INT = 0,
	@RowCount INT = 10,
	@Searchvalue NVARCHAR(50) = ''--'AVANCE2020-01851'--'PKIMT2020-13775'--'BIPH2018-02335'--'BIPH2019-04480'
AS
BEGIN

-- ############################ DAY OF MONTH #####################################333
IF OBJECT_ID('tempdb..#DaysMonth') IS NOT NULL
		DROP TABLE #DaysMonth;

;WITH N(N)AS 
(SELECT 1 FROM(VALUES(1),(1),(1),(1),(1),(1))M(N)),
tally(N)AS(SELECT ROW_NUMBER()OVER(ORDER BY N.N)FROM N,N a)
SELECT datefromparts(@year,@month,N) DayOfMonth 
INTO #DaysMonth
FROM tally
WHERE N <= day(EOMONTH(datefromparts(@year,@month,1)))

--SELECT * FROM #DaysMonth

-- ############################ DAY OF MONTH #####################################333

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
BEGIN
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
  SELECT M.*, ROW_NUMBER() OVER (PARTITION BY EmpNo ORDER BY ID ASC) AS rn
 FROM #TTFilter M
 WHERE TimeIn BETWEEN @Daynum AND @Daynum +' 23:59:59'
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
 AND CAST(TimeIn AS TIME) > '12:00:00 AM'
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
--ORDER BY DAY(TimeIn);


FETCH NEXT FROM MY_CURSOR INTO @Daynum

END
CLOSE MY_CURSOR
DEALLOCATE MY_CURSOR


DECLARE @NightInCout INT;
DECLARE @NightOutCount INT;

DECLARE @DayInCout INT;
DECLARE @DayOutCount INT;


--SELECT * FROM #DayIn

--SELECT * FROM #DayOut


SET @NightInCout = (SELECT COUNT(*) FROM #NightIn)
SET @NightOutCount = (SELECT COUNT(*) FROM #NightOut)

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
			YEAR(DATEADD(day,-1,CAST((CAST(Monthnum AS VARCHAR(2)) +'/' +CAST(Daynum AS VARCHAR(2)) + '/' + CAST(Yearnum AS VARCHAR(4))) AS DATE))) AS Yearnum
	FROM #NightOut
	WHERE Daynum = 1
END


END

INSERT INTO #TimeinOutRecord(EmpNo,RFID,ScheduleID,TimeIn,TimeOut,Daynum,Monthnum,Yearnum)
SELECT  ISNULL(a.EmpNo, b.EmpNo) AS EmpNo,
		ISNULL(a.RFID, b.RFID) AS RFID,
		ISNULL(a.ScheduleID,b.ScheduleID) AS ScheduleID,
		a.TimeIn,
		b.TimeOut,
		ISNULL(a.Daynum, b.Daynum) AS Daynum,
		ISNULL(a.Monthnum, b.Monthnum) AS Monthnum,
		ISNULL(a.Yearnum, b.Yearnum) AS Yearnum
FROM #DayIn a
FULL JOIN #DayOut b
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
AND CAST(CAST(a.Monthnum AS VARCHAR(2)) +'/' +CAST(a.Daynum AS VARCHAR(2)) + '/' + CAST(a.Yearnum AS VARCHAR(4)) AS DATE) = DATEADD(day,-1,CAST(CAST(b.Monthnum AS VARCHAR(2)) +'/' +CAST(b.Daynum AS VARCHAR(2)) + '/' + CAST(b.Yearnum AS VARCHAR(4)) AS DATE))
WHERE (CAST(CASE WHEN a.TimeIn = 'NoIn' THEN '17:00' ELSE a.TimeIn END AS Time) > '12:00:00 PM' OR a.TimeIn IS NULL)
--WHERE a.EmpNo =  'BIPH2017-01795'




--########################################################----------------------------##########################################################



--SELECT * FROM #TimeinOutRecord --WHERE EmpNo = 'BIPH2014-00485'

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
		'+REPLACE((SELECT STUFF( (SELECT ', CASE WHEN ISNULL((SELECT TOP 1 CAST(ROUND((DATEDIFF(second,ISNULL(TimeIn,''00:00''), ISNULL(TimeOut,''00:00''))/ 3600.0) * 2, 0) / 2 AS DECIMAL(18,1)) FROM #TimeinOutRecord a WHERE a.EmpNo = EL.EmpNo AND a.Daynum = ' + CAST(DAY(DayOfMonth) AS VARCHAR(2)) + '),''0'') < 0 THEN ''-1'' ELSE ISNULL((SELECT TOP 1 CAST(ROUND((DATEDIFF(second,ISNULL(TimeIn,''00:00''), ISNULL(TimeOut,''00:00''))/ 3600.0) * 2, 0) / 2 AS DECIMAL(18,1)) FROM #TimeinOutRecord a WHERE a.EmpNo = EL.EmpNo AND a.Daynum = ' + CAST(DAY(DayOfMonth) AS VARCHAR(2)) + '),''0.0'') END AS [' + CAST(DAY(DayOfMonth) AS VARCHAR(2)) + ']'
		   FROM #DaysMonth  
		   --WHERE DAY(DayOfMonth) = 29
		   FOR XML PATH('')), 1, 2, '')),'&lt;', '<')+'
		
FROM #EmpListwithDate EL
--WHERE EmpNo LIKE ''AVANCE%''
ORDER BY Prio,EmpNo

'

--SELECT @SQLf
EXECUTE(@SQLf)
--############# END DRAWING ###################


END







