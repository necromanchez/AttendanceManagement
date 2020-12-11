USE [Brother_AMSDB]
GO
/****** Object:  StoredProcedure [dbo].[GET_Employee_Details_Skill]    Script Date: 2020-12-10 12:27:23 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Chester
-- Create date: 10-07-2019
-- Description:	Get Employee details
-- =============================================
ALTER PROCEDURE [dbo].[GET_Employee_Details_Skill] --'6110'
--DECLARE
	@SectionSuperGroup NVARCHAR(50) = 'Printer'
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET FMTONLY OFF;
				

	IF OBJECT_ID('tempdb..#tabl2') IS NOT NULL
	DROP TABLE #tabl2
	IF OBJECT_ID('tempdb..#tabl2_1') IS NOT NULL
	DROP TABLE #tabl2_1



	BEGIN
		
		SELECT  MEL.EmpNo,
				MEL.First_Name,
				MEL.Family_Name,
				MSS.ID,
				ML.Line,
				MSS.Skill,
				(SELECT top 1 Status FROM M_Employee_Status MEC WHERE MEC.EmployNo = MEL.EmpNo ORDER BY MEC.ID DESC) AS ModifiedStatus,
				(SELECT TOP 1 MEC.CostCenter_AMS FROM M_Employee_CostCenter MEC WHERE MEC.EmployNo = MEL.EmpNo ORDER BY UpdateDate_AMS DESC) AS CostCode,
				CASE WHEN  (Company = 'BIPH')  THEN 1 ELSE 2 END AS OrderPrio
		FROM M_Employee_Master_List MEL
		LEFT JOIN M_Employee_Skills MS
		ON MS.EmpNo = MEL.EmpNo
		LEFT JOIN M_LineTeam ML
		ON ML.ID = MS.LineID 
		LEFT JOIN M_Skills MSS
		ON MSS.Line = ML.ID AND MS.SkillID = MSS.ID
		WHERE MEL.EmpNo <> '&nbsp;' AND MEL.Status IS NOT NULL
		--AND MEL.EmpNo = 'AMI2020-09546'
		AND MSS.IsDeleted <> 1 AND ML.IsDeleted <> 1
		AND (SELECT top 1 Status FROM M_Employee_Status MEC WHERE MEC.EmployNo = MEL.EmpNo ORDER BY MEC.ID DESC) = 'ACTIVE'
		AND (SELECT TOP 1 MEC.CostCenter_AMS FROM M_Employee_CostCenter MEC WHERE MEC.EmployNo = MEL.EmpNo AND MEC.UpdateDate_AMS <= GETDATE() ORDER BY UpdateDate_AMS DESC) IN (SELECT Cost_Center
																																	 FROM M_Cost_Center_List
																																	 WHERE GroupSection = @SectionSuperGroup
																																	 OR @SectionSuperGroup = ''
																																	 OR @SectionSuperGroup IS NULL)

																						 
		--AND MSS.IsDeleted <> 1
		--AND ML.IsDeleted <> 1
		--AND MEL.EmpNo = 'BIPH2019-03521'
		ORDER BY OrderPrio, EmpNo
	END


END















