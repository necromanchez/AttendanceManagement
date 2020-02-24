using Brothers_WMS.Controllers;
using Brothers_WMS.Models;
using OfficeOpenXml;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using static Brothers_WMS.Controllers.SessionExpire;
using OfficeOpenXml.Drawing;
using OfficeOpenXml.Style;
using System.Drawing;
using System.Net;
using System.ComponentModel;
using System.Threading.Tasks;

namespace Brothers_WMS.Areas.Summary.Controllers
{
    [SessionExpire]
    public class OTSummaryController : Controller
    {
        // GET: Summary/OTSummary
        Brothers_AMSDBEntities db = new Brothers_AMSDBEntities();
        M_Users user = (M_Users)System.Web.HttpContext.Current.Session["user"];
        public ActionResult OTSummary()
        {
            return View();
        }
        
        public ActionResult GetApproverOTSummaryList(string Refno, string Section, DateTime? DateFrom, DateTime? DateTo, string Type, string Status)
        {
            DateFrom = (DateFrom == null) ? new DateTime(1990, 1, 1) : DateFrom;
            DateTo = (DateTo == null) ? DateTime.Now : DateTo;
            int start = Convert.ToInt32(Request["start"]);
            int length = Convert.ToInt32(Request["length"]);
            string searchValue = (Session["RNO"] != null) ? Session["RNO"].ToString() : Request["search[value]"];
            string sortColumnName = Request["columns[" + Request["order[0][column]"] + "][name]"];
            string sortDirection = Request["order[0][dir]"];

            List<GET_AF_OTSummary_Result> list = db.GET_AF_OTSummary(Refno,Section,DateFrom,DateTo,Type, Status).ToList();

            if (!string.IsNullOrEmpty(searchValue))//filter
            {
                list = list.Where(x => x.OT_RefNo.ToLower().Contains(searchValue.ToLower())).ToList<GET_AF_OTSummary_Result>();
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
            list = list.Skip(start).Take(length).ToList<GET_AF_OTSummary_Result>();

            return Json(new { data = list, draw = Request["draw"], recordsTotal = totalrows, recordsFiltered = totalrowsafterfiltering }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult GetApproverOTDetailsList(string OTRefNo, int status, string OTType)
        {
            int start = Convert.ToInt32(Request["start"]);
            int length = Convert.ToInt32(Request["length"]);
            string searchValue = Request["search[value]"];
            string sortColumnName = Request["columns[" + Request["order[0][column]"] + "][name]"];
            string sortDirection = Request["order[0][dir]"];

            List<GET_AF_OTSummaryDetail_Result> list = db.GET_AF_OTSummaryDetail(OTRefNo, status, OTType).ToList();

            if (!string.IsNullOrEmpty(searchValue))//filter
            {
                list = list.Where(x => x.EmployeeNo.ToLower().Contains(searchValue.ToLower())
                || x.EmployeeName.ToLower().Contains(searchValue.ToLower())).ToList<GET_AF_OTSummaryDetail_Result>();
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
            list = list.Skip(start).Take(length).ToList<GET_AF_OTSummaryDetail_Result>();
            return Json(new { data = list, draw = Request["draw"], recordsTotal = totalrows, recordsFiltered = totalrowsafterfiltering }, JsonRequestBehavior.AllowGet);

            //return Json(new { }, JsonRequestBehavior.AllowGet);
        }

        public JsonResult GetOTRefnoList(string otrefno)
        {
            var list = (from c in db.AF_OTfiling where c.OT_RefNo.Contains(otrefno) select new { text = c.OT_RefNo }).Distinct().ToList();
            return Json(new { list = list }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult ExportOTSummary(string RefNo, string Status)
        {
            try
            {
                string templateFilename = "OT_template.xlsx";
                string dir = Path.GetTempPath();
                string datetimeToday = DateTime.Now.ToString("yyMMddhhmmss");
                string filename = string.Format("OT_template{0}_{1}.xlsx", datetimeToday, RefNo);
                FileInfo newFile = new FileInfo(Path.Combine(dir, filename));
                string apptemplatePath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, @"TemplateFiles\StandardTemplate\", templateFilename);
                FileInfo templateFile = new FileInfo(apptemplatePath);

                string ArrayRefNo = RefNo;
                string ArrayStatus = Status;

                string[] ARefno = new string[] {""};
                ARefno = ArrayRefNo.Split(',');

                string[] AStatus = new string[] { "" };
                AStatus = ArrayStatus.Split(',');

                int b = ARefno.Count() - 1;

                using (ExcelPackage package = new ExcelPackage(newFile, templateFile))  //-- With template.
                {

                    ExcelWorksheet ExportData = package.Workbook.Worksheets["OT Summary"];

                    var dateFile = string.Format("{0}", datetimeToday);
                    int start = 2;
                    for (int i = 0; i <= b; i++)
                    {
                         
                        //List<GET_AF_OTSummaryDetail_Result> list = db.GET_AF_OTSummaryDetail(ARefno[i], int.Parse(AStatus[i])).ToList();
                        //if (list.Count > 0)
                        //{
                            
                        //    foreach (GET_AF_OTSummaryDetail_Result item in list)
                        //    {

                        //        string Department = (from c in db.M_Employee_Master_List where c.EmpNo == item.EmployeeNo select c.Department).FirstOrDefault();
                        //        //item.DatePrepared = (from c in db.AF_OTfiling where c.EmployeeNo == item.EmployeeNo select c.CreateDate).FirstOrDefault();

                        //        string cAgency = (from c in db.AF_OTfiling where c.OT_RefNo == item.OT_RefNo select c.BIPH_Agency).FirstOrDefault();
                        //        string AgencyName = (from ma in db.M_Agency where ma.AgencyCode == cAgency select ma.AgencyName).FirstOrDefault();
                        //        string AgencyAddress = (from ma in db.M_Agency where ma.AgencyCode == cAgency select ma.Address).FirstOrDefault();
                        //        string ISOOT = (from ma in db.M_Agency where ma.AgencyCode == cAgency select ma.ISO_OT).FirstOrDefault();
                        //        string LogoName = (from ma in db.M_Agency where ma.AgencyCode == cAgency select ma.Logo).FirstOrDefault();



                        //        ExportData.Cells["B" + start].Value = item.OT_RefNo;
                        //        ExportData.Cells["C" + start].Value = item.EmployeeNo;
                        //        ExportData.Cells["D" + start].Value = item.EmployeeName;
                        //        ExportData.Cells["E" + start].Value = item.Section;
                        //        ExportData.Cells["F" + start].Value = item.Purpose;
                        //        ExportData.Cells["G" + start].Value = item.OvertimeType;
                        //        ExportData.Cells["H" + start].Value = item.DateFrom.ToString("MM-dd-yyyy");
                        //        //ExportData.Cells["I" + start].Value = item.DateTo.ToString("MM-dd-yyyy");

                        //        TimeSpan OTIN = DateTime.Parse(item.OTin).TimeOfDay;
                        //        TimeSpan OTOUT = DateTime.Parse(item.OTout).TimeOfDay;
                        //        TimeSpan ts = OTIN - OTOUT;

                        //        ExportData.Cells["I" + start].Value = item.OTin;
                        //        ExportData.Cells["J" + start].Value = item.OTout;

                        //        start++;
                        //    }
                        //}
                    }
                    return File(package.GetAsByteArray(), "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", filename);
                }
            }
             catch(Exception err) { }
            return Json(new { }, JsonRequestBehavior.AllowGet);
        }
 

    }
}