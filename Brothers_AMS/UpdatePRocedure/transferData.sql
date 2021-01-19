/****** Script for SelectTopNRows command from SSMS  ******/


INSERT INTO [Brother_AMSDB].[dbo].[T_TimeInOut] (Employee_RFID,ScheduleID,TimeIn,TimeOut,LineID,ProcessID,DTR_TimeIn,DTR_TimeOut,DTR_RefNo,CSRef_No,CS_ScheduleID,EmployeeRemover,EmpNo)
SELECT a.[Employee_RFID]
      ,a.[ScheduleID]
      ,a.[TimeIn]
      ,a.[TimeOut]
      ,a.[LineID]
      ,a.[ProcessID]
      ,a.[DTR_TimeIn]
      ,a.[DTR_TimeOut]
      ,a.[DTR_RefNo]
      ,a.[CSRef_No]
      ,a.[CS_ScheduleID]
      ,a.[EmployeeRemover]
	  ,(SELECT TOP 1 MEL.EmpNo FROM [Brother_AMSDB_Test].[dbo].M_Employee_Master_List MEL WHERE MEL.RFID = a.Employee_RFID)
FROM [Brother_AMSDB_Test].[dbo].[T_TimeInOut] a
WHERE YEAR(ISNULL(TimeIn,TimeOut)) = 2021