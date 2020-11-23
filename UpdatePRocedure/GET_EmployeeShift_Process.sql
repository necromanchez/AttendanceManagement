USE [Brother_AMSDB]
GO
/****** Object:  StoredProcedure [dbo].[GET_EmployeeShift_Process]    Script Date: 2020-11-22 8:13:37 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Chester
-- Create date: 10-07-2019
-- Description:	Get Employee details
-- =============================================
ALTER PROCEDURE [dbo].[GET_EmployeeShift_Process]
--DECLARE
	@SectionSuperGroup NVARCHAR(50) =  'Shipping'
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

	SET NOCOUNT ON;
	SET FMTONLY OFF;
	SET ARITHABORT ON;

	IF OBJECT_ID('tempdb..#tabl2Count') IS NOT NULL
	DROP TABLE #tabl2Count
	IF OBJECT_ID('tempdb..#tabl2_1Count') IS NOT NULL
	DROP TABLE #tabl2_1Count
	IF OBJECT_ID('tempdb..#TempTable') IS NOT NULL
	DROP TABLE #TempTable
	IF OBJECT_ID('tempdb..#TempTable_Schedule') IS NOT NULL
	DROP TABLE #TempTable_Schedule
	IF OBJECT_ID('tempdb..#TempTable_Process') IS NOT NULL
	DROP TABLE #TempTable_Process
	IF OBJECT_ID('tempdb..#TempTable_AMSActive') IS NOT NULL
	DROP TABLE #TempTable_AMSActive
	IF OBJECT_ID('tempdb..#TempTable_HRActive') IS NOT NULL
	DROP TABLE #TempTable_HRActive
	IF OBJECT_ID('tempdb..#TempTable_AMSInActive') IS NOT NULL
	DROP TABLE #TempTable_AMSInActive
	IF OBJECT_ID('tempdb..#TempTable_HRInActive') IS NOT NULL
	DROP TABLE #TempTable_HRInActive

	BEGIN
		
		BEGIN
		
		SELECT MEL.*,
			(SELECT top 1 Status FROM M_Employee_Status MEC WHERE MEC.EmployNo = MEL.EmpNo ORDER BY MEC.ID DESC) AS AMSStatus,
			MEL.Status AS HRStatus,
			ISNULL((SELECT top 1 CostCenter_AMS FROM M_Employee_CostCenter MEC WHERE MEC.EmployNo = MEL.EmpNo ORDER BY MEC.ID DESC), MEL.CostCode) AS CostCenter_AMS,
			
			(SELECT TOP 1 TimeIn + ' - ' + TimeOut 
			 FROM M_Schedule 
			 WHERE ID = ISNULL((SELECT TOP 1 s.Schedule FROM AF_ChangeSchedulefiling s
						 WHERE s.EmployeeNo = MEL.EmpNo
						 AND GETDATE() BETWEEN s.DateFrom AND s.DateTo
						 AND s.Status = s.StatusMax),(SELECT TOP 1 ScheduleID
						 FROM M_Employee_Master_List_Schedule 
						 WHERE EmployeeNo = MEL.EmpNo 
						 AND ScheduleID IS NOT NULL
						 AND EffectivityDate <= GETDATE()
						 ORDER BY ID DESC))
			AND IsDeleted <> 1) AS Schedule,
			CASE WHEN  (Company = 'BIPH' AND Status = 'ACTIVE')  THEN 1 ELSE 2 END AS OrderPrio
			INTO #tabl2Count
			FROM M_Employee_Master_List MEL
			WHERE MEL.EmpNo <> '&nbsp;' AND MEL.Status IS NOT NULL
			AND (SELECT TOP 1 MEC.CostCenter_AMS FROM M_Employee_CostCenter MEC WHERE MEC.EmployNo = MEL.EmpNo AND MEC.UpdateDate_AMS <= GETDATE() ORDER BY UpdateDate_AMS DESC) IN (SELECT Cost_Center
																																	 FROM M_Cost_Center_List
																																	 WHERE GroupSection = @SectionSuperGroup
																																	 OR @SectionSuperGroup = ''
																																	 OR @SectionSuperGroup IS NULL)


	--WHERE Me.EmpNo = 'PKIMT2019-09786'

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
						 AND s.Status = s.StatusMax),(SELECT TOP 1 ScheduleID
						 FROM M_Employee_Master_List_Schedule 
						 WHERE EmployeeNo = a.EmpNo 
						 AND ScheduleID IS NOT NULL
						 AND EffectivityDate <= GETDATE()
						 ORDER BY ID DESC))),'') AS ScheduleName
			INTO #tabl2_1Count
			FROM #tabl2Count a
			WHERE EmpNo <> '&nbsp;' AND Status IS NOT NULL
			ORDER BY OrderPrio, Status,Company,Family_Name

			--SELECT COUNT(*) FROM #tabl2_1Count WHERE Status = 'Active'
			--SELECT COUNT(*) FROM #tabl2_1Count WHERE Status <> 'Active'
			--SELECT * FROM #tabl2_1Count

			--SELECT COUNT(*) FROM #tabl2_1Count 
			----WHERE EmpNo <> '&nbsp;' AND Status IS NOT NULL
			--WHERE AMSStatus = 'ACTIVE'

			SELECT ROW_NUMBER() OVER(ORDER BY (select 0)) AS Rownum,*
			INTO #TempTable
			FROM #tabl2_1Count
			ORDER BY OrderPrio, Status,Company,Family_Name
		


		SELECT COUNT(*) AS NoSchedule
		INTO #TempTable_Schedule
		FROM #TempTable
		WHERE Schedule IS NULL
		AND AMSStatus = 'ACTIVE'

	
		SELECT COUNT(*) AS NoProcess
		INTO #TempTable_Process
		FROM #TempTable
		WHERE SkillCount = 0
		AND AMSStatus = 'ACTIVE'
		
		--SELECT * FROM #TempTable WHERE AMSStatus = 'ACTIVE'

		SELECT COUNT(*) AS AMSActive
		INTO #TempTable_AMSActive
		FROM #TempTable
		WHERE AMSStatus = 'ACTIVE'

		SELECT COUNT(*) AS HRActive
		INTO #TempTable_HRActive
		FROM #TempTable
		WHERE HRStatus = 'ACTIVE'

		SELECT COUNT(*) AS AMSInActive
		INTO #TempTable_AMSInActive
		FROM #TempTable
		WHERE AMSStatus <> 'ACTIVE'

		SELECT COUNT(*) AS HRInActive
		INTO #TempTable_HRInActive
		FROM #TempTable
		WHERE HRStatus <> 'ACTIVE'

		SELECT @SectionSuperGroup AS Section,* 
		FROM #TempTable_Schedule a
		CROSS JOIN #TempTable_Process b
		CROSS JOIN #TempTable_AMSActive c
		CROSS JOIN #TempTable_HRActive d
		CROSS JOIN #TempTable_AMSInActive e
		CROSS JOIN #TempTable_HRInActive f

		END
	END
	

END













