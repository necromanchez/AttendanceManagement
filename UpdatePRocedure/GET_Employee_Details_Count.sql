USE [Brother_AMSDB]
GO
/****** Object:  StoredProcedure [dbo].[GET_Employee_Details_Count]    Script Date: 2020-11-22 8:16:15 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Chester
-- Create date: 10-07-2019
-- Description:	Get Employee details
-- =============================================
ALTER PROCEDURE [dbo].[GET_Employee_Details_Count]
--DECLARE
	@SectionSuperGroup NVARCHAR(50) = '',
	@PageCount INT = 0,
	@RowCount INT = 10,
	@Searchvalue NVARCHAR(50) = '',
	@Status NVARCHAR(10) = '',
	@MStatus NVARCHAR(20) = ''

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

	SET NOCOUNT ON;
	SET FMTONLY OFF;
	SET ARITHABORT ON;


	IF OBJECT_ID('tempdb..#tabl2') IS NOT NULL
	DROP TABLE #tabl2
	IF OBJECT_ID('tempdb..#tabl2_1') IS NOT NULL
	DROP TABLE #tabl2_1

	BEGIN		
		SELECT 'Result' AS Result, COUNT(*) AS TotalCount
			
			
			
			FROM M_Employee_Master_List ME
			WHERE ME.EmpNo <> '&nbsp;' AND ME.Status IS NOT NULL
			AND (SELECT TOP 1 MEC.CostCenter_AMS FROM M_Employee_CostCenter MEC WHERE MEC.EmployNo = ME.EmpNo AND MEC.UpdateDate_AMS <= GETDATE() ORDER BY UpdateDate_AMS DESC) IN (SELECT Cost_Center
																																	 FROM M_Cost_Center_List
																																	 WHERE GroupSection = @SectionSuperGroup
																																	 OR @SectionSuperGroup = ''
																																	 OR @SectionSuperGroup IS NULL)
			AND (  ME.EmpNo LIKE '%'+@Searchvalue+'%' 
			OR ME.First_Name LIKE '%'+@Searchvalue+'%' 
			OR ME.Family_Name LIKE '%'+@Searchvalue+'%'
			)
			AND (ME.Status = @Status OR @Status IS NULL OR  @Status = '')
			AND ((SELECT top 1 Status FROM M_Employee_Status MEC WHERE MEC.EmployNo = ME.EmpNo ORDER BY MEC.ID DESC) = @MStatus OR @MStatus IS NULL OR  @MStatus = '')
			
		--AND MEL.EmpNo = 'AMI2020-09924'
		

		END




END














