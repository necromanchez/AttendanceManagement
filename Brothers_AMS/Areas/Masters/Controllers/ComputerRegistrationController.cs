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
    public class ComputerRegistrationController : Controller
    {
        // GET: Masters/ComputerRegistration
        Brothers_AMSDBEntities db = new Brothers_AMSDBEntities();
        M_Users user = (M_Users)System.Web.HttpContext.Current.Session["user"];
        public ActionResult ComputerRegistration()
        {
            return View();
        }
        public ActionResult GetComputerRegistrationList()
        {
            //Server Side Parameter
            int start = Convert.ToInt32(Request["start"]);
            int length = Convert.ToInt32(Request["length"]);
            string searchValue = Request["search[value]"];
            string sortColumnName = Request["columns[" + Request["order[0][column]"] + "][name]"];
            string sortDirection = Request["order[0][dir]"];

            List<M_ComputerRegistration> list = new List<M_ComputerRegistration>();
            list = (from c in db.M_ComputerRegistration
                    where c.IsDeleted == false
                    select c).ToList();

            if (!string.IsNullOrEmpty(searchValue))//filter
            {
                list = list.Where(x => x.ComputerName.ToLower().Contains(searchValue.ToLower())).ToList<M_ComputerRegistration>();
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
            list = list.Skip(start).Take(length).ToList<M_ComputerRegistration>();
            return Json(new { data = list, draw = Request["draw"], recordsTotal = totalrows, recordsFiltered = totalrowsafterfiltering }, JsonRequestBehavior.AllowGet);
        }
        public ActionResult CreateComputer(M_ComputerRegistration data)
        {
            try
            {
                data.CreateID = user.UserName;
                data.CreateDate = DateTime.Now;
                data.UpdateID = user.UserName;
                data.UpdateDate = DateTime.Now;

                M_ComputerRegistration checker = (from c in db.M_ComputerRegistration
                                                  where c.ComputerName == data.ComputerName
                                                    && c.ComputerIP == data.ComputerIP
                                                    && c.Status == data.Status
                                                    && c.IsDeleted == false
                                                    select c).FirstOrDefault();
                if (checker == null)
                {
                    db.M_ComputerRegistration.Add(data);
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
                error.PageModule = "Master - M_ComputerRegistration";
                error.ErrorLog = err.Message;
                error.DateLog = DateTime.Now;
                error.Username = user.UserName;
                db.Error_Logs.Add(error);
                db.SaveChanges();
                return Json(new { msg = err.Message }, JsonRequestBehavior.AllowGet);
            }
        }
        public ActionResult EditComputer(M_ComputerRegistration data)
        {
            try
            {
                M_ComputerRegistration computer = new M_ComputerRegistration();
                computer = (from u in db.M_ComputerRegistration.ToList()
                          where u.ID == data.ID
                          select u).FirstOrDefault();
                computer.ComputerName = data.ComputerName;
                computer.ComputerIP = data.ComputerIP;
                computer.Status = data.Status;
                computer.UpdateID = user.UserName;
                computer.UpdateDate = DateTime.Now;

                M_ComputerRegistration checker = (from c in db.M_ComputerRegistration
                                    where c.ComputerName == data.ComputerName
                                    && c.ComputerIP == data.ComputerIP
                                    && c.Status == data.Status
                                    && c.IsDeleted == false
                                    select c).FirstOrDefault();
                if (checker == null)
                {
                    db.Entry(computer).State = EntityState.Modified;
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
                error.PageModule = "Master - Computer Registration";
                error.ErrorLog = err.Message;
                error.DateLog = DateTime.Now;
                error.Username = user.UserName;
                db.Error_Logs.Add(error);
                db.SaveChanges();
            }

            return Json(new { msg = "Success" }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult DeleteComputer(int ID)
        {
            M_ComputerRegistration computer = new M_ComputerRegistration();
            computer = (from u in db.M_ComputerRegistration.ToList()
                      where u.ID == ID
                      select u).FirstOrDefault();
            computer.IsDeleted = true;
            computer.UpdateDate = DateTime.Now;
            computer.UpdateID = user.UserName;
            db.Entry(computer).State = EntityState.Modified;
            db.SaveChanges();
            return Json(new { msg = "Success" }, JsonRequestBehavior.AllowGet);
        }

    }
}