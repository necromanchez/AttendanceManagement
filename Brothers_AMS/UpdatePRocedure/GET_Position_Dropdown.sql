CREATE PROCEDURE [dbo].[GET_Position_Dropdown]
--DECLARE
	@SectionSuperGroup NVARCHAR(50) = ''
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

	SET NOCOUNT ON;
	SET FMTONLY OFF;
	SET ARITHABORT ON;


	SELECT 'Pos' AS Pos,Position
	FROM M_Employee_Master_List
	WHERE Position IS NOT NULL
	GROUP BY Position
	ORDER BY Position

END