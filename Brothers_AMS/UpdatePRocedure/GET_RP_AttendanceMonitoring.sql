USE [Brother_AMSDB]
GO
/****** Object:  StoredProcedure [dbo].[GET_RP_AttendanceMonitoring]    Script Date: 2020-12-10 10:03:59 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[GET_RP_AttendanceMonitoring]
	--DECLARE 
	@Month INT = '11',
	@Year INT = '2020',
	@Section NVARCHAR(50) = 'Printer',--'Production Engineering',--
	@Agency NVARCHAR(50) = '',
	@PageCount INT = 0,
	@RowCount INT = 10000,
	@Searchvalue NVARCHAR(50) = ''--'BIPH2017-01971'--'BIPH2018-02335'--

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



--SELECT * FROM #EmpList WHERE EmpNo = 'PKIMT2020-12955'

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
--WHERE ISNULL(TimeIn,Timeout) BETWEEN @StartofMonth AND @EndofMonth+' 23:59:59'
WHERE a.EmpNo IN (SELECT a.EmpNo FROM #EmpList a)

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
Yearnum INT,
LeaveHere NVARCHAR(20)

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
--SELECT @Daynum
;WITH ranked_messages AS (
  SELECT M.*, ROW_NUMBER() OVER (PARTITION BY EmpNo ORDER BY ID DESC) AS rn
 FROM #TTFilter M
 WHERE Timeout BETWEEN DATEADD(day,1,@Daynum) AND DATEADD(day,1,@Daynum) +' 23:59:59'
 AND ISNULL(CS_ScheduleID,ScheduleID) IN (SELECT ID FROM M_Schedule WHERE Type LIKE 'Night%')
 AND (convert(char(5), Timeout, 108) < '12:00:00 PM' OR TimeIn IS NULL)
 
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




IF @NightInCout <> @NightOutCount
BEGIN
	INSERT INTO #NightIn(ID,EmpNo,RFID,ScheduleID,TimeIn,Daynum,Monthnum,Yearnum)
	SELECT ID,EmpNo,RFID,ScheduleID,'NoIn',Daynum-1,Monthnum,Yearnum
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
--SELECT * FROM #NightIn

--SELECT *
--FROM #NightIn

--SELECT *
--FROM #NightOut

--SELECT *
--FROM #DayIn

--SELECT *
--FROM #DayOut

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
AND CAST(CAST(a.Monthnum AS VARCHAR(2)) +'/' +CAST(a.Daynum AS VARCHAR(2)) + '/' + CAST(a.Yearnum AS VARCHAR(4)) AS DATE) = DATEADD(day,-1,CAST(CAST(b.Monthnum AS VARCHAR(2)) +'/' +CAST(b.Daynum AS VARCHAR(2)) + '/' + CAST(b.Yearnum AS VARCHAR(4)) AS DATE))
--WHERE a.EmpNo =  'BIPH2017-01795'


--############### INSERT LEAVE ##################
INSERT INTO #TimeinOutRecord(EmpNo,RFID,ScheduleID,TimeIn,TimeOut,Daynum,Monthnum,Yearnum,LeaveHere)
SELECT RP.EmployeeNo, MEL.RFID, 2,'00:00','00:00',DAY(RP.Date),MONTH(RP.Date),YEAR(RP.Date),RP.LeaveType
FROM #RPLeave RP
LEFT JOIN M_Employee_Master_List MEL
ON RP.EmployeeNo = MEL.EmpNo
WHERE MEL.EmpNo IN (SELECT a.EmpNo FROM #EmpList a)
AND LeaveType <> 'AB'
AND DAY(RP.Date) NOT IN (SELECT Daynum FROM #NightIn)



--###############################################



--########################################################----------------------------##########################################################

--SELECT * FROM #TimeinOutRecord ORDER BY Daynum

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
								 AND ss.UpdateDate_AMS<= CAST((CAST(MEL.Monthnum AS VARCHAR(2)) +'/' +CAST(MEL.Daynum AS VARCHAR(2)) + '/' + CAST(MEL.Yearnum AS VARCHAR(4))) + ' 23:59:59' AS DATETIME)
								 AND LEN(CostCenter_AMS) > 0
								 ORDER BY ID DESC) IN (SELECT Cost_Center FROM #CostCodeList) THEN 'P(N)' ELSE 'TR(N)' END)
			 ELSE (CASE WHEN (SELECT TOP 1 ss.CostCenter_AMS FROM M_Employee_CostCenter ss 
								 WHERE ss.EmployNo = MEL.EmpNo 
								 AND ss.UpdateDate_AMS<= CAST((CAST(MEL.Monthnum AS VARCHAR(2)) +'/' +CAST(MEL.Daynum AS VARCHAR(2)) + '/' + CAST(MEL.Yearnum AS VARCHAR(4))) + ' 23:59:59' AS DATETIME)
								 AND LEN(CostCenter_AMS) > 0
								 ORDER BY ID DESC) IN (SELECT Cost_Center FROM #CostCodeList) THEN 'P(D)' ELSE 'TR(D)' END) 
			 END AS Result,
		CAST((CAST(MEL.Monthnum AS VARCHAR(2)) +'/' +CAST(MEL.Daynum AS VARCHAR(2)) + '/' + CAST(MEL.Yearnum AS VARCHAR(4))) AS DATE) AS Date,
		MEL2.Date_Resigned,
		CASE WHEN LEN(MEL.LeaveHere) > 2 THEN '' ELSE MEL.LeaveHere END AS LeaveHere,
		(SELECT TOP 1 ss.CostCenter_AMS FROM M_Employee_CostCenter ss 
		 WHERE ss.EmployNo = MEL.EmpNo 
		 AND ss.UpdateDate_AMS<= CAST((CAST(MEL.Monthnum AS VARCHAR(2)) +'/' +CAST(MEL.Daynum AS VARCHAR(2)) + '/' + CAST(MEL.Yearnum AS VARCHAR(4))) AS DATE)
		 AND LEN(CostCenter_AMS) > 0
		 ORDER BY ID DESC) AS CostCode
		
INTO #PresentAbsent
FROM #TimeinOutRecord MEL
LEFT JOIN M_Employee_Master_List MEL2
ON MEL.EmpNo = MEL2.EmpNo

--SELECT * FROM #PresentAbsent ORDER BY Date


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
																	ISNULL((SELECT TOP 1 CASE WHEN ((s.LeaveHere IS NULL OR s.LeaveHere = ''AB'') AND s.Result IS NOT NULL) THEN s.Result
																							  
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





