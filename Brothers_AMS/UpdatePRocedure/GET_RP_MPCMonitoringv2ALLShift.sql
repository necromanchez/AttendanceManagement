USE [Brother_AMSDB]
GO
/****** Object:  StoredProcedure [dbo].[GET_RP_MPCMonitoringv2ALLShift]    Script Date: 2020-12-07 9:28:10 am ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




ALTER PROCEDURE [dbo].[GET_RP_MPCMonitoringv2ALLShift]
	--DECLARE
	@DateFrom DATETIME = '11/01/2020',
	@DateTo DATETIME = '12/03/2020',
	@Shift NVARCHAR(20) = '',
	@Line BIGINT = '0',
	@Process BIGINT = '0',
	@SectionGroup NVARCHAR(50) = '',
	@PageCount INT = 0,
	@RowCount INT = 800,
	@Searchvalue NVARCHAR(50) = 'BIPH2012-00018',
	@Certified NVARCHAR(50) = '',
	@TotalCount INT OUT
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;
	SET ARITHABORT ON;
	IF OBJECT_ID('tempdb..#tmpBus') IS NOT NULL
		DROP TABLE #tmpBus;
	IF OBJECT_ID('tempdb..#checkCer') IS NOT NULL
		DROP TABLE #checkCer;
	IF OBJECT_ID('tempdb..#checkCer2') IS NOT NULL
		DROP TABLE #checkCer2;
	IF OBJECT_ID('tempdb..#OutputTable') IS NOT NULL
		DROP TABLE #OutputTable;
		IF OBJECT_ID('tempdb..#FinalTable') IS NOT NULL
		DROP TABLE #FinalTable;

IF OBJECT_ID('tempdb..#ShiftGroup') IS NOT NULL
		DROP TABLE #ShiftGroup;

SELECT ID
INTO #ShiftGroup
FROM M_Schedule MS
WHERE MS.Type LIKE @Shift+'%'

SET @DateTo = @DateTo + ' 23:59:59'


CREATE TABLE #tmpBus(
	RFID NVARCHAR(MAX),
	TimeIn DATETIME,
	TimeOut DATETIME,
	ScheduleID INT,
	ChangeShift NVARCHAR(MAX),
	OrigShift INT,
	LineID INT,
	ProcessID INT,
	EmpNo NVARCHAR(MAX),
	EmployeeName NVARCHAR(MAX),
	Date_Hired NVARCHAR(MAX),
	Status NVARCHAR(MAX),
	CostCenter_AMS NVARCHAR(MAX),
	TTID BIGINT
)


IF @Shift = 'Night'
BEGIN

INSERT INTO #tmpBus(RFID,TimeIn,TimeOut,ScheduleID,ChangeShift,OrigShift,LineID,ProcessID,EmpNo,EmployeeName,Date_Hired,Status,CostCenter_AMS,TTID)
	SELECT	  TT.Employee_RFID AS RFID
		, CASE WHEN (TT.DTR_RefNo IS NOT NULL) THEN TT.DTR_TimeIn ELSE TT.TimeIn END AS TimeIn
		, CASE WHEN (TT.DTR_RefNo IS NOT NULL) THEN TT.DTR_TimeOut ELSE TT.TimeOut END AS TimeOut
		, CASE WHEN (TT.CSRef_No IS NULL) THEN TT.ScheduleID ELSE TT.CS_ScheduleID END AS ScheduleID
		, CASE WHEN ((TT.ScheduleID = TT.CS_ScheduleID AND TT.CSRef_No IS NOT NULL) OR TT.CSRef_No IS NULL) THEN 'Black' ELSE TT.CSRef_No END AS ChangeShift
		, TT.ScheduleID AS OrigShift
		, TT.LineID
		, TT.ProcessID
		, MEL.EmpNo
		, MEL.Family_Name + ' ' + MEL.First_Name AS EmployeeName
		, MEL.Date_Hired
		, p.Status
		,(SELECT TOP 1 CostCenter_AMS FROM M_Employee_CostCenter WHERE EmployNo = MEL.EmpNo AND UpdateDate_AMS <= ISNULL(TT.TimeIn,TT.TimeOut) ORDER BY UpdateDate_AMS DESC) AS CostCenter_AMS
		, TT.ID
FROM T_TimeInOut TT
JOIN M_Employee_Master_List MEL
ON TT.EmpNo = MEL.EmpNo
INNER JOIN (SELECT RANK() OVER (PARTITION BY EmployNo ORDER BY ID DESC) r, *
             FROM M_Employee_Status) p
ON (TT.EmpNo = p.EmployNo)

WHERE p.r = 1
AND convert(char(5), TT.TimeIn, 108) > '12:00:00 PM'
AND (ISNULL(TimeIn,TimeOut) <= MEL.Date_Resigned OR MEL.Date_Resigned IS NULL)
AND ISNULL(TimeIn,TimeOut) BETWEEN @DateFrom AND @DateTo
AND  ((SELECT top 1 MEC.Status FROM M_Employee_Status MEC WHERE MEC.EmployNo = MEL.EmpNo ORDER BY MEC.ID DESC) = 'ACTIVE' OR ((SELECT top 1 MEC.UpdateDate FROM M_Employee_Status MEC WHERE MEC.EmployNo = MEL.EmpNo AND Status = 'ACTIVE' ORDER BY MEC.ID DESC) <= ISNULL(TimeIn,TimeOut))	AND (SELECT top 1 MEC.UpdateDate FROM M_Employee_Status MEC WHERE MEC.EmployNo = MEL.EmpNo AND Status <> 'ACTIVE' ORDER BY MEC.ID DESC) >= ISNULL(TimeIn,TimeOut))
AND (SELECT TOP 1 MEC.CostCenter_AMS FROM M_Employee_CostCenter MEC WHERE MEC.EmployNo = MEL.EmpNo AND MEC.UpdateDate_AMS <= ISNULL(TimeIn,TimeOut) ORDER BY UpdateDate_AMS DESC) IN (SELECT Cost_Center
																																													 FROM M_Cost_Center_List
																																													 WHERE GroupSection = @SectionGroup
																																													 OR @SectionGroup= ''
																																													 OR @SectionGroup IS NULL)
				
AND Employee_RFID IS NOT NULL
AND (  MEL.EmpNo LIKE '%'+@Searchvalue+'%' 
	OR MEL.First_Name LIKE '%'+@Searchvalue+'%' 

	OR MEL.Family_Name LIKE '%'+@Searchvalue+'%'
	)

GROUP BY  TT.Employee_RFID
		, TT.TimeIn
		, TT.TimeOut
		, TT.ScheduleID
		, TT.CSRef_No
		, TT.DTR_RefNo
		, TT.DTR_TimeIn
		, TT.DTR_TimeOut
		, TT.CS_ScheduleID
		, TT.LineID
		, TT.ProcessID
		, MEL.EmpNo
		, MEL.Family_Name
		, MEL.First_Name
		, MEL.Date_Hired
		, MEL.Status
		--, MEC.CostCenter_AMS
		, TT.ProcessID
		, p.Status
		, TT.ID

END


ELSE
BEGIN
INSERT INTO #tmpBus(RFID,TimeIn,TimeOut,ScheduleID,ChangeShift,OrigShift,LineID,ProcessID,EmpNo,EmployeeName,Date_Hired,Status,CostCenter_AMS,TTID)
	SELECT	  TT.Employee_RFID AS RFID
		, CASE WHEN (TT.DTR_RefNo IS NOT NULL) THEN TT.DTR_TimeIn ELSE TT.TimeIn END AS TimeIn
		, CASE WHEN (TT.DTR_RefNo IS NOT NULL) THEN TT.DTR_TimeOut ELSE TT.TimeOut END AS TimeOut
		, CASE WHEN (TT.CSRef_No IS NULL) THEN TT.ScheduleID ELSE TT.CS_ScheduleID END AS ScheduleID
		, CASE WHEN ((TT.ScheduleID = TT.CS_ScheduleID AND TT.CSRef_No IS NOT NULL) OR TT.CSRef_No IS NULL) THEN 'Black' ELSE TT.CSRef_No END AS ChangeShift
		, TT.ScheduleID AS OrigShift
		, TT.LineID
		, TT.ProcessID
		, MEL.EmpNo
		, MEL.Family_Name + ' ' + MEL.First_Name AS EmployeeName
		, MEL.Date_Hired
		, p.Status
		,(SELECT TOP 1 CostCenter_AMS FROM M_Employee_CostCenter WHERE EmployNo = MEL.EmpNo AND UpdateDate_AMS <= ISNULL(TT.TimeIn,TT.TimeOut) ORDER BY UpdateDate_AMS DESC) AS CostCenter_AMS
		,TT.ID
FROM T_TimeInOut TT
JOIN M_Employee_Master_List MEL
ON TT.EmpNo = MEL.EmpNo
INNER JOIN (SELECT RANK() OVER (PARTITION BY EmployNo ORDER BY ID DESC) r, *
             FROM M_Employee_Status) p
ON (TT.EmpNo = p.EmployNo)

WHERE p.r = 1
AND ISNULL(TimeIn,TimeOut) BETWEEN @DateFrom AND @DateTo
AND  ((SELECT top 1 MEC.Status FROM M_Employee_Status MEC WHERE MEC.EmployNo = MEL.EmpNo ORDER BY MEC.ID DESC) = 'ACTIVE' OR ((SELECT top 1 MEC.UpdateDate FROM M_Employee_Status MEC WHERE MEC.EmployNo = MEL.EmpNo AND Status = 'ACTIVE' ORDER BY MEC.ID DESC) <= ISNULL(TimeIn,TimeOut))	AND (SELECT top 1 MEC.UpdateDate FROM M_Employee_Status MEC WHERE MEC.EmployNo = MEL.EmpNo AND Status <> 'ACTIVE' ORDER BY MEC.ID DESC) >= ISNULL(TimeIn,TimeOut))
AND (SELECT TOP 1 MEC.CostCenter_AMS FROM M_Employee_CostCenter MEC WHERE MEC.EmployNo = MEL.EmpNo AND MEC.UpdateDate_AMS <= ISNULL(TimeIn,TimeOut) ORDER BY UpdateDate_AMS DESC) IN (SELECT Cost_Center
																																													 FROM M_Cost_Center_List
																																													 WHERE GroupSection = @SectionGroup
																																													 OR @SectionGroup= ''
																																													 OR @SectionGroup IS NULL)

AND Employee_RFID IS NOT NULL
AND (  MEL.EmpNo LIKE '%'+@Searchvalue+'%' 
	OR MEL.First_Name LIKE '%'+@Searchvalue+'%' 

	OR MEL.Family_Name LIKE '%'+@Searchvalue+'%'
	)

GROUP BY  TT.Employee_RFID
		, TT.TimeIn
		, TT.TimeOut
		, TT.ScheduleID
		, TT.CSRef_No
		, TT.DTR_RefNo
		, TT.DTR_TimeIn
		, TT.DTR_TimeOut
		, TT.CS_ScheduleID
		, TT.LineID
		, TT.ProcessID
		, MEL.EmpNo
		, MEL.Family_Name
		, MEL.First_Name
		, MEL.Date_Hired
		, MEL.Status
		--, MEC.CostCenter_AMS
		, TT.ProcessID
		, p.Status
		,TT.ID



END

SELECT CAST(CONVERT(Char(16), ISNULL(TB.TimeIn,TB.TimeOut) ,20) AS Date) AS InDate,
		ISNULL(CONVERT(VARCHAR(5),TB.TimeIn,108),'NoIn') AS TimeIn,
		CAST(CONVERT(Char(16), ISNULL(TB.TimeOut,TB.TimeOut) ,20) AS Date) AS InDateOut,
		ISNULL(CONVERT(VARCHAR(5),TB.TimeOut,108),'NoOut') AS TimeOut,
		ISNULL(MSS.Type + ' ('+ MSS.Timein + '-' + MSS.TimeOut +  ')','') AS Shift,
		TB.ChangeShift,
		ISNULL((SELECT TOP 1 aa.Type + ' (' + aa.TimeIn + ' - ' + aa.TimeOut +')'
				FROM M_Schedule aa
				WHERE ID = TB.OrigShift),'') AS OrigShift,
		ISNULL(ML.Line, 'No Line') AS Line,
		ISNULL(MS.Skill,'No Process') AS Skill,
		TB.EmpNo,
		TB.EmployeeName,
		TB.Date_Hired,
		CASE WHEN (MES.CreateDate IS NULL) THEN NULL ELSE MES.CreateDate END AS DateCertified,
		TB.Status,
		TB.TTID
INTO #checkCer
FROM #tmpBus TB
LEFT JOIN M_LineTeam ML
ON TB.LineID = ML.ID
LEFT JOIN M_Employee_Skills MES
ON MES.EmpNo = TB.EmpNo AND MES.LineID = TB.LineID AND MES.SkillID = TB.ProcessID
LEFT JOIN M_Skills MS
ON MS.ID = TB.ProcessID
LEFT JOIN M_Schedule MSS
ON MSS.ID = TB.ScheduleID
WHERE TB.ScheduleID IN (SELECT ID FROM #ShiftGroup)
AND (@Line = 0 OR @Line IS NULL OR @Line = ML.ID) 
AND (@Process = 0 OR @Process IS NULL OR @Process = MS.ID) 
--AND (@SectionGroup = '' OR @SectionGroup IS NULL OR TB.CostCenter_AMS IN (SELECT Cost_Center FROM M_Cost_Center_List WHERE GroupSection = @SectionGroup)) 


SELECT  a.*,
		CASE WHEN (DateCertified IS NOT NULL) THEN 'Green' ELSE 'Red' END AS 'Certified',
		(SELECT COUNT(EmpNo)
		 FROM #checkCer
		 WHERE InDate = a.InDate
		 AND EmpNo = a.EmpNo) AS CountTransfer
INTO #checkCer2
FROM #checkCer a

SELECT *, (CASE WHEN(CountTransfer = 1 AND Certified = 'Green') THEN 'Black'
			    WHEN(CountTransfer = 1 AND Certified = 'Red') THEN 'Red'
				WHEN(CountTransfer > 1 AND Certified = 'Red') THEN 'Red'
				ELSE 'Green' END
		   ) AS TrueColor
INTO #OutputTable
FROM #checkCer2
oRDER BY EmpNo, InDate,TimeIn
--WHERE EmployeeName = 'Jovelyn Caraan'
--ORDER BY TTID





SELECT CASE WHEN EmpNo LIKE 'BIPH%' THEN 1 ELSE 2 END AS Prio,
	   *
INTO #FinalTable
FROM #OutputTable
WHERE (
				@Certified IS NULL OR
				@Certified = '' OR
				TrueColor = CASE WHEN @Certified = 'Certified'
								 THEN 'Green'
								 ELSE 'Red'
							END
				OR
				TrueColor = CASE WHEN @Certified = 'Certified'
								 THEN 'Black'
								 ELSE 'Red'
							END
				
		)
ORDER BY CASE WHEN EmpNo LIKE 'BIPH%' THEN 1 ELSE 2 END, EmpNo			
OFFSET @PageCount * (@RowCount) ROWS
FETCH NEXT @RowCount ROWS ONLY	

IF OBJECT_ID('tempdb..#TABLEFinal') IS NOT NULL
		DROP TABLE #TABLEFinal;

SELECT Prio,
		CASE WHEN TimeIn = 'NoIn' THEN '-' ELSE convert(varchar, InDate, 23) END AS InDate,
		TimeIn,
		CASE WHEN  convert(varchar, InDateOut, 23) = '1900-01-01' THEN '-' ELSE ISNULL(convert(varchar, InDateOut, 23),'-') END AS InDateOut,
		CASE WHEN  convert(varchar, InDateOut, 23) = '1900-01-01' THEN 'NoOut' ELSE TimeOut END AS TimeOut,
		Shift,
		ChangeShift,
		OrigShift,
		Line,
		Skill,
		EmpNo,
		EmployeeName,
		convert(varchar, Date_Hired, 23) AS Date_Hired,
		convert(varchar, DateCertified, 23) AS DateCertified,
		Status,
		TTID,
		Certified,
		CountTransfer,
		TrueColor
INTO #TABLEFinal
FROM #FinalTable
ORDER BY Prio, EmpNo, ISNULL(InDate,InDateOut) DESC, TTID ASC 


SELECT CASE WHEN (@PageCount) = 0 THEN ROW_NUMBER() OVER(ORDER BY Prio, EmpNo, CASE WHEN(InDate) = '-' THEN InDateOut ELSE InDate END DESC ,TTID ASC) ELSE ROW_NUMBER() OVER(ORDER BY (select 0))+ (@RowCount) * (@PageCount) END AS Rownum,
*
FROM #TABLEFinal
ORDER BY Prio, EmpNo, CASE WHEN(InDate) = '-' THEN InDateOut ELSE InDate END DESC ,TTID ASC



SET @TotalCount = (

SELECT COUNT(*) FROM #tmpBus

)


END





















