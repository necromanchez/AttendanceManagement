USE [Brother_AMSDB]
GO
/****** Object:  StoredProcedure [dbo].[GET_Employee_OTFiling]    Script Date: 11/25/2020 9:25:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Chester
-- Create date: 10-08-2019
-- Description:	Get Employee details for OT
-- =============================================

ALTER PROCEDURE [dbo].[GET_Employee_OTFiling]
	--DECLARE
	@Agency NVARCHAR(20)  = '',
	@CostCode NVARCHAR(50) = '4130',
	@LINEID BIGINT = '11',
	@EmployeeNo NVARCHAR(50) = '',
	@PageCount INT = 0,
	@RowCount INT = 10,
	@Searchvalue NVARCHAR(50) = '',
	@TotalCount INT OUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET FMTONLY OFF;
	IF OBJECT_ID('tempdb..#TempEmployeeTBL') IS NOT NULL
		DROP TABLE #TempEmployeeTBL
	IF OBJECT_ID('tempdb..#Skill') IS NOT NULL
		DROP TABLE #Skill
	IF OBJECT_ID('tempdb..#SkillEmp') IS NOT NULL
		DROP TABLE #SkillEmp
	DECLARE @SectionGroup NVARCHAR(50)

		SET @SectionGroup = (SELECT GroupSection FROM M_Cost_Center_List WHERE Cost_Center = @CostCode);


SELECT *
INTO #Skill
FROM M_LineTeam
WHERE Section IN (SELECT Cost_Center FROM M_Cost_Center_List WHERE GroupSection = @SectionGroup)
AND IsDeleted <> 1
AND (@LINEID = '' OR @LINEID IS NULL OR ID = @LINEID)	

SELECT MES.EmpNo
INTO #SkillEmp
FROM M_Employee_Skills MES
WHERE LineID IN (

SELECT ID FROM #Skill
)

--SELECT * FROM #SkillEmp



SELECT	 CASE WHEN EmpNo LIKE 'BIPH%' THEN 1 ELSE 2 END AS Prio
		,MEL.EmpNo
		, MEL.Family_Name
		, MEL.First_Name
		, MEL.Date_Hired
		, (SELECT top 1 MEC.Status FROM M_Employee_Status MEC WHERE MEC.EmployNo = MEL.EmpNo ORDER BY MEC.ID DESC) as Status
		, MEL.Company
		,(SELECT TOP 1 CostCenter_AMS FROM M_Employee_CostCenter WHERE EmployNo = MEL.EmpNo AND UpdateDate_AMS <= GETDATE() ORDER BY UpdateDate_AMS DESC) AS CostCenter_AMS
		--, MEC.CostCenter_AMS
INTO #TempEmployeeTBL
FROM M_Employee_Master_List MEL 
WHERE (SELECT top 1 MEC.Status FROM M_Employee_Status MEC WHERE MEC.EmployNo = MEL.EmpNo ORDER BY MEC.ID DESC) = 'ACTIVE'
AND (MEL.EmpNo IN (SELECT EmpNo FROM #SkillEmp) OR @LINEID IS NULL OR @LINEID = '')
AND (SELECT TOP 1 MEC.CostCenter_AMS FROM M_Employee_CostCenter MEC WHERE MEC.EmployNo = MEL.EmpNo AND MEC.UpdateDate_AMS <= GETDATE() ORDER BY UpdateDate_AMS DESC) IN (SELECT Cost_Center
																																	 FROM M_Cost_Center_List
																																	 WHERE GroupSection = @SectionGroup
																																	 OR @SectionGroup= ''
																																	 OR @SectionGroup IS NULL)
		
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
--GROUP BY   MEL.EmpNo
--		, MEL.Family_Name
--		, MEL.First_Name
--		, MEL.Date_Hired
--		, MEL.Company
ORDER BY CASE WHEN EmpNo LIKE 'BIPH%' THEN 1 ELSE 2 END
OFFSET @PageCount * (@RowCount) ROWS
FETCH NEXT @RowCount ROWS ONLY	

SELECT  TB.EmpNo,
		TB.Family_Name,
		TB.First_Name,
		TB.Company AS Agency,
		TB.CostCenter_AMS,
		@SectionGroup AS Section,
		(SELECT TimeIn + ' - ' + TimeOut 
			 FROM M_Schedule 
			 WHERE ID = (SELECT TOP 1 ScheduleID
						 FROM M_Employee_Master_List_Schedule 
						 WHERE EmployeeNo = TB.EmpNo 
						 ORDER BY ID DESC)) AS Schedule,
			(SELECT SUM(OTHours) FROM AF_OTfiling_Cumulative WHERE EmployeeNo = TB.EmpNo AND MONTH(OTDate) = MONTH(GETDATE()) AND YEAR(OTDate) = YEAR(GETDATE())) AS CumulativeOT
		
--INTO #checkCer
FROM #TempEmployeeTBL TB
ORDER BY Prio, EmpNo
END



SET @TotalCount = (


SELECT COUNT(MEL.EmpNo)
FROM M_Employee_Master_List MEL 
WHERE (SELECT top 1 MEC.Status FROM M_Employee_Status MEC WHERE MEC.EmployNo = MEL.EmpNo ORDER BY MEC.ID DESC) = 'ACTIVE'	
AND (MEL.EmpNo IN (SELECT EmpNo FROM #SkillEmp) OR @LINEID IS NULL OR @LINEID = '')
AND (SELECT TOP 1 MEC.CostCenter_AMS FROM M_Employee_CostCenter MEC WHERE MEC.EmployNo = MEL.EmpNo AND MEC.UpdateDate_AMS <= GETDATE() ORDER BY UpdateDate_AMS DESC) IN (SELECT Cost_Center
																																	 FROM M_Cost_Center_List
																																	 WHERE GroupSection = @SectionGroup
																																	 OR @SectionGroup= ''
																																	 OR @SectionGroup IS NULL)
		
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



)




