USE [Brother_AMSDB]
GO
/****** Object:  StoredProcedure [dbo].[GET_Employee_Details]    Script Date: 2021-02-23 2:58:07 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Chester
-- Create date: 10-07-2019
-- Description:	Get Employee details
-- =============================================
ALTER PROCEDURE [dbo].[GET_Employee_Details]
--DECLARE
	@SectionSuperGroup NVARCHAR(50) = '',
	@PageCount INT = 0,
	@RowCount INT = 10000,
	@Searchvalue NVARCHAR(50) = '',
	@Status NVARCHAR(10) = '',
	@MStatus NVARCHAR(10) = ''
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
		SELECT ME.*,
			(SELECT top 1 Status FROM M_Employee_Status MEC WHERE MEC.EmployNo = ME.EmpNo ORDER BY MEC.ID DESC) AS ModifiedStatus,
			ISNULL((SELECT top 1 Position FROM M_Employee_Position MEC WHERE MEC.EmployNo = ME.EmpNo ORDER BY MEC.UpdateDate DESC),ME.Position) AS ModifiedPosition,
			ISNULL((SELECT top 1 CostCenter_AMS FROM M_Employee_CostCenter MEC WHERE MEC.EmployNo = ME.EmpNo ORDER BY MEC.UpdateDate_AMS DESC), ME.CostCode) AS CostCenter_AMS,
			(SELECT top 1 CostCenter_IT FROM M_Employee_CostCenter MEC WHERE MEC.EmployNo = ME.EmpNo ORDER BY MEC.UpdateDate_IT DESC) AS CostCenter_IT,
			(SELECT top 1 CostCenter_EXPROD FROM M_Employee_CostCenter MEC WHERE MEC.EmployNo = ME.EmpNo ORDER BY MEC.UpdateDate_EXPROD DESC) AS CostCenter_EXPROD,
			(SELECT TOP 1 TimeIn + ' - ' + TimeOut 
			 FROM M_Schedule 
			 WHERE ID = ISNULL((SELECT TOP 1 s.Schedule FROM AF_ChangeSchedulefiling s
						 WHERE s.EmployeeNo = ME.EmpNo
						 AND GETDATE() BETWEEN s.DateFrom AND s.DateTo
						 AND s.Status = s.StatusMax
						 ORDER BY ID DESC),(SELECT TOP 1 ScheduleID
						 FROM M_Employee_Master_List_Schedule 
						 WHERE EmployeeNo = ME.EmpNo 
						 AND ScheduleID IS NOT NULL
						 AND EffectivityDate <= GETDATE()
						 ORDER BY ID DESC))
			AND IsDeleted <> 1) AS Schedule,
			CASE WHEN  (Company = 'BIPH' AND Status = 'ACTIVE')  THEN 1 ELSE 2 END AS OrderPrio
			INTO #tabl2
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
		--ORDER BY CASE WHEN ME.EmpNo LIKE 'BIPH%' THEN 1 ELSE 2 END, ME.EmpNo			
			ORDER BY OrderPrio, (SELECT top 1 Status FROM M_Employee_Status MEC WHERE MEC.EmployNo = ME.EmpNo ORDER BY MEC.ID DESC),Company,EmpNo
			OFFSET @PageCount * (@RowCount) ROWS
			FETCH NEXT @RowCount ROWS ONLY	


			--AND Me.EmpNo = 'BIPH2019-03521'

			--SELECT * FROM #tabl2


			SELECT *,
					(SELECT TOP 1 Section FROM M_Cost_Center_List WHERE Cost_Center = a.CostCenter_AMS) AS ModifiedSection,
					(	SELECT COUNT(*) 
						FROM M_Employee_Skills MS 
						LEFT JOIN M_Skills msa 
						ON MS.SkillID = msa.ID 
						LEFT JOIN M_LineTeam ML
						ON msa.Line = ML.ID
						WHERE MS.EmpNo = a.EmpNo
						AND msa.IsDeleted <> 1
						AND ML.IsDeleted <> 1
						AND a.CostCenter_AMS IN (SELECT Cost_Center FROM M_Cost_Center_List WHERE GroupSection = (SELECT TOP 1 s.GroupSection FROM M_Cost_Center_List s WHERE s.Cost_Center = ML.Section))
					
					) AS SkillCount,
					ISNULL((SELECT Type
					 FROM M_Schedule 
					 WHERE ID = ISNULL((SELECT TOP 1 s.Schedule FROM AF_ChangeSchedulefiling s
						 WHERE s.EmployeeNo = a.EmpNo
						 AND GETDATE() BETWEEN s.DateFrom AND s.DateTo
						 AND s.Status = s.StatusMax
						 ORDER BY ID DESC),(SELECT TOP 1 ScheduleID
						 FROM M_Employee_Master_List_Schedule 
						 WHERE EmployeeNo = a.EmpNo 
						 AND ScheduleID IS NOT NULL
						 AND EffectivityDate <= GETDATE()
						 ORDER BY ID DESC))),'') AS ScheduleName
			INTO #tabl2_1
			FROM #tabl2 a
			ORDER BY OrderPrio, ModifiedStatus,Company,Family_Name

			SELECT CASE WHEN (@PageCount) = 0 THEN ROW_NUMBER() OVER(ORDER BY (select 0)) ELSE ROW_NUMBER() OVER(ORDER BY (select 0))+ (@RowCount) * (@PageCount) END AS Rownum,
				   *,
				   ISNULL(RFID,'') AS MainRFID
			FROM #tabl2_1
			--WHERE EmpNo = 'BIPH2016-01587'
			ORDER BY OrderPrio,EmpNo, ModifiedStatus,Company,Family_Name
			--WHERE ModifiedStatus = 'ACTIVE'
			--AND EmpNo = 'BIPH2020-05243'
			
		END




END















