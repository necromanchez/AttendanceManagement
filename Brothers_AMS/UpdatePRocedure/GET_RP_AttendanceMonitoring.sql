USE [Brother_AMSDB]
GO
/****** Object:  StoredProcedure [dbo].[GET_RP_AttendanceMonitoring]    Script Date: 11/23/2020 6:00:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[GET_RP_AttendanceMonitoring]
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
		CASE WHEN (SELECT TOP 1 s.Type FROM M_Schedule s WHERE s.ID = MEL.ScheduleID) LIKE 'Night%' 
			 THEN 'P(N)'
			 ELSE 'P(D)'
			 END AS Result,
		--CASE WHEN (SELECT TOP 1 s.Type FROM M_Schedule s WHERE s.ID = MEL.ScheduleID) LIKE 'Night%' 
		--	 THEN (CASE WHEN (SELECT TOP 1 ss.CostCenter_AMS FROM M_Employee_CostCenter ss 
		--						 WHERE ss.EmployNo = MEL.EmpNo 
		--						 AND ss.UpdateDate_AMS<= MEL.Date
		--						 AND LEN(CostCenter_AMS) > 0
		--						 ORDER BY ID DESC) IN (SELECT Cost_Center FROM #CostCodeList) THEN 'P(N)' ELSE 'TR(N)' END)
		--	 ELSE (CASE WHEN (SELECT TOP 1 ss.CostCenter_AMS FROM M_Employee_CostCenter ss 
		--						 WHERE ss.EmployNo = MEL.EmpNo 
		--						 AND ss.UpdateDate_AMS<= MEL.Date
		--						 AND LEN(CostCenter_AMS) > 0
		--						 ORDER BY ID DESC) IN (SELECT Cost_Center FROM #CostCodeList) THEN 'P(D)' ELSE 'TR(D)' END) 
		--	 END AS Result,
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

																				 THEN ''AB''
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



