USE [Brother_AMSDB]
GO
/****** Object:  StoredProcedure [dbo].[GET_RP_AttendanceMonitoring_Shift]    Script Date: 2021-02-19 8:35:30 am ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[GET_RP_AttendanceMonitoring_Shift]
	--DECLARE 
	@Month INT = '12',
	@Year INT = '2020',
	@Section NVARCHAR(50) = '',
	@Agency NVARCHAR(50) = '',
	@PageCount INT = 0,
	@RowCount INT = 10000,
	@Searchvalue NVARCHAR(50) = 'PKIMT2020-12053'

AS
BEGIN

--FOR DAYS GENERATOR --

-- ############################ DAY OF MONTH #####################################333
IF OBJECT_ID('tempdb..#DaysMonth') IS NOT NULL
		DROP TABLE #DaysMonth;

	--;WITH
	--CTE_Days AS
	--(
	--SELECT DATEADD(month, @Month, DATEADD(month, -MONTH(GETDATE()), DATEADD(day, -DAY(GETDATE()) + 1, CAST(FLOOR(CAST(GETDATE() AS FLOAT)) AS DATETIME)))) D
	--UNION ALL
	--SELECT DATEADD(day, 1, D)
	--FROM CTE_Days
	--WHERE D < DATEADD(day, -1, DATEADD(month, 1, DATEADD(month, @Month, DATEADD(month, -MONTH(GETDATE()), DATEADD(day, -DAY(GETDATE()) + 1, CAST(FLOOR(CAST(GETDATE() AS FLOAT)) AS DATETIME))))))
	--)

	--SELECT D AS DayOfMonth
	--INTO #DaysMonth
	--FROM CTE_Days


	--

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
				OR MEL.EmpNo LIKE CASE WHEN @Agency = 'AGENCY'
						THEN 'EMS%'
						ELSE @Agency+'%'
				END		
				)

AND ((SELECT TOP 1 MEC.UpdateDate FROM M_Employee_Status MEC WHERE MEC.EmployNo = MEL.EmpNo AND MEC.Status = 'ACTIVE' AND MEC.UpdateDate <= CAST((CAST(@Year AS VARCHAR(4)) + '-' + CAST(@Month AS VARCHAR(2)) + '-' + CAST(@EndofMonthDays AS VARCHAR(2))) AS DATETIME) ORDER BY MEC.ID DESC )) <= CAST((CAST(@Year AS VARCHAR(4)) + '-' + CAST(@Month AS VARCHAR(2)) + '-' + CAST(@EndofMonthDays AS VARCHAR(2))) AS DATETIME)

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
						 AND s.Status = s.StatusMax
						 ORDER BY s.ID DESC),(SELECT TOP 1 ScheduleID
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







