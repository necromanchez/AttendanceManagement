USE [Brother_AMSDB]
GO
/****** Object:  StoredProcedure [dbo].[GET_AF_CSRequest]    Script Date: 2021-01-18 10:03:19 am ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Chester R.
-- Create date: 10-10-2019
-- Description:	GET Change Schedule Approver
-- =============================================
ALTER PROCEDURE [dbo].[GET_AF_CSRequest]
--DECLARE 
	@SectionSuperGroup NVARCHAR(50) = '',
	@DateFrom DATETIME = '2021-01-01',
	@DateTo DATETIME = '2021-01-30'
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET FMTONLY OFF

	IF OBJECT_ID('tempdb..#CStable') IS NOT NULL
		DROP TABLE #CStable;

	SELECT  CS.CS_RefNo,
		(SELECT TOP 1 GroupSection FROM M_Cost_Center_List WHERE Cost_Center = CS.Section) AS Section,
		CONVERT(VARCHAR(20), CS.CreateDate, 23) AS CreateDate,
		CS.Status,
		CS.StatusMax,
		--(SELECT TOP 1 TimeIn + ' - ' + TimeOut FROM M_Schedule MS
		--	 WHERE MS.ID = CS.Schedule) AS Schedule,
		(SELECT TOP 1 (SELECT m.FirstName + ' ' + m.LastName FROM M_Users m WHERE m.UserName = MSA.EmployeeNo) + ' ' + CONVERT(VARCHAR(20), MSA.ApprovedDate, 120) FROM M_Section_ApproverStatus MSA WHERE MSA.Approved = 1 AND MSA.RefNo = CS.CS_RefNo AND MSA.Position = 'Supervisor') AS ApprovedSupervisor,
		(SELECT TOP 1 (SELECT m.FirstName + ' ' + m.LastName FROM M_Users m WHERE m.UserName = MSA.EmployeeNo) + ' ' + CONVERT(VARCHAR(20), MSA.ApprovedDate, 120) FROM M_Section_ApproverStatus MSA WHERE MSA.Approved = 1 AND MSA.RefNo = CS.CS_RefNo AND MSA.Position = 'Manager') AS ApprovedManager
	INTO #CStable
	FROM AF_ChangeSchedulefiling CS
	WHERE EmployeeNo <> '' AND EmployeeNo IS NOT NULL

	SELECT  ROW_NUMBER() OVER(ORDER BY (select 0)) AS Rownum,
			CS_RefNo,
			Section,
			CreateDate,
			Status,
			StatusMax,
			'Approved By: ' + ApprovedSupervisor AS ApprovedSupervisor,
			CASE WHEN Status < 2 THEN '' ELSE  ApprovedManager END AS ApprovedManager
	FROM #CStable
	WHERE Status < StatusMax AND Status >= 0
	AND (Section = @SectionSuperGroup OR @SectionSuperGroup = '' OR @SectionSuperGroup IS NULL)
	AND CreateDate BETWEEN @DateFrom AND @DateTo
	GROUP BY CS_RefNo,
		   Section,
		   CreateDate,
		   Status,
		   StatusMax,
		  -- Schedule,
		   ApprovedSupervisor,
		   ApprovedManager
	ORDER BY CS_RefNo DESC


    

END









