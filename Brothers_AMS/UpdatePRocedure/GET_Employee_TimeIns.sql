USE [Brother_AMSDB]
GO
/****** Object:  StoredProcedure [dbo].[GET_Employee_TimeIns]    Script Date: 2021-01-15 5:39:33 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Chester
-- Create date: 10-08-2019
-- Description:	Get Employee Time Ins
-- =============================================
ALTER PROCEDURE [dbo].[GET_Employee_TimeIns]
	--DECLARE
	@RFID NVARCHAR(MAX),-- = '11380'
	@PageCount INT,-- = 0
	@RowCount INT = 10
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	DECLARE @CurrentEmpNo NVARCHAR(50)

	SET @CurrentEmpNo = (SELECT TOP 1 EmpNo FROM M_Employee_Master_List WHERE RFID = @RFID AND Status = 'ACTIVE');


	SELECT  TT.Employee_RFID,
			TT.TimeIn,
			TT.TimeOut,
			ISNULL(LT.Line,'No Line') as Line,
			ISNULL(MS.Skill,'No Process') as Skill
	FROM T_TimeInOut TT
	LEFT JOIN M_Skills MS
	ON MS.ID = TT.ProcessID
	LEFT JOIN M_LineTeam LT
	ON LT.ID = TT.LineID
	--WHERE (CAST(TT.TimeIn AS DATE) = CAST(GETDATE() AS DATE)
	--OR CAST(TT.TimeOut AS DATE) = CAST(GETDATE() AS DATE))
	--AND TT.Employee_RFID = @RFID
	WHERE TT.EmpNo = @CurrentEmpNo
	ORDER BY TT.ID DESC			
	OFFSET @PageCount * (@RowCount) ROWS
	FETCH NEXT @RowCount ROWS ONLY	
END










