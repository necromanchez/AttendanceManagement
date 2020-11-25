USE [Brother_AMSDB]
GO
/****** Object:  StoredProcedure [dbo].[GET_AF_CSSummary]    Script Date: 11/25/2020 11:38:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Chester R.
-- Create date: 10-16-2019
-- Description:	GET CS Summary
-- =============================================
-- [dbo].[GET_AF_CSSummary] 'CS-Production Engineering_20191127','Production Engineering','1990-01-01','2019-11-29',''
ALTER PROCEDURE [dbo].[GET_AF_CSSummary] 
	--DECLARE
	@CSRefno NVARCHAR(50) = '',
	@Section NVARCHAR(MAX) ='',
	@DateFrom DATETIME = '2020-11-01',
	@DateTo DATETIME = '2020-11-29',
	@Status NVARCHAR(10) = ''
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET FMTONLY OFF

	DECLARE @ExtendStatus INT;

	IF @Status >= 2
	BEGIN 
	SET @Status = 2
	END

	IF @Status = -1
	BEGIN
		SET @ExtendStatus = -2
	END

   IF OBJECT_ID('tempdb..#CStableSUMMARY') IS NOT NULL
		DROP TABLE #CStableSUMMARY;

	SELECT  CS.CS_RefNo,
		(SELECT TOP 1 GroupSection FROM M_Cost_Center_List WHERE Cost_Center = CS.Section) AS Section,
		CONVERT(VARCHAR(20), CS.CreateDate, 23) AS CreateDate,
		CS.Status,
		CS.StatusMax,
		(SELECT TOP 1 (SELECT m.FirstName + ' ' + m.LastName FROM M_Users m WHERE m.UserName = MSA.EmployeeNo) + ' ' + CONVERT(VARCHAR(20), ISNULL(MSA.ApprovedDate,MSA.UpdateDate), 120) FROM M_Section_ApproverStatus MSA WHERE MSA.Approved = 1 AND MSA.RefNo = CS.CS_RefNo AND MSA.Position = 'Supervisor') AS ApprovedSupervisor,
		(SELECT TOP 1 (SELECT m.FirstName + ' ' + m.LastName FROM M_Users m WHERE m.UserName = MSA.EmployeeNo) + ' ' + CONVERT(VARCHAR(20), ISNULL(MSA.ApprovedDate,MSA.UpdateDate), 120) FROM M_Section_ApproverStatus MSA WHERE MSA.Approved = 1 AND MSA.RefNo = CS.CS_RefNo AND MSA.Position = 'Manager') AS ApprovedManager,
		(SELECT TOP 1 (SELECT TOP 1 m.FirstName + ' ' + m.LastName FROM M_Users m WHERE m.UserName = CS.CreateID)) AS Requestor,
		CONVERT(VARCHAR(20), CS.UpdateDate, 23) AS UpdateDate
	INTO #CStableSUMMARY
	FROM AF_ChangeSchedulefiling CS


	SELECT  ROW_NUMBER() OVER(ORDER BY (select 0)) AS Rownum,
			CS_RefNo,
			Section,
			CreateDate,
			Status,
			StatusMax,
			CASE WHEN Status = - 2
				 THEN  'Approved by ' + ApprovedSupervisor
				 WHEN Status = -1
				 THEN 'Rejected by ' + ApprovedSupervisor
				 WHEN Status = -10
				 THEN 'Cancelled by ' + Requestor + ' ' + UpdateDate
				 ELSE 'Approved by ' + ApprovedSupervisor
				 END AS ApprovedSupervisor,
			CASE WHEN Status = - 2
				 THEN  'Rejected by ' + ApprovedManager
				 WHEN Status = -1
				 THEN ''
				 WHEN Status = -10
				 THEN 'Cancelled by ' + Requestor + ' ' + UpdateDate
				 WHEN Status = 1
				 THEN ''
				 ELSE 'Approved by ' + ApprovedManager
				 END AS ApprovedManager
	FROM #CStableSUMMARY
	WHERE CreateDate BETWEEN @DateFrom AND @DateTo
	AND (@Section = '' OR @Section IS NULL OR Section = @Section)
	AND (@Status = '' OR @Status IS NULL OR Status = @Status OR Status = @ExtendStatus)
	AND (@CSRefno = '' OR @CSRefno IS NULL OR CS_RefNo = @CSRefno)
	
	GROUP BY CS_RefNo,
		   Section,
		   CreateDate,
		   UpdateDate,
		   Status,
		   StatusMax,
		  -- Schedule,
		   ApprovedSupervisor,
		   ApprovedManager,
		   Requestor
	ORDER BY CS_RefNo DESC


END










