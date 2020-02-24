using Brothers_WMS.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace Brothers_WMS.Controllers
{
    //[SessionExpire]
    public class LineViewController : Controller
    {
        Brothers_AMSDBEntities db = new Brothers_AMSDBEntities();
        M_Users user = (M_Users)System.Web.HttpContext.Current.Session["user"];
        // GET: LineView
        public ActionResult LineView()
        {
            return View();
        }
        
        public class Line_Process
        {
            public string Line { get; set; }
            public List<GET_TT_EmployeeLineViewCount_Result> IdealMPperLine { get; set; }
            public List<List<GET_TT_EmployeeLineView_Result>> Employeeperline { get; set; }
            public int? SM { get; set; }
            public int? CM { get; set; }

            public string Section { get; set; }
        }

        public class EmployeeperProcess
        {
            public List<GET_TT_EmployeeLineView_Result> EmployeeList { get; set; }

        }

        public class ManpowerLine
        {
            int Quantity { get; set; }
        }
        
        public ActionResult GetLineperSection(string Section, string Shift)
        {
            try
            {
                Shift = (Shift.Contains("Day")) ? "Day" : "Night";
               
                List<string> costcode = (from c in db.M_Cost_Center_List where c.GroupSection == Section select c.Cost_Center).ToList();
               
               

                #region FOR SUPER USER
               
                    List<Line_Process> theLineList = new List<Line_Process>();
                    List<List<GET_TT_EmployeeLineView_Result>> Employeesperprocess = new List<List<GET_TT_EmployeeLineView_Result>>();
                    List<M_LineTeam> Line = new List<M_LineTeam>();
                    List<M_Cost_Center_List> SectionList = new List<M_Cost_Center_List>();

                    if(costcode.Count == 0)
                    {
                        
                        SectionList = (from c in db.M_Cost_Center_List select c).Where(x => costcode.Contains(x.Cost_Center)).ToList();
                }
                    else
                    {
                        SectionList = (from c in db.M_Cost_Center_List select c).Where(x => costcode.Contains(x.Cost_Center)).ToList();
                    }
                   
                    List<string> Sectionpart = new List<string>();
                    foreach (M_Cost_Center_List sectionhere in SectionList)
                    {
                        Line = (from c in db.M_LineTeam
                                where c.Section == sectionhere.Cost_Center
                                && c.IsDeleted != true
                                select c).ToList();

                        if (Line.Count > 0)
                        {
                        
                            Sectionpart.Add(sectionhere.Section);
                            foreach (M_LineTeam line in Line)
                            {
                                Employeesperprocess = new List<List<GET_TT_EmployeeLineView_Result>>();
                                Line_Process LineEmployee = new Line_Process();
                                LineEmployee.Line = line.Line;
                                long? lineid = line.ID;
                                LineEmployee.IdealMPperLine = db.GET_TT_EmployeeLineViewCount(lineid, Shift).ToList();

                                foreach (GET_TT_EmployeeLineViewCount_Result process in LineEmployee.IdealMPperLine)
                                {
                                    List<GET_TT_EmployeeLineView_Result> emp = db.GET_TT_EmployeeLineView(lineid, Shift).ToList().Where(x => x.Process == process.Skill).ToList();

                                    Employeesperprocess.Add(emp);

                                }
                                LineEmployee.Employeeperline = Employeesperprocess;
                                LineEmployee.SM = 0;
                                LineEmployee.CM = 0;
                                foreach (GET_TT_EmployeeLineViewCount_Result c in LineEmployee.IdealMPperLine)
                                {
                                    LineEmployee.SM += c.Count;
                                }
                                foreach (GET_TT_EmployeeLineViewCount_Result c in LineEmployee.IdealMPperLine)
                                {
                                    LineEmployee.CM += c.CurrentCount;
                                }
                                LineEmployee.Section = sectionhere.GroupSection;
                                theLineList.Add(LineEmployee);
                            }
                        }

                    }

                   return Json(new { Line = Line, theLineList = theLineList }, JsonRequestBehavior.AllowGet);
               
                #endregion


                #region FOR USER
                //else
                //{
                //    List<Line_Process> theLineList = new List<Line_Process>();
                //    List<List<GET_TT_EmployeeLineView_Result>> Employeesperprocess = new List<List<GET_TT_EmployeeLineView_Result>>();
                //    List<M_LineTeam> Line = new List<M_LineTeam>();

                //    Line = (from c in db.M_LineTeam
                //            where c.Section == user.CostCode
                //            && c.IsDeleted != true
                //            select c).ToList();

                

                //    foreach (M_LineTeam line in Line)
                //    {
                //        Employeesperprocess = new List<List<GET_TT_EmployeeLineView_Result>>();
                //        Line_Process LineEmployee = new Line_Process();
                //        LineEmployee.Line = line.Line;
                //        long? lineid = line.ID;
                //        LineEmployee.IdealMPperLine = db.GET_TT_EmployeeLineViewCount(lineid).ToList();

                //        foreach (GET_TT_EmployeeLineViewCount_Result process in LineEmployee.IdealMPperLine)
                //        {
                //            List<GET_TT_EmployeeLineView_Result> emp = db.GET_TT_EmployeeLineView(lineid).ToList().Where(x => x.Process == process.Skill).ToList();

                //            Employeesperprocess.Add(emp);

                //        }
                //        LineEmployee.Employeeperline = Employeesperprocess;
                //        LineEmployee.SM = 0;
                //        LineEmployee.CM = 0;
                //        foreach (GET_TT_EmployeeLineViewCount_Result c in LineEmployee.IdealMPperLine)
                //        {
                //            LineEmployee.SM += c.Count;
                //        }
                //        foreach (GET_TT_EmployeeLineViewCount_Result c in LineEmployee.IdealMPperLine)
                //        {
                //            LineEmployee.CM += c.CurrentCount;
                //        }
                //        theLineList.Add(LineEmployee);
                //    }

                //    return Json(new { Line = Line, theLineList = theLineList }, JsonRequestBehavior.AllowGet);
                //}
                #endregion

              

            }
            catch (Exception err)
            {
                Error_Logs error = new Error_Logs();
                error.PageModule = "Master - Agency";
                error.ErrorLog = err.Message;
                error.DateLog = DateTime.Now;
                error.Username = user.UserName;
                db.Error_Logs.Add(error);
                db.SaveChanges();
                return Json(new { msg = err.Message }, JsonRequestBehavior.AllowGet);
            }
        }

        public ActionResult GetCurrentUser()
        {
            try
            {
                string SectionGroup = (from c in db.M_Cost_Center_List where c.Cost_Center == user.CostCode select c.GroupSection).FirstOrDefault();

                return Json(new { SectionGroup = SectionGroup }, JsonRequestBehavior.AllowGet);
            }
            catch(Exception err)
            {
                return Json(new { SectionGroup = "" }, JsonRequestBehavior.AllowGet);

            }
        }

        public JsonResult GetEmployeeName(string Name)
        {
            string GroupSection = "";
            if (user != null)
            {
                GroupSection = user.CostCode;
            }
            List<GET_Employee_NameAutocompletes_Result> list = db.GET_Employee_NameAutocompletes(Name, GroupSection).ToList();
          
            return Json(new { list = list }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult GetTimeInlocation(string Name)
        {
            GET_Employee_Location_Result Employee = db.GET_Employee_Location(Name).FirstOrDefault();
            return Json(new { Employee = Employee }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult RemoveEmployee(string Name)
        { 
            db.LineView_RemoveEmployee(Name);

            return Json(new { Employee = "success" }, JsonRequestBehavior.AllowGet);
        }
    }
}