using Brothers_WMS.Controllers;
using Brothers_WMS.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using static Brothers_WMS.Controllers.SessionExpire;

namespace Brothers_WMS.Areas.Summary.Controllers
{
    [SessionExpire]
    public class MPMonitoringController : Controller
    {
        // GET: Summary/MPCertificate
        Brothers_AMSDBEntities db = new Brothers_AMSDBEntities();
        M_Users user = (M_Users)System.Web.HttpContext.Current.Session["user"];
        public ActionResult MPMonitoring()
        {
            return View();
        }

        
        public ActionResult GetManPowerList(MPFilterModel Filter)
        {
            #region Time configure
            //DateTime s1 = Filter.DateFrom;
            //TimeSpan ts2 = new TimeSpan(00, 00, 0);
            //Filter.DateFrom = s1.Date + ts2;

            //DateTime s = Filter.DateTo;
            //TimeSpan ts = new TimeSpan(23, 59, 59);
            //Filter.DateTo = s = s.Date + ts;
            #endregion

            //Server Side Parameter
            int start = Convert.ToInt32(Request["start"]);
            int length = Convert.ToInt32(Request["length"]);
            string searchValue = Request["search[value]"];
            string sortColumnName = Request["columns[" + Request["order[0][column]"] + "][name]"];
            string sortDirection = Request["order[0][dir]"];

            string section = Filter.Section;
            string CostCode = (from d in db.M_Cost_Center_List where d.GroupSection == section select d.Cost_Center).FirstOrDefault();


            List<GET_RP_MPCMonitoring_Result> list = db.GET_RP_MPCMonitoring(Filter.DateFrom, Filter.DateTo, Filter.Shift, Filter.Line, Filter.Process, CostCode).ToList();

            if (!string.IsNullOrEmpty(searchValue))//filter
            {
                list = list.Where(x => x.EmployeeName.ToLower().Contains(searchValue.ToLower())
                                    || x.ShiftNew.ToLower().Contains(searchValue.ToLower())
                                    || x.LineNew.ToLower().Contains(searchValue.ToLower())
                                    || x.Skill.ToLower().Contains(searchValue.ToLower())).ToList<GET_RP_MPCMonitoring_Result>();
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
            list = list.Skip(start).Take(length).ToList<GET_RP_MPCMonitoring_Result>();
            return Json(new { data = list, draw = Request["draw"], recordsTotal = totalrows, recordsFiltered = totalrowsafterfiltering }, JsonRequestBehavior.AllowGet);
        }

        public class Graphcount
        {
            public DateTime? Date { get; set; }
            public int Count { get; set; }
        }

        public ActionResult GetManPowerGraph(MPFilterModel Filter)
        {
            //#region Time configure
            ////DateTime s1 = Filter.DateFrom;
            ////TimeSpan ts2 = new TimeSpan(00, 00, 0);
            ////Filter.DateFrom = s1.Date + ts2;

            //DateTime s = Filter.DateTo;
            //TimeSpan ts = new TimeSpan(23, 00, 0);
            //Filter.DateTo = s = s.Date + ts;

            ////int LineID = (from line in db.M_LineTeam where line.Section == user.CostCode select line.li)

            //#endregion
            string section = Filter.Section;
            string CostCode = (from d in db.M_Cost_Center_List where d.GroupSection == section select d.Cost_Center).FirstOrDefault();

            List<GET_RPMonitoring_Graph_Result> graphlist = db.GET_RPMonitoring_Graph(Filter.DateFrom, Filter.DateTo, Filter.Shift, Filter.Line, Filter.Process, CostCode).ToList();
            //List<GET_RPMonitoring_GraphData_Result> graphlist = db.GET_RPMonitoring_GraphData(Filter.DateFrom, Filter.DateTo, Filter.Shift, Filter.Line, Filter.Process, CostCode).ToList();
          


            return Json(new { graphlist = graphlist }, JsonRequestBehavior.AllowGet);
        }
    }
}