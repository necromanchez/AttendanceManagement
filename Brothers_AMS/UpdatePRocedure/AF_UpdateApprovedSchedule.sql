USE [Brother_AMSDB]
GO
/****** Object:  StoredProcedure [dbo].[AF_UpdateApprovedSchedule]    Script Date: 2021-01-06 8:45:15 am ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ================================================
-- Author:		Chester R.
-- Create date: 12-05-2019
-- Description:	Update Schedule if Approved
-- ================================================
ALTER PROCEDURE [dbo].[AF_UpdateApprovedSchedule]
	
	@RefNoCS NVARCHAR(100) = 'CS'
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	
	DECLARE @RefNo NVARCHAR(50),
			@Schedule BIGINT,
			@EmployNo NVARCHAR(50),
			@DateFrom DATETIME,
			@DateTo DATETIME,
			@RFID NVARCHAR(50)

	--FOR BEGIN
DECLARE MY_CURSOR CURSOR 
  LOCAL STATIC READ_ONLY FORWARD_ONLY
FOR 
SELECT CS_RefNo, Schedule, EmployeeNo, DateFrom, DateTo
FROM AF_ChangeSchedulefiling
WHERE Status = StatusMax
AND CS_RefNo = @RefNoCS
--AND CS_RefNo NOT IN (SELECT DISTINCT CSRef_No FROM T_TimeInOut WHERE CSRef_No IS NOT NULL)
--AND GETDATE() BETWEEN DateFrom AND DateTo  + ' 23:59:59'
--AND EmployeeAccept IS NOT NULL


	OPEN MY_CURSOR
	FETCH  FROM MY_CURSOR INTO @RefNo, @Schedule, @EmployNo, @DateFrom, @DateTo
WHILE @@FETCH_STATUS = 0
	BEGIN 
		SET @EmployNo = (SELECT TOP 1 EmpNo FROM M_Employee_Master_List WHERE EmpNo = @EmployNo)
		SELECT  @RefNo, @Schedule, @EmployNo, @DateFrom, @DateTo, @RFID

		UPDATE T_TimeInOut SET  CS_ScheduleID = @Schedule, CSRef_No = @RefNo
		--SELECT * FROM T_TimeInOut
		WHERE EmpNo = @EmployNo
		AND (TimeIn BETWEEN @DateFrom AND @DateTo
			 OR TimeOut BETWEEN @DateFrom AND @DateTo)
		--AND CS_ScheduleID IS NULL
			
		SET @EmployNo = ''

	FETCH NEXT FROM MY_CURSOR INTO @RefNo, @Schedule, @EmployNo, @DateFrom, @DateTo

	END
CLOSE MY_CURSOR
DEALLOCATE MY_CURSOR
	--END BEGIN



   
END




