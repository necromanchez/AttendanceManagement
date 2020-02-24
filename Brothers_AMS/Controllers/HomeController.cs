using Brothers_WMS.Models;
using Brothers_WMS.Models.DashboardModel;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Script.Serialization;

namespace Brothers_WMS.Controllers
{
    [SessionExpire]
    public class HomeController : Controller
    {
        Brothers_AMSDBEntities db = new Brothers_AMSDBEntities();

        public ActionResult Index()
        {
           
            return View();
        }

        public ActionResult ChangePassword()
        {

            return View();
        }
        
        public ActionResult About()
        {
            ViewBag.Message = "Your application description page.";

            return View();
        }

        public ActionResult Contact()
        {
            ViewBag.Message = "Your contact page.";

            return View();
        }


        private List<MARModel> GetAttendanceRate_data(int Month, int Year, string Agency, string Shift)
        {

            SqlConnection conn = new SqlConnection(Connection_String.AMSDB);
            SqlCommand cmdSql = new SqlCommand();
            cmdSql.Connection = conn;
            cmdSql.CommandType = CommandType.StoredProcedure;
            cmdSql.CommandText = @"dbo.GET_Dashboard_AttendanceRate";

            cmdSql.Parameters.Clear();
            cmdSql.Parameters.Add("@Month", SqlDbType.Int).Value = Month;
            cmdSql.Parameters.Add("@Year", SqlDbType.Int).Value = Year;
            cmdSql.Parameters.Add("@Agency", SqlDbType.NVarChar).Value = Agency;
            cmdSql.Parameters.Add("@Shift", SqlDbType.NVarChar).Value = Shift;
            cmdSql.CommandTimeout = 180;
            conn.Open();
          

            SqlDataReader sdr = cmdSql.ExecuteReader();
            var dt = new DataTable();
            dt.Load(sdr);
            cmdSql.Dispose();
            conn.Close();

            List<MARModel> convertedList = new List<MARModel>();

            try
            {
                convertedList = (from rw in dt.AsEnumerable()
                                 select new MARModel()
                                 {
                                  
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
            catch (Exception err)
            {
                try
                {
                    convertedList = (from rw in dt.AsEnumerable()
                                     select new MARModel()
                                     {
                                        
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
                catch (Exception err2)
                {
                    convertedList = (from rw in dt.AsEnumerable()
                                     select new MARModel()
                                     {
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

        private List<MARModel> GetAttendanceRate_AbsentRatedata(int Month, int Year, string Agency)
        {

            SqlConnection conn = new SqlConnection(Connection_String.AMSDB);
            SqlCommand cmdSql = new SqlCommand();
            cmdSql.Connection = conn;
            cmdSql.CommandType = CommandType.StoredProcedure;
            cmdSql.CommandText = @"dbo.GET_Dashboard_AbsentRate";

            cmdSql.Parameters.Clear();
            cmdSql.Parameters.Add("@Month", SqlDbType.Int).Value = Month;
            cmdSql.Parameters.Add("@Year", SqlDbType.Int).Value = Year;
            cmdSql.Parameters.Add("@Agency", SqlDbType.NVarChar).Value = Agency;

            conn.Open();
            SqlDataReader sdr = cmdSql.ExecuteReader();
            var dt = new DataTable();
            dt.Load(sdr);
            cmdSql.Dispose();
            conn.Close();

            List<MARModel> convertedList = new List<MARModel>();

            try
            {
                convertedList = (from rw in dt.AsEnumerable()
                                 select new MARModel()
                                 {

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
            catch (Exception err)
            {
                try
                {
                    convertedList = (from rw in dt.AsEnumerable()
                                     select new MARModel()
                                     {

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
                catch (Exception err2)
                {
                    convertedList = (from rw in dt.AsEnumerable()
                                     select new MARModel()
                                     {
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


        public ActionResult GeAttendanceRate(int Month, int Year, string Agency, string Shift)
        {
            List<MARModel> GetAttendanceRate = GetAttendanceRate_data(Month,Year,Agency,Shift);
            
            return Json(new { data2= GetAttendanceRate }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult GetAttendanceRate_AbsentRate(int Month, int Year, string Agency, string Shift)
        {
            List<MARModel> GetAbsentRate = GetAttendanceRate_AbsentRatedata(Month, Year, Agency);

            return Json(new { data = GetAbsentRate }, JsonRequestBehavior.AllowGet);
        }

    }
}