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
    public class CostCenterController : Controller
    {
        // GET: Masters/CostCenter
        Brothers_AMSDBEntities db = new Brothers_AMSDBEntities();
        M_Users user = (M_Users)System.Web.HttpContext.Current.Session["user"];

        public ActionResult CostCenter()
        {
            return View();
        }

        public ActionResult SyncIT()
        {
            try
            {
                db.M_SP_ImportCostCodeFromITSystem();
                return Json(new { msg = "Success" }, JsonRequestBehavior.AllowGet);
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
                return Json(new { msg = err.Message }, JsonRequestBehavior.AllowGet);
            }
        }

        public ActionResult GetCostCenterList()
        {
            //Server Side Parameter
            int start = Convert.ToInt32(Request["start"]);
            int length = Convert.ToInt32(Request["length"]);
            string searchValue = Request["search[value]"];
            string sortColumnName = Request["columns[" + Request["order[0][column]"] + "][name]"];
            string sortDirection = Request["order[0][dir]"];

            List<M_Cost_Center_List> list = new List<M_Cost_Center_List>();
            list = (from c in db.M_Cost_Center_List
                    select c).ToList();

            if (!string.IsNullOrEmpty(searchValue))//filter
            {
                list = list.Where(x => x.Cost_Center.ToLower().Contains(searchValue.ToLower())
                || x.Section.ToLower().Contains(searchValue.ToLower())).ToList<M_Cost_Center_List>();
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
            list = list.Skip(start).Take(length).ToList<M_Cost_Center_List>();
            return Json(new { data = list, draw = Request["draw"], recordsTotal = totalrows, recordsFiltered = totalrowsafterfiltering }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult UpdateGroup(string CostCode, string SectionGroup)
        {
            M_Cost_Center_List cost = (from c in db.M_Cost_Center_List
                                       where c.Cost_Center == CostCode
                                       select c).FirstOrDefault();

            cost.GroupSection = (SectionGroup == "")?null: SectionGroup;
            db.Entry(cost).State = EntityState.Modified;
            db.SaveChanges();
            return Json(new { }, JsonRequestBehavior.AllowGet);
        }

    }
}