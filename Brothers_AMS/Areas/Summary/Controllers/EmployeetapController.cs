using Brothers_WMS.Controllers;
using Brothers_WMS.Models;
using System;
using System.Collections.Generic;
using System.Data.Entity.Core.Objects;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using static Brothers_WMS.Controllers.SessionExpire;

namespace Brothers_WMS.Areas.Summary.Controllers
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

        public ActionResult GetTapList(DateTime searchdate, DateTime searchdate2, string Sectiontap, string Agency)
        {
            //Server Side Parameter
           
            searchdate2 = searchdate2.AddHours(23).AddMinutes(59).AddSeconds(59);
            int start = (Convert.ToInt32(Request["start"]) == 0) ? 0 : (Convert.ToInt32(Request["start"]) / Convert.ToInt32(Request["length"]));
            int length = Convert.ToInt32(Request["length"]);
            string searchValue = Request["search[value]"];
            string sortColumnName = Request["columns[" + Request["order[0][column]"] + "][name]"];
            string sortDirection = Request["order[0][dir]"];
            db.Database.CommandTimeout = 0;
            ObjectParameter totalCount = new ObjectParameter("TotalCount", typeof(int));
            List<TT_EmployeeTaps_Result> list = new List<TT_EmployeeTaps_Result>();
            list = db.TT_EmployeeTaps(Sectiontap, searchdate, searchdate2, searchValue, Agency, start, length, totalCount).ToList();

            int? totalrows = Convert.ToInt32(totalCount.Value);//list.Count;
            int? totalrowsafterfiltering = Convert.ToInt32(totalCount.Value);//list.Count;


            //paging
            // list = list.Skip(start).Take(length).ToList<TT_EmployeeTaps_Result>();
            return Json(new { data = list, draw = Request["draw"], recordsTotal = totalrows, recordsFiltered = totalrowsafterfiltering }, JsonRequestBehavior.AllowGet);
        }
    }
}