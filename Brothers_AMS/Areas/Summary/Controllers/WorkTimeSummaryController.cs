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
        public ActionResult WorkTimeSummary()
        {
            return View();
        }

        #region OLD
        //public ActionResult GeAttendanceMonitoringList(int Month, int Year, string Section)
        //{

        //    int start = Convert.ToInt32(Request["start"]);
        //    int length = Convert.ToInt32(Request["length"]);
        //    string searchValue = (Session["RNO"] != null) ? Session["RNO"].ToString() : Request["search[value]"];
        //    string sortColumnName = Request["columns[" + Request["order[0][column]"] + "][name]"];
        //    string sortDirection = Request["order[0][dir]"];


        //    //List<GET_RP_AttendanceMonitoring_Result> list = db.GET_RP_AttendanceMonitoring(Month,Year, Section).ToList();
        //    var list = db.GET_RP_AttendanceMonitoring(Month, Year, Section).ToList();

        //    if (!string.IsNullOrEmpty(searchValue))//filter
        //    {
        //        list = list.Where(x => x.EmployeeName.ToLower().Contains(searchValue.ToLower())).ToList<GET_RP_AttendanceMonitoring_Result>();
        //    }
        //    if (sortColumnName != "" && sortColumnName != null)
        //    {
        //        if (sortDirection == "asc")
        //        {
        //            list = list.OrderBy(x => TypeHelper.GetPropertyValue(x, sortColumnName)).ToList();
        //        }
        //        else
        //        {
        //            list = list.OrderByDescending(x => TypeHelper.GetPropertyValue(x, sortColumnName)).ToList();
        //        }
        //    }
        //    int totalrows = list.Count;
        //    int totalrowsafterfiltering = list.Count;
        //    //paging
        //    list = list.Skip(start).Take(length).ToList<GET_RP_AttendanceMonitoring_Result>();

        //    return Json(new { data = list, draw = Request["draw"], recordsTotal = totalrows, recordsFiltered = totalrowsafterfiltering }, JsonRequestBehavior.AllowGet);
        //}
        #endregion
            
            
        private List<GET_RP_AttendanceMonitoring_Result> test(int Month, int Year, string Section)
        {

            SqlConnection conn = new SqlConnection(Connection_String.AMSDB);
            SqlCommand cmdSql = new SqlCommand();
            cmdSql.Connection = conn;
            cmdSql.CommandType = CommandType.StoredProcedure;
            cmdSql.CommandText = @"dbo.GET_RP_AttendanceMonitoring";

            cmdSql.Parameters.Clear();
            cmdSql.Parameters.Add("@Monthparam", SqlDbType.Int).Value = Month;
            cmdSql.Parameters.Add("@Year", SqlDbType.Int).Value = Year;
            cmdSql.Parameters.Add("@Section", SqlDbType.NVarChar).Value = Section;


            conn.Open();
            SqlDataReader sdr = cmdSql.ExecuteReader();
            var dt = new DataTable();
            dt.Load(sdr);
            cmdSql.Dispose();
            conn.Close();

            List<GET_RP_AttendanceMonitoring_Result> convertedList = new List<GET_RP_AttendanceMonitoring_Result>();

            try
            {
                convertedList = (from rw in dt.AsEnumerable()
                                 select new GET_RP_AttendanceMonitoring_Result()
                                 {
                                     MainRFID = Convert.ToString(rw["MainRFID"]),
                                     EmpNo = Convert.ToString(rw["EmpNo"]),
                                     EmployeeName = Convert.ToString(rw["EmployeeName"]),
                                     Position = Convert.ToString(rw["Position"]),
                                     Schedule = Convert.ToString(rw["Schedule"]),
                                     CostCenter_AMS = Convert.ToString(rw["CostCenter_AMS"]),
                                     Status = Convert.ToString(rw["Status"]),
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
                                         MainRFID = Convert.ToString(rw["MainRFID"]),
                                         EmpNo = Convert.ToString(rw["EmpNo"]),
                                         EmployeeName = Convert.ToString(rw["EmployeeName"]),
                                         Position = Convert.ToString(rw["Position"]),
                                         Schedule = Convert.ToString(rw["Schedule"]),
                                         CostCenter_AMS = Convert.ToString(rw["CostCenter_AMS"]),
                                         Status = Convert.ToString(rw["Status"]),
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
                                         MainRFID = Convert.ToString(rw["MainRFID"]),
                                         EmpNo = Convert.ToString(rw["EmpNo"]),
                                         EmployeeName = Convert.ToString(rw["EmployeeName"]),
                                         Position = Convert.ToString(rw["Position"]),
                                         Schedule = Convert.ToString(rw["Schedule"]),
                                         CostCenter_AMS = Convert.ToString(rw["CostCenter_AMS"]),
                                         Status = Convert.ToString(rw["Status"]),
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
           

            return convertedList;
        }

        public ActionResult GetHeaderData(int Month, int Year, string Section)
        {
          
            List<GET_RP_AttendanceMonitoring_Result> list = test(Month, Year, Section);
            List<GET_RP_AttendanceMonitoring_Result> orig = list;

            int daysinMonth = DateTime.DaysInMonth(2020, 1);
            list = list.Where(x => x.Schedule != null).ToList();
            List<GET_RP_AttendanceMonitoring_Result> Dayshift = list.Where(x => x.Schedule.ToLower().Contains("day")).ToList();
            List<GET_RP_AttendanceMonitoring_Result> NightShift = list.Where(x => x.Schedule.ToLower().Contains("night")).ToList();
            int bDay = BusinessDays(1, 1, 2020);
            int employeecount = orig.Count();//Dayshift.Count + NightShift.Count;
            

            int AbsentCountDay = 0;
            int AbsentCountNight = 0;

            #region DS
            foreach (GET_RP_AttendanceMonitoring_Result row in Dayshift)
            {
                if (row.C1 == "" && Dayname(1, Month, Year))
                {
                    AbsentCountDay++;
                }
                if (row.C2 == "" && Dayname(2, Month, Year))
                {
                    AbsentCountDay++;
                }
                if (row.C3 == "" && Dayname(3, Month, Year))
                {
                    AbsentCountDay++;
                }
                if (row.C4 == "" && Dayname(4, Month, Year))
                {
                    AbsentCountDay++;
                }
                if (row.C5 == "" && Dayname(5, Month, Year))
                {
                    AbsentCountDay++;
                }
                if (row.C6 == "" && Dayname(6, Month, Year))
                {
                    AbsentCountDay++;
                }
                if (row.C7 == "" && Dayname(7, Month, Year))
                {
                    AbsentCountDay++;
                }
                if (row.C8 == "" && Dayname(8, Month, Year))
                {
                    AbsentCountDay++;
                }
                if (row.C9 == "" && Dayname(9, Month, Year))
                {
                    AbsentCountDay++;
                }
                if (row.C10 == "" && Dayname(10, Month, Year))
                {
                    AbsentCountDay++;
                }
                if (row.C11 == "" && Dayname(11, Month, Year))
                {
                    AbsentCountDay++;
                }
                if (row.C12 == "" && Dayname(12, Month, Year))
                {
                    AbsentCountDay++;
                }
                if (row.C13 == "" && Dayname(13, Month, Year))
                {
                    AbsentCountDay++;
                }
                if (row.C14 == "" && Dayname(14, Month, Year))
                {
                    AbsentCountDay++;
                }
                if (row.C15 == "" && Dayname(15, Month, Year))
                {
                    AbsentCountDay++;
                }
                if (row.C16 == "" && Dayname(16, Month, Year))
                {
                    AbsentCountDay++;
                }
                if (row.C17 == "" && Dayname(17, Month, Year))
                {
                    AbsentCountDay++;
                }
                if (row.C18 == "" && Dayname(18, Month, Year))
                {
                    AbsentCountDay++;
                }
                if (row.C19 == "" && Dayname(19, Month, Year))
                {
                    AbsentCountDay++;
                }
                if (row.C20 == "" && Dayname(20, Month, Year))
                {
                    AbsentCountDay++;
                }
                if (row.C21 == "" && Dayname(21, Month, Year))
                {
                    AbsentCountDay++;
                }
                if (row.C22 == "" && Dayname(22, Month, Year))
                {
                    AbsentCountDay++;
                }
                if (row.C23 == "" && Dayname(23, Month, Year))
                {
                    AbsentCountDay++;
                }
                if (row.C24 == "" && Dayname(24, Month, Year))
                {
                    AbsentCountDay++;
                }
                if (row.C25 == "" && Dayname(25, Month, Year))
                {
                    AbsentCountDay++;
                }
                if (row.C26 == "" && Dayname(26, Month, Year))
                {
                    AbsentCountDay++;
                }
                if (row.C27 == "" && Dayname(27, Month, Year))
                {
                    AbsentCountDay++;
                }
                if (row.C28 == "" && Dayname(28, Month, Year))
                {
                    AbsentCountDay++;
                }
                if (row.C29 == "" && Dayname(29, Month, Year))
                {
                    AbsentCountDay++;
                }
                if (row.C30 == "" && Dayname(30, Month, Year))
                {
                    AbsentCountDay++;
                }
                if (row.C31 == "" && Dayname(31, Month, Year))
                {
                    AbsentCountDay++;
                }
            }
            #endregion

            #region NS
            foreach (GET_RP_AttendanceMonitoring_Result row in NightShift)
            {
                if (row.C1 == "" && Dayname(1, Month, Year))
                {
                    AbsentCountNight++;
                }
                if (row.C2 == "" && Dayname(2, Month, Year))
                {
                    AbsentCountNight++;
                }
                if (row.C3 == "" && Dayname(3, Month, Year))
                {
                    AbsentCountNight++;
                }
                if (row.C4 == "" && Dayname(4, Month, Year))
                {
                    AbsentCountNight++;
                }
                if (row.C5 == "" && Dayname(5, Month, Year))
                {
                    AbsentCountNight++;
                }
                if (row.C6 == "" && Dayname(6, Month, Year))
                {
                    AbsentCountNight++;
                }
                if (row.C7 == "" && Dayname(7, Month, Year))
                {
                    AbsentCountNight++;
                }
                if (row.C8 == "" && Dayname(8, Month, Year))
                {
                    AbsentCountNight++;
                }
                if (row.C9 == "" && Dayname(9, Month, Year))
                {
                    AbsentCountNight++;
                }
                if (row.C10 == "" && Dayname(10, Month, Year))
                {
                    AbsentCountNight++;
                }
                if (row.C11 == "" && Dayname(11, Month, Year))
                {
                    AbsentCountNight++;
                }
                if (row.C12 == "" && Dayname(12, Month, Year))
                {
                    AbsentCountNight++;
                }
                if (row.C13 == "" && Dayname(13, Month, Year))
                {
                    AbsentCountNight++;
                }
                if (row.C14 == "" && Dayname(14, Month, Year))
                {
                    AbsentCountNight++;
                }
                if (row.C15 == "" && Dayname(15, Month, Year))
                {
                    AbsentCountNight++;
                }
                if (row.C16 == "" && Dayname(16, Month, Year))
                {
                    AbsentCountNight++;
                }
                if (row.C17 == "" && Dayname(17, Month, Year))
                {
                    AbsentCountNight++;
                }
                if (row.C18 == "" && Dayname(18, Month, Year))
                {
                    AbsentCountNight++;
                }
                if (row.C19 == "" && Dayname(19, Month, Year))
                {
                    AbsentCountNight++;
                }
                if (row.C20 == "" && Dayname(20, Month, Year))
                {
                    AbsentCountNight++;
                }
                if (row.C21 == "" && Dayname(21, Month, Year))
                {
                    AbsentCountNight++;
                }
                if (row.C22 == "" && Dayname(22, Month, Year))
                {
                    AbsentCountNight++;
                }
                if (row.C23 == "" && Dayname(23, Month, Year))
                {
                    AbsentCountNight++;
                }
                if (row.C24 == "" && Dayname(24, Month, Year))
                {
                    AbsentCountNight++;
                }
                if (row.C25 == "" && Dayname(25, Month, Year))
                {
                    AbsentCountNight++;
                }
                if (row.C26 == "" && Dayname(26, Month, Year))
                {
                    AbsentCountNight++;
                }
                if (row.C27 == "" && Dayname(27, Month, Year))
                {
                    AbsentCountNight++;
                }
                if (row.C28 == "" && Dayname(28, Month, Year))
                {
                    AbsentCountNight++;
                }
                if (row.C29 == "" && Dayname(29, Month, Year))
                {
                    AbsentCountNight++;
                }
                if (row.C30 == "" && Dayname(30, Month, Year))
                {
                    AbsentCountNight++;
                }
                if (row.C31 == "" && Dayname(31, Month, Year))
                {
                    AbsentCountNight++;
                }
            }
            #endregion


            decimal DayShiftper = Math.Round((100 * ((decimal)AbsentCountDay / ((decimal)bDay * employeecount))), 2);
            decimal NightShiftper = Math.Round((100 * ((decimal)AbsentCountNight / ((decimal)bDay * employeecount))), 2);




            return Json(new {
                Dayshift= Dayshift.Count,
                NightShift= NightShift.Count,
                DayShiftper= DayShiftper,
                NightShiftper= NightShiftper
            }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult GetAttendanceEmployeeProcess(string EmpNo, string CostCode)
        {
            List<GET_RP_AttendanceMonitoring_Process_Result> list = db.GET_RP_AttendanceMonitoring_Process(EmpNo, CostCode).ToList();
            
            return Json(new {list=list }, JsonRequestBehavior.AllowGet);
        }

        public int BusinessDays(int Month, int daysselected, int year)
        {
            int daysInMonth = 0;
            int days = DateTime.DaysInMonth(year, Month);
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

        public bool Dayname(int daysselected, int Month, int year)
        {
            try
            {
                DateTime day = new DateTime(year, Month, daysselected);
                if ((day.DayOfWeek != DayOfWeek.Sunday) && (day.DayOfWeek != DayOfWeek.Saturday))
                {
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

        public ActionResult ExportAdjust(int Month, int Year, string Section)
        {
            try
            {
           
                string templateFilename = "AttendanceMonitoring.xlsx";
                string dir = Path.GetTempPath();
                string datetimeToday = DateTime.Now.ToString("yyMMddhhmmss");
                string filename = string.Format("AttendanceMonitoring{0}.xlsx", datetimeToday);
                FileInfo newFile = new FileInfo(Path.Combine(dir, filename));
                string apptemplatePath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, @"TemplateFiles\", templateFilename);
                FileInfo templateFile = new FileInfo(apptemplatePath);

                using (ExcelPackage package = new ExcelPackage(newFile, templateFile))  //-- With template.
                {
                    int start = 2;
                    ExcelWorksheet ExportData = package.Workbook.Worksheets["Sheet1"];
                    //List<GET_RP_AttendanceMonitoring_Result> list = test(Month,Year,Section);// db.GET_RP_AttendanceMonitoring(Month, Year, Section).ToList();
                    DataTable s = ExportsEmployee(Month, Year, Section);

                    for (int i = 0; i < s.Rows.Count; i++)
                    {
                        ExportData.Cells["A" + start].Value = s.Rows[i][1].ToString();
                        ExportData.Cells["B" + start].Value = s.Rows[i][2].ToString();
                        ExportData.Cells["C" + start].Value = s.Rows[i][3].ToString();
                        ExportData.Cells["D" + start].Value = s.Rows[i][5].ToString();
                        start++;
                    }

                        //for (int i = 0; i < list.Count; i++)
                        //{
                        //    ExportData.Cells["A" + start].Value = list[i].EmpNo;
                        //    ExportData.Cells["B" + start].Value = list[i].EmployeeName;
                        //    ExportData.Cells["C" + start].Value = list[i].Position;
                        //    ExportData.Cells["D" + start].Value = list[i].CostCenter_AMS;
                        //    start++;
                        //}

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
                    string path = Server.MapPath("~/Uploads/");
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
                                cmdExcel.Connection = connExcel;
                                string sheetName = "Sheet1";
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
                                cmdExcel.CommandText = "SELECT EmployeeNo, LeaveType FROM [" + sheetName + "$]";//ung * is column name, ung sheetname ay settings
                                odaExcel.SelectCommand = cmdExcel;
                                odaExcel.Fill(dt);
                                connExcel.Close();
                                for (int x = 0; x < dt.Rows.Count; x++)
                                {
                                    try
                                    {
                                        string EmployeeNo = dt.Rows[x]["EmployeeNo"].ToString();
                                        string LeaveType = dt.Rows[x]["LeaveType"].ToString();
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

                                                db.RP_AttendanceMonitoring.Add(EmpStatus);
                                                db.SaveChanges();

                                            }
                                            else
                                            {

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
                                        //Error_Logs error = new Error_Logs();
                                        //error.PageModule = "Reports - WorkTimeSummary";
                                        //error.ErrorLog = err.Message;
                                        //error.DateLog = DateTime.Now;
                                        //error.Username = user.UserName;
                                        //db.Error_Logs.Add(error);
                                        //db.SaveChanges();
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

        public ActionResult GeAttendanceMonitoringList(int Month, int Year, string Section)
        {
            SqlConnection conn = new SqlConnection(Connection_String.AMSDB);
            SqlCommand cmdSql = new SqlCommand();
            cmdSql.Connection = conn;
            cmdSql.CommandType = CommandType.StoredProcedure;
            cmdSql.CommandText = @"dbo.GET_RP_AttendanceMonitoring";
            
            cmdSql.Parameters.Clear();
            cmdSql.Parameters.Add("@Monthparam", SqlDbType.Int).Value = Month;
            cmdSql.Parameters.Add("@Year", SqlDbType.Int).Value = Year;
            cmdSql.Parameters.Add("@Section", SqlDbType.NVarChar).Value = Section;

            
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

            return Json(new { data = list, draw = Request["draw"], recordsTotal = totalrows, recordsFiltered = totalrowsafterfiltering }, JsonRequestBehavior.AllowGet);
            //return Json(new { data = list }, JsonRequestBehavior.AllowGet);
        }



        public DataTable ExportsEmployee(int Month, int Year, string Section)
        {
            SqlConnection conn = new SqlConnection(Connection_String.AMSDB);
            SqlCommand cmdSql = new SqlCommand();
            cmdSql.Connection = conn;
            cmdSql.CommandType = CommandType.StoredProcedure;
            cmdSql.CommandText = @"dbo.GET_RP_AttendanceMonitoring";

            cmdSql.Parameters.Clear();
            cmdSql.Parameters.Add("@Monthparam", SqlDbType.Int).Value = Month;
            cmdSql.Parameters.Add("@Year", SqlDbType.Int).Value = Year;
            cmdSql.Parameters.Add("@Section", SqlDbType.NVarChar).Value = Section;


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
        public ActionResult GeAttendanceMonitoringList_WorkingHours(int Month, int Year, string Section)
        {
            SqlConnection conn = new SqlConnection(Connection_String.AMSDB);
            SqlCommand cmdSql = new SqlCommand();
            cmdSql.Connection = conn;
            cmdSql.CommandType = CommandType.StoredProcedure;
            cmdSql.CommandText = @"dbo.GET_RP_AttendanceMonitoring_TTWorkingHours";

            cmdSql.Parameters.Clear();
            cmdSql.Parameters.Add("@Monthparam", SqlDbType.Int).Value = Month;
            cmdSql.Parameters.Add("@Year", SqlDbType.Int).Value = Year;
            cmdSql.Parameters.Add("@Section", SqlDbType.NVarChar).Value = Section;


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

            return Json(new { data = list, draw = Request["draw"], recordsTotal = totalrows, recordsFiltered = totalrowsafterfiltering }, JsonRequestBehavior.AllowGet);
            //return Json(new { data = list }, JsonRequestBehavior.AllowGet);
        }

        #endregion


        #region OT Hours BreakDown
        public ActionResult GeAttendanceMonitoringList_OTBreakDown(int Month, int Year, string Section)
        {
            string lastday = DateTime.DaysInMonth(Year, Month).ToString();
            DateTime MinDate = Convert.ToDateTime(Month.ToString() + "/1/" + Year.ToString());
            DateTime MaxDate = Convert.ToDateTime(Month.ToString() + "/"+lastday+"/" + Year.ToString());

            SqlConnection conn = new SqlConnection(Connection_String.AMSDB);
            SqlCommand cmdSql = new SqlCommand();
            cmdSql.Connection = conn;
            cmdSql.CommandType = CommandType.StoredProcedure;
            cmdSql.CommandText = @"dbo.GET_RP_AttendanceMonitoring_OTBreakDown";

            cmdSql.Parameters.Clear();
            cmdSql.Parameters.Add("@MinDate", SqlDbType.DateTime).Value = MinDate;
            cmdSql.Parameters.Add("@MaxDate", SqlDbType.DateTime).Value = MaxDate;
            cmdSql.Parameters.Add("@Section", SqlDbType.NVarChar).Value = Section;
            cmdSql.CommandTimeout = 180;

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

            return Json(new { data = list, draw = Request["draw"], recordsTotal = totalrows, recordsFiltered = totalrowsafterfiltering }, JsonRequestBehavior.AllowGet);
            //return Json(new { data = list }, JsonRequestBehavior.AllowGet);
        }

        #endregion
    }
}