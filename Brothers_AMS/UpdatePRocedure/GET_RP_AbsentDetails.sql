USE [Brother_AMSDB]
GO
/****** Object:  StoredProcedure [dbo].[GET_RP_AbsentDetails]    Script Date: 2021-03-03 5:24:53 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Chester
-- Create date: 02-29-2020
-- Description:	Get Employee Absent Details
-- =============================================
ALTER PROCEDURE [dbo].[GET_RP_AbsentDetails]
--DECLARE
	@Month INT = '3',
	@Year INT = '2021',
	@SectionSuperGroup NVARCHAR(50) = '',
	@Agency NVARCHAR(50) = ''
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	IF OBJECT_ID('tempdb..#EmployeeTempTBL') IS NOT NULL
	DROP TABLE #EmployeeTempTBL

	SELECT  RP.Date,
			MEL.Company,
			MEL.EmpNo,
			MEL.Family_Name + ', '+ MEL.First_Name + ' ' + MEL.Middle_Name AS EmployeeName,
			(SELECT top 1 CostCenter_AMS FROM M_Employee_CostCenter MEC WHERE MEC.EmployNo = MEL.EmpNo ORDER BY MEC.UpdateDate_AMS DESC) AS CostCenter_AMS,
			(SELECT top 1 Position FROM M_Employee_Position MEC WHERE MEC.EmployNo = MEL.EmpNo ORDER BY MEC.ID DESC) AS ModifiedPosition,
			RP.LeaveType,
			RP.Reason,
			CASE WHEN MEL.EmpNo LIKE 'BIPH%' THEN 1 ELSE 2 END AS Prio
	INTO #EmployeeTempTBL
	FROM RP_AttendanceMonitoring RP
	LEFT JOIN M_Employee_Master_List MEL
	ON RP.EmployeeNo = MEL.EmpNo
	WHERE MONTH(RP.Date) = @Month
	AND YEAR(RP.Date) = @Year
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


	SELECT *
	FROM #EmployeeTempTBL
	WHERE CostCenter_AMS IN (SELECT Cost_Center FROM M_Cost_Center_List WHERE GroupSection = @SectionSuperGroup OR @SectionSuperGroup = '')
	ORDER BY Prio, EmpNo
	
END








