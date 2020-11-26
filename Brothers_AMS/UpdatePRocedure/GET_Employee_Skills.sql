USE [Brother_AMSDB]
GO
/****** Object:  StoredProcedure [dbo].[GET_Employee_Skills]    Script Date: 11/26/2020 4:05:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Chester
-- Create date: 10-04-2019
-- Description:	Get Employee Skills
-- =============================================
-- [dbo].[GET_Employee_Skills] 'SRI2015-01443'
ALTER PROCEDURE [dbo].[GET_Employee_Skills]
	--DECLARE
	@EmployeeNo NVARCHAR(50) = 'BIPH2013-00166'

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	DECLARE @SectionGroup NVARCHAR(MAX),
			@CostCodenow NVARCHAR(10)

	SET @CostCodenow = (SELECT TOP 1 CostCenter_AMS FROM M_Employee_CostCenter WHERE EmployNo = @EmployeeNo ORDER BY UpdateDate_AMS DESC)
	SET @SectionGroup = (SELECT TOP 1 GroupSection FROM M_Cost_Center_List WHERE Cost_Center = @CostCodenow)

    SELECT  MS.EmpNo,
			MS.LineID,
			MS.SkillID,
			LT.Line, 
			S.Skill,
			S.SkillLogo,
			(SELECT FirstName + ' '+ LastName FROM M_Users WHERE UserName = MS.UpdateID) AS UpdateBy,
			MS.UpdateDate
			FROM M_Employee_Skills MS
			LEFT JOIN M_LineTeam LT
			ON MS.LineID = LT.ID
			LEFT JOIN M_Skills S
			ON MS.SkillID = S.ID
			WHERE MS.EmpNo = @EmployeeNo
			AND S.IsDeleted <> 1
			AND LT.IsDeleted <> 1
			AND LT.Section IN (SELECT Cost_Center FROM M_Cost_Center_List WHERE GroupSection = @SectionGroup)
END










