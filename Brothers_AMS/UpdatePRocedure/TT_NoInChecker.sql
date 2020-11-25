USE [Brother_AMSDB]
GO
/****** Object:  StoredProcedure [dbo].[AF_EmailCSRequest]    Script Date: 2020-11-24 4:23:34 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Chester R.
-- Create date: 10-31-2019
-- Description:	Email Approvers OVERTIME
-- =============================================

ALTER PROCEDURE [dbo].[TT_NoInChecker] 
--DECLARE
@EmpNo NVARCHAR(MAX) = 'BIPH2013-00166',
@TimeOut DATETIME = GETDATE
AS
BEGIN


SELECT 'Result' AS Result, COUNT(*) AS Value
FROM T_TimeInOut
WHERE EmpNo = @EmpNo
--AND TimeIn IS NULL
AND CONVERT(VARCHAR(10),TimeIn,120) = CONVERT(VARCHAR(10),GETDATE(),120) 
AND TimeOut IS NULL


END








