using Brothers_WMS.Controllers;
using Brothers_WMS.Models;
using Newtonsoft.Json;
using OfficeOpenXml;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.Common;
using System.Data.Entity;
using System.Data.OleDb;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using static Brothers_WMS.Controllers.SessionExpire;

namespace Brothers_WMS.Areas.Summary.Controllers
{
    [SessionExpire]

    public class WorkTimeSummaryController : Controller
    {
        // GET: Summary/WorkTimeSummary
        Brothers_AMSDBEntities db = new Brothers_AMSDBEntities();
        M_Users user = (M_Users)System.Web.HttpContext.Current.Session["user"];
        WTGlobal wt = new WTGlobal();
        public ActionResult WorkTimeSummary()
        {
            return View();
        }

        private List<GET_RP_AttendanceMonitoring_Result> test(int Month, int Year, string Section, DataTable dt)       
        {
            List<GET_RP_AttendanceMonitoring_Result> convertedList = new List<GET_RP_AttendanceMonitoring_Result>();

            try
            {
                convertedList = (from rw in dt.AsEnumerable()
                                 select new GET_RP_AttendanceMonitoring_Result()
                                 {
                                     Rownum = Convert.ToInt32(rw["Rownum"]),
                                     //RFID = Convert.ToString(rw["RFID"]),
                                     EmpNo = Convert.ToString(rw["EmpNo"]),
                                     EmployeeName = Convert.ToString(rw["EmployeeName"]),
                                     Position = Convert.ToString(rw["Position"]),
                                     Schedule = Convert.ToString(rw["Schedule"]),
                                     CostCode = Convert.ToString(rw["CostCode"]),
                                     //Status = Convert.ToString(rw["Status"]),
                                     C1 = Convert.ToString(rw["1"]),
                                     C2 = Convert.ToString(rw["2"]),
                                     C3 = Convert.ToString(rw["3"]),
                                     C4 = Convert.ToString(rw["4"]),
                                     C5 = Convert.ToString(rw["5"]),
                                     C6 = Convert.ToString(rw["6"]),
                                     C7 = Convert.ToString(rw["7"]),
                                     C8 = Convert.ToString(rw["8"]),
                                     C9 = Convert.ToString(rw["9"]),
                                     C10 = Convert.ToString(rw["10"]),
                                     C11 = Convert.ToString(rw["11"]),
                                     C12 = Convert.ToString(rw["12"]),
                                     C13 = Convert.ToString(rw["13"]),
                                     C14 = Convert.ToString(rw["14"]),
                                     C15 = Convert.ToString(rw["15"]),
                                     C16 = Convert.ToString(rw["16"]),
                                     C17 = Convert.ToString(rw["17"]),
                                     C18 = Convert.ToString(rw["18"]),
                                     C19 = Convert.ToString(rw["19"]),
                                     C20 = Convert.ToString(rw["20"]),
                                     C21 = Convert.ToString(rw["21"]),
                                     C22 = Convert.ToString(rw["22"]),
                                     C23 = Convert.ToString(rw["23"]),
                                     C24 = Convert.ToString(rw["24"]),
                                     C25 = Convert.ToString(rw["25"]),
                                     C26 = Convert.ToString(rw["26"]),
                                     C27 = Convert.ToString(rw["27"]),
                                     C28 = Convert.ToString(rw["28"]),
                                     C29 = Convert.ToString(rw["29"]),
                                     C30 = Convert.ToString(rw["30"]),
                                     C31 = Convert.ToString(rw["31"]),

                                 }).ToList();
            }
            catch(Exception err)
            {
                try
                {
                    convertedList = (from rw in dt.AsEnumerable()
                                     select new GET_RP_AttendanceMonitoring_Result()
                                     {
                                         Rownum = Convert.ToInt32(rw["Rownum"]),
                                         //RFID = Convert.ToString(rw["RFID"]),
                                         EmpNo = Convert.ToString(rw["EmpNo"]),
                                         EmployeeName = Convert.ToString(rw["EmployeeName"]),
                                         Position = Convert.ToString(rw["Position"]),
                                         Schedule = Convert.ToString(rw["Schedule"]),
                                         CostCode = Convert.ToString(rw["CostCode"]),
                                         //Status = Convert.ToString(rw["Status"]),
                                         C1 = Convert.ToString(rw["1"]),
                                         C2 = Convert.ToString(rw["2"]),
                                         C3 = Convert.ToString(rw["3"]),
                                         C4 = Convert.ToString(rw["4"]),
                                         C5 = Convert.ToString(rw["5"]),
                                         C6 = Convert.ToString(rw["6"]),
                                         C7 = Convert.ToString(rw["7"]),
                                         C8 = Convert.ToString(rw["8"]),
                                         C9 = Convert.ToString(rw["9"]),
                                         C10 = Convert.ToString(rw["10"]),
                                         C11 = Convert.ToString(rw["11"]),
                                         C12 = Convert.ToString(rw["12"]),
                                         C13 = Convert.ToString(rw["13"]),
                                         C14 = Convert.ToString(rw["14"]),
                                         C15 = Convert.ToString(rw["15"]),
                                         C16 = Convert.ToString(rw["16"]),
                                         C17 = Convert.ToString(rw["17"]),
                                         C18 = Convert.ToString(rw["18"]),
                                         C19 = Convert.ToString(rw["19"]),
                                         C20 = Convert.ToString(rw["20"]),
                                         C21 = Convert.ToString(rw["21"]),
                                         C22 = Convert.ToString(rw["22"]),
                                         C23 = Convert.ToString(rw["23"]),
                                         C24 = Convert.ToString(rw["24"]),
                                         C25 = Convert.ToString(rw["25"]),
                                         C26 = Convert.ToString(rw["26"]),
                                         C27 = Convert.ToString(rw["27"]),
                                         C28 = Convert.ToString(rw["28"]),
                                         C29 = Convert.ToString(rw["29"]),
                                         C30 = Convert.ToString(rw["30"]),

                                     }).ToList();
                }
                catch(Exception err2) {
                    convertedList = (from rw in dt.AsEnumerable()
                                     select new GET_RP_AttendanceMonitoring_Result()
                                     {
                                         Rownum = Convert.ToInt32(rw["Rownum"]),
                                         //RFID = Convert.ToString(rw["RFID"]),
                                         EmpNo = Convert.ToString(rw["EmpNo"]),
                                         EmployeeName = Convert.ToString(rw["EmployeeName"]),
                                         Position = Convert.ToString(rw["Position"]),
                                         Schedule = Convert.ToString(rw["Schedule"]),
                                         CostCode = Convert.ToString(rw["CostCode"]),
                                         //Status = Convert.ToString(rw["Status"]),
                                         C1 = Convert.ToString(rw["1"]),
                                         C2 = Convert.ToString(rw["2"]),
                                         C3 = Convert.ToString(rw["3"]),
                                         C4 = Convert.ToString(rw["4"]),
                                         C5 = Convert.ToString(rw["5"]),
                                         C6 = Convert.ToString(rw["6"]),
                                         C7 = Convert.ToString(rw["7"]),
                                         C8 = Convert.ToString(rw["8"]),
                                         C9 = Convert.ToString(rw["9"]),
                                         C10 = Convert.ToString(rw["10"]),
                                         C11 = Convert.ToString(rw["11"]),
                                         C12 = Convert.ToString(rw["12"]),
                                         C13 = Convert.ToString(rw["13"]),
                                         C14 = Convert.ToString(rw["14"]),
                                         C15 = Convert.ToString(rw["15"]),
                                         C16 = Convert.ToString(rw["16"]),
                                         C17 = Convert.ToString(rw["17"]),
                                         C18 = Convert.ToString(rw["18"]),
                                         C19 = Convert.ToString(rw["19"]),
                                         C20 = Convert.ToString(rw["20"]),
                                         C21 = Convert.ToString(rw["21"]),
                                         C22 = Convert.ToString(rw["22"]),
                                         C23 = Convert.ToString(rw["23"]),
                                         C24 = Convert.ToString(rw["24"]),
                                         C25 = Convert.ToString(rw["25"]),
                                         C26 = Convert.ToString(rw["26"]),
                                         C27 = Convert.ToString(rw["27"]),
                                         C28 = Convert.ToString(rw["28"]),
                                         C29 = Convert.ToString(rw["29"]),
                                     }).ToList();
                }
            }
            List<GET_RP_AttendanceMonitoring_Result> adjustedNW = new List<GET_RP_AttendanceMonitoring_Result>();
            foreach (GET_RP_AttendanceMonitoring_Result row in convertedList)
            {
                double Pcount = 0;
                double Bcount = 0;
                double Ycount = 0;
                int MLcount = 0;
                int WKWeekend = 0;
               
                if (!Dayname(1, Month, Year) && row.C1 == "AB")
                {
                    DateTime day = new DateTime(Year, Month, 1);
                    if(day <= DateTime.Now)
                    {
                        row.C1 = "NW";
                    }
                    else
                    {
                        row.C1 = "-";
                    }
                }
                else if (row.C1 == "HD")
                {
                    Ycount = Ycount + 0.5;
                }
                else if (row.C1 == "ML")
                {
                    MLcount++;
                }
                else if (row.C1 == "AB" || row.C1.Contains("L"))
                {
                    Bcount++;
                }
                else if (row.C1.Contains("P"))
                {
                    if (!Dayname(1, Month, Year))
                    {
                        WKWeekend++;
                    }
                    Pcount++;
                }

                if (!Dayname(2, Month, Year) && row.C2 == "AB")
                {
                    DateTime day = new DateTime(Year, Month, 2);
                    if (day <= DateTime.Now)
                    {
                        row.C2 = "NW";
                    }
                    else
                    {
                        row.C2 = "-";
                    }
                }
               
                else if (row.C2 == "HD")
                {
                    Ycount = Ycount + 0.5;
                }
                else if (row.C2 == "ML")
                {
                    MLcount++;
                }
                else if (row.C2 == "AB" || row.C2.Contains("L"))
                {
                    Bcount++;
                }
                else if (row.C2.Contains("P"))
                {
                    if (!Dayname(2, Month, Year))
                    {
                        WKWeekend++;
                    }
                    Pcount++;
                }

                if (!Dayname(3, Month, Year) && row.C3 == "AB")
                {
                    DateTime day = new DateTime(Year, Month, 3);
                    if (day <= DateTime.Now)
                    {
                        row.C3 = "NW";
                    }
                    else
                    {
                        row.C3 = "-";
                    }
                }
                
                else if (row.C3 == "HD")
                {
                    Ycount = Ycount + 0.5;
                }
                else if (row.C3 == "ML")
                {
                    MLcount++;
                }
                else if (row.C3 == "AB" || row.C3.Contains("L"))
                {
                    Bcount++;
                }
                else if (row.C3.Contains("P"))
                {
                    if (!Dayname(3, Month, Year))
                    {
                        WKWeekend++;
                    }
                    Pcount++;
                }
                if (!Dayname(4, Month, Year) && row.C4 == "AB")
                {
                    DateTime day = new DateTime(Year, Month, 4);
                    if (day <= DateTime.Now)
                    {
                        row.C4 = "NW";
                    }
                    else
                    {
                        row.C4 = "-";
                    }
                }
                
                else if (row.C4 == "HD")
                {
                    Ycount = Ycount + 0.5;
                }
                else if (row.C4 == "ML")
                {
                    MLcount++;
                }
                else if (row.C4 == "AB" || row.C4.Contains("L"))
                {
                    Bcount++;
                }
                else if (row.C4.Contains("P"))
                {
                    if (!Dayname(4, Month, Year))
                    {
                        WKWeekend++;
                    }
                    Pcount++;
                }
                if (!Dayname(5, Month, Year) && row.C5 == "AB")
                {
                    DateTime day = new DateTime(Year, Month, 5);
                    if (day <= DateTime.Now)
                    {
                        row.C5 = "NW";
                    }
                    else
                    {
                        row.C5 = "-";
                    }
                }
                
                else if (row.C5 == "HD")
                {
                    Ycount = Ycount + 0.5;
                }
                else if (row.C5 == "ML")
                {
                    MLcount++;
                }
                else if (row.C5 == "AB" || row.C5.Contains("L"))
                {
                    Bcount++;
                }
                else if (row.C5.Contains("P"))
                {
                    if (!Dayname(5, Month, Year))
                    {
                        WKWeekend++;
                    }
                    Pcount++;
                }
                if (!Dayname(6, Month, Year) && row.C6 == "AB")
                {
                    DateTime day = new DateTime(Year, Month, 6);
                    if (day <= DateTime.Now)
                    {
                        row.C6 = "NW";
                    }
                    else
                    {
                        row.C6 = "-";
                    }
                }
                
                else if (row.C6 == "HD")
                {
                    Ycount = Ycount + 0.5;
                }
                else if (row.C6 == "ML")
                {
                    MLcount++;
                }
                else if (row.C6 == "AB" || row.C6.Contains("L"))
                {
                    Bcount++;
                }
                else if (row.C6.Contains("P"))
                {
                    if (!Dayname(6, Month, Year))
                    {
                        WKWeekend++;
                    }
                    Pcount++;
                }
                if (!Dayname(7, Month, Year) && row.C7 == "AB")
                {
                    DateTime day = new DateTime(Year, Month, 7);
                    if (day <= DateTime.Now)
                    {
                        row.C7 = "NW";
                    }
                    else
                    {
                        row.C7 = "-";
                    }
                }
                
                else if (row.C7 == "HD")
                {
                    Ycount = Ycount + 0.5;
                }
                else if (row.C7 == "ML")
                {
                    MLcount++;
                }
                else if (row.C7 == "AB" || row.C7.Contains("L"))
                {
                    Bcount++;
                }
                else if (row.C7.Contains("P"))
                {
                    if (!Dayname(7, Month, Year))
                    {
                        WKWeekend++;
                    }
                    Pcount++;
                }
                if (!Dayname(8, Month, Year) && row.C8 == "AB")
                {
                    DateTime day = new DateTime(Year, Month, 8);
                    if (day <= DateTime.Now)
                    {
                        row.C8 = "NW";
                    }
                    else
                    {
                        row.C8 = "-";
                    }
                }
                
                else if (row.C8 == "HD")
                {
                    Ycount = Ycount + 0.5;
                }
                else if (row.C8 == "ML")
                {
                    MLcount++;
                }
                else if (row.C8 == "AB" || row.C8.Contains("L"))
                {
                    Bcount++;
                }
                else if (row.C8.Contains("P"))
                {
                    if (!Dayname(8, Month, Year))
                    {
                        WKWeekend++;
                    }
                    Pcount++;
                }
                if (!Dayname(9, Month, Year) && row.C9 == "AB")
                {
                    DateTime day = new DateTime(Year, Month, 9);
                    if (day <= DateTime.Now)
                    {
                        row.C9 = "NW";
                    }
                    else
                    {
                        row.C9 = "-";
                    }
                }
               
                else if (row.C9 == "HD")
                {
                    Ycount = Ycount + 0.5;
                }
                else if (row.C9 == "ML")
                {
                    MLcount++;
                }
                else if (row.C9 == "AB" || row.C9.Contains("L"))
                {
                    Bcount++;
                }
                else if (row.C9.Contains("P"))
                {
                    if (!Dayname(9, Month, Year))
                    {
                        WKWeekend++;
                    }
                    Pcount++;
                }
                if (!Dayname(10, Month, Year) && row.C10 == "AB")
                {
                    DateTime day = new DateTime(Year, Month, 10);
                    if (day <= DateTime.Now)
                    {
                        row.C10 = "NW";
                    }
                    else
                    {
                        row.C10 = "-";
                    }
                }
                
                else if (row.C10 == "HD")
                {
                    Ycount = Ycount + 0.5;
                }
                else if (row.C10 == "ML")
                {
                    MLcount++;
                }
                else if (row.C10 == "AB" || row.C10.Contains("L"))
                {
                    Bcount++;
                }
                else if (row.C10.Contains("P"))
                {
                    if (!Dayname(10, Month, Year))
                    {
                        WKWeekend++;
                    }
                    Pcount++;
                }
                if (!Dayname(11, Month, Year) && row.C11 == "AB")
                {
                    DateTime day = new DateTime(Year, Month, 11);
                    if (day <= DateTime.Now)
                    {
                        row.C11 = "NW";
                    }
                    else
                    {
                        row.C11 = "-";
                    }
                }
               
                else if (row.C11 == "HD")
                {
                    Ycount = Ycount + 0.5;
                }
                else if (row.C11 == "ML")
                {
                    MLcount++;
                }
                else if (row.C11 == "AB" || row.C11.Contains("L"))
                {
                    Bcount++;
                }
                else if (row.C11.Contains("P"))
                {
                    if (!Dayname(11, Month, Year))
                    {
                        WKWeekend++;
                    }
                    Pcount++;
                }
                if (!Dayname(12, Month, Year) && row.C12 == "AB")
                {
                    DateTime day = new DateTime(Year, Month, 12);
                    if (day <= DateTime.Now)
                    {
                        row.C12 = "NW";
                    }
                    else
                    {
                        row.C12 = "-";
                    }
                }
                
                else if (row.C12 == "HD")
                {
                    Ycount = Ycount + 0.5;
                }
                else if (row.C12 == "ML")
                {
                    MLcount++;
                }
                else if (row.C12 == "AB" || row.C12.Contains("L"))
                {
                    Bcount++;
                }
                else if (row.C12.Contains("P"))
                {
                    if (!Dayname(12, Month, Year))
                    {
                        WKWeekend++;
                    }
                    Pcount++;
                }
                if (!Dayname(13, Month, Year) && row.C13 == "AB")
                {
                    DateTime day = new DateTime(Year, Month, 13);
                    if (day <= DateTime.Now)
                    {
                        row.C13 = "NW";
                    }
                    else
                    {
                        row.C13 = "-";
                    }
                }
                
                else if (row.C13 == "HD")
                {
                    Ycount = Ycount + 0.5;
                }
                else if (row.C13 == "ML")
                {
                    MLcount++;
                }
                else if (row.C13 == "AB" || row.C13.Contains("L"))
                { 
                    Bcount++;
                }
                else if (row.C13.Contains("P"))
                {
                    if (!Dayname(13, Month, Year))
                    {
                        WKWeekend++;
                    }
                    Pcount++;
                }
                if (!Dayname(14, Month, Year) && row.C14 == "AB")
                {
                    DateTime day = new DateTime(Year, Month, 14);
                    if (day <= DateTime.Now)
                    {
                        row.C14 = "NW";
                    }
                    else
                    {
                        row.C14 = "-";
                    }
                }
               
                else if (row.C14 == "HD")
                {
                    Ycount = Ycount + 0.5;
                }
                else if (row.C14 == "ML")
                {
                    MLcount++;
                }
                else if (row.C14 == "AB" || row.C14.Contains("L"))
                {
                    Bcount++;
                }
                else if (row.C13.Contains("P"))
                {
                    if (!Dayname(14, Month, Year))
                    {
                        WKWeekend++;
                    }
                    Pcount++;
                }
                if (!Dayname(15, Month, Year) && row.C15 == "AB")
                {
                    DateTime day = new DateTime(Year, Month, 15);
                    if (day <= DateTime.Now)
                    {
                        row.C15 = "NW";
                    }
                    else
                    {
                        row.C15 = "-";
                    }
                }
               
                else if (row.C15 == "HD")
                {
                    Ycount = Ycount + 0.5;
                }
                else if (row.C15 == "ML")
                {
                    MLcount++;
                }
                else if (row.C15 == "AB" || row.C15.Contains("L"))
                {
                    Bcount++;
                }
                else if (row.C15.Contains("P"))
                {
                    if (!Dayname(15, Month, Year))
                    {
                        WKWeekend++;
                    }
                    Pcount++;
                }
                if (!Dayname(16, Month, Year) && row.C16 == "AB")
                {
                    DateTime day = new DateTime(Year, Month, 16);
                    if (day <= DateTime.Now)
                    {
                        row.C16 = "NW";
                    }
                    else
                    {
                        row.C16 = "-";
                    }
                }
                
                else if (row.C16 == "HD")
                {
                    Ycount = Ycount + 0.5;
                }
                else if (row.C16 == "ML")
                {
                    MLcount++;
                }
                else if (row.C16 == "AB" || row.C16.Contains("L"))
                {
                    Bcount++;
                }
                else if (row.C16.Contains("P"))
                {
                    if (!Dayname(16, Month, Year))
                    {
                        WKWeekend++;
                    }
                    Pcount++;
                }
                if (!Dayname(17, Month, Year) && row.C17 == "AB")
                {
                    DateTime day = new DateTime(Year, Month, 17);
                    if (day <= DateTime.Now)
                    {
                        row.C17 = "NW";
                    }
                    else
                    {
                        row.C17 = "-";
                    }
                }
                
                else if (row.C17 == "HD")
                {
                    Ycount = Ycount + 0.5;
                }
                else if (row.C17 == "ML")
                {
                    MLcount++;
                }
                else if (row.C17 == "AB" || row.C17.Contains("L"))
                {
                    Bcount++;
                }
                else if (row.C17.Contains("P"))
                {
                    if (!Dayname(17, Month, Year))
                    {
                        WKWeekend++;
                    }
                    Pcount++;
                }
                if (!Dayname(18, Month, Year) && row.C18 == "AB")
                {
                    DateTime day = new DateTime(Year, Month, 18);
                    if (day <= DateTime.Now)
                    {
                        row.C18 = "NW";
                    }
                    else
                    {
                        row.C18 = "-";
                    }
                }
                
                else if (row.C18 == "HD")
                {
                    Ycount = Ycount + 0.5;
                }
                else if (row.C18 == "ML")
                {
                    MLcount++;
                }
                else if (row.C18 == "AB" || row.C18.Contains("L"))
                {
                    Bcount++;
                }
                else if (row.C18.Contains("P"))
                {
                    if (!Dayname(18, Month, Year))
                    {
                        WKWeekend++;
                    }
                    Pcount++;
                }
                if (!Dayname(19, Month, Year) && row.C19 == "AB")
                {
                    DateTime day = new DateTime(Year, Month, 19);
                    if (day <= DateTime.Now)
                    {
                        row.C19 = "NW";
                    }
                    else
                    {
                        row.C19 = "-";
                    }
                }
                
                else if (row.C19 == "HD")
                {
                    Ycount = Ycount + 0.5;
                }
                else if (row.C19 == "ML")
                {
                    MLcount++;
                }
                else if (row.C19 == "AB" || row.C19.Contains("L"))
                {
                    Bcount++;
                }
                else if (row.C19.Contains("P"))
                {
                    if (!Dayname(19, Month, Year))
                    {
                        WKWeekend++;
                    }
                    Pcount++;
                }
                if (!Dayname(20, Month, Year) && row.C20 == "AB")
                {
                    DateTime day = new DateTime(Year, Month, 20);
                    if (day <= DateTime.Now)
                    {
                        row.C20 = "NW";
                    }
                    else
                    {
                        row.C20 = "-";
                    }
                }
                
                else if (row.C20 == "HD")
                {
                    Ycount = Ycount + 0.5;
                }
                else if (row.C20 == "ML")
                {
                    MLcount++;
                }
                else if (row.C20 == "AB" || row.C20.Contains("L"))
                {
                    Bcount++;
                }
                else if (row.C20.Contains("P"))
                {
                    if (!Dayname(20, Month, Year))
                    {
                        WKWeekend++;
                    }
                    Pcount++;
                }
                if (!Dayname(21, Month, Year) && row.C21 == "AB")
                {
                    DateTime day = new DateTime(Year, Month, 21);
                    if (day <= DateTime.Now)
                    {
                        row.C21 = "NW";
                    }
                    else
                    {
                        row.C21 = "-";
                    }
                }
                
                else if (row.C21 == "HD")
                {
                    Ycount = Ycount + 0.5;
                }
                else if (row.C21 == "ML")
                {
                    MLcount++;
                }
                else if (row.C21 == "AB" || row.C21.Contains("L"))
                {
                    Bcount++;
                }
                else if (row.C21.Contains("P"))
                {
                    if (!Dayname(21, Month, Year))
                    {
                        WKWeekend++;
                    }
                    Pcount++;
                }
                if (!Dayname(22, Month, Year) && row.C22 == "AB")
                {
                    DateTime day = new DateTime(Year, Month, 22);
                    if (day <= DateTime.Now)
                    {
                        row.C22 = "NW";
                    }
                    else
                    {
                        row.C22 = "-";
                    }
                }
                
                else if (row.C22 == "HD")
                {
                    Ycount = Ycount + 0.5;
                }
                else if (row.C22 == "ML")
                {
                    MLcount++;
                }
                else if (row.C22 == "AB" || row.C22.Contains("L"))
                {
                    Bcount++;
                }
                else if (row.C22.Contains("P"))
                {
                    if (!Dayname(22, Month, Year))
                    {
                        WKWeekend++;
                    }
                    Pcount++;
                }
                if (!Dayname(23, Month, Year) && row.C23 == "AB")
                {
                    DateTime day = new DateTime(Year, Month, 23);
                    if (day <= DateTime.Now)
                    {
                        row.C23 = "NW";
                    }
                    else
                    {
                        row.C23 = "-";
                    }
                }
                
                else if (row.C23 == "HD")
                {
                    Ycount = Ycount + 0.5;
                }
                else if (row.C23 == "ML")
                {
                    MLcount++;
                }
                else if (row.C23 == "AB" || row.C23.Contains("L"))
                {
                    Bcount++;
                }
                else if (row.C23.Contains("P"))
                {
                    if (!Dayname(23, Month, Year))
                    {
                        WKWeekend++;
                    }
                    Pcount++;
                }
                if (!Dayname(24, Month, Year) && row.C24 == "AB")
                {
                    DateTime day = new DateTime(Year, Month, 24);
                    if (day <= DateTime.Now)
                    {
                        row.C24 = "NW";
                    }
                    else
                    {
                        row.C24 = "-";
                    }
                }
                
                else if (row.C24 == "HD")
                {
                    Ycount = Ycount + 0.5;
                }
                else if (row.C24 == "ML")
                {
                    MLcount++;
                }
                else if (row.C24 == "AB" || row.C24.Contains("L"))
                {
                    Bcount++;
                }
                else if (row.C24.Contains("P"))
                {
                    if (!Dayname(24, Month, Year))
                    {
                        WKWeekend++;
                    }
                    Pcount++;
                }
                if (!Dayname(25, Month, Year) && row.C25 == "AB")
                {
                    DateTime day = new DateTime(Year, Month, 25);
                    if (day <= DateTime.Now)
                    {
                        row.C25 = "NW";
                    }
                    else
                    {
                        row.C25 = "-";
                    }
                }
                
                else if (row.C25 == "HD")
                {
                    Ycount = Ycount + 0.5;
                }
                else if (row.C25 == "ML")
                {
                    MLcount++;
                }
                else if (row.C25 == "AB" || row.C25.Contains("L"))
                {
                    Bcount++;
                }
                else if (row.C25.Contains("P"))
                {
                    if (!Dayname(25, Month, Year))
                    {
                        WKWeekend++;
                    }
                    Pcount++;
                }
                if (!Dayname(26, Month, Year) && row.C26 == "AB")
                {
                    DateTime day = new DateTime(Year, Month, 26);
                    if (day <= DateTime.Now)
                    {
                        row.C26 = "NW";
                    }
                    else
                    {
                        row.C26 = "-";
                    }
                }
                
                else if (row.C26 == "HD")
                {
                    Ycount = Ycount + 0.5;
                }
                else if (row.C26 == "ML")
                {
                    MLcount++;
                }
                else if (row.C26 == "AB" || row.C26.Contains("L"))
                {
                    Bcount++;
                }
                else if (row.C26.Contains("P"))
                {
                    if (!Dayname(26, Month, Year))
                    {
                        WKWeekend++;
                    }
                    Pcount++;
                }
                if (!Dayname(27, Month, Year) && row.C27 == "AB")
                {
                    DateTime day = new DateTime(Year, Month, 27);
                    if (day <= DateTime.Now)
                    {
                        row.C27 = "NW";
                    }
                    else
                    {
                        row.C27 = "-";
                    }
                }
                
                else if (row.C27 == "HD")
                {
                    Ycount = Ycount + 0.5;
                }
                else if (row.C27 == "ML")
                {
                    MLcount++;
                }
                else if (row.C27 == "AB" || row.C27.Contains("L"))
                {
                    Bcount++;
                }
                else if (row.C27.Contains("P"))
                {
                    if (!Dayname(27, Month, Year))
                    {
                        WKWeekend++;
                    }
                    Pcount++;
                }
                if (!Dayname(28, Month, Year) && row.C28 == "AB")
                {
                    DateTime day = new DateTime(Year, Month, 28);
                    if (day <= DateTime.Now)
                    {
                        row.C28 = "NW";
                    }
                    else
                    {
                        row.C28 = "-";
                    }
                }
                
                else if (row.C28 == "HD")
                {
                    Ycount = Ycount + 0.5;
                }
                else if (row.C28 == "ML")
                {
                    MLcount++;
                }
                else if (row.C28 == "AB" || row.C28.Contains("L"))
                {
                    Bcount++;
                }
                else if (row.C28.Contains("P"))
                {
                    if (!Dayname(28, Month, Year))
                    {
                        WKWeekend++;
                    }
                    Pcount++;
                }
                if (!Dayname(29, Month, Year) && row.C29 == "AB")
                {
                    DateTime day = new DateTime(Year, Month, 29);
                    if (day <= DateTime.Now)
                    {
                        row.C29 = "NW";
                    }
                    else
                    {
                        row.C29 = "-";
                    }
                }
                
                else if (row.C29 == "HD")
                {
                    Ycount = Ycount + 0.5;
                }
                else if (row.C29 == "ML")
                {
                    MLcount++;
                }
                else if (row.C29 == "AB" || row.C29.Contains("L"))
                {
                    Bcount++;
                }
                else if (row.C29.Contains("P"))
                {
                    if (!Dayname(29, Month, Year))
                    {
                        WKWeekend++;
                    }
                    Pcount++;
                }

                if (row.C30 != null)
                {
                    if (!Dayname(30, Month, Year) && row.C30 == "AB")
                    {
                        DateTime day = new DateTime(Year, Month, 30);
                        if (day <= DateTime.Now)
                        {
                            row.C30 = "NW";
                        }
                        else
                        {
                            row.C30 = "-";
                        }
                    }
                   
                    else if (row.C30 == "HD")
                    {
                        Ycount = Ycount + 0.5;
                    }
                    else if (row.C30 == "ML")
                    {
                        MLcount++;
                    }
                    else if (row.C30 == "AB" || row.C30.Contains("L"))
                    {
                        Bcount++;
                    }
                    else if (row.C30.Contains("P"))
                    {
                        if (!Dayname(30, Month, Year))
                        {
                            WKWeekend++;
                        }
                        Pcount++;
                    }
                }

                if (row.C31 != null)
                {
                    if (!Dayname(31, Month, Year) && row.C31 == "AB")
                    {
                        DateTime day = new DateTime(Year, Month, 31);
                        if (day <= DateTime.Now)
                        {
                            row.C31 = "NW";
                        }
                        else
                        {
                            row.C31 = "-";
                        }
                    }
                   
                    else if (row.C31 == "HD")
                    {
                        Ycount = Ycount + 0.5;
                    }
                    else if (row.C31 == "ML")
                    {
                        MLcount++;
                    }
                    else if (row.C31 == "AB" || row.C31.Contains("L"))
                    {
                        Bcount++;
                    }
                    else if (row.C31.Contains("P"))
                    {
                        if (!Dayname(31, Month, Year))
                        {
                            WKWeekend++;
                        }
                        Pcount++;
                    }
                }
                row.Pcount = Pcount + Ycount;
                row.Bcount = Bcount;
                row.Ycount = Ycount;
                row.MLcount = MLcount;
                row.WD = BusinessDays(Month, 1, Year) + WKWeekend;
                adjustedNW.Add(row);

                
            }

            adjustedNW = adjustedNW.OrderBy(x => x.Rownum).ToList();

                return adjustedNW;
        }

