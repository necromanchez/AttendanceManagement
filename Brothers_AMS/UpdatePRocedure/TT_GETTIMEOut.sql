USE [Brother_AMSDB]
GO
/****** Object:  StoredProcedure [dbo].[TT_GETTIME]    Script Date: 2020-12-11 3:14:44 pm ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Chester R.
-- Create date: 06-08-2020
-- Description:	GET Current Time
-- =============================================

ALTER PROCEDURE [dbo].[TT_GETTIMEOut] 
--DECLARE
	@Shift NVARCHAR(20) = 'Night'
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET FMTONLY OFF;
	DECLARE @timenow DATETIME, @TotalCount BIT

	SET @timenow = GETDATE()
    

	IF @Shift LIKE 'Day%' OR @Shift IS NULL OR @Shift = ''
	BEGIN
		SET @TotalCount = CASE WHEN convert(char(5), @timenow, 108) < '12:00:00 PM' THEN 1 ELSE 0 END
	END
	IF @Shift LIKE 'Night%'
	BEGIN
		SET @TotalCount = CASE WHEN convert(char(5), @timenow, 108) < '12:00:00 AM' THEN 1 ELSE 0 END
	END
	
	SELECT 'Result' AS Result,@TotalCount AS Resultanswer

END





