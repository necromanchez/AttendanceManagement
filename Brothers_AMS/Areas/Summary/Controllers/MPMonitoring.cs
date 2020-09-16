﻿using Brothers_WMS.Controllers;
using Brothers_WMS.Models;
using Newtonsoft.Json;
using OfficeOpenXml;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.IO;
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


        public ActionResult RemoveCache()
        {
            System.Web.HttpContext.Current.Session["MPresult"] = null;
            return Json(new { }, JsonRequestBehavior.AllowGet);
        }


        public ActionResult GetManPowerList(MPFilterModel Filter)
        {
            Filter.DateTo = Filter.DateTo.AddHours(23).AddMinutes(59).AddSeconds(59);
            //Server Side Parameter
            int start = Convert.ToInt32(Request["start"]);
            int length = Convert.ToInt32(Request["length"]);
            string searchValue = Request["search[value]"];
            string sortColumnName = Request["columns[" + Request["order[0][column]"] + "][name]"];
            string sortDirection = Request["order[0][dir]"];

            if (Filter.Section == null)
            {
                if (user.CostCode != null)
                {
                    Filter.Section = (from c in db.M_Cost_Center_List where c.Cost_Center == user.CostCode select c.GroupSection).FirstOrDefault();
                }
            }

            string section = (Filter.Section == null)?"":Filter.Section;
            //  string CostCode = (from d in db.M_Cost_Center_List where d.GroupSection == section select d.Cost_Center).FirstOrDefault();

            if (Filter.Shift != "Day" && Filter.Shift != "Night")
            {
                db.Database.CommandTimeout = 0;
                List<GET_RP_MPCMonitoringv2_Result> list = new List<GET_RP_MPCMonitoringv2_Result>();

                long shift = Convert.ToInt64(Filter.Shift);
                list = db.GET_RP_MPCMonitoringv2(Filter.DateFrom, Filter.DateTo, shift, Filter.Line, Filter.Process, section).ToList();

                System.Web.HttpContext.Current.Session["MPresult"] = Filter;

                switch (Filter.Certified)
                {
                    case "Certified":
                        list = list.Where(x => x.TrueColor == "Green" || x.TrueColor == "Black").ToList();
                        break;
                    case "Uncertified":
                        list = list.Where(x => x.TrueColor == "Red").ToList();
                        break;
                }
                if (!string.IsNullOrEmpty(searchValue))//filter
                {
                    #region null remover
                    list = list.Where(xx => xx.EmpNo != null).ToList();
                    //list = list.Where(xx => xx.Shift != null).ToList();//To search all
                    //list = list.Where(xx => xx.Line != null).ToList();
                    //list = list.Where(xx => xx.Skill != null).ToList();
                    #endregion
                    list = list.Where(x => x.EmployeeName.ToLower().Contains(searchValue.ToLower())
                                        || x.EmpNo.ToLower().Contains(searchValue.ToLower())).ToList<GET_RP_MPCMonitoringv2_Result>();
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
                list = list.Skip(start).Take(length).ToList<GET_RP_MPCMonitoringv2_Result>();
                //return Json(new { data = list, draw = Request["draw"], recordsTotal = totalrows, recordsFiltered = totalrowsafterfiltering }, JsonRequestBehavior.AllowGet);

                var jsonResult = Json(new { data = list, draw = Request["draw"], recordsTotal = totalrows, recordsFiltered = totalrowsafterfiltering }, JsonRequestBehavior.AllowGet);
                jsonResult.MaxJsonLength = int.MaxValue;
                return jsonResult;
            }
            else
            {
                db.Database.CommandTimeout = 0;
                List<GET_RP_MPCMonitoringv2ALLShift_Result> list = new List<GET_RP_MPCMonitoringv2ALLShift_Result>();
                
                list = db.GET_RP_MPCMonitoringv2ALLShift(Filter.DateFrom, Filter.DateTo, Filter.Shift, Filter.Line, Filter.Process, section).ToList();

                System.Web.HttpContext.Current.Session["MPresult"] = Filter;

                switch (Filter.Certified)
                {
                    case "Certified":
                        list = list.Where(x => x.TrueColor == "Green" || x.TrueColor == "Black").ToList();
                        break;
                    case "Uncertified":
                        list = list.Where(x => x.TrueColor == "Red").ToList();
                        break;
                }
                if (!string.IsNullOrEmpty(searchValue))//filter
                {
                    #region null remover
                    list = list.Where(xx => xx.EmpNo != null).ToList();
                    //list = list.Where(xx => xx.Shift != null).ToList();//To search all
                    //list = list.Where(xx => xx.Line != null).ToList();
                    //list = list.Where(xx => xx.Skill != null).ToList();
                    #endregion
                    list = list.Where(x => x.EmployeeName.ToLower().Contains(searchValue.ToLower())
                                        || x.EmpNo.ToLower().Contains(searchValue.ToLower())).ToList<GET_RP_MPCMonitoringv2ALLShift_Result>();
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
                list = list.Skip(start).Take(length).ToList<GET_RP_MPCMonitoringv2ALLShift_Result>();
                //return Json(new { data = list, draw = Request["draw"], recordsTotal = totalrows, recordsFiltered = totalrowsafterfiltering }, JsonRequestBehavior.AllowGet);

                var jsonResult = Json(new { data = list, draw = Request["draw"], recordsTotal = totalrows, recordsFiltered = totalrowsafterfiltering }, JsonRequestBehavior.AllowGet);
                jsonResult.MaxJsonLength = int.MaxValue;
                return jsonResult;
            }
           

            
        }

        public class Graphcount
        {
            public DateTime InDate { get; set; }
            public string TrueColor { get; set; }
            public int HeadCount { get; set; }
        }

        public ActionResult GetManPowerGraph(MPFilterModel Filter)
        {
            
            switch (Filter.Certified)
            {
                case "Certified":
                    Filter.Certified = "Green";
                    break;
                case "Uncertified":
                    Filter.Certified = "Red";
                    break;
            }
            if (Filter.Section == null)
            {
                if (user.CostCode != null)
                {
                    Filter.Section = (from c in db.M_Cost_Center_List where c.Cost_Center == user.CostCode select c.GroupSection).FirstOrDefault();
                }
            }
            string section = (Filter.Section == null) ? "" : Filter.Section;
           
            TimeSpan ts = new TimeSpan(23, 00, 0);
           
            Filter.DateTo = Filter.DateTo = Filter.DateTo.AddHours(23).AddMinutes(59).AddSeconds(59);

            if (Filter.Shift != "Day" && Filter.Shift != "Night")
            {
                long shift = Convert.ToInt64(Filter.Shift);
                db.Database.CommandTimeout = 0;
                List<GET_RPMonitoring_Graphv2_Result> graphlist = db.GET_RPMonitoring_Graphv2(Filter.DateFrom, Filter.DateTo, shift, Filter.Line, Filter.Process, section, Filter.Certified).ToList();

                var jsonResult = Json(new { graphlist = graphlist }, JsonRequestBehavior.AllowGet);
                jsonResult.MaxJsonLength = int.MaxValue;
                return jsonResult;
            }
            else
            {
                db.Database.CommandTimeout = 0;
                List<GET_RPMonitoring_Graphv2ALLShift_Result> graphlist = db.GET_RPMonitoring_Graphv2ALLShift(Filter.DateFrom, Filter.DateTo, Filter.Shift, Filter.Line, Filter.Process, section, Filter.Certified).ToList();

                var jsonResult = Json(new { graphlist = graphlist }, JsonRequestBehavior.AllowGet);
                jsonResult.MaxJsonLength = int.MaxValue;
                return jsonResult;
            }
        }


        public ActionResult ExportMP(string Section)
        {
            try
            {
                string templateFilename = "ManPowerMonitoring.xlsx";
                string dir = Path.GetTempPath();
                string datetimeToday = DateTime.Now.ToString("yyMMddhhmmss");

                string filename = string.Format("ManPowerMonitoring{0}_{1}.xlsx", datetimeToday, Section);
                FileInfo newFile = new FileInfo(Path.Combine(dir, filename));
                string apptemplatePath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, @"TemplateFiles\ExportReports\", templateFilename);
                FileInfo templateFile = new FileInfo(apptemplatePath);

                using (ExcelPackage package = new ExcelPackage(newFile, templateFile))  //-- With template.
                {
                    MPFilterModel Filter = (MPFilterModel)System.Web.HttpContext.Current.Session["MPresult"];
                    long shift = Convert.ToInt64(Filter.Shift);
                    string section = (Filter.Section == null) ? "" : Filter.Section;
                    List<GET_RP_MPCMonitoringv2_Result> list = new List<GET_RP_MPCMonitoringv2_Result>();
                    list = db.GET_RP_MPCMonitoringv2(Filter.DateFrom, Filter.DateTo, shift, Filter.Line, Filter.Process, section).ToList(); //(List<GET_RP_MPCMonitoringv2_Result>)System.Web.HttpContext.Current.Session["MPresult"]; //db.GET_RP_MPCMonitoringv2(Filter.DateFrom, Filter.DateTo, shift, Filter.Line, Filter.Process, section).ToList();
                    ExcelWorksheet ExportData = package.Workbook.Worksheets["Sheet1"];
                    int start = 2;

                    for (int i = 0; i < list.Count; i++)
                    {
                        ExportData.Cells["A" + start].Value = list[i].Rownum;
                        ExportData.Cells["B" + start].Value = list[i].InDate;
                        ExportData.Cells["C" + start].Value = list[i].TimeIn;
                        ExportData.Cells["D" + start].Value = list[i].InDateOut;
                        ExportData.Cells["E" + start].Value = list[i].TimeOut;
                        ExportData.Cells["F" + start].Value = list[i].Shift;
                        ExportData.Cells["G" + start].Value = list[i].Line;
                        ExportData.Cells["H" + start].Value = list[i].Skill;
                        ExportData.Cells["I" + start].Value = list[i].EmpNo;
                        ExportData.Cells["J" + start].Value = list[i].EmployeeName;
                        ExportData.Cells["K" + start].Value = list[i].Date_Hired;
                        ExportData.Cells["L" + start].Value = list[i].DateCertified;
                        ExportData.Cells["M" + start].Value = list[i].Status;

                        start++;
                    }
                    return File(package.GetAsByteArray(), "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", filename);
                }
            }
            catch (Exception err) { }
            return Json(new { }, JsonRequestBehavior.AllowGet);
        }


        #region for OverallShift
        //public ActionResult GetManPowerList_OvellAll(MPFilterModel Filter)
        //{
        //    Filter.DateTo = Filter.DateTo.AddHours(23).AddMinutes(59).AddSeconds(59);
        //    //Server Side Parameter
        //    int start = Convert.ToInt32(Request["start"]);
        //    int length = Convert.ToInt32(Request["length"]);
        //    string searchValue = Request["search[value]"];
        //    string sortColumnName = Request["columns[" + Request["order[0][column]"] + "][name]"];
        //    string sortDirection = Request["order[0][dir]"];

        //    if (Filter.Section == null)
        //    {
        //        if (user.CostCode != null)
        //        {
        //            Filter.Section = (from c in db.M_Cost_Center_List where c.Cost_Center == user.CostCode select c.GroupSection).FirstOrDefault();
        //        }
        //    }

        //    string section = (Filter.Section == null) ? "" : Filter.Section;
        //    //  string CostCode = (from d in db.M_Cost_Center_List where d.GroupSection == section select d.Cost_Center).FirstOrDefault();


        //    db.Database.CommandTimeout = 0;
        //    List<GET_RP_MPCMonitoringv2_OverallShift_Result> list = db.GET_RP_MPCMonitoringv2_OverallShift(Filter.DateFrom, Filter.DateTo, Filter.Shift, Filter.Line, Filter.Process, section).ToList();

        //    switch (Filter.Certified)
        //    {
        //        case "Certified":
        //            list = list.Where(x => x.TrueColor == "Green" || x.TrueColor == "Black").ToList();
        //            break;
        //        case "Uncertified":
        //            list = list.Where(x => x.TrueColor == "Red").ToList();
        //            break;
        //    }
        //    if (!string.IsNullOrEmpty(searchValue))//filter
        //    {
        //        #region null remover
        //        list = list.Where(xx => xx.EmpNo != null).ToList();
        //        list = list.Where(xx => xx.Shift != null).ToList();
        //        list = list.Where(xx => xx.Line != null).ToList();
        //        list = list.Where(xx => xx.Skill != null).ToList();
        //        #endregion
        //        list = list.Where(x => x.EmployeeName.ToLower().Contains(searchValue.ToLower())
        //                            || x.Shift.ToLower().Contains(searchValue.ToLower())
        //                            || x.Line.ToLower().Contains(searchValue.ToLower())
        //                            || x.Skill.ToLower().Contains(searchValue.ToLower())).ToList<GET_RP_MPCMonitoringv2_OverallShift_Result>();
        //    }
        //    if (sortColumnName != "" && sortColumnName != null)
        //    {
        //        if (sortDirection == "asc")
        //        {
        //            list = list.OrderBy(x => TypeHelper.GetPropertyValue(x, sortColumnName)).ToList();
        //        }
        //        else
        //        {
        //            list = list.OrderByDescending(x => TypeHelper.GetPropertyValue(x, sortColumnName)).ToList();
        //        }
        //    }
        //    int totalrows = list.Count;
        //    int totalrowsafterfiltering = list.Count;

        //    //paging
        //    list = list.Skip(start).Take(length).ToList<GET_RP_MPCMonitoringv2_OverallShift_Result>();
        //    return Json(new { data = list, draw = Request["draw"], recordsTotal = totalrows, recordsFiltered = totalrowsafterfiltering }, JsonRequestBehavior.AllowGet);
        //}

        //public ActionResult GetManPowerGraph_OverAll(MPFilterModel Filter)
        //{

        //    switch (Filter.Certified)
        //    {
        //        case "Certified":
        //            Filter.Certified = "Green";
        //            break;
        //        case "Uncertified":
        //            Filter.Certified = "Red";
        //            break;
        //    }
        //    if (Filter.Section == null)
        //    {
        //        if (user.CostCode != null)
        //        {
        //            Filter.Section = (from c in db.M_Cost_Center_List where c.Cost_Center == user.CostCode select c.GroupSection).FirstOrDefault();
        //        }
        //    }
        //    string section = (Filter.Section == null) ? "" : Filter.Section;

        //    TimeSpan ts = new TimeSpan(23, 00, 0);
        //    Filter.DateTo = Filter.DateTo = Filter.DateTo.AddHours(23).AddMinutes(59).AddSeconds(59);
        //    db.Database.CommandTimeout = 0;
        //    List<GET_RPMonitoring_Graphv2_OverallShift_Result> graphlist = db.GET_RPMonitoring_Graphv2_OverallShift(Filter.DateFrom, Filter.DateTo, Filter.Shift, Filter.Line, Filter.Process, section, Filter.Certified).ToList();

        //    return Json(new { graphlist = graphlist }, JsonRequestBehavior.AllowGet);
        //}
        #endregion
    }
}