        public ActionResult ExportHRFormat(int? Month, int? Year, string Section, string Agency,DateTime? DateFrom, DateTime? DateTo)
        {
            try
            {
                string templateFilename = "HRFormatAttendance_TimeInOut.xlsx";
                string dir = Path.GetTempPath();
                string datetimeToday = DateTime.Now.ToString("yyMMddhhmmss");
                string GroupSection = Section;

                string filename = string.Format("HRFormatAttendance_TimeInOut{0}_{1}.xlsx", datetimeToday, GroupSection);
                FileInfo newFile = new FileInfo(Path.Combine(dir, filename));
                string apptemplatePath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, @"TemplateFiles\ExportReports\", templateFilename);
                FileInfo templateFile = new FileInfo(apptemplatePath);

                using (ExcelPackage package = new ExcelPackage(newFile, templateFile))  //-- With template.
                {

                    List<GET_RP_AttendanceMonitoring_TimeINOUT_HRExport_D_Result> list = new List<GET_RP_AttendanceMonitoring_TimeINOUT_HRExport_D_Result>();
                    db.Database.CommandTimeout = 0;
                    list = db.GET_RP_AttendanceMonitoring_TimeINOUT_HRExport_D(Month,Year,Section, Agency, DateFrom, DateTo).ToList();
                    //list = list.Where(x => x.ModifiedStatus.ToLower() == "active").ToList();
                    ExcelWorksheet ExportData = package.Workbook.Worksheets["AMSSheet"];

                    int start = 2;
                    for (int i = 0; i < list.Count; i++)
                    {
                        ExportData.Cells["A" + start].Value = list[i].EmpNo;
                        ExportData.Cells["B" + start].Value = list[i].Date;
                        ExportData.Cells["C" + start].Value = list[i].LogType;
                        ExportData.Cells["D" + start].Value = list[i].TimeTap;
                        start++;
                    }
                    
                    return File(package.GetAsByteArray(), "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", filename);
                }
            }
            catch (Exception err)
            {
                Error_Logs error = new Error_Logs();
                error.PageModule = "Master - Employee";
                error.ErrorLog = err.Message;
                error.DateLog = DateTime.Now;
                error.Username = user.UserName;
                db.Error_Logs.Add(error);
                db.SaveChanges();
            }
            return Json(new { }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult WrongShift(int? Month, int? Year, string Section, string Agency, DateTime? DateFrom, DateTime? DateTo, string Shift)
        {
            try
            {
                string templateFilename = "WrongShift.xlsx";
                string dir = Path.GetTempPath();
                string datetimeToday = DateTime.Now.ToString("yyMMddhhmmss");
                string GroupSection = Section;

                string filename = string.Format("WrongShift{0}_{1}.xlsx", datetimeToday, GroupSection);
                FileInfo newFile = new FileInfo(Path.Combine(dir, filename));
                string apptemplatePath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, @"TemplateFiles\ExportReports\", templateFilename);
                FileInfo templateFile = new FileInfo(apptemplatePath);

                using (ExcelPackage package = new ExcelPackage(newFile, templateFile))  //-- With template.
                {

                    List<GET_RP_WrongShift_Result> list = new List<GET_RP_WrongShift_Result>();
                    db.Database.CommandTimeout = 0;

                    if (Shift == "Day" || Shift == "Night")
                    {
                        list = db.GET_RP_WrongShift(Month, Year, Section, Agency, DateFrom, DateTo, Shift).ToList();
                        //list = list.Where(x => x.ModifiedStatus.ToLower() == "active").ToList();
                        ExcelWorksheet ExportData = package.Workbook.Worksheets["AMSSheet"];

                        int start = 2;
                        for (int i = 0; i < list.Count; i++)
                        {
                            ExportData.Cells["A" + start].Value = list[i].EmpNo;
                            ExportData.Cells["B" + start].Value = list[i].EmployeeName;
                            ExportData.Cells["C" + start].Value = list[i].Date;
                            ExportData.Cells["D" + start].Value = list[i].TimeTap;
                            ExportData.Cells["E" + start].Value = list[i].Shifts;
                            ExportData.Cells["F" + start].Value = list[i].Section;
                            start++;
                        }
                    }
                    else
                    {
                        List<GET_RP_WrongShift_Result> listDay = new List<GET_RP_WrongShift_Result>();
                        List<GET_RP_WrongShift_Result> listNight = new List<GET_RP_WrongShift_Result>();
                        listDay = db.GET_RP_WrongShift(Month, Year, Section, Agency, DateFrom, DateTo, "Day").ToList();
                        listNight = db.GET_RP_WrongShift(Month, Year, Section, Agency, DateFrom, DateTo, "Night").ToList();

                        ExcelWorksheet ExportData = package.Workbook.Worksheets["AMSSheet"];

                        int start = 2;
                        for (int i = 0; i < listDay.Count; i++)
                        {
                            ExportData.Cells["A" + start].Value = listDay[i].EmpNo;
                            ExportData.Cells["B" + start].Value = listDay[i].EmployeeName;
                            ExportData.Cells["C" + start].Value = listDay[i].Date;
                            ExportData.Cells["D" + start].Value = listDay[i].TimeTap;
                            ExportData.Cells["E" + start].Value = listDay[i].Shifts;
                            ExportData.Cells["F" + start].Value = listDay[i].Section;
                            start++;
                        }
                        for (int i = 0; i < listNight.Count; i++)
                        {
                            ExportData.Cells["A" + start].Value = listNight[i].EmpNo;
                            ExportData.Cells["B" + start].Value = listNight[i].EmployeeName;
                            ExportData.Cells["C" + start].Value = listNight[i].Date;
                            ExportData.Cells["D" + start].Value = listNight[i].TimeTap;
                            ExportData.Cells["E" + start].Value = listNight[i].Shifts;
                            ExportData.Cells["F" + start].Value = listNight[i].Section;
                            start++;
                        }
                    }

                    return File(package.GetAsByteArray(), "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", filename);
                }
            }
            catch (Exception err)
            {
                Error_Logs error = new Error_Logs();
                error.PageModule = "Master - Employee";
                error.ErrorLog = err.Message;
                error.DateLog = DateTime.Now;
                error.Username = user.UserName;
                db.Error_Logs.Add(error);
                db.SaveChanges();
            }
            return Json(new { }, JsonRequestBehavior.AllowGet);
        }

        public WTGlobal GetHeaderVs2(List<GET_RP_AttendanceMonitoring_Result> list)
        {
            List<GET_RP_AttendanceMonitoring_Result> Dayshift = list.Where(x => x.Schedule.ToLower().Contains("day")).ToList();
            List<GET_RP_AttendanceMonitoring_Result> NightShift = list.Where(x => x.Schedule.ToLower().Contains("night")).ToList();
            List<string> LeaveList = new List<string>();
            //LeaveList.Add("ML");
            LeaveList.Add("SL");
            LeaveList.Add("VL");
            LeaveList.Add("EL");
            LeaveList.Add("AB");

            int peremployeeAttendance = 0;
            int peremployeeAttendance2 = 0;
            foreach (GET_RP_AttendanceMonitoring_Result day in Dayshift)
            {
                if(day.C1 == "NW")
                {
                    wt.NWCountDay++;
                }
                else if(day.C1 == "ML")
                {
                    wt.MLCountDay++;
                }
                else if (LeaveList.Contains(day.C1))
                {
                    wt.DayShiftCountnow++;
                    peremployeeAttendance++;
                }
                else if(day.C1 == "P(D)" || day.C1 == "P(N)")
                {
                    peremployeeAttendance++;
                }

                if (day.C2 == "NW")
                {
                    wt.NWCountDay++;
                }
                else if (day.C2 == "ML")
                {
                    wt.MLCountDay++;
                }
                else if (LeaveList.Contains(day.C2))
                {
                    wt.DayShiftCountnow++;
                    peremployeeAttendance++;
                }
                else if (day.C2 == "P(D)" || day.C2 == "P(N)")
                {
                    peremployeeAttendance++;
                }

                if (day.C3 == "NW")
                {
                    wt.NWCountDay++;
                }
                else if (day.C3 == "ML")
                {
                    wt.MLCountDay++;
                }
                else if (LeaveList.Contains(day.C3))
                {
                    wt.DayShiftCountnow++;
                    peremployeeAttendance++;
                }
                else if (day.C3 == "P(D)" || day.C3 == "P(N)")
                {
                    peremployeeAttendance++;
                }

                if (day.C4 == "NW")
                {
                    wt.NWCountDay++;
                }
                else if (day.C4 == "ML")
                {
                    wt.MLCountDay++;
                }
                else if (LeaveList.Contains(day.C4))
                {
                    wt.DayShiftCountnow++;
                    peremployeeAttendance++;
                }
                else if (day.C4 == "P(D)" || day.C4 == "P(N)")
                {
                    peremployeeAttendance++;
                }

                if (day.C5 == "NW")
                {
                    wt.NWCountDay++;
                }
                else if (day.C5 == "ML")
                {
                    wt.MLCountDay++;
                }
                else if (LeaveList.Contains(day.C5))
                {
                    wt.DayShiftCountnow++;
                    peremployeeAttendance++;
                }
                else if (day.C5 == "P(D)" || day.C5 == "P(N)")
                {
                    peremployeeAttendance++;
                }

                if (day.C6 == "NW")
                {
                    wt.NWCountDay++;
                }
                else if (day.C6 == "ML")
                {
                    wt.MLCountDay++;
                }
                else if (LeaveList.Contains(day.C6))
                {
                    wt.DayShiftCountnow++;
                    peremployeeAttendance++;
                }
                else if (day.C6 == "P(D)" || day.C6 == "P(N)")
                {
                    peremployeeAttendance++;
                }

                if (day.C7 == "NW")
                {
                    wt.NWCountDay++;
                }
                else if (day.C7 == "ML")
                {
                    wt.MLCountDay++;
                }
                else if (LeaveList.Contains(day.C7))
                {
                    wt.DayShiftCountnow++;
                    peremployeeAttendance++;
                }
                else if (day.C7 == "P(D)" || day.C7 == "P(N)")
                {
                    peremployeeAttendance++;
                }


                if (day.C8 == "NW")
                {
                    wt.NWCountDay++;
                }
                else if (day.C8 == "ML")
                {
                    wt.MLCountDay++;
                }
                else if (LeaveList.Contains(day.C8))
                {
                    wt.DayShiftCountnow++;
                    peremployeeAttendance++;
                }
                else if (day.C8 == "P(D)" || day.C8 == "P(N)")
                {
                    peremployeeAttendance++;
                }

                if (day.C9 == "NW")
                {
                    wt.NWCountDay++;
                }
                else if (day.C9 == "ML")
                {
                    wt.MLCountDay++;
                }
                else if (LeaveList.Contains(day.C9))
                {
                    wt.DayShiftCountnow++;
                    peremployeeAttendance++;
                }
                else if (day.C9 == "P(D)" || day.C9 == "P(N)")
                {
                    peremployeeAttendance++;
                }


                if (day.C10 == "NW")
                {
                    wt.NWCountDay++;
                }
                else if (day.C10 == "ML")
                {
                    wt.MLCountDay++;
                }
                else if (LeaveList.Contains(day.C10))
                {
                    wt.DayShiftCountnow++;
                    peremployeeAttendance++;
                }
                else if (day.C10 == "P(D)" || day.C10 == "P(N)")
                {
                    peremployeeAttendance++;
                }

                if (day.C11 == "NW")
                {
                    wt.NWCountDay++;
                }
                else if (day.C11 == "ML")
                {
                    wt.MLCountDay++;
                }
                else if (LeaveList.Contains(day.C11))
                {
                    wt.DayShiftCountnow++;
                    peremployeeAttendance++;
                }
                else if (day.C11 == "P(D)" || day.C11 == "P(N)")
                {
                    peremployeeAttendance++;
                }


                if (day.C12 == "NW")
                {
                    wt.NWCountDay++;
                }
                else if (day.C12 == "ML")
                {
                    wt.MLCountDay++;
                }
                else if (LeaveList.Contains(day.C12))
                {
                    wt.DayShiftCountnow++;
                    peremployeeAttendance++;
                }
                else if (day.C12 == "P(D)" || day.C12 == "P(N)")
                {
                    peremployeeAttendance++;
                }

                if (day.C13 == "NW")
                {
                    wt.NWCountDay++;
                }
                else if (day.C13 == "ML")
                {
                    wt.MLCountDay++;
                }
                else if (LeaveList.Contains(day.C13))
                {
                    wt.DayShiftCountnow++;
                    peremployeeAttendance++;
                }
                else if (day.C13 == "P(D)" || day.C13 == "P(N)")
                {
                    peremployeeAttendance++;
                }

                if (day.C14 == "NW")
                {
                    wt.NWCountDay++;
                }
                else if (day.C14 == "ML")
                {
                    wt.MLCountDay++;
                }
                else if (LeaveList.Contains(day.C14))
                {
                    wt.DayShiftCountnow++;
                    peremployeeAttendance++;
                }
                else if (day.C14 == "P(D)" || day.C14 == "P(N)")
                {
                    peremployeeAttendance++;
                }

                if (day.C15 == "NW")
                {
                    wt.NWCountDay++;
                }
                else if (day.C15 == "ML")
                {
                    wt.MLCountDay++;
                }
                else if (LeaveList.Contains(day.C15))
                {
                    wt.DayShiftCountnow++;
                    peremployeeAttendance++;
                }
                else if (day.C15 == "P(D)" || day.C15 == "P(N)")
                {
                    peremployeeAttendance++;
                }


                if (day.C16 == "NW")
                {
                    wt.NWCountDay++;
                }
                else if (day.C16 == "ML")
                {
                    wt.MLCountDay++;
                }
                else if (LeaveList.Contains(day.C16))
                {
                    wt.DayShiftCountnow++;
                    peremployeeAttendance++;
                }
                else if (day.C16 == "P(D)" || day.C16 == "P(N)")
                {
                    peremployeeAttendance++;
                }


                if (day.C17 == "NW")
                {
                    wt.NWCountDay++;
                }
                else if (day.C17 == "ML")
                {
                    wt.MLCountDay++;
                }
                else if (LeaveList.Contains(day.C17))
                {
                    wt.DayShiftCountnow++;
                    peremployeeAttendance++;
                }
                else if (day.C17 == "P(D)" || day.C17 == "P(N)")
                {
                    peremployeeAttendance++;
                }


                if (day.C18 == "NW")
                {
                    wt.NWCountDay++;
                }
                else if (day.C18 == "ML")
                {
                    wt.MLCountDay++;
                }
                else if (LeaveList.Contains(day.C18))
                {
                    wt.DayShiftCountnow++;
                    peremployeeAttendance++;
                }
                else if (day.C18 == "P(D)" || day.C18 == "P(N)")
                {
                    peremployeeAttendance++;
                }


                if (day.C19 == "NW")
                {
                    wt.NWCountDay++;
                }
                else if (day.C19 == "ML")
                {
                    wt.MLCountDay++;
                }
                else if (LeaveList.Contains(day.C19))
                {
                    wt.DayShiftCountnow++;
                    peremployeeAttendance++;
                }
                else if (day.C19 == "P(D)" || day.C19 == "P(N)")
                {
                    peremployeeAttendance++;
                }


                if (day.C20 == "NW")
                {
                    wt.NWCountDay++;
                }
                else if (day.C20 == "ML")
                {
                    wt.MLCountDay++;
                }
                else if (LeaveList.Contains(day.C20))
                {
                    wt.DayShiftCountnow++;
                    peremployeeAttendance++;
                }
                else if (day.C20 == "P(D)" || day.C20 == "P(N)")
                {
                    peremployeeAttendance++;
                }


                if (day.C21 == "NW")
                {
                    wt.NWCountDay++;
                }
                else if (day.C21 == "ML")
                {
                    wt.MLCountDay++;
                }
                else if (LeaveList.Contains(day.C21))
                {
                    wt.DayShiftCountnow++;
                    peremployeeAttendance++;
                }
                else if (day.C21 == "P(D)" || day.C21 == "P(N)")
                {
                    peremployeeAttendance++;
                }


                if (day.C22 == "NW")
                {
                    wt.NWCountDay++;
                }
                else if (day.C22 == "ML")
                {
                    wt.MLCountDay++;
                }
                else if (LeaveList.Contains(day.C22))
                {
                    wt.DayShiftCountnow++;
                    peremployeeAttendance++;
                }
                else if (day.C22 == "P(D)" || day.C22 == "P(N)")
                {
                    peremployeeAttendance++;
                }

                if (day.C23 == "NW")
                {
                    wt.NWCountDay++;
                }
                else if (day.C23 == "ML")
                {
                    wt.MLCountDay++;
                }
                else if (LeaveList.Contains(day.C23))
                {
                    wt.DayShiftCountnow++;
                    peremployeeAttendance++;
                }
                else if (day.C23 == "P(D)" || day.C23 == "P(N)")
                {
                    peremployeeAttendance++;
                }

                if (day.C24 == "NW")
                {
                    wt.NWCountDay++;
                }
                else if (day.C24 == "ML")
                {
                    wt.MLCountDay++;
                }
                else if (LeaveList.Contains(day.C24))
                {
                    wt.DayShiftCountnow++;
                    peremployeeAttendance++;
                }
                else if (day.C24 == "P(D)" || day.C24 == "P(N)")
                {
                    peremployeeAttendance++;
                }


                if (day.C25 == "NW")
                {
                    wt.NWCountDay++;
                }
                else if (day.C25 == "ML")
                {
                    wt.MLCountDay++;
                }
                else if (LeaveList.Contains(day.C25))
                {
                    wt.DayShiftCountnow++;
                    peremployeeAttendance++;
                }
                else if (day.C25 == "P(D)" || day.C25 == "P(N)")
                {
                    peremployeeAttendance++;
                }


                if (day.C26 == "NW")
                {
                    wt.NWCountDay++;
                }
                else if (day.C26 == "ML")
                {
                    wt.MLCountDay++;
                }
                else if (LeaveList.Contains(day.C26))
                {
                    wt.DayShiftCountnow++;
                    peremployeeAttendance++;
                }
                else if (day.C26 == "P(D)" || day.C26 == "P(N)")
                {
                    peremployeeAttendance++;
                }


                if (day.C27 == "NW")
                {
                    wt.NWCountDay++;
                }
                else if (day.C27 == "ML")
                {
                    wt.MLCountDay++;
                }
                else if (LeaveList.Contains(day.C27))
                {
                    wt.DayShiftCountnow++;
                    peremployeeAttendance++;
                }
                else if (day.C27 == "P(D)" || day.C27 == "P(N)")
                {
                    peremployeeAttendance++;
                }


                if (day.C28 == "NW")
                {
                    wt.NWCountDay++;
                }
                else if (day.C28 == "ML")
                {
                    wt.MLCountDay++;
                }
                else if (LeaveList.Contains(day.C28))
                {
                    wt.DayShiftCountnow++;
                    peremployeeAttendance++;
                }
                else if (day.C28 == "P(D)" || day.C28 == "P(N)")
                {
                    peremployeeAttendance++;
                }


                if (day.C29 == "NW")
                {
                    wt.NWCountDay++;
                }
                else if (day.C29 == "ML")
                {
                    wt.MLCountDay++;
                }
                else if (LeaveList.Contains(day.C29))
                {
                    wt.DayShiftCountnow++;
                    peremployeeAttendance++;
                }
                else if (day.C29 == "P(D)" || day.C29 == "P(N)")
                {
                    peremployeeAttendance++;
                }

                if (day.C30 != null)
                {
                    if (day.C30 == "NW")
                    {
                        wt.NWCountDay++;
                    }
                    else if (day.C30 == "ML")
                    {
                        wt.MLCountDay++;
                    }
                    else if (LeaveList.Contains(day.C30))
                    {
                        wt.DayShiftCountnow++;
                        peremployeeAttendance++;
                    }
                    else if (day.C30 == "P(D)" || day.C30 == "P(N)")
                    {
                        peremployeeAttendance++;
                    }
                }

                if (day.C31 != null)
                {
                    if (day.C31 == "NW")
                    {
                        wt.NWCountDay++;
                    }
                    else if (day.C31 == "ML")
                    {
                        wt.MLCountDay++;
                    }
                    else if (LeaveList.Contains(day.C31))
                    {
                        wt.DayShiftCountnow++;
                        peremployeeAttendance++;
                    }
                    else if (day.C31 == "P(D)" || day.C31 == "P(N)")
                    {
                        peremployeeAttendance++;
                    }
                }
            }
            foreach (GET_RP_AttendanceMonitoring_Result night in NightShift)
            {
                if (night.C1 == "NW")
                {
                    wt.NWCountNight++;
                }
                else if (night.C1 == "ML")
                {
                    wt.MLCountNight++;
                }
                else if (LeaveList.Contains(night.C1))
                {
                    wt.NightshiftCountnow++;
                    peremployeeAttendance2++;
                }
                else if (night.C1 == "P(D)" || night.C1 == "P(N)")
                {
                    peremployeeAttendance2++;
                }

                if (night.C2 == "NW")
                {
                    wt.NWCountNight++;
                }
                else if (night.C2 == "ML")
                {
                    wt.MLCountNight++;
                }
                else if (LeaveList.Contains(night.C2))
                {
                    wt.NightshiftCountnow++;
                    peremployeeAttendance2++;
                }
                else if (night.C2 == "P(D)" || night.C2 == "P(N)")
                {
                    peremployeeAttendance2++;
                }

                if (night.C3 == "NW")
                {
                    wt.NWCountNight++;
                }
                else if (night.C3 == "ML")
                {
                    wt.MLCountNight++;
                }
                else if (LeaveList.Contains(night.C3))
                {
                    wt.NightshiftCountnow++;
                    peremployeeAttendance2++;
                }
                else if (night.C3 == "P(D)" || night.C3 == "P(N)")
                {
                    peremployeeAttendance2++;
                }

                if (night.C4 == "NW")
                {
                    wt.NWCountNight++;
                }
                else if (night.C4 == "ML")
                {
                    wt.MLCountNight++;
                }
                else if (LeaveList.Contains(night.C4))
                {
                    wt.NightshiftCountnow++;
                    peremployeeAttendance2++;
                }
                else if (night.C4 == "P(D)" || night.C4 == "P(N)")
                {
                    peremployeeAttendance2++;
                }

                if (night.C5 == "NW")
                {
                    wt.NWCountNight++;
                }
                else if (night.C5 == "ML")
                {
                    wt.MLCountNight++;
                }
                else if (LeaveList.Contains(night.C5))
                {
                    wt.NightshiftCountnow++;
                    peremployeeAttendance2++;
                }
                else if (night.C5 == "P(D)" || night.C5 == "P(N)")
                {
                    peremployeeAttendance2++;
                }

                if (night.C6 == "NW")
                {
                    wt.NWCountNight++;
                }
                else if (night.C6 == "ML")
                {
                    wt.MLCountNight++;
                }
                else if (LeaveList.Contains(night.C6))
                {
                    wt.NightshiftCountnow++;
                    peremployeeAttendance2++;
                }
                else if (night.C6 == "P(D)" || night.C6 == "P(N)")
                {
                    peremployeeAttendance2++;
                }

                if (night.C7 == "NW")
                {
                    wt.NWCountNight++;
                }
                else if (night.C7 == "ML")
                {
                    wt.MLCountNight++;
                }
                else if (LeaveList.Contains(night.C7))
                {
                    wt.NightshiftCountnow++;
                    peremployeeAttendance2++;
                }
                else if (night.C7 == "P(D)" || night.C7 == "P(N)")
                {
                    peremployeeAttendance2++;
                }


                if (night.C8 == "NW")
                {
                    wt.NWCountNight++;
                }
                else if (night.C8 == "ML")
                {
                    wt.MLCountNight++;
                }
                else if (LeaveList.Contains(night.C8))
                {
                    wt.NightshiftCountnow++;
                    peremployeeAttendance2++;
                }
                else if (night.C8 == "P(D)" || night.C8 == "P(N)")
                {
                    peremployeeAttendance2++;
                }

                if (night.C9 == "NW")
                {
                    wt.NWCountNight++;
                }
                else if (night.C9 == "ML")
                {
                    wt.MLCountNight++;
                }
                else if (LeaveList.Contains(night.C9))
                {
                    wt.NightshiftCountnow++;
                    peremployeeAttendance2++;
                }
                else if (night.C9 == "P(D)" || night.C9 == "P(N)")
                {
                    peremployeeAttendance2++;
                }


                if (night.C10 == "NW")
                {
                    wt.NWCountNight++;
                }
                else if (night.C10 == "ML")
                {
                    wt.MLCountNight++;
                }
                else if (LeaveList.Contains(night.C10))
                {
                    wt.NightshiftCountnow++;
                    peremployeeAttendance2++;
                }
                else if (night.C10 == "P(D)" || night.C10 == "P(N)")
                {
                    peremployeeAttendance2++;
                }

                if (night.C11 == "NW")
                {
                    wt.NWCountNight++;
                }
                else if (night.C11 == "ML")
                {
                    wt.MLCountNight++;
                }
                else if (LeaveList.Contains(night.C11))
                {
                    wt.NightshiftCountnow++;
                    peremployeeAttendance2++;
                }
                else if (night.C11 == "P(D)" || night.C11 == "P(N)")
                {
                    peremployeeAttendance2++;
                }


                if (night.C12 == "NW")
                {
                    wt.NWCountNight++;
                }
                else if (night.C12 == "ML")
                {
                    wt.MLCountNight++;
                }
                else if (LeaveList.Contains(night.C12))
                {
                    wt.NightshiftCountnow++;
                    peremployeeAttendance2++;
                }
                else if (night.C12 == "P(D)" || night.C12 == "P(N)")
                {
                    peremployeeAttendance2++;
                }

                if (night.C13 == "NW")
                {
                    wt.NWCountNight++;
                }
                else if (night.C13 == "ML")
                {
                    wt.MLCountNight++;
                }
                else if (LeaveList.Contains(night.C13))
                {
                    wt.NightshiftCountnow++;
                    peremployeeAttendance2++;
                }
                else if (night.C13 == "P(D)" || night.C13 == "P(N)")
                {
                    peremployeeAttendance2++;
                }

                if (night.C14 == "NW")
                {
                    wt.NWCountNight++;
                }
                else if (night.C14 == "ML")
                {
                    wt.MLCountNight++;
                }
                else if (LeaveList.Contains(night.C14))
                {
                    wt.NightshiftCountnow++;
                    peremployeeAttendance2++;
                }
                else if (night.C14 == "P(D)" || night.C14 == "P(N)")
                {
                    peremployeeAttendance2++;
                }

                if (night.C15 == "NW")
                {
                    wt.NWCountNight++;
                }
                else if (night.C15 == "ML")
                {
                    wt.MLCountNight++;
                }
                else if (LeaveList.Contains(night.C15))
                {
                    wt.NightshiftCountnow++;
                    peremployeeAttendance2++;
                }
                else if (night.C15 == "P(D)" || night.C15 == "P(N)")
                {
                    peremployeeAttendance2++;
                }


                if (night.C16 == "NW")
                {
                    wt.NWCountNight++;
                }
                else if (night.C16 == "ML")
                {
                    wt.MLCountNight++;
                }
                else if (LeaveList.Contains(night.C16))
                {
                    wt.NightshiftCountnow++;
                    peremployeeAttendance2++;
                }
                else if (night.C16 == "P(D)" || night.C16 == "P(N)")
                {
                    peremployeeAttendance2++;
                }


                if (night.C17 == "NW")
                {
                    wt.NWCountNight++;
                }
                else if (night.C17 == "ML")
                {
                    wt.MLCountNight++;
                }
                else if (LeaveList.Contains(night.C17))
                {
                    wt.NightshiftCountnow++;
                    peremployeeAttendance2++;
                }
                else if (night.C17 == "P(D)" || night.C17 == "P(N)")
                {
                    peremployeeAttendance2++;
                }


                if (night.C18 == "NW")
                {
                    wt.NWCountNight++;
                }
                else if (night.C18 == "ML")
                {
                    wt.MLCountNight++;
                }
                else if (LeaveList.Contains(night.C18))
                {
                    wt.NightshiftCountnow++;
                    peremployeeAttendance2++;
                }
                else if (night.C18 == "P(D)" || night.C18 == "P(N)")
                {
                    peremployeeAttendance2++;
                }


                if (night.C19 == "NW")
                {
                    wt.NWCountNight++;
                }
                else if (night.C19 == "ML")
                {
                    wt.MLCountNight++;
                }
                else if (LeaveList.Contains(night.C19))
                {
                    wt.NightshiftCountnow++;
                    peremployeeAttendance2++;
                }
                else if (night.C19 == "P(D)" || night.C19 == "P(N)")
                {
                    peremployeeAttendance2++;
                }


                if (night.C20 == "NW")
                {
                    wt.NWCountNight++;
                }
                else if (night.C20 == "ML")
                {
                    wt.MLCountNight++;
                }
                else if (LeaveList.Contains(night.C20))
                {
                    wt.NightshiftCountnow++;
                    peremployeeAttendance2++;
                }
                else if (night.C20 == "P(D)" || night.C20 == "P(N)")
                {
                    peremployeeAttendance2++;
                }


                if (night.C21 == "NW")
                {
                    wt.NWCountNight++;
                }
                else if (night.C21 == "ML")
                {
                    wt.MLCountNight++;
                }
                else if (LeaveList.Contains(night.C21))
                {
                    wt.NightshiftCountnow++;
                    peremployeeAttendance2++;
                }
                else if (night.C21 == "P(D)" || night.C21 == "P(N)")
                {
                    peremployeeAttendance2++;
                }


                if (night.C22 == "NW")
                {
                    wt.NWCountNight++;
                }
                else if (night.C22 == "ML")
                {
                    wt.MLCountNight++;
                }
                else if (LeaveList.Contains(night.C22))
                {
                    wt.NightshiftCountnow++;
                    peremployeeAttendance2++;
                }
                else if (night.C22 == "P(D)" || night.C22 == "P(N)")
                {
                    peremployeeAttendance2++;
                }

                if (night.C23 == "NW")
                {
                    wt.NWCountNight++;
                }
                else if (night.C23 == "ML")
                {
                    wt.MLCountNight++;
                }
                else if (LeaveList.Contains(night.C23))
                {
                    wt.NightshiftCountnow++;
                    peremployeeAttendance2++;
                }
                else if (night.C23 == "P(D)" || night.C23 == "P(N)")
                {
                    peremployeeAttendance2++;
                }

                if (night.C24 == "NW")
                {
                    wt.NWCountNight++;
                }
                else if (night.C24 == "ML")
                {
                    wt.MLCountNight++;
                }
                else if (LeaveList.Contains(night.C24))
                {
                    wt.NightshiftCountnow++;
                    peremployeeAttendance2++;
                }
                else if (night.C24 == "P(D)" || night.C24 == "P(N)")
                {
                    peremployeeAttendance2++;
                }


                if (night.C25 == "NW")
                {
                    wt.NWCountNight++;
                }
                else if (night.C25 == "ML")
                {
                    wt.MLCountNight++;
                }
                else if (LeaveList.Contains(night.C25))
                {
                    wt.NightshiftCountnow++;
                    peremployeeAttendance2++;
                }
                else if (night.C25 == "P(D)" || night.C25 == "P(N)")
                {
                    peremployeeAttendance2++;
                }


                if (night.C26 == "NW")
                {
                    wt.NWCountNight++;
                }
                else if (night.C26 == "ML")
                {
                    wt.MLCountNight++;
                }
                else if (LeaveList.Contains(night.C26))
                {
                    wt.NightshiftCountnow++;
                    peremployeeAttendance2++;
                }
                else if (night.C26 == "P(D)" || night.C26 == "P(N)")
                {
                    peremployeeAttendance2++;
                }


                if (night.C27 == "NW")
                {
                    wt.NWCountNight++;
                }
                else if (night.C27 == "ML")
                {
                    wt.MLCountNight++;
                }
                else if (LeaveList.Contains(night.C27))
                {
                    wt.NightshiftCountnow++;
                    peremployeeAttendance2++;
                }
                else if (night.C27 == "P(D)" || night.C27 == "P(N)")
                {
                    peremployeeAttendance2++;
                }


                if (night.C28 == "NW")
                {
                    wt.NWCountNight++;
                }
                else if (night.C28 == "ML")
                {
                    wt.MLCountNight++;
                }
                else if (LeaveList.Contains(night.C28))
                {
                    wt.NightshiftCountnow++;
                    peremployeeAttendance2++;
                }
                else if (night.C28 == "P(D)" || night.C28 == "P(N)")
                {
                    peremployeeAttendance2++;
                }


                if (night.C29 == "NW")
                {
                    wt.NWCountNight++;
                }
                else if (night.C29 == "ML")
                {
                    wt.MLCountNight++;
                }
                else if (LeaveList.Contains(night.C29))
                {
                    wt.NightshiftCountnow++;
                    peremployeeAttendance2++;
                }
                else if (night.C29 == "P(D)" || night.C29 == "P(N)")
                {
                    peremployeeAttendance2++;
                }

                if (night.C30 != null)
                {
                    if (night.C30 == "NW")
                    {
                        wt.NWCountNight++;
                    }
                    else if (night.C30 == "ML")
                    {
                        wt.MLCountNight++;
                    }
                    else if (LeaveList.Contains(night.C30))
                    {
                        wt.NightshiftCountnow++;
                        peremployeeAttendance2++;
                    }
                    else if (night.C30 == "P(D)" || night.C30 == "P(N)")
                    {
                        peremployeeAttendance2++;
                    }
                }

                if (night.C31 != null)
                {
                    if (night.C31 == "NW")
                    {
                        wt.NWCountNight++;
                    }
                    else if (night.C31 == "ML")
                    {
                        wt.MLCountNight++;
                    }
                    else if (LeaveList.Contains(night.C31))
                    {
                        wt.NightshiftCountnow++;
                        peremployeeAttendance2++;
                    }
                    else if (night.C31 == "P(D)" || night.C31 == "P(N)")
                    {
                        peremployeeAttendance2++;
                    }
                }
            }
            double divisor = 0;
            if (peremployeeAttendance > 0)
            {
                divisor = (double)peremployeeAttendance + (double)peremployeeAttendance2;
                double c = (double)wt.DayShiftCountnow / divisor;
                double Ppercentage = c * 100;
                wt.DayShiftper = Math.Round((decimal)Ppercentage, 2);
                
            }
            else
            {
                wt.DayShiftper = 0;
            }
            
            wt.Dayshift = Dayshift.Count;

            if (peremployeeAttendance2 > 0)
            {
                divisor = (double)peremployeeAttendance + (double)peremployeeAttendance2;
                double c1 = (double)wt.NightshiftCountnow / divisor;
                double Ppercentage2 = c1 * 100;

                wt.NightShiftper = Math.Round((decimal)Ppercentage2, 2);
            }
            else
            {
                wt.NightShiftper = 0;
            }
            
            wt.NightShift = NightShift.Count;

            return wt;
        }


        #region Remove
        //public WTGlobal GetHeaderData(int Month, int Year, string Section, List<GET_RP_AttendanceMonitoring_Result> dt)
        //{

        //    List<GET_RP_AttendanceMonitoring_Result> list = dt;//test(Month, Year, Section, dt);
        //    List<GET_RP_AttendanceMonitoring_Result> orig = list;

        //    int daysinMonth = DateTime.DaysInMonth(Year, Month);
        //    list = list.Where(x => x.Schedule != "").ToList();
        //    List<GET_RP_AttendanceMonitoring_Result> Dayshift = list.Where(x => x.Schedule.ToLower().Contains("day")).ToList();
        //    List<GET_RP_AttendanceMonitoring_Result> NightShift = list.Where(x => x.Schedule.ToLower().Contains("night")).ToList();

            
        //    int bDay = BusinessDays(Month, 1, Year);
        //    int employeecount = orig.Count();//Dayshift.Count + NightShift.Count;
            

        //    int AbsentCountDay = 0;
        //    int MLCountDay = 0;
        //    int NWCountDay = 0;
        //    int AbsentCountNight = 0;
        //    int MLCountNight = 0;
        //    int NWCountNight = 0;

        //    List<string> LeaveList = new List<string>();
        //    LeaveList.Add("ML");
        //    LeaveList.Add("SL");
        //    LeaveList.Add("VL");
        //    LeaveList.Add("EL");
        //    LeaveList.Add("AB");

        //    #region DS
        //    foreach (GET_RP_AttendanceMonitoring_Result row in Dayshift)
        //    {
        //        if (Dayname(1, Month, Year))
        //        {
        //            switch (row.C1)
        //            {
        //                case "AB":
        //                    AbsentCountDay++;
        //                    break;
        //                case "ML":
        //                    MLCountDay++;
        //                    break;
        //                case "NW":
        //                    NWCountDay++;
        //                    break;
        //            }       
                   
        //        }
        //        if (Dayname(2, Month, Year))
        //        {
        //            switch (row.C2)
        //            {
        //                case "AB":
        //                    AbsentCountDay++;
        //                    break;
        //                case "ML":
        //                    MLCountDay++;
        //                    break;
        //                case "NW":
        //                    NWCountDay++;
        //                    break;
        //            }
        //        }
        //        if (Dayname(3, Month, Year))
        //        {
        //            switch (row.C3)
        //            {
        //                case "AB":
        //                    AbsentCountDay++;
        //                    break;
        //                case "ML":
        //                    MLCountDay++;
        //                    break;
        //                case "NW":
        //                    NWCountDay++;
        //                    break;
        //            }
        //        }
        //        if (Dayname(4, Month, Year))
        //        {
        //            switch (row.C4)
        //            {
        //                case "AB":
        //                    AbsentCountDay++;
        //                    break;
        //                case "ML":
        //                    MLCountDay++;
        //                    break;
        //                case "NW":
        //                    NWCountDay++;
        //                    break;
        //            }
        //        }
        //        if (Dayname(5, Month, Year))
        //        {
        //            switch (row.C5)
        //            {
        //                case "AB":
        //                    AbsentCountDay++;
        //                    break;
        //                case "ML":
        //                    MLCountDay++;
        //                    break;
        //                case "NW":
        //                    NWCountDay++;
        //                    break;
        //            }
        //        }
        //        if (Dayname(6, Month, Year))
        //        {
        //            switch (row.C6)
        //            {
        //                case "AB":
        //                    AbsentCountDay++;
        //                    break;
        //                case "ML":
        //                    MLCountDay++;
        //                    break;
        //                case "NW":
        //                    NWCountDay++;
        //                    break;
        //            }
        //        }
        //        if (Dayname(7, Month, Year))
        //        {
        //            switch (row.C7)
        //            {
        //                case "AB":
        //                    AbsentCountDay++;
        //                    break;
        //                case "ML":
        //                    MLCountDay++;
        //                    break;
        //                case "NW":
        //                    NWCountDay++;
        //                    break;
        //            }
        //        }
        //        if (Dayname(8, Month, Year))
        //        {
        //            switch (row.C8)
        //            {
        //                case "AB":
        //                    AbsentCountDay++;
        //                    break;
        //                case "ML":
        //                    MLCountDay++;
        //                    break;
        //                case "NW":
        //                    NWCountDay++;
        //                    break;
        //            }
        //        }
        //        if (Dayname(9, Month, Year))
        //        {
        //            switch (row.C9)
        //            {
        //                case "AB":
        //                    AbsentCountDay++;
        //                    break;
        //                case "ML":
        //                    MLCountDay++;
        //                    break;
        //                case "NW":
        //                    NWCountDay++;
        //                    break;
        //            }
        //        }
        //        if (Dayname(10, Month, Year))
        //        {
        //            switch (row.C10)
        //            {
        //                case "AB":
        //                    AbsentCountDay++;
        //                    break;
        //                case "ML":
        //                    MLCountDay++;
        //                    break;
        //                case "NW":
        //                    NWCountDay++;
        //                    break;
        //            }
        //        }
        //        if (Dayname(11, Month, Year))
        //        {
        //            switch (row.C11)
        //            {
        //                case "AB":
        //                    AbsentCountDay++;
        //                    break;
        //                case "ML":
        //                    MLCountDay++;
        //                    break;
        //                case "NW":
        //                    NWCountDay++;
        //                    break;
        //            }
        //        }
        //        if (Dayname(12, Month, Year))
        //        {
        //            switch (row.C12)
        //            {
        //                case "AB":
        //                    AbsentCountDay++;
        //                    break;
        //                case "ML":
        //                    MLCountDay++;
        //                    break;
        //                case "NW":
        //                    NWCountDay++;
        //                    break;
        //            }
        //        }
        //        if (Dayname(13, Month, Year))
        //        {
        //            switch (row.C13)
        //            {
        //                case "AB":
        //                    AbsentCountDay++;
        //                    break;
        //                case "ML":
        //                    MLCountDay++;
        //                    break;
        //                case "NW":
        //                    NWCountDay++;
        //                    break;
        //            }
        //        }
        //        if (Dayname(14, Month, Year))
        //        {
        //            switch (row.C14)
        //            {
        //                case "AB":
        //                    AbsentCountDay++;
        //                    break;
        //                case "ML":
        //                    MLCountDay++;
        //                    break;
        //                case "NW":
        //                    NWCountDay++;
        //                    break;
        //            }
        //        }
        //        if (Dayname(15, Month, Year))
        //        {
        //            switch (row.C15)
        //            {
        //                case "AB":
        //                    AbsentCountDay++;
        //                    break;
        //                case "ML":
        //                    MLCountDay++;
        //                    break;
        //                case "NW":
        //                    NWCountDay++;
        //                    break;
        //            }
        //        }
        //        if (Dayname(16, Month, Year))
        //        {
        //            switch (row.C16)
        //            {
        //                case "AB":
        //                    AbsentCountDay++;
        //                    break;
        //                case "ML":
        //                    MLCountDay++;
        //                    break;
        //                case "NW":
        //                    NWCountDay++;
        //                    break;
        //            }
        //        }
        //        if (Dayname(17, Month, Year))
        //        {
        //            switch (row.C17)
        //            {
        //                case "AB":
        //                    AbsentCountDay++;
        //                    break;
        //                case "ML":
        //                    MLCountDay++;
        //                    break;
        //                case "NW":
        //                    NWCountDay++;
        //                    break;
        //            }
        //        }
        //        if (Dayname(18, Month, Year))
        //        {
        //            switch (row.C18)
        //            {
        //                case "AB":
        //                    AbsentCountDay++;
        //                    break;
        //                case "ML":
        //                    MLCountDay++;
        //                    break;
        //                case "NW":
        //                    NWCountDay++;
        //                    break;
        //            }
        //        }
        //        if (Dayname(19, Month, Year))
        //        {
        //            switch (row.C19)
        //            {
        //                case "AB":
        //                    AbsentCountDay++;
        //                    break;
        //                case "ML":
        //                    MLCountDay++;
        //                    break;
        //                case "NW":
        //                    NWCountDay++;
        //                    break;
        //            }
        //        }
        //        if (Dayname(20, Month, Year))
        //        {
        //            switch (row.C20)
        //            {
        //                case "AB":
        //                    AbsentCountDay++;
        //                    break;
        //                case "ML":
        //                    MLCountDay++;
        //                    break;
        //                case "NW":
        //                    NWCountDay++;
        //                    break;
        //            }
        //        }
        //        if (Dayname(21, Month, Year))
        //        {
        //            switch (row.C21)
        //            {
        //                case "AB":
        //                    AbsentCountDay++;
        //                    break;
        //                case "ML":
        //                    MLCountDay++;
        //                    break;
        //                case "NW":
        //                    NWCountDay++;
        //                    break;
        //            }
        //        }
        //        if (Dayname(22, Month, Year))
        //        {
        //            switch (row.C22)
        //            {
        //                case "AB":
        //                    AbsentCountDay++;
        //                    break;
        //                case "ML":
        //                    MLCountDay++;
        //                    break;
        //                case "NW":
        //                    NWCountDay++;
        //                    break;
        //            }
        //        }
        //        if (Dayname(23, Month, Year))
        //        {
        //            switch (row.C23)
        //            {
        //                case "AB":
        //                    AbsentCountDay++;
        //                    break;
        //                case "ML":
        //                    MLCountDay++;
        //                    break;
        //                case "NW":
        //                    NWCountDay++;
        //                    break;
        //            }
        //        }
        //        if (Dayname(24, Month, Year))
        //        {
        //            switch (row.C24)
        //            {
        //                case "AB":
        //                    AbsentCountDay++;
        //                    break;
        //                case "ML":
        //                    MLCountDay++;
        //                    break;
        //                case "NW":
        //                    NWCountDay++;
        //                    break;
        //            }
        //        }
        //        if (Dayname(25, Month, Year))
        //        {
        //            switch (row.C25)
        //            {
        //                case "AB":
        //                    AbsentCountDay++;
        //                    break;
        //                case "ML":
        //                    MLCountDay++;
        //                    break;
        //                case "NW":
        //                    NWCountDay++;
        //                    break;
        //            }
        //        }
        //        if (Dayname(26, Month, Year))
        //        {
        //            switch (row.C26)
        //            {
        //                case "AB":
        //                    AbsentCountDay++;
        //                    break;
        //                case "ML":
        //                    MLCountDay++;
        //                    break;
        //                case "NW":
        //                    NWCountDay++;
        //                    break;
        //            }
        //        }
        //        if (Dayname(27, Month, Year))
        //        {
        //            switch (row.C27)
        //            {
        //                case "AB":
        //                    AbsentCountDay++;
        //                    break;
        //                case "ML":
        //                    MLCountDay++;
        //                    break;
        //                case "NW":
        //                    NWCountDay++;
        //                    break;
        //            }
        //        }
        //        if (Dayname(28, Month, Year))
        //        {
        //            switch (row.C28)
        //            {
        //                case "AB":
        //                    AbsentCountDay++;
        //                    break;
        //                case "ML":
        //                    MLCountDay++;
        //                    break;
        //                case "NW":
        //                    NWCountDay++;
        //                    break;
        //            }
        //        }
        //        if (Dayname(29, Month, Year))
        //        {
        //            switch (row.C29)
        //            {
        //                case "AB":
        //                    AbsentCountDay++;
        //                    break;
        //                case "ML":
        //                    MLCountDay++;
        //                    break;
        //                case "NW":
        //                    NWCountDay++;
        //                    break;
        //            }
        //        }
        //        if (row.C30 != null)
        //        {
        //            if (Dayname(30, Month, Year))
        //            {
        //                switch (row.C30)
        //                {
        //                    case "AB":
        //                        AbsentCountDay++;
        //                        break;
        //                    case "ML":
        //                        MLCountDay++;
        //                        break;
        //                    case "NW":
        //                        NWCountDay++;
        //                        break;
        //                }
        //            }
        //        }
        //        if (row.C31 != null)
        //        {
        //            if (Dayname(31, Month, Year))
        //            {
        //                switch (row.C31)
        //                {
        //                    case "AB":
        //                        AbsentCountDay++;
        //                        break;
        //                    case "ML":
        //                        MLCountDay++;
        //                        break;
        //                    case "NW":
        //                        NWCountDay++;
        //                        break;
        //                }
        //            }
        //        }
        //    }
        //    #endregion

        //    #region NS
        //    foreach (GET_RP_AttendanceMonitoring_Result row in NightShift)
        //    {
        //        if (Dayname(1, Month, Year))
        //        {
        //            switch (row.C1)
        //            {
        //                case "AB":
        //                    AbsentCountNight++;
        //                    break;
        //                case "ML":
        //                    MLCountNight++;
        //                    break;
        //                case "NW":
        //                    NWCountNight++;
        //                    break;
        //            }

        //        }
        //        if (Dayname(2, Month, Year))
        //        {
        //            switch (row.C2)
        //            {
        //                case "AB":
        //                    AbsentCountNight++;
        //                    break;
        //                case "ML":
        //                    MLCountNight++;
        //                    break;
        //                case "NW":
        //                    NWCountNight++;
        //                    break;
        //            }
        //        }
        //        if (Dayname(3, Month, Year))
        //        {
        //            switch (row.C3)
        //            {
        //                case "AB":
        //                    AbsentCountNight++;
        //                    break;
        //                case "ML":
        //                    MLCountNight++;
        //                    break;
        //                case "NW":
        //                    NWCountNight++;
        //                    break;
        //            }
        //        }
        //        if (Dayname(4, Month, Year))
        //        {
        //            switch (row.C4)
        //            {
        //                case "AB":
        //                    AbsentCountNight++;
        //                    break;
        //                case "ML":
        //                    MLCountNight++;
        //                    break;
        //                case "NW":
        //                    NWCountNight++;
        //                    break;
        //            }
        //        }
        //        if (Dayname(5, Month, Year))
        //        {
        //            switch (row.C5)
        //            {
        //                case "AB":
        //                    AbsentCountNight++;
        //                    break;
        //                case "ML":
        //                    MLCountNight++;
        //                    break;
        //                case "NW":
        //                    NWCountNight++;
        //                    break;
        //            }
        //        }
        //        if (Dayname(6, Month, Year))
        //        {
        //            switch (row.C6)
        //            {
        //                case "AB":
        //                    AbsentCountNight++;
        //                    break;
        //                case "ML":
        //                    MLCountNight++;
        //                    break;
        //                case "NW":
        //                    NWCountNight++;
        //                    break;
        //            }
        //        }
        //        if (Dayname(7, Month, Year))
        //        {
        //            switch (row.C7)
        //            {
        //                case "AB":
        //                    AbsentCountNight++;
        //                    break;
        //                case "ML":
        //                    MLCountNight++;
        //                    break;
        //                case "NW":
        //                    NWCountNight++;
        //                    break;
        //            }
        //        }
        //        if (Dayname(8, Month, Year))
        //        {
        //            switch (row.C8)
        //            {
        //                case "AB":
        //                    AbsentCountNight++;
        //                    break;
        //                case "ML":
        //                    MLCountNight++;
        //                    break;
        //                case "NW":
        //                    NWCountNight++;
        //                    break;
        //            }
        //        }
        //        if (Dayname(9, Month, Year))
        //        {
        //            switch (row.C9)
        //            {
        //                case "AB":
        //                    AbsentCountNight++;
        //                    break;
        //                case "ML":
        //                    MLCountNight++;
        //                    break;
        //                case "NW":
        //                    NWCountNight++;
        //                    break;
        //            }
        //        }
        //        if (Dayname(10, Month, Year))
        //        {
        //            switch (row.C10)
        //            {
        //                case "AB":
        //                    AbsentCountNight++;
        //                    break;
        //                case "ML":
        //                    MLCountNight++;
        //                    break;
        //                case "NW":
        //                    NWCountNight++;
        //                    break;
        //            }
        //        }
        //        if (Dayname(11, Month, Year))
        //        {
        //            switch (row.C11)
        //            {
        //                case "AB":
        //                    AbsentCountNight++;
        //                    break;
        //                case "ML":
        //                    MLCountNight++;
        //                    break;
        //                case "NW":
        //                    NWCountNight++;
        //                    break;
        //            }
        //        }
        //        if (Dayname(12, Month, Year))
        //        {
        //            switch (row.C12)
        //            {
        //                case "AB":
        //                    AbsentCountNight++;
        //                    break;
        //                case "ML":
        //                    MLCountNight++;
        //                    break;
        //                case "NW":
        //                    NWCountNight++;
        //                    break;
        //            }
        //        }
        //        if (Dayname(13, Month, Year))
        //        {
        //            switch (row.C13)
        //            {
        //                case "AB":
        //                    AbsentCountNight++;
        //                    break;
        //                case "ML":
        //                    MLCountNight++;
        //                    break;
        //                case "NW":
        //                    NWCountNight++;
        //                    break;
        //            }
        //        }
        //        if (Dayname(14, Month, Year))
        //        {
        //            switch (row.C14)
        //            {
        //                case "AB":
        //                    AbsentCountNight++;
        //                    break;
        //                case "ML":
        //                    MLCountNight++;
        //                    break;
        //                case "NW":
        //                    NWCountNight++;
        //                    break;
        //            }
        //        }
        //        if (Dayname(15, Month, Year))
        //        {
        //            switch (row.C15)
        //            {
        //                case "AB":
        //                    AbsentCountNight++;
        //                    break;
        //                case "ML":
        //                    MLCountNight++;
        //                    break;
        //                case "NW":
        //                    NWCountNight++;
        //                    break;
        //            }
        //        }
        //        if (Dayname(16, Month, Year))
        //        {
        //            switch (row.C16)
        //            {
        //                case "AB":
        //                    AbsentCountNight++;
        //                    break;
        //                case "ML":
        //                    MLCountNight++;
        //                    break;
        //                case "NW":
        //                    NWCountNight++;
        //                    break;
        //            }
        //        }
        //        if (Dayname(17, Month, Year))
        //        {
        //            switch (row.C17)
        //            {
        //                case "AB":
        //                    AbsentCountNight++;
        //                    break;
        //                case "ML":
        //                    MLCountNight++;
        //                    break;
        //                case "NW":
        //                    NWCountNight++;
        //                    break;
        //            }
        //        }
        //        if (Dayname(18, Month, Year))
        //        {
        //            switch (row.C18)
        //            {
        //                case "AB":
        //                    AbsentCountNight++;
        //                    break;
        //                case "ML":
        //                    MLCountNight++;
        //                    break;
        //                case "NW":
        //                    NWCountNight++;
        //                    break;
        //            }
        //        }
        //        if (Dayname(19, Month, Year))
        //        {
        //            switch (row.C19)
        //            {
        //                case "AB":
        //                    AbsentCountNight++;
        //                    break;
        //                case "ML":
        //                    MLCountNight++;
        //                    break;
        //                case "NW":
        //                    NWCountNight++;
        //                    break;
        //            }
        //        }
        //        if (Dayname(20, Month, Year))
        //        {
        //            switch (row.C20)
        //            {
        //                case "AB":
        //                    AbsentCountNight++;
        //                    break;
        //                case "ML":
        //                    MLCountNight++;
        //                    break;
        //                case "NW":
        //                    NWCountNight++;
        //                    break;
        //            }
        //        }
        //        if (Dayname(21, Month, Year))
        //        {
        //            switch (row.C21)
        //            {
        //                case "AB":
        //                    AbsentCountNight++;
        //                    break;
        //                case "ML":
        //                    MLCountNight++;
        //                    break;
        //                case "NW":
        //                    NWCountNight++;
        //                    break;
        //            }
        //        }
        //        if (Dayname(22, Month, Year))
        //        {
        //            switch (row.C22)
        //            {
        //                case "AB":
        //                    AbsentCountNight++;
        //                    break;
        //                case "ML":
        //                    MLCountNight++;
        //                    break;
        //                case "NW":
        //                    NWCountNight++;
        //                    break;
        //            }
        //        }
        //        if (Dayname(23, Month, Year))
        //        {
        //            switch (row.C23)
        //            {
        //                case "AB":
        //                    AbsentCountNight++;
        //                    break;
        //                case "ML":
        //                    MLCountNight++;
        //                    break;
        //                case "NW":
        //                    NWCountNight++;
        //                    break;
        //            }
        //        }
        //        if (Dayname(24, Month, Year))
        //        {
        //            switch (row.C24)
        //            {
        //                case "AB":
        //                    AbsentCountNight++;
        //                    break;
        //                case "ML":
        //                    MLCountNight++;
        //                    break;
        //                case "NW":
        //                    NWCountNight++;
        //                    break;
        //            }
        //        }
        //        if (Dayname(25, Month, Year))
        //        {
        //            switch (row.C25)
        //            {
        //                case "AB":
        //                    AbsentCountNight++;
        //                    break;
        //                case "ML":
        //                    MLCountNight++;
        //                    break;
        //                case "NW":
        //                    NWCountNight++;
        //                    break;
        //            }
        //        }
        //        if (Dayname(26, Month, Year))
        //        {
        //            switch (row.C26)
        //            {
        //                case "AB":
        //                    AbsentCountNight++;
        //                    break;
        //                case "ML":
        //                    MLCountNight++;
        //                    break;
        //                case "NW":
        //                    NWCountNight++;
        //                    break;
        //            }
        //        }
        //        if (Dayname(27, Month, Year))
        //        {
        //            switch (row.C27)
        //            {
        //                case "AB":
        //                    AbsentCountNight++;
        //                    break;
        //                case "ML":
        //                    MLCountNight++;
        //                    break;
        //                case "NW":
        //                    NWCountNight++;
        //                    break;
        //            }
        //        }
        //        if (Dayname(28, Month, Year))
        //        {
        //            switch (row.C28)
        //            {
        //                case "AB":
        //                    AbsentCountNight++;
        //                    break;
        //                case "ML":
        //                    MLCountNight++;
        //                    break;
        //                case "NW":
        //                    NWCountNight++;
        //                    break;
        //            }
        //        }
        //        if (Dayname(29, Month, Year))
        //        {
        //            switch (row.C29)
        //            {
        //                case "AB":
        //                    AbsentCountNight++;
        //                    break;
        //                case "ML":
        //                    MLCountNight++;
        //                    break;
        //                case "NW":
        //                    NWCountNight++;
        //                    break;
        //            }
        //        }
        //        if (row.C30 != null)
        //        {
        //            if (Dayname(30, Month, Year))
        //            {
        //                switch (row.C30)
        //                {
        //                    case "AB":
        //                        AbsentCountNight++;
        //                        break;
        //                    case "ML":
        //                        MLCountNight++;
        //                        break;
        //                    case "NW":
        //                        NWCountNight++;
        //                        break;
        //                }
        //            }
        //        }
        //        if (row.C31 != null)
        //        {
        //            if (Dayname(31, Month, Year))
        //            {
        //                switch (row.C31)
        //                {
        //                    case "AB":
        //                        AbsentCountNight++;
        //                        break;
        //                    case "ML":
        //                        MLCountNight++;
        //                        break;
        //                    case "NW":
        //                        NWCountNight++;
        //                        break;
        //                }
        //            }
        //        }
        //    }
        //    #endregion
        //    decimal DayShiftper = 0;
        //    decimal NightShiftper = 0;


        //    decimal DayShiftCountnow = AbsentCountDay;
        //    decimal NightshiftCountnow = AbsentCountNight;
        //    try
        //    {
        //        //DayShiftper = Math.Round((100 * ((decimal)AbsentCountDay / ((decimal)bDay * employeecount))), 2);
        //        //NightShiftper = Math.Round((100 * ((decimal)AbsentCountNight / ((decimal)bDay * employeecount))), 2);
        //        DayShiftper = Math.Round((100 * ((decimal)DayShiftCountnow / ((decimal)bDay * employeecount))), 2);
        //        NightShiftper = Math.Round((100 * ((decimal)NightshiftCountnow / ((decimal)bDay * employeecount))), 2);
        //    }
        //    catch (Exception err)
        //    {

        //    }

        //    WTGlobal header = new WTGlobal();
        //    header.DayShiftCountnow = DayShiftCountnow;
        //    header.NightshiftCountnow = NightshiftCountnow;
        //    header.Dayshift = Dayshift.Count;
        //    header.NightShift = NightShift.Count;
        //    header.DayShiftper = DayShiftper;
        //    header.NightShiftper = NightShiftper;
        //    header.MLCountDay = MLCountDay;
        //    header.MLCountNight = MLCountNight;
        //    header.NWCountDay = NWCountDay;
        //    header.NWCountNight = NWCountNight;
            
        //    return header;
        //}
        #endregion

        public ActionResult GetAttendanceEmployeeProcess(string EmpNo, string CostCode)
        {
            List<GET_RP_AttendanceMonitoring_Process_Result> list = db.GET_RP_AttendanceMonitoring_Process(EmpNo, CostCode).ToList();
            
            return Json(new {list=list }, JsonRequestBehavior.AllowGet);
        }

        public int BusinessDays(int Month, int daysselected, int year)
        {
            int daysInMonth = 0;
            int days = DateTime.Now.Day;//DateTime.DaysInMonth(year, Month);
            for (int i = 1; i <= days; i++)
            {
                DateTime day = new DateTime(year, Month, i);
                if (day.DayOfWeek != DayOfWeek.Sunday && day.DayOfWeek != DayOfWeek.Saturday)
                {
                    daysInMonth++;
                }
            }

            return daysInMonth;
        }


        int WDinmonth = 0;
        public bool Dayname(int daysselected, int Month, int year)
        {
            try
            {
                DateTime day = new DateTime(year, Month, daysselected);
                //string aa = "07/01/2020";
                //DateTime a = Convert.ToDateTime(aa);
                if ((day.DayOfWeek != DayOfWeek.Sunday) && (day.DayOfWeek != DayOfWeek.Saturday) && day <= DateTime.Now)
                {
                    WDinmonth++;
                    return true;
                }
                else
                {
                    return false;
                }
            }
            catch(Exception err)
            {
                return false;
            }
        }

        public ActionResult ExportAdjust(int Month, int Year, int Day, string Section)
        {
            try
            {
           
                string templateFilename = "AttendanceMonitoring.xlsx";
                string dir = Path.GetTempPath();
                string datetimeToday = DateTime.Now.ToString("yyMMddhhmmss");
                string filename = string.Format("LeaveAdjustment{0}_{1}.xlsx", datetimeToday, Section);
                FileInfo newFile = new FileInfo(Path.Combine(dir, filename));
                string apptemplatePath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, @"TemplateFiles\", templateFilename);
                FileInfo templateFile = new FileInfo(apptemplatePath);

                using (ExcelPackage package = new ExcelPackage(newFile, templateFile))  //-- With template.
                {
                    int start = 2;
                    ExcelWorksheet ExportData = package.Workbook.Worksheets["AMSSheet"];
                    //List<GET_RP_AttendanceMonitoring_Result> list = test(Month,Year,Section);// db.GET_RP_AttendanceMonitoring(Month, Year, Section).ToList();
                    DataTable dt = new DataTable();// (DataTable)System.Web.HttpContext.Current.Session["ExportWT"];//ExportsEmployee(Month, Year, Day, Section);

                    SqlConnection conn = new SqlConnection(Connection_String.AMSDB);
                    SqlCommand cmdSql = new SqlCommand();
                    cmdSql.Connection = conn;
                    cmdSql.CommandType = CommandType.StoredProcedure;
                    cmdSql.CommandText = @"dbo.GET_RP_AttendanceMonitoring";

                    cmdSql.Parameters.Clear();
                    cmdSql.Parameters.Add("@Month", SqlDbType.Int).Value = Month;
                    cmdSql.Parameters.Add("@Year", SqlDbType.Int).Value = Year;
                    cmdSql.Parameters.Add("@Section", SqlDbType.NVarChar).Value = Section;

                    cmdSql.CommandTimeout = 0;
                    conn.Open();

                    //if (System.Web.HttpContext.Current.Session["ExportWT"] == null)
                    //{
                    SqlDataReader sdr = cmdSql.ExecuteReader();
                    dt.Load(sdr);
                    //}

                    //else
                    //{
                    // dt = (DataTable)System.Web.HttpContext.Current.Session["ExportWT"];
                    //}


                    //wt.globawt = dt;
                    cmdSql.Dispose();
                    conn.Close();
                    int dday = Day + 12;
                    List<string> Pr = new List<string>();
                    Pr.Add("P(D)");
                    Pr.Add("P(N)");
                    Pr.Add("TR(D)");
                    Pr.Add("TR(N)");
                    Pr.Add("TR");
                    for (int i = 0; i < dt.Rows.Count; i++)
                    {
                        if (!Pr.Contains(dt.Rows[i][dday].ToString()))
                        {
                            string rfid = dt.Rows[i][1].ToString();
                            //T_TimeInOut checker = (from c in db.T_TimeInOut
                            //                       where c.Employee_RFID == rfid 
                            //                       && c.TimeIn.Value.Month == Month
                            //                       && c.TimeIn.Value.Year == Year
                            //                       select c).FirstOrDefault();
                            //if (checker != null)
                            //{
                                ExportData.Cells["A" + start].Value = dt.Rows[i][1].ToString();
                                ExportData.Cells["B" + start].Value = dt.Rows[i][2].ToString();
                                ExportData.Cells["C" + start].Value = dt.Rows[i][4].ToString();
                                ExportData.Cells["D" + start].Value = dt.Rows[i][3].ToString();
                             
                                ExportData.Cells["E" + start].Value = (dt.Rows[i][dday].ToString() == "AB") ? "AB" : dt.Rows[i][dday].ToString();
                                start++;
                            //}
                        }
                    }
                        return File(package.GetAsByteArray(), "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", filename);
                }
            }
            catch (Exception err)
            {
                Error_Logs error = new Error_Logs();
                error.PageModule = "Reports - Attendance Monitoring";
                error.ErrorLog = err.Message;
                error.DateLog = DateTime.Now;
                error.Username = user.UserName;
                db.Error_Logs.Add(error);
                db.SaveChanges();
            }
            return Json(new { }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult UploadAdjustment(DateTime DateChange)
        {
            try
            {
                var postedFile = Request.Files[0] as HttpPostedFileBase;
                string filePath = string.Empty;
                if (postedFile != null)
                {

                    Z_UploadTracker uploaddetails = new Z_UploadTracker();
                    uploaddetails.Uploaddate = db.TT_GETTIME().FirstOrDefault();
                    uploaddetails.Uploader = user.UserName;
                    uploaddetails.UploadFile = postedFile.FileName;
                    db.Z_UploadTracker.Add(uploaddetails);
                    db.SaveChanges();


                    string LeaveAdjustment = "LeaveAdjustment";
                    string path = Server.MapPath("~/Uploads/"+ LeaveAdjustment+"/");
                    if (!Directory.Exists(path))
                    {
                        Directory.CreateDirectory(path);
                    }
                    filePath = path + Path.GetFileName(postedFile.FileName);
                    string extension = Path.GetExtension(postedFile.FileName);
                    postedFile.SaveAs(filePath);
                    string conString = string.Empty;
                    switch (extension.ToLower())
                    {
                        case ".xls": //Excel 97-03.
                            conString = ConfigurationManager.ConnectionStrings["Excel03ConString"].ConnectionString;
                            break;
                        case ".xlsx": //Excel 07 and above.
                            conString = ConfigurationManager.ConnectionStrings["Excel07ConString"].ConnectionString;
                            break;
                    }
                    conString = string.Format(conString, filePath);

                    using (OleDbConnection connExcel = new OleDbConnection(conString))
                    {
                        using (OleDbCommand cmdExcel = new OleDbCommand())
                        {
                            using (OleDbDataAdapter odaExcel = new OleDbDataAdapter())
                            {
                                DataTable dt = new DataTable();
                                DataTable dtchecker = new DataTable();
                                cmdExcel.Connection = connExcel;
                                string sheetName = "AMSSheet";
                                try
                                {
                                    connExcel.Open();
                                }
                                catch (Exception err)
                                {
                                    Error_Logs error = new Error_Logs();
                                    error.PageModule = "Reports - WorkTimeSummary";
                                    error.ErrorLog = err.Message;
                                    error.DateLog = DateTime.Now;
                                    error.Username = user.UserName;
                                    db.Error_Logs.Add(error);
                                    db.SaveChanges();
                                }
                                cmdExcel.CommandText = "SELECT EmployeeNo, LeaveType, Reason FROM [" + sheetName + "$] WHERE EmployeeNo <> '' AND LeaveType <> 'NoLeave'";//ung * is column name, ung sheetname ay settings
                                odaExcel.SelectCommand = cmdExcel;
                                odaExcel.Fill(dt);


                                cmdExcel.CommandText = "SELECT EmployeeNo, LeaveType, Reason FROM [" + sheetName + "$] WHERE LeaveType <> 'AB' AND EmployeeNo <> '' AND LeaveType <> 'NoLeave' AND (LeaveType IS NULL OR LeaveType = '' OR Reason IS NULL OR Reason = '')";//ung * is column name, ung sheetname ay settings
                                odaExcel.SelectCommand = cmdExcel;
                                odaExcel.Fill(dtchecker);
                                connExcel.Close();

                                if(dtchecker.Rows.Count > 0) {
                                    return Json(new { result = "failed" }, JsonRequestBehavior.AllowGet);
                                }
                                else
                                {
                                    for (int x = 0; x < dt.Rows.Count; x++)
                                    {
                                        try
                                        {
                                            string EmployeeNo = dt.Rows[x]["EmployeeNo"].ToString();
                                            string LeaveType = dt.Rows[x]["LeaveType"].ToString();
                                            string Reason = dt.Rows[x]["Reason"].ToString();
                                            if (LeaveType != "")
                                            {
                                                RP_AttendanceMonitoring checker = (from c in db.RP_AttendanceMonitoring where c.EmployeeNo == EmployeeNo && c.Date == DateChange select c).FirstOrDefault();
                                                if (checker == null)
                                                {

                                                    RP_AttendanceMonitoring EmpStatus = new RP_AttendanceMonitoring();
                                                    EmpStatus.EmployeeNo = EmployeeNo;
                                                    EmpStatus.LeaveType = LeaveType;
                                                    EmpStatus.Date = DateChange;
                                                    EmpStatus.UpdateDate = DateTime.Now;
                                                    EmpStatus.UpdateID = user.UserName;
                                                    EmpStatus.Reason = Reason;
                                                    db.RP_AttendanceMonitoring.Add(EmpStatus);
                                                    db.SaveChanges();

                                                }
                                                else
                                                {
                                                    checker.Reason = Reason;
                                                    checker.LeaveType = LeaveType;
                                                    checker.UpdateDate = DateTime.Now;
                                                    checker.UpdateID = user.UpdateID;
                                                    db.Entry(checker).State = EntityState.Modified;
                                                    db.SaveChanges();

                                                }
                                            }

                                        }
                                        catch (Exception err)
                                        {
                                            Error_Logs error = new Error_Logs();
                                            error.PageModule = "Reports - WorkTimeSummary";
                                            error.ErrorLog = err.Message;
                                            error.DateLog = DateTime.Now;
                                            error.Username = user.UserName;
                                            db.Error_Logs.Add(error);
                                            db.SaveChanges();
                                        }
                                    }
                                }
                               
                            }
                        }
                    }
                }
            }
            catch (Exception err)
            {
                Error_Logs error = new Error_Logs();
                error.PageModule = "Reports - WorkTimeSummary";
                error.ErrorLog = err.Message;
                error.DateLog = DateTime.Now;
                error.Username = user.UserName;
                db.Error_Logs.Add(error);
                db.SaveChanges();
                return Json(new { result = "failed" }, JsonRequestBehavior.AllowGet);
            }
            return Json(new { result = "success" }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult CheckLeave(int Month, int Year, int Day, string EmpNo)
        {
            string Datehere = Month.ToString() + "/" + Day.ToString() + "/" + Year.ToString();
            DateTime convertedDate = Convert.ToDateTime(Datehere);
            string Leave = (from c in db.RP_AttendanceMonitoring where c.Date == convertedDate && c.EmployeeNo == EmpNo select c.LeaveType).FirstOrDefault();

            return Json(new {Actual = Leave }, JsonRequestBehavior.AllowGet);
        }
        
        public ActionResult GETHEADER()
        {
            WTGlobal Header = (WTGlobal)System.Web.HttpContext.Current.Session["WT"];
            return Json(new { header = Header }, JsonRequestBehavior.AllowGet);
        }


        public ActionResult RemoveCache()
        {
            System.Web.HttpContext.Current.Session["ExportWT"] = null;
            System.Web.HttpContext.Current.Session["ExportDTR"] = null;
            System.Web.HttpContext.Current.Session["ExportShift"] = null;
            System.Web.HttpContext.Current.Session["ExportTT"] = null;
            
            return Json(new { }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult GeAttendanceMonitoringList(int Month, int Year, string Section, bool go, string Agency)
        {
            try
            {
                DataTable dt = new DataTable();
                int start = Convert.ToInt32(Request["start"]);
                int length = Convert.ToInt32(Request["length"]);
                string searchValue = Request["search[value]"];
                string sortColumnName = Request["columns[" + Request["order[0][column]"] + "][name]"];
                string sortDirection = Request["order[0][dir]"];
                SqlConnection conn = new SqlConnection(Connection_String.AMSDB);
                SqlCommand cmdSql = new SqlCommand();
                cmdSql.Connection = conn;
                cmdSql.CommandType = CommandType.StoredProcedure;
                cmdSql.CommandText = @"dbo.GET_RP_AttendanceMonitoring";

                cmdSql.Parameters.Clear();
                cmdSql.Parameters.Add("@Month", SqlDbType.Int).Value = Month;
                cmdSql.Parameters.Add("@Year", SqlDbType.Int).Value = Year;
                cmdSql.Parameters.Add("@Section", SqlDbType.NVarChar).Value = Section;
                cmdSql.Parameters.Add("@Agency", SqlDbType.NVarChar).Value = Agency;
                cmdSql.CommandTimeout = 0;
                conn.Open();

                //if (System.Web.HttpContext.Current.Session["ExportWT"] == null)
                //{
                    SqlDataReader sdr = cmdSql.ExecuteReader();
                    dt.Load(sdr);
                //}

                //else
                //{
                   // dt = (DataTable)System.Web.HttpContext.Current.Session["ExportWT"];
                //}


                //wt.globawt = dt;
                cmdSql.Dispose();
                conn.Close();
                
                List<GET_RP_AttendanceMonitoring_Result> list = test(Month, Year, Section, dt);
                WTGlobal header = GetHeaderVs2(list);
                //WTGlobal header = GetHeaderData(Month, Year, Section, list);
                System.Web.HttpContext.Current.Session["WT"] = header;
                //System.Web.HttpContext.Current.Session["ExportWT"] = dt;

                if (!string.IsNullOrEmpty(searchValue))//filter
                {
                    list = list.Where(x => x.EmpNo.ToLower().Contains(searchValue.ToLower())
                                        || x.EmployeeName.ToLower().Contains(searchValue.ToLower())).ToList<GET_RP_AttendanceMonitoring_Result>();
                }
                if (sortColumnName != "" && sortColumnName != null)
                {
                    if (sortDirection == "asc")
                    {
                        list = list.OrderBy(x => TypeHelper.GetPropertyValue(x, sortColumnName)).ToList();
                    }
                    else
                    {
                        list = list.OrderByDescending(x => TypeHelper.GetPropertyValue(x, sortColumnName)).ToList();
                    }
                }
                else
                {
                    list = list.OrderBy(x => x.Rownum).ToList();
                }

               

                int totalrows = list.Count;
                int totalrowsafterfiltering = list.Count;


                //paging
                list = list.Skip(start).Take(length).ToList<GET_RP_AttendanceMonitoring_Result>();


              
                //return Json(new { header=header,data = list, draw = Request["draw"], recordsTotal = totalrows, recordsFiltered = totalrowsafterfiltering }, JsonRequestBehavior.AllowGet);
                var jsonResult = Json(new { data = list, draw = Request["draw"], recordsTotal = totalrows, recordsFiltered = totalrowsafterfiltering }, JsonRequestBehavior.AllowGet);
                jsonResult.MaxJsonLength = int.MaxValue;
                return jsonResult;
            }
            catch(Exception err)
            {
                Error_Logs error = new Error_Logs();
                error.PageModule = "Reports - Worktime Summary";
                error.ErrorLog = err.Message;
                error.DateLog = DateTime.Now;
                error.Username = user.UserName;
                db.Error_Logs.Add(error);
                db.SaveChanges();
                return Json(new { data = "" }, JsonRequestBehavior.AllowGet);
            }
        }

        public ActionResult ExportWorktimeSummary_Present(int Month, int Year, string Section, string Agency)
        {
            try
            {
                string templateFilename = "WorkTimeSummary.xlsx";
                string dir = Path.GetTempPath();
                string datetimeToday = DateTime.Now.ToString("yyMMddhhmmss");
                DataTable dt = new DataTable();
                string filename = string.Format("WorkTimeSummary_PresentAbsent{0}_{1}.xlsx", datetimeToday, Section);
                FileInfo newFile = new FileInfo(Path.Combine(dir, filename));
                string apptemplatePath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, @"TemplateFiles\ExportReports\", templateFilename);
                FileInfo templateFile = new FileInfo(apptemplatePath);

                
                SqlConnection conn = new SqlConnection(Connection_String.AMSDB);
                SqlCommand cmdSql = new SqlCommand();
                cmdSql.Connection = conn;
                cmdSql.CommandType = CommandType.StoredProcedure;
                cmdSql.CommandText = @"dbo.GET_RP_AttendanceMonitoring";

                cmdSql.Parameters.Clear();
                cmdSql.Parameters.Add("@Month", SqlDbType.Int).Value = Month;
                cmdSql.Parameters.Add("@Year", SqlDbType.Int).Value = Year;
                cmdSql.Parameters.Add("@Section", SqlDbType.NVarChar).Value = Section;
                cmdSql.Parameters.Add("@Agency", SqlDbType.NVarChar).Value = Agency;

                cmdSql.CommandTimeout = 0;
                conn.Open();

                
                SqlDataReader sdr = cmdSql.ExecuteReader();
                dt.Load(sdr);
               

                using (ExcelPackage package = new ExcelPackage(newFile, templateFile))  //-- With template.
                {

                   // dt = (DataTable)System.Web.HttpContext.Current.Session["ExportWT"];
                    List<GET_RP_AttendanceMonitoring_Result> list = new List<GET_RP_AttendanceMonitoring_Result>();
                    list = test(Month, Year, Section, dt); //db.GET_RP_MPCMonitoringv2(Filter.DateFrom, Filter.DateTo, shift, Filter.Line, Filter.Process, section).ToList();
                    ExcelWorksheet ExportData = package.Workbook.Worksheets["AMSSheet"];
                    int start = 2;

                    for (int i = 0; i < list.Count; i++)
                    {
                        ExportData.Cells["A" + start].Value = list[i].Rownum;
                        ExportData.Cells["B" + start].Value = list[i].EmpNo;
                        ExportData.Cells["C" + start].Value = list[i].EmployeeName;
                        ExportData.Cells["D" + start].Value = list[i].Position;
                        ExportData.Cells["E" + start].Value = list[i].CostCode;
                        ExportData.Cells["F" + start].Value = list[i].Schedule;
                        ExportData.Cells["G" + start].Value = list[i].C1;
                        ExportData.Cells["H" + start].Value = list[i].C2;
                        ExportData.Cells["I" + start].Value = list[i].C3;
                        ExportData.Cells["J" + start].Value = list[i].C4;
                        ExportData.Cells["K" + start].Value = list[i].C5;
                        ExportData.Cells["L" + start].Value = list[i].C6;
                        ExportData.Cells["M" + start].Value = list[i].C7;
                        ExportData.Cells["N" + start].Value = list[i].C8;
                        ExportData.Cells["O" + start].Value = list[i].C9;
                        ExportData.Cells["P" + start].Value = list[i].C10;
                        ExportData.Cells["Q" + start].Value = list[i].C11;
                        ExportData.Cells["R" + start].Value = list[i].C12;
                        ExportData.Cells["S" + start].Value = list[i].C13;
                        ExportData.Cells["T" + start].Value = list[i].C14;
                        ExportData.Cells["U" + start].Value = list[i].C15;
                        ExportData.Cells["V" + start].Value = list[i].C16;
                        ExportData.Cells["W" + start].Value = list[i].C17;
                        ExportData.Cells["X" + start].Value = list[i].C18;
                        ExportData.Cells["Y" + start].Value = list[i].C19;
                        ExportData.Cells["Z" + start].Value = list[i].C20;
                        ExportData.Cells["AA" + start].Value = list[i].C21;
                        ExportData.Cells["AB" + start].Value = list[i].C22;
                        ExportData.Cells["AC" + start].Value = list[i].C23;
                        ExportData.Cells["AD" + start].Value = list[i].C24;
                        ExportData.Cells["AE" + start].Value = list[i].C25;
                        ExportData.Cells["AF" + start].Value = list[i].C26;
                        ExportData.Cells["AG" + start].Value = list[i].C27;
                        ExportData.Cells["AH" + start].Value = list[i].C28;
                        ExportData.Cells["AI" + start].Value = list[i].C28;
                        ExportData.Cells["AJ" + start].Value = list[i].C30;
                        ExportData.Cells["AK" + start].Value = list[i].C31;
                        ExportData.Cells["AL" + start].Value = list[i].Pcount;
                        ExportData.Cells["AM" + start].Value = list[i].Bcount;
                        ExportData.Cells["AN" + start].Value = list[i].Ycount;
                        ExportData.Cells["AO" + start].Value = list[i].MLcount;

                        //if (list[i].EmpNo == "AMI2018-06536")
                        //{

                        double c = (double)list[i].Pcount / ((double)list[i].Pcount + (double)list[i].Bcount + (double)list[i].Ycount);
                        double Ppercentage = c * 100;
                        string aaa = Ppercentage.ToString("#.##");

                        if (((double)list[i].Pcount + (double)list[i].Bcount + (double)list[i].Ycount) == 0)
                        {
                            ExportData.Cells["AP" + start].Value = 0;
                        }
                        else
                        {
                            ExportData.Cells["AP" + start].Value = Ppercentage;//aaa + "%";
                        }
                        //}

                        start++;
                    }
                    return File(package.GetAsByteArray(), "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", filename);
                }
            }
            catch (Exception err) { }
            return Json(new { }, JsonRequestBehavior.AllowGet);
        }

        public DataTable ExportsEmployee(int Month, int Year, int Day, string Section, string Agency)
        {
            SqlConnection conn = new SqlConnection(Connection_String.AMSDB);
            SqlCommand cmdSql = new SqlCommand();
            cmdSql.Connection = conn;
            cmdSql.CommandTimeout = 0;
            cmdSql.CommandType = CommandType.StoredProcedure;
            cmdSql.CommandText = @"dbo.GET_RP_AttendanceMonitoring";

            cmdSql.Parameters.Clear();
            cmdSql.Parameters.Add("@Month", SqlDbType.Int).Value = Month;
            cmdSql.Parameters.Add("@Year", SqlDbType.Int).Value = Year;
            cmdSql.Parameters.Add("@Section", SqlDbType.NVarChar).Value = Section;
            cmdSql.Parameters.Add("@Agency", SqlDbType.NVarChar).Value = Agency;

            conn.Open();
            SqlDataReader sdr = cmdSql.ExecuteReader();
            DataTable dt = new DataTable();
            dt.Load(sdr);
            cmdSql.Dispose();
            conn.Close();

            //var list = JsonConvert.SerializeObject(dt,
            //    Formatting.None,
            //    new JsonSerializerSettings()
            //    {
            //        ReferenceLoopHandling = Newtonsoft.Json.ReferenceLoopHandling.Ignore
            //    });

            //return Content(list, "application/json");
          
            return dt;
        }


        #region Working Hours
        public ActionResult GeAttendanceMonitoringList_WorkingHours(int Month, int Year, string Section, string Agency)
        {
            var dt = new DataTable();
            SqlConnection conn = new SqlConnection(Connection_String.AMSDB);
            SqlCommand cmdSql = new SqlCommand();
            cmdSql.Connection = conn;
            cmdSql.CommandType = CommandType.StoredProcedure;
            cmdSql.CommandText = @"dbo.GET_RP_AttendanceMonitoring_TTWorkingHours";
            cmdSql.CommandTimeout = 0;
            cmdSql.Parameters.Clear();
            cmdSql.Parameters.Add("@Month", SqlDbType.Int).Value = Month;
            cmdSql.Parameters.Add("@Year", SqlDbType.Int).Value = Year;
            cmdSql.Parameters.Add("@Section", SqlDbType.NVarChar).Value = Section;
            cmdSql.Parameters.Add("@Agency", SqlDbType.NVarChar).Value = Agency;

            conn.Open();

            //if (System.Web.HttpContext.Current.Session["ExportDTR"] == null)
            //{
                SqlDataReader sdr = cmdSql.ExecuteReader();
                dt.Load(sdr);
            //}

            //else
            //{
            //    dt = (DataTable)System.Web.HttpContext.Current.Session["ExportDTR"];
            //}
          
            cmdSql.Dispose();
            conn.Close();



            //System.Web.HttpContext.Current.Session["ExportDTR"] = dt;

            var list = JsonConvert.SerializeObject(dt,
                Formatting.None,
                new JsonSerializerSettings()
                {
                    ReferenceLoopHandling = Newtonsoft.Json.ReferenceLoopHandling.Ignore
                });

            //return Content(list, "application/json");
            int totalrows = list.Length;
            int totalrowsafterfiltering = list.Length;

            var jsonResult = Json(new { data = list, draw = Request["draw"], recordsTotal = totalrows, recordsFiltered = totalrowsafterfiltering }, JsonRequestBehavior.AllowGet);
            jsonResult.MaxJsonLength = int.MaxValue;
            return jsonResult;
        }
        
        #endregion


        #region OT Hours BreakDown
        public ActionResult GeAttendanceMonitoringList_OTBreakDown(int Month, int Year, string Section, string Agency)
        {

            SqlConnection conn = new SqlConnection(Connection_String.AMSDB);
            SqlCommand cmdSql = new SqlCommand();
            cmdSql.Connection = conn;
            cmdSql.CommandTimeout = 0;
            cmdSql.CommandType = CommandType.StoredProcedure;
            cmdSql.CommandText = @"dbo.GET_RP_AttendanceMonitoring_OTBreakDown";

            cmdSql.Parameters.Clear();
            cmdSql.Parameters.Add("@Month", SqlDbType.Int).Value = Month;
            cmdSql.Parameters.Add("@Year", SqlDbType.Int).Value = Year;
            cmdSql.Parameters.Add("@Section", SqlDbType.NVarChar).Value = Section;
            cmdSql.Parameters.Add("@Agency", SqlDbType.NVarChar).Value = Agency;
            cmdSql.CommandTimeout = 0;

            conn.Open();
            SqlDataReader sdr = cmdSql.ExecuteReader();
            var dt = new DataTable();
            dt.Load(sdr);
            cmdSql.Dispose();
            conn.Close();

            var list = JsonConvert.SerializeObject(dt,
                Formatting.None,
                new JsonSerializerSettings()
                {
                    ReferenceLoopHandling = Newtonsoft.Json.ReferenceLoopHandling.Ignore
                });

            //return Content(list, "application/json");
            int totalrows = list.Length;
            int totalrowsafterfiltering = list.Length;

            var jsonResult = Json(new { data = list, draw = Request["draw"], recordsTotal = totalrows, recordsFiltered = totalrowsafterfiltering }, JsonRequestBehavior.AllowGet);
            jsonResult.MaxJsonLength = int.MaxValue;
            return jsonResult;
        }

        #endregion


        #region Absent Details
        public ActionResult GetAbsentDetails(int Month, int Year, string Section, string Agency)
        {

            //Server Side Parameter
            int start = Convert.ToInt32(Request["start"]);
            int length = Convert.ToInt32(Request["length"]);
            string searchValue = Request["search[value]"];
            string sortColumnName = Request["columns[" + Request["order[0][column]"] + "][name]"];
            string sortDirection = Request["order[0][dir]"];

            List<GET_RP_AbsentDetails_Result> list = new List<GET_RP_AbsentDetails_Result>();
            list = db.GET_RP_AbsentDetails(Month,Year,Section,Agency).ToList();

            if (!string.IsNullOrEmpty(searchValue))//filter
            {
                list = list.Where(x => x.EmpNo.ToLower().Contains(searchValue.ToLower())).ToList<GET_RP_AbsentDetails_Result>();
            }
            if (sortColumnName != "" && sortColumnName != null)
            {
                if (sortDirection == "asc")
                {
                    list = list.OrderBy(x => TypeHelper.GetPropertyValue(x, sortColumnName)).ToList();
                }
                else
                {
                    list = list.OrderByDescending(x => TypeHelper.GetPropertyValue(x, sortColumnName)).ToList();
                }
            }
            int totalrows = list.Count;
            int totalrowsafterfiltering = list.Count;


            //paging
            list = list.Skip(start).Take(length).ToList<GET_RP_AbsentDetails_Result>();
            return Json(new { data = list, draw = Request["draw"], recordsTotal = totalrows, recordsFiltered = totalrowsafterfiltering }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult ExportWorktimeSummary_AbsentDetails(int Month, int Year, string Section, string Agency)
        {
            try
            {
                string templateFilename = "AbsentDetails.xlsx";
                string dir = Path.GetTempPath();
                string datetimeToday = DateTime.Now.ToString("yyMMddhhmmss");
                DataTable dt = new DataTable();
                string filename = string.Format("WorkTimeSummary_AbsentDetails{0}_{1}.xlsx", datetimeToday, Section);
                FileInfo newFile = new FileInfo(Path.Combine(dir, filename));
                string apptemplatePath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, @"TemplateFiles\ExportReports\", templateFilename);
                FileInfo templateFile = new FileInfo(apptemplatePath);

                using (ExcelPackage package = new ExcelPackage(newFile, templateFile))  //-- With template.
                {
                   
                    List<GET_RP_AbsentDetails_Result> list = new List<GET_RP_AbsentDetails_Result>();
                    list = db.GET_RP_AbsentDetails(Month, Year, Section, Agency).ToList();
                    ExcelWorksheet ExportData = package.Workbook.Worksheets["AMSSheet"];
                    int start = 2;

                    for (int i = 0; i < list.Count; i++)
                    {
                        ExportData.Cells["A" + start].Value = list[i].Date;
                        ExportData.Cells["B" + start].Value = list[i].Company;
                        ExportData.Cells["C" + start].Value = list[i].EmpNo;
                        ExportData.Cells["D" + start].Value = list[i].EmployeeName;
                        ExportData.Cells["E" + start].Value = list[i].ModifiedPosition;
                        ExportData.Cells["F" + start].Value = list[i].CostCenter_AMS;
                        ExportData.Cells["G" + start].Value = list[i].LeaveType;
                        ExportData.Cells["H" + start].Value = list[i].Reason;

                        start++;
                    }
                    return File(package.GetAsByteArray(), "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", filename);
                }
            }
            catch (Exception err) { }
            return Json(new { }, JsonRequestBehavior.AllowGet);
        }

        #endregion


        #region EmployeeShift
        public ActionResult GETEmployeeShift(string Month, string Year, string Section, string Agency)
        {
            SqlConnection conn = new SqlConnection(Connection_String.AMSDB);
            SqlCommand cmdSql = new SqlCommand();
            cmdSql.Connection = conn;
            cmdSql.CommandTimeout = 0;
            cmdSql.CommandType = CommandType.StoredProcedure;
            cmdSql.CommandText = @"dbo.GET_RP_AttendanceMonitoring_Shift";

            cmdSql.Parameters.Clear();
            cmdSql.Parameters.Add("@Month", SqlDbType.Int).Value = Month;
            cmdSql.Parameters.Add("@Year", SqlDbType.Int).Value = Year;
            cmdSql.Parameters.Add("@Section", SqlDbType.NVarChar).Value = Section;
            cmdSql.Parameters.Add("@Agency", SqlDbType.NVarChar).Value = Agency;
            
            conn.Open();
           
            var dt = new DataTable();

            //if (System.Web.HttpContext.Current.Session["ExportShift"] == null)
            //{
                SqlDataReader sdr = cmdSql.ExecuteReader();
                dt.Load(sdr);
            //}

            //else
            //{
            //    dt = (DataTable)System.Web.HttpContext.Current.Session["ExportShift"];
            //}
           
            cmdSql.Dispose();
            conn.Close();

            var list = JsonConvert.SerializeObject(dt,
                Formatting.None,
                new JsonSerializerSettings()
                {
                    ReferenceLoopHandling = Newtonsoft.Json.ReferenceLoopHandling.Ignore
                });

            //return Content(list, "application/json");
            int totalrows = list.Length;
            int totalrowsafterfiltering = list.Length;

            var jsonResult = Json(new { data = list, draw = Request["draw"], recordsTotal = totalrows, recordsFiltered = totalrowsafterfiltering }, JsonRequestBehavior.AllowGet);
            jsonResult.MaxJsonLength = int.MaxValue;
            return jsonResult;
        }

        #endregion

        #region Employee Time in out
        public ActionResult GETEmployeeTimeinout(string Month, string Year, string Section, string Agency)
        {
            SqlConnection conn = new SqlConnection(Connection_String.AMSDB);
            SqlCommand cmdSql = new SqlCommand();
            cmdSql.Connection = conn;
            cmdSql.CommandType = CommandType.StoredProcedure;
            cmdSql.CommandText = @"dbo.GET_RP_AttendanceMonitoring_TimeINOUT";

            cmdSql.Parameters.Clear();
            cmdSql.Parameters.Add("@Month", SqlDbType.Int).Value = Month;
            cmdSql.Parameters.Add("@Year", SqlDbType.Int).Value = Year;
            cmdSql.Parameters.Add("@Section", SqlDbType.NVarChar).Value = Section;
            cmdSql.Parameters.Add("@Agency", SqlDbType.NVarChar).Value = Agency;
            cmdSql.CommandTimeout = 0;

            conn.Open();
           
            var dt = new DataTable();
            //if (System.Web.HttpContext.Current.Session["ExportTT"] == null)
            //{
                SqlDataReader sdr = cmdSql.ExecuteReader();
                dt.Load(sdr);
            //}
            //else
            //{
            //    dt = (DataTable)System.Web.HttpContext.Current.Session["ExportTT"];
            //}
            cmdSql.Dispose();
            conn.Close();

            var list = JsonConvert.SerializeObject(dt,
                Formatting.None,
                new JsonSerializerSettings()
                {
                    ReferenceLoopHandling = Newtonsoft.Json.ReferenceLoopHandling.Ignore
                });

            //return Content(list, "application/json");
            int totalrows = list.Length;
            int totalrowsafterfiltering = list.Length;

            var jsonResult = Json(new { data = list, draw = Request["draw"], recordsTotal = totalrows, recordsFiltered = totalrowsafterfiltering }, JsonRequestBehavior.AllowGet);
            jsonResult.MaxJsonLength = int.MaxValue;
            return jsonResult;
        }

        #endregion
    }
}