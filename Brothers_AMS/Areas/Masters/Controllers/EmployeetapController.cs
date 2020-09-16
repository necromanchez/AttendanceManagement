using Brothers_WMS.Controllers;
using Brothers_WMS.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using static Brothers_WMS.Controllers.SessionExpire;

namespace Brothers_WMS.Areas.Masters.Controllers
{
    [SessionExpire]
    public class EmployeetapController : Controller
    {
        Brothers_AMSDBEntities db = new Brothers_AMSDBEntities();
        M_Users user = (M_Users)System.Web.HttpContext.Current.Session["user"];
        // GET: Masters/Employeetap
        public ActionResult Employeetap()
        {
            return View();
        }

        public ActionResult GetTapList(DateTime? searchdate)
        {
            //Server Side Parameter
            int start = Convert.ToInt32(Request["start"]);
            int length = Convert.ToInt32(Request["length"]);
            string searchValue = Request["search[value]"];
            string sortColumnName = Request["columns[" + Request["order[0][column]"] + "][name]"];
            string sortDirection = Request["order[0][dir]"];

            List<TT_EmployeeTaps_Result> list = new List<TT_EmployeeTaps_Result>();
            list = (from c in db.TT_EmployeeTaps("",DateTime.Now, DateTime.Now)
                   
                    orderby c.Employee_RFID descending
                    select c).ToList();

            if (!string.IsNullOrEmpty(searchValue))//filter
            {
                list = list.Where(x => x.Employee_RFID.ToLower().Contains(searchValue.ToLower())
                                    || x.EmployeeName.ToLower().Contains(searchValue.ToLower())
                                    || x.Type.ToLower().Contains(searchValue.ToLower())
                                    || x.Taptype.ToLower().Contains(searchValue.ToLower())).ToList<TT_EmployeeTaps_Result>();
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
            list = list.Skip(start).Take(length).ToList<TT_EmployeeTaps_Result>();
            return Json(new { data = list, draw = Request["draw"], recordsTotal = totalrows, recordsFiltered = totalrowsafterfiltering }, JsonRequestBehavior.AllowGet);
        }
    }
}