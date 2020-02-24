using Brothers_WMS.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace Brothers_WMS.Controllers
{
    public class HelperController : Controller
    {
        // GET: Helper

        Brothers_AMSDBEntities db = new Brothers_AMSDBEntities();
        M_Users user = (M_Users)System.Web.HttpContext.Current.Session["user"];

        public ActionResult Index()
        {
            return View();
        }

        private string dec2Hex(long val)
        {
            return Convert.ToString(val, 16);
        }
        private double hex2Dec(string strHex)
        {
            return Convert.ToInt16(strHex, 16);
        }

        public ActionResult GetCurrentSection()
        {
            //string sectionnow = (from w in db.M_Users.ToList()
            //                     where w.IsDeleted == false && w.Status == true && w.UserName == user.UserName
            //                     select w.Section).FirstOrDefault();
            string sectionnow = user.Section;
            return Json(new { sectionnow = sectionnow }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult GetSection()
        {
            string usersection = user.Section;
            return Json(new { usersection = usersection, usercost = user.CostCode }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult GetSuperSection(string section)
        {
            M_Cost_Center_List usersection = (from c in db.M_Cost_Center_List where c.GroupSection == section select c).FirstOrDefault();
            return Json(new { usersection = usersection, usercostcode = usersection.Cost_Center }, JsonRequestBehavior.AllowGet);
        }

        public JsonResult GetEmployeeNo(string Agency)
        {
            List<M_Employee_Master_List> list = (from c in db.M_Employee_Master_List
                                                 where c.EmpNo.Contains(Agency)
                                                 && c.Position == "Supervisor"
                                                 select c).ToList();
            //return Json(new { list = list }, JsonRequestBehavior.AllowGet);
            var jsonResponse = new
            {
                list = list    
            };
            var jsonResult = Json(jsonResponse, JsonRequestBehavior.AllowGet);
            jsonResult.MaxJsonLength = int.MaxValue;
            return jsonResult;
        }

        public JsonResult GetUsername(string Agency)
        {
            List<M_Users> list = (from c in db.M_Users
                                  where c.UserName.Contains(Agency)
                                  select c).ToList();
            var jsonResponse = new
            {
                list = list
            };
            var jsonResult = Json(jsonResponse, JsonRequestBehavior.AllowGet);
            jsonResult.MaxJsonLength = int.MaxValue;
            return jsonResult;
        }
        

        public JsonResult GetLine(string line)
        {
            List<M_LineTeam> list = new List<M_LineTeam>();
            list = (from c in db.M_LineTeam
                    where c.IsDeleted == false
                    && c.Section == user.CostCode
                    select c).ToList();
            return Json(new { list = list }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult GetDropdown_EmployeeStatus()
        {
            List<GET_Employee_Status_Result> listmain = db.GET_Employee_Status(user.CostCode).ToList();
            var list = (from w in listmain
                        select new { text = w.Status, value = w.Status }).Distinct().ToList();
            return Json(new { list = list }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult GetDropdown_EmployeeModStatus()
        {
            List<M_Employee_Status> listmain = (from c in db.M_Employee_Status select c).ToList();
            var list = (from w in listmain
                        select new { text = w.Status, value = w.Status }).Distinct().ToList();
            return Json(new { list = list }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult GetDropdown_EmployeePosition()
        {
            List<GET_Employee_Status_Result> listmain = db.GET_Employee_Status(user.CostCode).ToList();
            var list = (from w in listmain
                        select new { text = w.Position, value = w.Position }).Distinct().ToList();
            return Json(new { list = list }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult GetDropdown_Section()
        {
            var list = (from w in db.M_Cost_Center_List.ToList()
                        select new { text = w.Section, value = w.Cost_Center }).Distinct().ToList();
            return Json(new { list = list }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult GetDropdown_SectionAMS()
        {
            var list = (from w in db.M_Cost_Center_List.ToList()
                        select new { text = w.GroupSection, value = w.GroupSection }).Distinct().ToList();
            return Json(new { list = list }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult GetDropdown_Agency()
        {
            var list = (from w in db.M_Agency.ToList()
                        where w.IsDeleted == false && w.Status == true
                        select new { text = w.AgencyCode +" - "+ w.AgencyName, value = w.AgencyCode }).Distinct().ToList();
            return Json(new { list = list }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult GetDropdown_EmployeeNo()
        {
            var list = (from w in db.M_Employee_Master_List.ToList()
                        where w.Date_Resigned == null
                        select new { text = w.ID, value = w.First_Name +" "+w.Family_Name }).Distinct().ToList();
            return Json(new { list = list }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult GetDropdown_LineProcessTeam()
        {
            var list = (from w in db.M_LineTeam.ToList()
                        where w.IsDeleted == false && w.Status == true
                        select new { text = w.Line, value = w.ID }).Distinct().ToList();
            return Json(new { list = list }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult GetDropdown_LineProcessTeamLogin()
        {
            var list = (from w in db.M_LineTeam.ToList()
                        where w.IsDeleted == false && w.Status == true
                        && w.Section == user.CostCode
                        select new { text = w.Line, value = w.ID }).Distinct().ToList();
            return Json(new { list = list }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult GetLineDropdownMP(string Section)
        {

            return Json(new { list = "" }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult GetDropdown_LineProcessTeamwithSection(string CostCode, string RFID, string GroupSection)
        {
            long removezero = (RFID != "") ? Convert.ToInt64(RFID) : 0;
            if(CostCode == "undefined")
            {
                CostCode = (from c in db.M_Cost_Center_List where c.GroupSection == GroupSection select c.Cost_Center).FirstOrDefault();
            }
            string a = (removezero == 0) ? "" : removezero.ToString();
             var list = (from w in db.GET_M_SP_LineTeam(CostCode, a).ToList()
                        where w.IsDeleted == false 
                        && w.Status == true
                        select new { text = w.Line, value = w.ID }).Distinct().ToList();


            if(list.Count == 0)
            {
                string SourceValue = dec2Hex(Convert.ToInt64(RFID));
                string Hexvalue = SourceValue.Substring(SourceValue.Length - 4);
                string Prefix = SourceValue.Remove(SourceValue.Length - 4).ToUpper();
                string THERFID = hex2Dec(Hexvalue).ToString();
                list = (from w in db.GET_M_SP_LineTeam(CostCode, THERFID).ToList()
                        where w.IsDeleted == false
                        && w.Status == true
                        select new { text = w.Line, value = w.ID }).Distinct().ToList();
            }
            
            return Json(new { list = list }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult GetDropdown_Skills(long LineProcessTeam)
        {
            var list = (from w in db.M_Skills.ToList()
                        where w.IsDeleted == false && w.Line == LineProcessTeam
                        select new { text = w.Skill, value = w.ID }).Distinct().ToList();
            return Json(new { list = list }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult GetDropdown_CostCenter()
        {
            var list = (from w in db.M_Cost_Center_List.ToList()
                        select new { text = w.Cost_Center, value = w.Cost_Center }).Distinct().ToList();
            return Json(new { list = list }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult GetDropdown_Schedule()
        {
            var list = (from w in db.M_Schedule.ToList()
                        where w.IsDeleted == false && w.Status == true
                        select new { text = w.Timein +" - "+w.TimeOut + " ("+w.Type+")" , value = w.ID }).Distinct().ToList();
            return Json(new { list = list }, JsonRequestBehavior.AllowGet);
        }


       

        #region Transaction CODE Generator
        public string GenerateDTRRef()
        {
            //DateTime startDateTime = DateTime.Today;
            //DateTime endDateTime = DateTime.Today.AddDays(1).AddTicks(-1);
            //string DTRRefNo = "";
            //DateTime dt = DateTime.Now;
            //string datenow = String.Format("{0:yyyyMMdd}", dt);
            //int todayOT = (from c in db.AF_DTRfiling where c.CreateDate >= startDateTime && c.CreateDate <= endDateTime select c).ToList().GroupBy(i => i.DTR_RefNo).Count();
            //todayOT++;
            //DTRRefNo = "DTR-" + datenow + "-" + todayOT.ToString();
            //return DTRRefNo;

            string DTRRefNo = "";
            DateTime dt = DateTime.Now;
            string datenow = String.Format("{0:yyyyMMdd}", dt);
            DTRRefNo = "DTR-" + user.Section + "_" + datenow;
            return DTRRefNo;
        }

        public string GenerateOTRef()
        {
            string OTRefNo = "";
            DateTime dt = DateTime.Now;
            string datenow = String.Format("{0:yyyyMMdd}", dt);
            //int todayOT = (from c in db.AF_OTfiling where c.CreateDate >= startDateTime && c.CreateDate <= endDateTime select c).ToList().GroupBy(i => i.OT_RefNo).Count();
            //todayOT++;
            OTRefNo = "OT-" + user.Section + "_" + datenow;
            return OTRefNo;
        }

        public string GenerateCSRef()
        {
            #region OLD Format
            //DateTime startDateTime = DateTime.Today;
            //DateTime endDateTime = DateTime.Today.AddDays(1).AddTicks(-1);
            //string CSRefNo = "";
            //DateTime dt = DateTime.Now;
            //string datenow = String.Format("{0:yyyyMMdd}", dt);
            //int todayOT = (from c in db.AF_ChangeSchedulefiling where c.CreateDate >= startDateTime && c.CreateDate <= endDateTime select c).ToList().GroupBy(i => i.CS_RefNo).Count();
            //todayOT++;
            //CSRefNo = "CS-" + datenow + "-" + todayOT.ToString();
            //return CSRefNo;
            #endregion
            string CSRefNo = "";
            DateTime dt = DateTime.Now;
            string datenow = String.Format("{0:yyyyMMdd}", dt);
            CSRefNo = "CS-" + user.Section + "_" + datenow;
            return CSRefNo;
        }


        #endregion
    }
}