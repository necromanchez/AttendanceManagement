using Brothers_WMS.Models;
using Brothers_WMS.Models.DashboardModel;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Reflection;
using System.Web;
using System.Web.Mvc;
using System.Web.Script.Serialization;

namespace Brothers_WMS.Controllers
{
    [SessionExpire]
    public class HomeController : Controller
    {
        Brothers_AMSDBEntities db = new Brothers_AMSDBEntities();
       
        M_Users user = (M_Users)System.Web.HttpContext.Current.Session["user"];
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

        public ActionResult ChangeSection(string Section)
        {
            string Costcode = (from c in db.M_Cost_Center_List where c.GroupSection == Section select c.Cost_Center).FirstOrDefault();
            user.CostCode = Costcode;

            return Json(new { }, JsonRequestBehavior.AllowGet);
        }


        private List<MARModel> GetAttendanceRate_data(int Month, int Year, string Agency, string Shift, long? Line)
        {
            string currentuser = user.UserName;
            string CostCode = (from c in db.M_Employee_CostCenter where c.EmployNo == currentuser orderby c.ID descending select c.CostCenter_AMS).FirstOrDefault();

            CostCode = (CostCode == null) ? user.CostCode : CostCode;
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
            cmdSql.Parameters.Add("@Line", SqlDbType.BigInt).Value = Line;
            cmdSql.Parameters.Add("@CostCode", SqlDbType.NVarChar).Value = CostCode;
            cmdSql.CommandTimeout = 0;
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
            //PropertyInfo[] columns = convertedList.First().GetType().GetProperties();
            //foreach (var f in columns)
            //{
            //    string s = f.Name;
            //    convertedList[2].[s] = "555";


            //}
            try
            {
                convertedList = Topercent(convertedList);
            }
            catch(Exception err) { }
            return convertedList;
        }

