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
            System.Web.HttpContext.Current.Session["chosendashgroup"] = "";
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
            System.Web.HttpContext.Current.Session["chosendashgroup"] = Section;
            //string Costcode = (from c in db.M_Cost_Center_List where c.GroupSection == Section select c.Cost_Center).FirstOrDefault();
            //user.Section = Costcode;
            return Json(new { }, JsonRequestBehavior.AllowGet);
        }



        public ActionResult GET_ManPowerAttendanceRate(int Month, int Year, string Agency, string Shift, long? Line)
        {
            string CostCode = "";
            string groupsec = (Session["chosendashgroup"] != null) ? Session["chosendashgroup"].ToString() : "";
            if (groupsec == "")
            {
                CostCode = user.CostCode;
            }
            else
            {
                
                CostCode = (from c in db.M_Cost_Center_List where c.GroupSection == groupsec select c.Cost_Center).FirstOrDefault();
            }
            //string CostCode = (Session["chosendashgroup"].ToString) ?user.Section : user.CostCode;
            db.Database.CommandTimeout = 0;
            List<Dashboard_ManpowerAttendanceRate_Result> list = db.Dashboard_ManpowerAttendanceRate(Month, Year, Agency, Shift, Line, CostCode).ToList();

            return Json(new { list = list }, JsonRequestBehavior.AllowGet);
        }


        public ActionResult GET_AbsentRate(int Month, int Year, string Agency, string Shift, long? Line)
        {
            string CostCode = "";
            string groupsec = (Session["chosendashgroup"] != null) ? Session["chosendashgroup"].ToString() : "";
            if (groupsec == "")
            {
                CostCode = user.CostCode;
            }
            else
            {

                CostCode = (from c in db.M_Cost_Center_List where c.GroupSection == groupsec select c.Cost_Center).FirstOrDefault();
            }
            //string CostCode = (Session["chosendashgroup"].ToString) ?user.Section : user.CostCode;
            db.Database.CommandTimeout = 0;
            
            List<Dashboard_AbsentRate_Result> list = db.Dashboard_AbsentRate(Month, Year, Agency, Shift, Line, CostCode).ToList();
          
            return Json(new { list = list }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult GET_LeaveBreakdown(int Month, int Year, string Agency, string Shift, long? Line)
        {
            string CostCode = "";
            string groupsec = (Session["chosendashgroup"] != null) ? Session["chosendashgroup"].ToString() : "";
            if (groupsec == "")
            {
                CostCode = user.CostCode;
            }
            else
            {

                CostCode = (from c in db.M_Cost_Center_List where c.GroupSection == groupsec select c.Cost_Center).FirstOrDefault();
            }
            //string CostCode = (Session["chosendashgroup"].ToString) ?user.Section : user.CostCode;
            db.Database.CommandTimeout = 0;

            List<Dashboard_LeaveBreakDown_Result> list = db.Dashboard_LeaveBreakDown(Month, Year, Agency, Shift, Line, CostCode).ToList();

            return Json(new { list = list }, JsonRequestBehavior.AllowGet);
        }


        public ActionResult GET_AWOLandResignrate(int Month, int Year, string Agency, string Shift, long? Line)
        {
            string CostCode = "";
            string groupsec = (Session["chosendashgroup"] != null) ? Session["chosendashgroup"].ToString() : "";
            if (groupsec == "")
            {
                CostCode = user.CostCode;
            }
            else
            {
                CostCode = (from c in db.M_Cost_Center_List where c.GroupSection == groupsec select c.Cost_Center).FirstOrDefault();
            }
            //string CostCode = (Session["chosendashgroup"].ToString) ?user.Section : user.CostCode;
            db.Database.CommandTimeout = 0;
            List<Dashboard_AWOLandResignRate_Result> list = db.Dashboard_AWOLandResignRate(Month, Year, Agency, Shift, Line, CostCode).ToList();
            return Json(new { list = list }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult GET_OTRate(int Month, int Year, string Agency, string Shift, long? Line)
        {
            string CostCode = "";
            string groupsec = (Session["chosendashgroup"] != null) ? Session["chosendashgroup"].ToString() : "";
            if (groupsec == "")
            {
                CostCode = user.CostCode;
            }
            else
            {

                CostCode = (from c in db.M_Cost_Center_List where c.GroupSection == groupsec select c.Cost_Center).FirstOrDefault();
            }
            //string CostCode = (Session["chosendashgroup"].ToString) ?user.Section : user.CostCode;
            db.Database.CommandTimeout = 0;
            List<Dashboard_OvertimeRate_Result> list = db.Dashboard_OvertimeRate(Month, Year, Agency, Shift, Line, CostCode).ToList();

            return Json(new { list = list }, JsonRequestBehavior.AllowGet);
        }


        #region Monthly

        public ActionResult Get_MonthlyDashboard(int Year, string Agency, string Shift, long? Line, string GroupSection)
        {
            string CostCode = "";
            string groupsec = (Session["chosendashgroup"] != null) ? Session["chosendashgroup"].ToString() : "";
            if (groupsec == "")
            {
                CostCode = user.CostCode;
            }
            else
            {

                CostCode = (from c in db.M_Cost_Center_List where c.GroupSection == groupsec select c.Cost_Center).FirstOrDefault();
            }
            db.Database.CommandTimeout = 0;
            List<Dashboard_ManpowerAttendanceRate_Monthly_Result> AttendanceRateMonthly = db.Dashboard_ManpowerAttendanceRate_Monthly(Year, Agency, Shift, Line, CostCode).ToList();
            List<Dashboard_AbsentRate_Monthly_Result> AbsentRateMonthly = db.Dashboard_AbsentRate_Monthly(Year, Agency, Shift, Line, CostCode).ToList();
            List<Dashboard_LeaveBreakDown_Monthly_Result> LeaveBreakdownMonthly = db.Dashboard_LeaveBreakDown_Monthly(Year, Agency, Shift, Line, CostCode).ToList();
            List<Dashboard_AWOLandResignRate_Monthly_Result> AwolandResignedMonthly = db.Dashboard_AWOLandResignRate_Monthly(Year, Agency, Shift, Line, CostCode).ToList();
            List<Dashboard_OvertimeRate_Monthly_Result> OTRateMonthly = db.Dashboard_OvertimeRate_Monthly(Year, Agency, Shift, Line, CostCode).ToList();


            Session["chosendashgroup"] = "";
            return Json(new {
                AttendanceRateMonthly = AttendanceRateMonthly,
                AbsentRateMonthly = AbsentRateMonthly,
                LeaveBreakdownMonthly = LeaveBreakdownMonthly,
                AwolandResignedMonthly = AwolandResignedMonthly,
                OTRateMonthly = OTRateMonthly
            }, JsonRequestBehavior.AllowGet);
        }

        #endregion


        #region Yearly
        public ActionResult Get_YearlyDashboard(string Agency, string Shift, long? Line, string GroupSection)
        {
            string CostCode = "";
            string groupsec = (Session["chosendashgroup"] != null) ? Session["chosendashgroup"].ToString() : "";
            if (groupsec == "")
            {
                CostCode = user.CostCode;
            }
            else
            {

                CostCode = (from c in db.M_Cost_Center_List where c.GroupSection == groupsec select c.Cost_Center).FirstOrDefault();
            }
            db.Database.CommandTimeout = 0;
            List<Dashboard_ManpowerAttendanceRate_Yearly_Result> AttendanceRateYearly = db.Dashboard_ManpowerAttendanceRate_Yearly(Agency, Shift, Line, CostCode).ToList();
            List<Dashboard_AbsentRate_Yearly_Result> AbsentRateYearly = db.Dashboard_AbsentRate_Yearly(Agency, Shift, Line, CostCode).ToList();
            List<Dashboard_LeaveBreakDown_Yearly_Result> LeaveBreakdownYearly = db.Dashboard_LeaveBreakDown_Yearly(Agency, Shift, Line, CostCode).ToList();
            List<Dashboard_AWOLandResignRate_Yearly_Result> AwolandResignedYearly = db.Dashboard_AWOLandResignRate_Yearly(Agency, Shift, Line, CostCode).ToList();
            List<Dashboard_OvertimeRate_Yearly_Result> OTRateYearly = db.Dashboard_OvertimeRate_Yearly(Agency, Shift, Line, CostCode).ToList();


            Session["chosendashgroup"] = "";
            return Json(new
            {
                AttendanceRateYearly = AttendanceRateYearly,
                AbsentRateYearly = AbsentRateYearly,
                LeaveBreakdownYearly = LeaveBreakdownYearly,
                AwolandResignedYearly = AwolandResignedYearly,
                OTRateYearly = OTRateYearly
            }, JsonRequestBehavior.AllowGet);
        }


      

      


        
        

        #endregion

    }
}