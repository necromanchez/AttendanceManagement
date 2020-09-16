using Brothers_WMS.Controllers;
using Brothers_WMS.Models;
using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using static Brothers_WMS.Controllers.SessionExpire;

namespace Brothers_WMS.Areas.Masters.Controllers
{
    [SessionExpire]
    public class SectionController : Controller
    {
        // GET: Masters/Section
        Brothers_AMSDBEntities db = new Brothers_AMSDBEntities();
        M_Users user = (M_Users)System.Web.HttpContext.Current.Session["user"];
        public ActionResult Section()
        {
            db.M_SP_SectionInsert();
            return View();
        }
        public ActionResult GetSectionList(string supersection)
        {
            //Server Side Parameter
            int start = Convert.ToInt32(Request["start"]);
            int length = Convert.ToInt32(Request["length"]);
            string searchValue = Request["search[value]"];
            string sortColumnName = Request["columns[" + Request["order[0][column]"] + "][name]"];
            string sortDirection = Request["order[0][dir]"];
            supersection = (supersection == null) ? "" : supersection;
            List<GET_M_Section_Result> list = new List<GET_M_Section_Result>();
            if (user.CostCode != "" && user.CostCode != null)
            {
                list = db.GET_M_Section(user.CostCode).ToList(); //List<M_Section> list = new List<M_Section>();

            }
            else
            {
                string cost = (from c in db.M_Cost_Center_List where c.GroupSection == supersection select c.Cost_Center).FirstOrDefault();
                list = db.GET_M_Section(cost).ToList(); //List<M_Section> list = new List<M_Section>();

            }
            //if (user.CostCode != "")
            //{
            //        list = (from c in db.M_Cost_Center_List
            //        where c.Cost_Center == user.CostCode
            //        select c).ToList();
            //}
            //else
            //{
            //    list = (from c in db.M_Cost_Center_List
            //            select c).ToList();

            //}

            if (!string.IsNullOrEmpty(searchValue))//filter
            {
                list = list.Where(x => x.Section.ToLower().Contains(searchValue.ToLower())).ToList<GET_M_Section_Result>();
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
            list = list.Skip(start).Take(length).ToList<GET_M_Section_Result>();
            return Json(new { data = list, draw = Request["draw"], recordsTotal = totalrows, recordsFiltered = totalrowsafterfiltering }, JsonRequestBehavior.AllowGet);
        }
        public ActionResult CreateSection(M_Section data)
        {
            try
            {
                data.CreateID = user.UserName;
                data.CreateDate = DateTime.Now;
                data.UpdateID = user.UserName;
                data.UpdateDate = DateTime.Now;

                M_Section checker = (from c in db.M_Section
                                      where c.Section == data.Section
                                      && c.Status == data.Status
                                      && c.IsDeleted == false
                                      select c).FirstOrDefault();
                if (checker == null)
                {
                    db.M_Section.Add(data);
                    db.SaveChanges();
                    return Json(new { msg = "Success" }, JsonRequestBehavior.AllowGet);
                }
                else
                {
                    return Json(new { msg = "Failed" }, JsonRequestBehavior.AllowGet);

                }
            }
            catch (Exception err)
            {
                Error_Logs error = new Error_Logs();
                error.PageModule = "Master - Section";
                error.ErrorLog = err.Message;
                error.DateLog = DateTime.Now;
                error.Username = user.UserName;
                db.Error_Logs.Add(error);
                db.SaveChanges();
                return Json(new { msg = err.Message }, JsonRequestBehavior.AllowGet);
            }
        }
        public ActionResult DeleteSection(int ID)
        {
            M_Section section = new M_Section();
            section = (from u in db.M_Section.ToList()
                        where u.ID == ID
                        select u).FirstOrDefault();
            section.IsDeleted = true;
            section.UpdateDate = DateTime.Now;
            section.UpdateID = user.UserName;
            db.Entry(section).State = EntityState.Modified;
            db.SaveChanges();
            return Json(new { msg = "Success" }, JsonRequestBehavior.AllowGet);
        }
        public ActionResult EditSection(M_Section data)
        {
            try
            {
                M_Section section = new M_Section();
                section = (from u in db.M_Section.ToList()
                            where u.ID == data.ID
                            select u).FirstOrDefault();
                section.Section = data.Section;
                section.Status = data.Status;

                section.UpdateID = "AdminUp";
                section.UpdateDate = DateTime.Now;

                M_Section checker = (from c in db.M_Section
                                      where c.Section == data.Section
                                      && c.Status == data.Status
                                      && c.IsDeleted == false
                                      select c).FirstOrDefault();
                if (checker == null)
                {
                    db.Entry(section).State = EntityState.Modified;
                    db.SaveChanges();
                }
                else
                {
                    return Json(new { msg = "Failed" }, JsonRequestBehavior.AllowGet);

                }
            }
            catch (Exception err) {
                Error_Logs error = new Error_Logs();
                error.PageModule = "Master - Section";
                error.ErrorLog = err.Message;
                error.DateLog = DateTime.Now;
                error.Username = user.UserName;
                db.Error_Logs.Add(error);
                db.SaveChanges();
            }

            return Json(new { msg = "Success" }, JsonRequestBehavior.AllowGet);
        }
        public ActionResult GetEmployeeName(string EmployeeNo)
        {
            M_Users Employeename = (from c in db.M_Users where c.UserName == EmployeeNo select c).FirstOrDefault();
            if (Employeename != null)
            {
                string completename = Employeename.FirstName + " " + Employeename.LastName;
                return Json(new { completename = completename }, JsonRequestBehavior.AllowGet);
            }
            else
            {
                return Json(new { completename = "" }, JsonRequestBehavior.AllowGet);
            }
        }

        public ActionResult GetUserName(string EmployeeNo)
        {
            M_Users Employeename = (from c in db.M_Users where c.UserName == EmployeeNo select c).FirstOrDefault();
            if (Employeename != null)
            {
                string completename = Employeename.FirstName + " " + Employeename.LastName;
                return Json(new { completename = completename }, JsonRequestBehavior.AllowGet);
            }
            else
            {
                return Json(new { completename = "" }, JsonRequestBehavior.AllowGet);
            }
        }
        public ActionResult SaveApprover(List<M_Section_Approver> Approver)
        {
            try
            {
                if (Approver[0].Section != null)
                {
                    db.M_SectionApproverReassign(Approver[0].Section);
                    foreach (M_Section_Approver approver in Approver)
                    {


                        approver.CreateID = user.UserName;
                        approver.CreateDate = DateTime.Now;
                        approver.UpdateID = user.UserName;
                        approver.UpdateDate = DateTime.Now;
                        db.M_Section_Approver.Add(approver);
                        db.SaveChanges();
                    }
                }
            }
            catch(Exception err)
            {
                Error_Logs error = new Error_Logs();
                error.PageModule = "Master - Section";
                error.ErrorLog = err.Message;
                error.DateLog = DateTime.Now;
                error.Username = user.UserName;
                db.Error_Logs.Add(error);
                db.SaveChanges();
                return Json(new { msg = err.Message }, JsonRequestBehavior.AllowGet);
            }
            return Json(new { msg="" }, JsonRequestBehavior.AllowGet);
        }
        public ActionResult GetApprovers(string Section)
        {
            if (Section == "")
            {
                Section = (from c in db.M_Cost_Center_List where c.Cost_Center == user.CostCode select c.GroupSection).FirstOrDefault();
            }

            List<M_Section_Approver> ApproversSupervisors = (from c in db.M_Section_Approver where c.Section == Section && c.Position == "Supervisor" select c).ToList();
            List<M_Section_Approver> ApproversManager = (from c in db.M_Section_Approver where c.Section == Section && c.Position == "Manager" select c).ToList();
            List<M_Section_Approver> ApproversGenManager = (from c in db.M_Section_Approver where c.Section == Section && c.Position == "GeneralManager" select c).ToList();
            List<M_Section_Approver> ApproversFGenManager = (from c in db.M_Section_Approver where c.Section == Section && c.Position == "FactoryGeneralManager" select c).ToList();


            return Json(new {
                ApproversSupervisors = ApproversSupervisors,
                ApproversManager = ApproversManager,
                ApproversGenManager = ApproversGenManager,
                ApproversFGenManager= ApproversFGenManager
            }, JsonRequestBehavior.AllowGet);
        }
    }
}