        public List<MARModel> Topercent(List<MARModel> convertedList)
        {
           
            convertedList[2].C1 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[1].C1) / Convert.ToInt32(convertedList[2].C1)))).ToString();
            convertedList[2].C2 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[1].C2) / Convert.ToInt32(convertedList[2].C2)))).ToString();
            convertedList[2].C3 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[1].C3) / Convert.ToInt32(convertedList[2].C3)))).ToString();
            convertedList[2].C4 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[1].C4) / Convert.ToInt32(convertedList[2].C4)))).ToString();
            convertedList[2].C5 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[1].C5) / Convert.ToInt32(convertedList[2].C5)))).ToString();
            convertedList[2].C6 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[1].C6) / Convert.ToInt32(convertedList[2].C6)))).ToString();
            convertedList[2].C7 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[1].C7) / Convert.ToInt32(convertedList[2].C7)))).ToString();
            convertedList[2].C8 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[1].C8) / Convert.ToInt32(convertedList[2].C8)))).ToString();
            convertedList[2].C9 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[1].C9) / Convert.ToInt32(convertedList[2].C9)))).ToString();
            convertedList[2].C10 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[1].C10) / Convert.ToInt32(convertedList[2].C10)))).ToString();
            convertedList[2].C11 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[1].C11) / Convert.ToInt32(convertedList[2].C11)))).ToString();
            convertedList[2].C12 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[1].C12) / Convert.ToInt32(convertedList[2].C12)))).ToString();
            convertedList[2].C13 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[1].C13) / Convert.ToInt32(convertedList[2].C13)))).ToString();
            convertedList[2].C14 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[1].C14) / Convert.ToInt32(convertedList[2].C14)))).ToString();
            convertedList[2].C15 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[1].C15) / Convert.ToInt32(convertedList[2].C15)))).ToString();
            convertedList[2].C16 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[1].C16) / Convert.ToInt32(convertedList[2].C16)))).ToString();
            convertedList[2].C17 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[1].C17) / Convert.ToInt32(convertedList[2].C17)))).ToString();
            convertedList[2].C18 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[1].C18) / Convert.ToInt32(convertedList[2].C18)))).ToString();
            convertedList[2].C19 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[1].C19) / Convert.ToInt32(convertedList[2].C19)))).ToString();
            convertedList[2].C20 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[1].C20) / Convert.ToInt32(convertedList[2].C20)))).ToString();
            convertedList[2].C21 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[1].C21) / Convert.ToInt32(convertedList[2].C21)))).ToString();
            convertedList[2].C22 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[1].C22) / Convert.ToInt32(convertedList[2].C22)))).ToString();
            convertedList[2].C23 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[1].C23) / Convert.ToInt32(convertedList[2].C23)))).ToString();
            convertedList[2].C24 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[1].C24) / Convert.ToInt32(convertedList[2].C24)))).ToString();
            convertedList[2].C25 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[1].C25) / Convert.ToInt32(convertedList[2].C25)))).ToString();
            convertedList[2].C26 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[1].C26) / Convert.ToInt32(convertedList[2].C26)))).ToString();
            convertedList[2].C27 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[1].C27) / Convert.ToInt32(convertedList[2].C27)))).ToString();
            convertedList[2].C28 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[1].C28) / Convert.ToInt32(convertedList[2].C28)))).ToString();
            convertedList[2].C29 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[1].C29) / Convert.ToInt32(convertedList[2].C29)))).ToString();
            if (convertedList[2].C30 != null)
            {
                convertedList[2].C30 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[1].C30) / Convert.ToInt32(convertedList[2].C30)))).ToString();
            }
            if (convertedList[2].C31 != null)
            {
                convertedList[2].C31 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[1].C31) / Convert.ToInt32(convertedList[2].C31)))).ToString();
            }
           

            return convertedList;
        }
        public List<MARModel> Topercent_AbsentRate(List<MARModel> convertedList)
        {
            List<MARModel> absentdata = new List<MARModel>();
            try
            {
                MARModel Daydata = new MARModel();
                Daydata.C1 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[2].C1) / Convert.ToInt32(convertedList[0].C1)))).ToString();
                Daydata.C2 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[2].C2) / Convert.ToInt32(convertedList[0].C2)))).ToString();
                Daydata.C3 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[2].C3) / Convert.ToInt32(convertedList[0].C3)))).ToString();
                Daydata.C4 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[2].C4) / Convert.ToInt32(convertedList[0].C4)))).ToString();
                Daydata.C5 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[2].C5) / Convert.ToInt32(convertedList[0].C5)))).ToString();

                Daydata.C6 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[2].C6) / Convert.ToInt32(convertedList[0].C6)))).ToString();
                Daydata.C7 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[2].C7) / Convert.ToInt32(convertedList[0].C7)))).ToString();
                Daydata.C8 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[2].C8) / Convert.ToInt32(convertedList[0].C8)))).ToString();
                Daydata.C9 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[2].C9) / Convert.ToInt32(convertedList[0].C9)))).ToString();
                Daydata.C10 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[2].C10) / Convert.ToInt32(convertedList[0].C10)))).ToString();
                Daydata.C11 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[2].C11) / Convert.ToInt32(convertedList[0].C11)))).ToString();
                Daydata.C12 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[2].C12) / Convert.ToInt32(convertedList[0].C12)))).ToString();
                Daydata.C13 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[2].C13) / Convert.ToInt32(convertedList[0].C13)))).ToString();
                Daydata.C14 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[2].C14) / Convert.ToInt32(convertedList[0].C14)))).ToString();
                Daydata.C15 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[2].C15) / Convert.ToInt32(convertedList[0].C15)))).ToString();
                Daydata.C16 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[2].C16) / Convert.ToInt32(convertedList[0].C16)))).ToString();
                Daydata.C17 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[2].C17) / Convert.ToInt32(convertedList[0].C17)))).ToString();
                Daydata.C18 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[2].C18) / Convert.ToInt32(convertedList[0].C18)))).ToString();
                Daydata.C19 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[2].C19) / Convert.ToInt32(convertedList[0].C19)))).ToString();
                Daydata.C20 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[2].C20) / Convert.ToInt32(convertedList[0].C20)))).ToString();
                Daydata.C21 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[2].C21) / Convert.ToInt32(convertedList[0].C21)))).ToString();
                Daydata.C22 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[2].C22) / Convert.ToInt32(convertedList[0].C22)))).ToString();
                Daydata.C23 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[2].C23) / Convert.ToInt32(convertedList[0].C23)))).ToString();
                Daydata.C24 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[2].C24) / Convert.ToInt32(convertedList[0].C24)))).ToString();
                Daydata.C25 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[2].C25) / Convert.ToInt32(convertedList[0].C25)))).ToString();
                Daydata.C26 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[2].C26) / Convert.ToInt32(convertedList[0].C26)))).ToString();
                Daydata.C27 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[2].C27) / Convert.ToInt32(convertedList[0].C27)))).ToString();
                Daydata.C28 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[2].C28) / Convert.ToInt32(convertedList[0].C28)))).ToString();
                Daydata.C29 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[2].C29) / Convert.ToInt32(convertedList[0].C29)))).ToString();
                if (convertedList[0].C30 != null)
                {
                    Daydata.C30 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[2].C30) / Convert.ToInt32(convertedList[0].C30)))).ToString();
                }
                if (convertedList[0].C31 != null)
                {
                    Daydata.C31 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[2].C31) / Convert.ToInt32(convertedList[0].C31)))).ToString();
                }
                absentdata.Add(Daydata);


                MARModel Nightdata = new MARModel();
                Nightdata.C1 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[3].C1) / Convert.ToInt32(convertedList[1].C1)))).ToString();
                Nightdata.C2 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[3].C2) / Convert.ToInt32(convertedList[1].C2)))).ToString();
                Nightdata.C3 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[3].C3) / Convert.ToInt32(convertedList[1].C3)))).ToString();
                Nightdata.C4 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[3].C4) / Convert.ToInt32(convertedList[1].C4)))).ToString();
                Nightdata.C5 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[3].C5) / Convert.ToInt32(convertedList[1].C5)))).ToString();

                Nightdata.C6 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[3].C6) / Convert.ToInt32(convertedList[1].C6)))).ToString();
                Nightdata.C7 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[3].C7) / Convert.ToInt32(convertedList[1].C7)))).ToString();
                Nightdata.C8 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[3].C8) / Convert.ToInt32(convertedList[1].C8)))).ToString();
                Nightdata.C9 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[3].C9) / Convert.ToInt32(convertedList[1].C9)))).ToString();
                Nightdata.C10 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[3].C10) / Convert.ToInt32(convertedList[1].C10)))).ToString();
                Nightdata.C11 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[3].C11) / Convert.ToInt32(convertedList[1].C11)))).ToString();
                Nightdata.C12 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[3].C12) / Convert.ToInt32(convertedList[1].C12)))).ToString();
                Nightdata.C13 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[3].C13) / Convert.ToInt32(convertedList[1].C13)))).ToString();
                Nightdata.C14 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[3].C14) / Convert.ToInt32(convertedList[1].C14)))).ToString();
                Nightdata.C15 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[3].C15) / Convert.ToInt32(convertedList[1].C15)))).ToString();
                Nightdata.C16 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[3].C16) / Convert.ToInt32(convertedList[1].C16)))).ToString();
                Nightdata.C17 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[3].C17) / Convert.ToInt32(convertedList[1].C17)))).ToString();
                Nightdata.C18 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[3].C18) / Convert.ToInt32(convertedList[1].C18)))).ToString();
                Nightdata.C19 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[3].C19) / Convert.ToInt32(convertedList[1].C19)))).ToString();
                Nightdata.C20 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[3].C20) / Convert.ToInt32(convertedList[1].C20)))).ToString();
                Nightdata.C21 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[3].C21) / Convert.ToInt32(convertedList[1].C21)))).ToString();
                Nightdata.C22 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[3].C22) / Convert.ToInt32(convertedList[1].C22)))).ToString();
                Nightdata.C23 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[3].C23) / Convert.ToInt32(convertedList[1].C23)))).ToString();
                Nightdata.C24 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[3].C24) / Convert.ToInt32(convertedList[1].C24)))).ToString();
                Nightdata.C25 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[3].C25) / Convert.ToInt32(convertedList[1].C25)))).ToString();
                Nightdata.C26 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[3].C26) / Convert.ToInt32(convertedList[1].C26)))).ToString();
                Nightdata.C27 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[3].C27) / Convert.ToInt32(convertedList[1].C27)))).ToString();
                Nightdata.C28 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[3].C28) / Convert.ToInt32(convertedList[1].C28)))).ToString();
                Nightdata.C29 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[3].C29) / Convert.ToInt32(convertedList[1].C29)))).ToString();
                if (convertedList[1].C30 != null)
                {
                    Nightdata.C30 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[3].C30) / Convert.ToInt32(convertedList[1].C30)))).ToString();
                }
                if (convertedList[1].C31 != null)
                {
                    Nightdata.C31 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[3].C31) / Convert.ToInt32(convertedList[1].C31)))).ToString();
                }
                absentdata.Add(Nightdata);



                MARModel Totaldata = new MARModel();
                Totaldata.C1 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[4].C1) / Convert.ToInt32(convertedList[5].C1)))).ToString();
                Totaldata.C2 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[4].C2) / Convert.ToInt32(convertedList[5].C2)))).ToString();
                Totaldata.C3 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[4].C3) / Convert.ToInt32(convertedList[5].C3)))).ToString();
                Totaldata.C4 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[4].C4) / Convert.ToInt32(convertedList[5].C4)))).ToString();
                Totaldata.C5 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[4].C5) / Convert.ToInt32(convertedList[5].C5)))).ToString();

                Totaldata.C6 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[4].C6) / Convert.ToInt32(convertedList[5].C6)))).ToString();
                Totaldata.C7 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[4].C7) / Convert.ToInt32(convertedList[5].C7)))).ToString();
                Totaldata.C8 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[4].C8) / Convert.ToInt32(convertedList[5].C8)))).ToString();
                Totaldata.C9 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[4].C9) / Convert.ToInt32(convertedList[5].C9)))).ToString();
                Totaldata.C10 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[4].C10) / Convert.ToInt32(convertedList[5].C10)))).ToString();
                Totaldata.C11 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[4].C11) / Convert.ToInt32(convertedList[5].C11)))).ToString();
                Totaldata.C12 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[4].C12) / Convert.ToInt32(convertedList[5].C12)))).ToString();
                Totaldata.C13 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[4].C13) / Convert.ToInt32(convertedList[5].C13)))).ToString();
                Totaldata.C14 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[4].C14) / Convert.ToInt32(convertedList[5].C14)))).ToString();
                Totaldata.C15 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[4].C15) / Convert.ToInt32(convertedList[5].C15)))).ToString();
                Totaldata.C16 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[4].C16) / Convert.ToInt32(convertedList[5].C16)))).ToString();
                Totaldata.C17 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[4].C17) / Convert.ToInt32(convertedList[5].C17)))).ToString();
                Totaldata.C18 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[4].C18) / Convert.ToInt32(convertedList[5].C18)))).ToString();
                Totaldata.C19 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[4].C19) / Convert.ToInt32(convertedList[5].C19)))).ToString();
                Totaldata.C20 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[4].C20) / Convert.ToInt32(convertedList[5].C20)))).ToString();
                Totaldata.C21 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[4].C21) / Convert.ToInt32(convertedList[5].C21)))).ToString();
                Totaldata.C22 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[4].C22) / Convert.ToInt32(convertedList[5].C22)))).ToString();
                Totaldata.C23 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[4].C23) / Convert.ToInt32(convertedList[5].C23)))).ToString();
                Totaldata.C24 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[4].C24) / Convert.ToInt32(convertedList[5].C24)))).ToString();
                Totaldata.C25 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[4].C25) / Convert.ToInt32(convertedList[5].C25)))).ToString();
                Totaldata.C26 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[4].C26) / Convert.ToInt32(convertedList[5].C26)))).ToString();
                Totaldata.C27 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[4].C27) / Convert.ToInt32(convertedList[5].C27)))).ToString();
                Totaldata.C28 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[4].C28) / Convert.ToInt32(convertedList[5].C28)))).ToString();
                Totaldata.C29 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[4].C29) / Convert.ToInt32(convertedList[5].C29)))).ToString();
                if (convertedList[5].C30 != null)
                {
                    Totaldata.C30 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[4].C30) / Convert.ToInt32(convertedList[5].C30)))).ToString();
                }
                if (convertedList[5].C31 != null)
                {
                    Totaldata.C31 = ((int)Math.Round((double)(100 * Convert.ToInt32(convertedList[4].C31) / Convert.ToInt32(convertedList[5].C31)))).ToString();
                }
                absentdata.Add(Totaldata);


                MARModel TotalABS = new MARModel();
                TotalABS.C1 = convertedList[4].C1;
                TotalABS.C2 = convertedList[4].C2;
                TotalABS.C3 = convertedList[4].C3;
                TotalABS.C4 = convertedList[4].C4;
                TotalABS.C5 = convertedList[4].C5;

                TotalABS.C6 = convertedList[4].C6;
                TotalABS.C7 = convertedList[4].C7;
                TotalABS.C8 = convertedList[4].C8;
                TotalABS.C9 = convertedList[4].C9;
                TotalABS.C10 = convertedList[4].C10;
                TotalABS.C11 = convertedList[4].C11;
                TotalABS.C12 = convertedList[4].C12;
                TotalABS.C13 = convertedList[4].C13;
                TotalABS.C14 = convertedList[4].C14;
                TotalABS.C15 = convertedList[4].C15;
                TotalABS.C16 = convertedList[4].C16;
                TotalABS.C17 = convertedList[4].C17;
                TotalABS.C18 = convertedList[4].C18;
                TotalABS.C19 = convertedList[4].C19;
                TotalABS.C20 = convertedList[4].C20;
                TotalABS.C21 = convertedList[4].C21;
                TotalABS.C22 = convertedList[4].C22;
                TotalABS.C23 = convertedList[4].C23;
                TotalABS.C24 = convertedList[4].C24;
                TotalABS.C25 = convertedList[4].C25;
                TotalABS.C26 = convertedList[4].C26;
                TotalABS.C27 = convertedList[4].C27;
                TotalABS.C28 = convertedList[4].C28;
                TotalABS.C29 = convertedList[4].C29;
                if (convertedList[5].C30 != null)
                {
                    TotalABS.C30 = convertedList[4].C30;
                }
                if (convertedList[5].C31 != null)
                {
                    TotalABS.C31 = convertedList[4].C31;
                }

                absentdata.Add(TotalABS);
                return absentdata;
            }
            catch(Exception err)
            {
                return convertedList;
            }


           
        }

        public List<MARModel> Topercent_Awol(List<MARModel> convertedList)
        {
            convertedList[2].C1 = Math.Round(((double)(100 * Convert.ToInt32(convertedList[2].C1)) / Convert.ToInt32(convertedList[0].C10)), 2).ToString();
            convertedList[2].C2 = Math.Round(((double)(100 * Convert.ToInt32(convertedList[2].C2)) / Convert.ToInt32(convertedList[0].C2)), 2).ToString();
            convertedList[2].C3 = Math.Round(((double)(100 * Convert.ToInt32(convertedList[2].C3)) / Convert.ToInt32(convertedList[0].C3)), 2).ToString();
            convertedList[2].C4 = Math.Round(((double)(100 * Convert.ToInt32(convertedList[2].C4)) / Convert.ToInt32(convertedList[0].C4)), 2).ToString();
            convertedList[2].C5 = Math.Round(((double)(100 * Convert.ToInt32(convertedList[2].C5)) / Convert.ToInt32(convertedList[0].C5)), 2).ToString();
            convertedList[2].C6 = Math.Round(((double)(100 * Convert.ToInt32(convertedList[2].C6)) / Convert.ToInt32(convertedList[0].C6)), 2).ToString();
            convertedList[2].C7 = Math.Round(((double)(100 * Convert.ToInt32(convertedList[2].C7)) / Convert.ToInt32(convertedList[0].C7)), 2).ToString();
            convertedList[2].C8 = Math.Round(((double)(100 * Convert.ToInt32(convertedList[2].C8)) / Convert.ToInt32(convertedList[0].C8)), 2).ToString();
            convertedList[2].C9 = Math.Round(((double)(100 * Convert.ToInt32(convertedList[2].C9)) / Convert.ToInt32(convertedList[0].C9)), 2).ToString();
            convertedList[2].C10 = Math.Round(((double)(100 * Convert.ToInt32(convertedList[2].C10)) / Convert.ToInt32(convertedList[0].C10)),2).ToString();
            convertedList[2].C11 = Math.Round(((double)(100 * Convert.ToInt32(convertedList[2].C11)) / Convert.ToInt32(convertedList[0].C11)), 2).ToString();
            convertedList[2].C12 = Math.Round(((double)(100 * Convert.ToInt32(convertedList[2].C12)) / Convert.ToInt32(convertedList[0].C12)), 2).ToString();
            convertedList[2].C13 = Math.Round(((double)(100 * Convert.ToInt32(convertedList[2].C13)) / Convert.ToInt32(convertedList[0].C13)), 2).ToString();
            convertedList[2].C14 = Math.Round(((double)(100 * Convert.ToInt32(convertedList[2].C14)) / Convert.ToInt32(convertedList[0].C14)), 2).ToString();
            convertedList[2].C15 = Math.Round(((double)(100 * Convert.ToInt32(convertedList[2].C15)) / Convert.ToInt32(convertedList[0].C15)), 2).ToString();
            convertedList[2].C16 = Math.Round(((double)(100 * Convert.ToInt32(convertedList[2].C16)) / Convert.ToInt32(convertedList[0].C16)), 2).ToString();
            convertedList[2].C17 = Math.Round(((double)(100 * Convert.ToInt32(convertedList[2].C17)) / Convert.ToInt32(convertedList[0].C17)), 2).ToString();
            convertedList[2].C18 = Math.Round(((double)(100 * Convert.ToInt32(convertedList[2].C18)) / Convert.ToInt32(convertedList[0].C18)), 2).ToString();
            convertedList[2].C19 = Math.Round(((double)(100 * Convert.ToInt32(convertedList[2].C19)) / Convert.ToInt32(convertedList[0].C19)), 2).ToString();
            convertedList[2].C20 = Math.Round(((double)(100 * Convert.ToInt32(convertedList[2].C20)) / Convert.ToInt32(convertedList[0].C20)), 2).ToString();
            convertedList[2].C21 = Math.Round(((double)(100 * Convert.ToInt32(convertedList[2].C21)) / Convert.ToInt32(convertedList[0].C21)), 2).ToString();
            convertedList[2].C22 = Math.Round(((double)(100 * Convert.ToInt32(convertedList[2].C22)) / Convert.ToInt32(convertedList[0].C22)), 2).ToString();
            convertedList[2].C23 = Math.Round(((double)(100 * Convert.ToInt32(convertedList[2].C23)) / Convert.ToInt32(convertedList[0].C23)), 2).ToString();
            convertedList[2].C24 = Math.Round(((double)(100 * Convert.ToInt32(convertedList[2].C24)) / Convert.ToInt32(convertedList[0].C24)), 2).ToString();
            convertedList[2].C25 = Math.Round(((double)(100 * Convert.ToInt32(convertedList[2].C25)) / Convert.ToInt32(convertedList[0].C25)), 2).ToString();
            convertedList[2].C26 = Math.Round(((double)(100 * Convert.ToInt32(convertedList[2].C26)) / Convert.ToInt32(convertedList[0].C26)), 2).ToString();
            convertedList[2].C27 = Math.Round(((double)(100 * Convert.ToInt32(convertedList[2].C27)) / Convert.ToInt32(convertedList[0].C27)), 2).ToString();
            convertedList[2].C28 = Math.Round(((double)(100 * Convert.ToInt32(convertedList[2].C28)) / Convert.ToInt32(convertedList[0].C28)), 2).ToString();
            convertedList[2].C29 = Math.Round(((double)(100 * Convert.ToInt32(convertedList[2].C29)) / Convert.ToInt32(convertedList[0].C29)), 2).ToString();
            if (convertedList[2].C30 != null)
            {
                convertedList[2].C30 = Math.Round(((double)(100 * Convert.ToInt32(convertedList[2].C30)) / Convert.ToInt32(convertedList[0].C30)), 2).ToString();
            }
            if (convertedList[2].C31 != null)
            {
                convertedList[2].C31 = Math.Round(((double)(100 * Convert.ToInt32(convertedList[2].C31)) / Convert.ToInt32(convertedList[0].C31)), 2).ToString();
            }


            return convertedList;
        }

        private List<MARModel> GetAttendanceRate_AbsentRatedata(int Month, int Year, string Agency, long? Line)
        {
            string currentuser = user.UserName;
            string CostCode = (from c in db.M_Employee_CostCenter where c.EmployNo == currentuser orderby c.ID descending select c.CostCenter_AMS).FirstOrDefault();
            CostCode = (CostCode == null) ? user.CostCode : CostCode;
            SqlConnection conn = new SqlConnection(Connection_String.AMSDB);
            SqlCommand cmdSql = new SqlCommand();
            cmdSql.Connection = conn;
            cmdSql.CommandType = CommandType.StoredProcedure;
            cmdSql.CommandText = @"dbo.GET_Dashboard_AbsentRate";

            cmdSql.Parameters.Clear();
            cmdSql.Parameters.Add("@Month", SqlDbType.Int).Value = Month;
            cmdSql.Parameters.Add("@Year", SqlDbType.Int).Value = Year;
            cmdSql.Parameters.Add("@Agency", SqlDbType.NVarChar).Value = Agency;
            cmdSql.Parameters.Add("@Line", SqlDbType.BigInt).Value = Line;
            cmdSql.Parameters.Add("@CostCode", SqlDbType.NVarChar).Value = CostCode;
            conn.Open();
            cmdSql.CommandTimeout = 0;
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


        public ActionResult GeAttendanceRate(int Month, int Year, string Agency, string Shift, long? Line)
        {
            List<MARModel> GetAttendanceRate = GetAttendanceRate_data(Month,Year,Agency,Shift,Line);
            
            return Json(new { data2= GetAttendanceRate }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult GetAttendanceRate_AbsentRate(int Month, int Year, string Agency, long? Line)
        {
            List<MARModel> GetAbsentRate = GetAttendanceRate_AbsentRatedata(Month, Year, Agency, Line);
            GetAbsentRate = Topercent_AbsentRate(GetAbsentRate);
            return Json(new { data = GetAbsentRate }, JsonRequestBehavior.AllowGet);
        }


        private List<MarModelLV> GetAbsentBreakdownRate_data(int Month, int Year, string Agency, string Shift, long? Line)
        {
            string currentuser = user.UserName;
            string CostCode = (from c in db.M_Employee_CostCenter where c.EmployNo == currentuser orderby c.ID descending select c.CostCenter_AMS).FirstOrDefault();
            CostCode = (CostCode == null) ? user.CostCode : CostCode;
            List<MarModelLV> convertedList = new List<MarModelLV>();
            if (CostCode != "")
            {
                SqlConnection conn = new SqlConnection(Connection_String.AMSDB);
                SqlCommand cmdSql = new SqlCommand();
                cmdSql.Connection = conn;
                cmdSql.CommandType = CommandType.StoredProcedure;
                cmdSql.CommandText = @"dbo.GET_Dashboard_LeaveBreakDownRatev2";

                cmdSql.Parameters.Clear();
                cmdSql.Parameters.Add("@Month", SqlDbType.Int).Value = Month;
                cmdSql.Parameters.Add("@Year", SqlDbType.Int).Value = Year;
                cmdSql.Parameters.Add("@Agency", SqlDbType.NVarChar).Value = Agency;
                cmdSql.Parameters.Add("@Line", SqlDbType.BigInt).Value = Line;
                cmdSql.Parameters.Add("@Shift", SqlDbType.NVarChar).Value = Shift;
                cmdSql.Parameters.Add("@CostCode", SqlDbType.NVarChar).Value = CostCode;

                conn.Open();


                SqlDataReader sdr = cmdSql.ExecuteReader();
                var dt = new DataTable();
                dt.Load(sdr);
                cmdSql.Dispose();
                conn.Close();

               

                try
                {
                    convertedList = (from rw in dt.AsEnumerable()
                                     select new MarModelLV()
                                     {
                                         LeaveType = Convert.ToString(rw["LeaveType"]),
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
                                         select new MarModelLV()
                                         {
                                             LeaveType = Convert.ToString(rw["LeaveType"]),
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
                                         select new MarModelLV()
                                         {
                                             LeaveType = Convert.ToString(rw["LeaveType"]),
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
            }

            return convertedList;
        }

        public ActionResult GetAbsentBreakdownRate(int Month, int Year, string Agency, string Shift, long? Line)
        {
            List<MarModelLV> GetAbsentBreakdownRate = GetAbsentBreakdownRate_data(Month, Year, Agency, Shift, Line);

            return Json(new { data2 = GetAbsentBreakdownRate }, JsonRequestBehavior.AllowGet);
        }

        private List<MARModel> GetAWOLResignedRate_data(int Month, int Year, string Agency, string Shift, long? Line)
        {
            string currentuser = user.UserName;
            string CostCode = (from c in db.M_Employee_CostCenter where c.EmployNo == currentuser orderby c.ID descending select c.CostCenter_AMS).FirstOrDefault();
            CostCode = (CostCode == null) ? user.CostCode : CostCode;
            List<MARModel> convertedList = new List<MARModel>();

            if (CostCode != "")
            {
                SqlConnection conn = new SqlConnection(Connection_String.AMSDB);
                SqlCommand cmdSql = new SqlCommand();
                cmdSql.Connection = conn;
                cmdSql.CommandType = CommandType.StoredProcedure;
                cmdSql.CommandText = @"dbo.GET_Dashboard_AWOLresignRate";

                cmdSql.Parameters.Clear();
                cmdSql.Parameters.Add("@Month", SqlDbType.Int).Value = Month;
                cmdSql.Parameters.Add("@Year", SqlDbType.Int).Value = Year;
                cmdSql.Parameters.Add("@Agency", SqlDbType.NVarChar).Value = Agency;
                cmdSql.Parameters.Add("@Shift", SqlDbType.NVarChar).Value = Shift;
                cmdSql.Parameters.Add("@Line", SqlDbType.BigInt).Value = Line;
                cmdSql.Parameters.Add("@CostCode", SqlDbType.NVarChar).Value = CostCode;
                //cmdSql.Parameters.Add("@Shift", SqlDbType.NVarChar).Value = Shift;
                cmdSql.CommandTimeout = 180;
                conn.Open();


                SqlDataReader sdr = cmdSql.ExecuteReader();
                var dt = new DataTable();
                dt.Load(sdr);
                cmdSql.Dispose();
                conn.Close();

             
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

                convertedList = Topercent_Awol(convertedList);
            }
            return convertedList;
        }

        public ActionResult GetAWOLResignedRate(int Month, int Year, string Agency, string Shift, long? Line)
        {

            List<MARModel> GetAWOLResignedRate = new List<Models.DashboardModel.MARModel>();
            try
            {
                GetAWOLResignedRate_data(Month, Year, Agency, Shift, Line);
            }
            catch(Exception err) { }

            return Json(new { data2 = GetAWOLResignedRate }, JsonRequestBehavior.AllowGet);
        }


        private List<MARModel> GetOvertime_data(int Month, int Year, string Agency, long? Line)
        {

            SqlConnection conn = new SqlConnection(Connection_String.AMSDB);
            SqlCommand cmdSql = new SqlCommand();
            cmdSql.Connection = conn;
            cmdSql.CommandType = CommandType.StoredProcedure;
            cmdSql.CommandText = @"dbo.GET_Dashboard_OvertimeRate";

            cmdSql.Parameters.Clear();
            cmdSql.Parameters.Add("@Month", SqlDbType.Int).Value = Month;
            cmdSql.Parameters.Add("@Year", SqlDbType.Int).Value = Year;
            cmdSql.Parameters.Add("@Agency", SqlDbType.NVarChar).Value = Agency;
            cmdSql.Parameters.Add("@Line", SqlDbType.BigInt).Value = Line;
            cmdSql.CommandTimeout = 0;
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

        public ActionResult GetOvertime(int Month, int Year, string Agency, long? Line)
        {
            List<MARModel> GetovertimeRate = GetOvertime_data(Month, Year, Agency, Line);

            return Json(new { data = GetovertimeRate }, JsonRequestBehavior.AllowGet);
        }



        #region MonthlyGeneration

        public ActionResult GetMonthly_AttendanceRate(int Year, string Agency, long? Line, string Shift)
        {
            string currentuser = user.UserName;
            string CostCode = (from c in db.M_Employee_CostCenter where c.EmployNo == currentuser orderby c.ID descending select c.CostCenter_AMS).FirstOrDefault();
            CostCode = (CostCode == null) ? user.CostCode : CostCode;
            SqlConnection conn = new SqlConnection(Connection_String.AMSDB);
            SqlCommand cmdSql = new SqlCommand();
            cmdSql.Connection = conn;
            cmdSql.CommandType = CommandType.StoredProcedure;
            cmdSql.CommandText = @"dbo.GET_Dashboard_AttendanceRate_MonthlyOutput";

            cmdSql.Parameters.Clear();
            cmdSql.Parameters.Add("@Year", SqlDbType.Int).Value = Year;
            cmdSql.Parameters.Add("@Agency", SqlDbType.NVarChar).Value = Agency;
            cmdSql.Parameters.Add("@Line", SqlDbType.BigInt).Value = Line;
            cmdSql.Parameters.Add("@Shift", SqlDbType.NVarChar).Value = Shift;
            cmdSql.Parameters.Add("@CostCode", SqlDbType.NVarChar).Value = CostCode;
            conn.Open();
            cmdSql.CommandTimeout = 0;
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
            
            return Json(new { data = list }, JsonRequestBehavior.AllowGet);
        }
        
        public ActionResult GetMonthly_AbsentRate(int Year, string Agency, long? Line, string Shift)
        {
            string currentuser = user.UserName;
            string CostCode = (from c in db.M_Employee_CostCenter where c.EmployNo == currentuser orderby c.ID descending select c.CostCenter_AMS).FirstOrDefault();
            CostCode = (CostCode == null) ? user.CostCode : CostCode;
            SqlConnection conn = new SqlConnection(Connection_String.AMSDB);
            SqlCommand cmdSql = new SqlCommand();
            cmdSql.Connection = conn;
            cmdSql.CommandType = CommandType.StoredProcedure;
            cmdSql.CommandText = @"dbo.GET_Dashboard_AbsentRate_MonthlyOutput";

            cmdSql.Parameters.Clear();
            cmdSql.Parameters.Add("@Year", SqlDbType.Int).Value = Year;
            cmdSql.Parameters.Add("@Agency", SqlDbType.NVarChar).Value = Agency;
            cmdSql.Parameters.Add("@Line", SqlDbType.BigInt).Value = Line;
            cmdSql.Parameters.Add("@Shift", SqlDbType.NVarChar).Value = Shift;
            cmdSql.Parameters.Add("@CostCode", SqlDbType.NVarChar).Value = CostCode;
            conn.Open();
            cmdSql.CommandTimeout = 0;
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

            return Json(new { data = list }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult GetMonthly_AwolResignRate(int Year, string Agency, long? Line, string Shift)
        {
            string currentuser = user.UserName;
            string CostCode = (from c in db.M_Employee_CostCenter where c.EmployNo == currentuser orderby c.ID descending select c.CostCenter_AMS).FirstOrDefault();
            CostCode = (CostCode == null) ? user.CostCode : CostCode;
            SqlConnection conn = new SqlConnection(Connection_String.AMSDB);
            SqlCommand cmdSql = new SqlCommand();
            cmdSql.Connection = conn;
            cmdSql.CommandType = CommandType.StoredProcedure;
            cmdSql.CommandText = @"dbo.GET_Dashboard_AWOLresignRate_MonthlyOutput";

            cmdSql.Parameters.Clear();
            cmdSql.Parameters.Add("@Year", SqlDbType.Int).Value = Year;
            cmdSql.Parameters.Add("@Agency", SqlDbType.NVarChar).Value = Agency;
            cmdSql.Parameters.Add("@Line", SqlDbType.BigInt).Value = Line;
            cmdSql.Parameters.Add("@Shift", SqlDbType.NVarChar).Value = Shift;
            cmdSql.Parameters.Add("@CostCode", SqlDbType.NVarChar).Value = CostCode;
            conn.Open();
            cmdSql.CommandTimeout = 0;
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

            return Json(new { data = list }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult GetMonthly_LeaveBreakdown(int Year, string Agency, long? Line, string Shift)
        {
            string currentuser = user.UserName;
            string CostCode = (from c in db.M_Employee_CostCenter where c.EmployNo == currentuser orderby c.ID descending select c.CostCenter_AMS).FirstOrDefault();
            CostCode = (CostCode == null) ? user.CostCode : CostCode;
            SqlConnection conn = new SqlConnection(Connection_String.AMSDB);
            SqlCommand cmdSql = new SqlCommand();
            cmdSql.Connection = conn;
            cmdSql.CommandType = CommandType.StoredProcedure;
            cmdSql.CommandText = @"dbo.GET_Dashboard_LeaveBreakDownRateMonthlyOutput";

            cmdSql.Parameters.Clear();
            cmdSql.Parameters.Add("@Year", SqlDbType.Int).Value = Year;
            cmdSql.Parameters.Add("@Agency", SqlDbType.NVarChar).Value = Agency;
            cmdSql.Parameters.Add("@Line", SqlDbType.BigInt).Value = Line;
            cmdSql.Parameters.Add("@Shift", SqlDbType.NVarChar).Value = Shift;
            cmdSql.Parameters.Add("@CostCode", SqlDbType.NVarChar).Value = CostCode;
            conn.Open();
            cmdSql.CommandTimeout = 0;
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

            return Json(new { data = list }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult GetMonthly_Overtime(int Year, string Agency, long? Line, string Shift)
        {
            string currentuser = user.UserName;
            string CostCode = (from c in db.M_Employee_CostCenter where c.EmployNo == currentuser orderby c.ID descending select c.CostCenter_AMS).FirstOrDefault();
            CostCode = (CostCode == null) ? user.CostCode : CostCode;
            SqlConnection conn = new SqlConnection(Connection_String.AMSDB);
            SqlCommand cmdSql = new SqlCommand();
            cmdSql.Connection = conn;
            cmdSql.CommandType = CommandType.StoredProcedure;
            cmdSql.CommandText = @"dbo.GET_Dashboard_OvertimeRateMonthlyOutput";

            cmdSql.Parameters.Clear();
            cmdSql.Parameters.Add("@Year", SqlDbType.Int).Value = Year;
            cmdSql.Parameters.Add("@Agency", SqlDbType.NVarChar).Value = Agency;
            cmdSql.Parameters.Add("@Line", SqlDbType.BigInt).Value = Line;
            cmdSql.Parameters.Add("@Shift", SqlDbType.NVarChar).Value = Shift;
            cmdSql.Parameters.Add("@CostCode", SqlDbType.NVarChar).Value = CostCode;
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

            return Json(new { data = list }, JsonRequestBehavior.AllowGet);
        }

        #endregion



        #region Yearly Generation

        public ActionResult GetYearly_AttendanceRate(string Agency, long? Line, string Shift)
        {
            string currentuser = user.UserName;
            string CostCode = (from c in db.M_Employee_CostCenter where c.EmployNo == currentuser orderby c.ID descending select c.CostCenter_AMS).FirstOrDefault();
            CostCode = (CostCode == null) ? user.CostCode : CostCode;
            SqlConnection conn = new SqlConnection(Connection_String.AMSDB);
            SqlCommand cmdSql = new SqlCommand();
            cmdSql.Connection = conn;
            cmdSql.CommandType = CommandType.StoredProcedure;
            cmdSql.CommandText = @"dbo.GET_Dashboard_AttendanceRate_Yearly";

            cmdSql.Parameters.Clear();
            cmdSql.Parameters.Add("@Agency", SqlDbType.NVarChar).Value = Agency;
            cmdSql.Parameters.Add("@Line", SqlDbType.BigInt).Value = Line;
            cmdSql.Parameters.Add("@Shift", SqlDbType.NVarChar).Value = Shift;
            cmdSql.Parameters.Add("@CostCode", SqlDbType.NVarChar).Value = CostCode;
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

            return Json(new { data = list }, JsonRequestBehavior.AllowGet);
        }


        public ActionResult GetYearly_AbsentRate(string Agency, long? Line, string Shift)
        {
            string currentuser = user.UserName;
            string CostCode = (from c in db.M_Employee_CostCenter where c.EmployNo == currentuser orderby c.ID descending select c.CostCenter_AMS).FirstOrDefault();
            CostCode = (CostCode == null) ? user.CostCode : CostCode;
            SqlConnection conn = new SqlConnection(Connection_String.AMSDB);
            SqlCommand cmdSql = new SqlCommand();
            cmdSql.Connection = conn;
            cmdSql.CommandType = CommandType.StoredProcedure;
            cmdSql.CommandText = @"dbo.GET_Dashboard_AbsentRate_Yearly";

            cmdSql.Parameters.Clear();
            cmdSql.Parameters.Add("@Agency", SqlDbType.NVarChar).Value = Agency;
            cmdSql.Parameters.Add("@Line", SqlDbType.BigInt).Value = Line;
            cmdSql.Parameters.Add("@Shift", SqlDbType.NVarChar).Value = Shift;
            cmdSql.Parameters.Add("@CostCode", SqlDbType.NVarChar).Value = CostCode;
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

            return Json(new { data = list }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult GetYearly_AwolResignRate(string Agency, long? Line, string Shift)
        {
            string currentuser = user.UserName;
            string CostCode = (from c in db.M_Employee_CostCenter where c.EmployNo == currentuser orderby c.ID descending select c.CostCenter_AMS).FirstOrDefault();
            CostCode = (CostCode == null) ? user.CostCode : CostCode;
            SqlConnection conn = new SqlConnection(Connection_String.AMSDB);
            SqlCommand cmdSql = new SqlCommand();
            cmdSql.Connection = conn;
            cmdSql.CommandType = CommandType.StoredProcedure;
            cmdSql.CommandText = @"dbo.GET_Dashboard_AWOLresignRate_Yearly";

            cmdSql.Parameters.Clear();
           
            cmdSql.Parameters.Add("@Agency", SqlDbType.NVarChar).Value = Agency;
            cmdSql.Parameters.Add("@Line", SqlDbType.BigInt).Value = Line;
            cmdSql.Parameters.Add("@Shift", SqlDbType.NVarChar).Value = Shift;
            cmdSql.Parameters.Add("@CostCode", SqlDbType.NVarChar).Value = CostCode;
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

            return Json(new { data = list }, JsonRequestBehavior.AllowGet);
        }


        public ActionResult GetYearly_LeaveBreakdown(string Agency, long? Line, string Shift)
        {
            string currentuser = user.UserName;
            string CostCode = (from c in db.M_Employee_CostCenter where c.EmployNo == currentuser orderby c.ID descending select c.CostCenter_AMS).FirstOrDefault();
            CostCode = (CostCode == null) ? user.CostCode : CostCode;
            SqlConnection conn = new SqlConnection(Connection_String.AMSDB);
            SqlCommand cmdSql = new SqlCommand();
            cmdSql.Connection = conn;
            cmdSql.CommandType = CommandType.StoredProcedure;
            cmdSql.CommandText = @"dbo.GET_Dashboard_LeaveBreakDownRateYearly";

            cmdSql.Parameters.Clear();
            cmdSql.Parameters.Add("@Agency", SqlDbType.NVarChar).Value = Agency;
            cmdSql.Parameters.Add("@Line", SqlDbType.BigInt).Value = Line;
            cmdSql.Parameters.Add("@Shift", SqlDbType.NVarChar).Value = Shift;
            cmdSql.Parameters.Add("@CostCode", SqlDbType.NVarChar).Value = CostCode;
            conn.Open();
            cmdSql.CommandTimeout = 0;
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

            return Json(new { data = list }, JsonRequestBehavior.AllowGet);
        }


        public ActionResult GetYearly_Overtime(string Agency, long? Line, string Shift)
        {
            string currentuser = user.UserName;
            string CostCode = (from c in db.M_Employee_CostCenter where c.EmployNo == currentuser orderby c.ID descending select c.CostCenter_AMS).FirstOrDefault();
            CostCode = (CostCode == null) ? user.CostCode : CostCode;
            SqlConnection conn = new SqlConnection(Connection_String.AMSDB);
            SqlCommand cmdSql = new SqlCommand();
            cmdSql.Connection = conn;
            cmdSql.CommandType = CommandType.StoredProcedure;
            cmdSql.CommandText = @"dbo.GET_Dashboard_OvertimeRateYearly";

            cmdSql.Parameters.Clear();
            cmdSql.Parameters.Add("@Agency", SqlDbType.NVarChar).Value = Agency;
            cmdSql.Parameters.Add("@Line", SqlDbType.BigInt).Value = Line;
            cmdSql.Parameters.Add("@Shift", SqlDbType.NVarChar).Value = Shift;
            cmdSql.Parameters.Add("@CostCode", SqlDbType.NVarChar).Value = CostCode;
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

            return Json(new { data = list }, JsonRequestBehavior.AllowGet);
        }
        #endregion




        public ActionResult GET_ManPowerAttendanceRate(int Month, int Year, string Agency, string Shift, long? Line)
        {
            string CostCode = user.CostCode;
            db.Database.CommandTimeout = 0;
            List<Dashboard_ManpowerAttendanceRate_Result> list = db.Dashboard_ManpowerAttendanceRate(Month, Year, Agency, Shift, Line, CostCode).ToList();

            return Json(new { list = list }, JsonRequestBehavior.AllowGet);
        }


        public ActionResult GET_AbsentRate(int Month, int Year, string Agency, string Shift, long? Line)
        {
            string CostCode = user.CostCode;
            db.Database.CommandTimeout = 0;
            List<Dashboard_AbsentRate_Result> list = db.Dashboard_AbsentRate(Month, Year, Agency, Shift, Line, CostCode).ToList();

            return Json(new { list = list }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult GET_LeaveBreakdown(int Month, int Year, string Agency, string Shift, long? Line)
        {
            string CostCode = user.CostCode;
            db.Database.CommandTimeout = 0;
            List<Dashboard_LeaveBreakDown_Result> list = db.Dashboard_LeaveBreakDown(Month, Year, Agency, Shift, Line, CostCode).ToList();

            return Json(new { list = list }, JsonRequestBehavior.AllowGet);
        }



    }
}