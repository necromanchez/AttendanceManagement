USE [Brother_AMSDB]
GO
/****** Object:  StoredProcedure [dbo].[TT_EmployeeTaps]    Script Date: 11/23/2020 9:25:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Chester R.
-- Create date: 06-08-2020
-- Description:	GET Current Time
-- =============================================

ALTER PROCEDURE [dbo].[TT_EmployeeTaps] 
--DECLARE
	@SectionGroup NVARCHAR(MAX) = 'BPS',
	@Datechosen DATETIME = '2020-11-01',
	@DatechosenEnd DATETIME = '2020-11-23 23:59:59',
	@Agency NVARCHAR(50) = '',
	@Searchvalue NVARCHAR(50) = '',
	@PageCount INT = 0,
	@RowCount INT = 10,
	@TotalCount INT OUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	IF OBJECT_ID('tempdb..#Taps') IS NOT NULL
	DROP TABLE #Taps;

	SELECT TT.*
		 , ISNULL(MEL.First_Name,'') + ' ' + ISNULL(MEL.Family_Name,'') AS EmployeeName
		 , MC.GroupSection AS SectionGroup
		 , MEL.EmpNo AS EmployeeNo
		 --, (SELECT TOP 1 GroupSection FROM M_Cost_Center_List WHERE Cost_Center = MEL.CostCode) AS SectionGroup
	INTO #Taps
	FROM T_TimeTap TT
	LEFT JOIN M_Employee_Master_List MEL
	ON TT.EmpNo = MEL.EmpNo
	LEFT JOIN M_Cost_Center_List MC
	ON MEL.CostCode = MC.Cost_Center
    WHERE Employee_RFID IS NOT NULL
	AND MC.Cost_Center IN (SELECT s.Cost_Center FROM M_Cost_Center_List s WHERE s.GroupSection = @SectionGroup OR @SectionGroup = '' OR @SectionGroup IS NULL)
	AND (TT.Tap BETWEEN @Datechosen AND @DatechosenEnd)
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
	AND (  MEL.EmpNo LIKE '%'+@Searchvalue+'%' 
			OR MEL.First_Name LIKE '%'+@Searchvalue+'%' 
			OR MEL.Family_Name LIKE '%'+@Searchvalue+'%'
			)
	ORDER BY ID
	OFFSET @PageCount * (@RowCount) ROWS
	FETCH NEXT @RowCount ROWS ONLY	
	
	--SELECT * FROM #Taps


	SELECT  Employee_RFID,
			Type,
			CONVERT(VARCHAR(10), Tap, 23) AS TapDate,
			CONVERT(VARCHAR(8), Tap, 108) AS TapTime,
			Taptype,
			EmployeeNo,
			EmployeeName,
			SectionGroup		
	FROM #Taps
	WHERE SectionGroup = @SectionGroup OR @SectionGroup = null OR @SectionGroup = ''
	ORDER BY TapDate,EmployeeNo, TapTime


	SET @TotalCount = (SELECT COUNT(*) FROM #Taps)
END






