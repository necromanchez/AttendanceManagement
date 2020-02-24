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
    public class ApproverController : Controller
    {
        // GET: Masters/Approver
        Brothers_AMSDBEntities db = new Brothers_AMSDBEntities();
        M_Users user = (M_Users)System.Web.HttpContext.Current.Session["user"];
        public ActionResult Approver()
        {
            //EmailApprover s = new EmailApprover();
            //s.sendMail("asd","asd");
            return View();
        }

        public ActionResult GetApproverList()
        {
            //Server Side Parameter
            int start = Convert.ToInt32(Request["start"]);
            int length = Convert.ToInt32(Request["length"]);
            string searchValue = Request["search[value]"];
            string sortColumnName = Request["columns[" + Request["order[0][column]"] + "][name]"];
            string sortDirection = Request["order[0][dir]"];
            
            List<GET_Employee_Approver_Result> list = db.GET_Employee_Approver().ToList();

            if (!string.IsNullOrEmpty(searchValue))//filter
            {
                list = list.Where(x => x.BIPH_Agency.ToLower().Contains(searchValue.ToLower())).ToList<GET_Employee_Approver_Result>();
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
            list = list.Skip(start).Take(length).ToList<GET_Employee_Approver_Result>();
            return Json(new { data = list, draw = Request["draw"], recordsTotal = totalrows, recordsFiltered = totalrowsafterfiltering }, JsonRequestBehavior.AllowGet);
        }
        public ActionResult CreateApprover(M_Approver data)
        {
            try
            {
                data.CreateID = user.UserName;
                data.CreateDate = DateTime.Now;
                data.UpdateID = user.UserName;
                data.UpdateDate = DateTime.Now;

                M_Approver checker = (from c in db.M_Approver
                                      where c.BIPH_Agency == data.BIPH_Agency
                                      && c.EmployeeNo == data.EmployeeNo
                                      && c.Status == data.Status
                                      && c.IsDeleted == false
                                      select c).FirstOrDefault();
                if (checker == null)
                {
                    db.M_Approver.Add(data);
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
                error.PageModule = "Masters - Approver";
                error.ErrorLog = err.Message;
                error.DateLog = DateTime.Now;
                error.Username = user.UserName;
                db.Error_Logs.Add(error);
                db.SaveChanges();
                return Json(new { msg = err.Message }, JsonRequestBehavior.AllowGet);
            }
        }
        public ActionResult DeleteApprover(int ID)
        {
            M_Approver approver = new M_Approver();
            approver = (from u in db.M_Approver.ToList()
                        where u.ID == ID
                        select u).FirstOrDefault();
            approver.IsDeleted = true;
            approver.UpdateDate = DateTime.Now;
            approver.UpdateID = user.UserName;
            db.Entry(approver).State = EntityState.Modified;
            db.SaveChanges();
            return Json(new { msg = "Success" }, JsonRequestBehavior.AllowGet);
        }
        public ActionResult EditApprover(M_Approver data)
        {
            try
            {
                M_Approver approver = new M_Approver();
                approver = (from u in db.M_Approver.ToList()
                            where u.ID == data.ID
                            select u).FirstOrDefault();
                approver.BIPH_Agency = data.BIPH_Agency;
                approver.EmployeeNo = data.EmployeeNo;
                approver.Section = data.Section;
                approver.Status = data.Status;

                approver.UpdateID = "AdminUp";
                approver.UpdateDate = DateTime.Now;

                M_Approver checker = (from c in db.M_Approver
                                      where c.BIPH_Agency == data.BIPH_Agency
                                      && c.EmployeeNo == data.EmployeeNo
                                      && c.Section == data.Section
                                      && c.Status == data.Status
                                      && c.IsDeleted == false
                                      select c).FirstOrDefault();
                if (checker == null)
                {
                    db.Entry(approver).State = EntityState.Modified;
                    db.SaveChanges();
                }
                else
                {
                    return Json(new { msg = "Failed" }, JsonRequestBehavior.AllowGet);

                }
            }
            catch (Exception err)
            {
                Error_Logs error = new Error_Logs();
                error.PageModule = "Master - Approver";
                error.ErrorLog = err.Message;
                error.DateLog = DateTime.Now;
                error.Username = user.UserName;
                db.Error_Logs.Add(error);
                db.SaveChanges();
            }

            return Json(new { msg = "Success" }, JsonRequestBehavior.AllowGet);
        }
    }
}