USE [Brother_AMSDB]
GO
/****** Object:  StoredProcedure [dbo].[GET_RP_AttendanceMonitoring_COUNT]    Script Date: 2021-01-19 2:12:43 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Chester R.
-- Create date: 10-31-2019
-- Description:	Email Approvers OVERTIME
-- =============================================

ALTER PROCEDURE [dbo].[GET_RP_AttendanceMonitoring_COUNT] 
--DECLARE 
	@Month INT = '11',
	@Year INT = '2020',
	@Section NVARCHAR(50) = 'P-Touch',
	@Agency NVARCHAR(50) = '',
	@Searchvalue NVARCHAR(50) = ''
AS
BEGIN
SET NOCOUNT ON;
SET FMTONLY OFF;
IF OBJECT_ID('tempdb..#DaysMonth2') IS NOT NULL
		DROP TABLE #DaysMonth2;
IF OBJECT_ID('tempdb..#DaysMonth') IS NOT NULL
		DROP TABLE #DaysMonth;

	-- ############################ DAY OF MONTH #####################################333
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


;WITH N(N)AS 
(SELECT 1 FROM(VALUES(1),(1),(1),(1),(1),(1))M(N)),
tally(N)AS(SELECT ROW_NUMBER()OVER(ORDER BY N.N)FROM N,N a)
SELECT datefromparts(@year,@month,N) DayOfMonth 
INTO #DaysMonth2
FROM tally
WHERE N <= day(EOMONTH(datefromparts(@year,@month,1)))

--SELECT * FROM #DaysMonth

-- ############################ DAY OF MONTH #####################################333


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

AND ((SELECT TOP 1 MEC.UpdateDate FROM M_Employee_Status MEC WHERE MEC.EmployNo = MEL.EmpNo AND MEC.Status = 'ACTIVE' AND MEC.UpdateDate <= CAST((CAST(@Year AS VARCHAR(4)) + '-' + CAST(@Month AS VARCHAR(2)) + '-' + CAST(@EndofMonthDay AS VARCHAR(2))) AS DATETIME) ORDER BY MEC.ID DESC )) <= CAST((CAST(@Year AS VARCHAR(4)) + '-' + CAST(@Month AS VARCHAR(2)) + '-' + CAST(@EndofMonthDay AS VARCHAR(2))) AS DATETIME)
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











