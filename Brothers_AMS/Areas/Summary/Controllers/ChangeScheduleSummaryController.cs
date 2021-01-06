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

namespace Brothers_WMS.Areas.Summary.Controllers
{
    [SessionExpire]
    public class ChangeScheduleSummaryController : Controller
    {
      
        // GET: Summary/ChangeScheduleSummary
        Brothers_AMSDBEntities db = new Brothers_AMSDBEntities();
        M_Users user = (M_Users)System.Web.HttpContext.Current.Session["user"];
        public ActionResult ChangeScheduleSummary(string RefNo, string CSType, string Status)
        {
            Session["RefNoCS"] = RefNo;
            Session["CSType"] = (CSType == null) ? "" : CSType;
            Session["SumStatus"] = (Status == null) ? "" : Status;
            CSType = (CSType == null) ? "" : CSType;
            //if ((RefNo != null && CSType != null) || Status != null)
            //{
            //    List<string> result = db.EmailPrompter(RefNo, "", user.UserName, "CS").ToList();
            //    if (result.Count > 0)
            //    {
            //        return Redirect("http://apbiphwb08:2020/Correction/ApproverChangeSchedule/ApproverChangeSchedule?Approved=" + result[0]);
            //        //return Redirect("http://apbiphwb08:2020/Correction/ApproverChangeSchedule/ApproverChangeSchedule?Approved=" + result[0]);
            //        //return Redirect("http://localhost:49710/Correction/ApproverChangeSchedule/ApproverChangeSchedule?Approved=" + result[0]);
            //    }
            //}
            return View();
        }

        public JsonResult GetCSRefnoList(string csrefno)
        {
            var list = (from c in db.AF_ChangeSchedulefiling where c.CS_RefNo.Contains(csrefno) select new { text = c.CS_RefNo }).Distinct().ToList();
            return Json(new { list = list }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult GetApproverCSSummaryList(string Refno, string Section, DateTime? DateFrom, DateTime? DateTo, string Status)
        {
            DateFrom = (DateFrom == null) ? new DateTime(1990, 1, 1) : DateFrom;
            DateTo = (DateTo == null) ? db.TT_GETTIME().FirstOrDefault() : DateTo;
            int start = Convert.ToInt32(Request["start"]);
            int length = Convert.ToInt32(Request["length"]);
            //string searchValue = (Session["RNO"] != null) ? Session["RNO"].ToString() : Request["search[value]"];
            string sortColumnName = Request["columns[" + Request["order[0][column]"] + "][name]"];
            string sortDirection = Request["order[0][dir]"];
            string searchValue = (Session["RefNoCS"] != null) ? Session["RefNoCS"].ToString() : Request["search[value]"];
            string searchValueStatus = (Session["SumStatus"] != null) ? Session["SumStatus"].ToString() : Request["search[value]"];

            List<GET_AF_CSSummary_Result> list = db.GET_AF_CSSummary(Refno, Section, DateFrom, DateTo, Status).ToList();

            if (!string.IsNullOrEmpty(searchValue))//filter
            {
                list = list.Where(x => x.CS_RefNo.ToLower().Contains(searchValue.ToLower())).ToList<GET_AF_CSSummary_Result>();
                try
                {
                    int stt = (searchValueStatus != null) ? Convert.ToInt32(searchValueStatus) : 0;
                    if (stt != 0)
                    {
                        list = list.Where(x => x.Status == stt).ToList<GET_AF_CSSummary_Result>();
                    }
                }
                catch (Exception err) { }

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
            list = list.Skip(start).Take(length).ToList<GET_AF_CSSummary_Result>();

            return Json(new { data = list, draw = Request["draw"], recordsTotal = totalrows, recordsFiltered = totalrowsafterfiltering }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult GetApproverCSDetailsList(string CSRefNo, int status)
        {
            int start = Convert.ToInt32(Request["start"]);
            int length = Convert.ToInt32(Request["length"]);
            string searchValue = Request["search[value]"];
            string sortColumnName = Request["columns[" + Request["order[0][column]"] + "][name]"];
            string sortDirection = Request["order[0][dir]"];

            List<GET_AF_CSSummaryDetail_Result> list = db.GET_AF_CSSummaryDetail(CSRefNo, status).ToList();

            if (!string.IsNullOrEmpty(searchValue))//filter
            {
                list = list.Where(x => x.EmployeeNo.ToLower().Contains(searchValue.ToLower())
                || x.EmployeeName.ToLower().Contains(searchValue.ToLower())).ToList<GET_AF_CSSummaryDetail_Result>();
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
            list = list.Skip(start).Take(length).ToList<GET_AF_CSSummaryDetail_Result>();
            return Json(new { data = list, draw = Request["draw"], recordsTotal = totalrows, recordsFiltered = totalrowsafterfiltering }, JsonRequestBehavior.AllowGet);

        }

        public ActionResult ExportChangeSched(string RefNo, string Status)
        {
            try
            {
                string templateFilename = "CS_template.xlsx";
                string dir = Path.GetTempPath();
                string datetimeToday = db.TT_GETTIME().FirstOrDefault().ToString();//DateTime.Now;.ToString("yyMMddhhmmss");
                string filename = string.Format("CS_template{0}.xlsx", datetimeToday);
                FileInfo newFile = new FileInfo(Path.Combine(dir, filename));
                string apptemplatePath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, @"TemplateFiles\StandardTemplate\", templateFilename);
                FileInfo templateFile = new FileInfo(apptemplatePath);

                string ArrayRefNo = RefNo;
                string ArrayStatus = Status;

                string[] ARefno = new string[] { "" };
                ARefno = ArrayRefNo.Split(',');

                string[] AStatus = new string[] { "" };
                AStatus = ArrayStatus.Split(',');

                int b = ARefno.Count() - 1;


                using (ExcelPackage package = new ExcelPackage(newFile, templateFile))  //-- With template.
                {

                    ExcelWorksheet ExportData = package.Workbook.Worksheets["CS Summary"];
                    var dateFile = string.Format("{0}", datetimeToday);
                    int start = 2;

                    for (int i = 0; i <= b; i++)
                    {
                        List<GET_AF_CSSummaryDetail_Result> list = db.GET_AF_CSSummaryDetail(ARefno[i], int.Parse(AStatus[i])).ToList();
                    if (list.Count > 0)
                    {


                        foreach (GET_AF_CSSummaryDetail_Result item in list)
                        {
                            string Department = (from c in db.M_Employee_Master_List where c.EmpNo == item.EmployeeNo select c.Department).FirstOrDefault();
                            string DatePrepared = (from c in db.AF_ChangeSchedulefiling where c.EmployeeNo == item.EmployeeNo select c.CreateDate).FirstOrDefault().ToString("MM-dd-yyyy");

                            //ExportData.Cells["C5"].Value = Department;
                            //ExportData.Cells["O6"].Value = DatePrepared;
                            //ExportData.Cells["O5"].Value = item.Section;


                            ExportData.Cells["B" + start].Value = item.EmployeeNo;
                            ExportData.Cells["D" + start].Value = item.EmployeeName;


                            ExportData.Cells["I" + start].Value = item.DateFrom.ToString("MM-dd-yyyy");
                            ExportData.Cells["J" + start].Value = item.DateTo.ToString("MM-dd-yyyy");

                            ExportData.Cells["K" + start].Value = item.Reason;

                                start++;
                            }
                    }
                }
                    return File(package.GetAsByteArray(), "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", filename);
                }

                // }
            }
            catch (Exception err) { }
            return Json(new { }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult ExportChangeSchedule(string Section,DateTime? DateFrom, DateTime? DateTo, string Status)
        {
            try
            {
               
                string templateFilename = "CSexport.xlsx";
                string dir = Path.GetTempPath();
                string datetimeToday = DateTime.Now.ToString("yyMMddhhmmss");
                string GroupSection = Section;

                string filename = string.Format("ChangeScheduleSummary{0}_{1}.xlsx", datetimeToday, GroupSection);
                FileInfo newFile = new FileInfo(Path.Combine(dir, filename));
                string apptemplatePath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, @"TemplateFiles\StandardTemplate\", templateFilename);
                FileInfo templateFile = new FileInfo(apptemplatePath);

                using (ExcelPackage package = new ExcelPackage(newFile, templateFile))  //-- With template.
                {

                    List<GET_AF_CSSummaryDetailExport_Result> list = new List<GET_AF_CSSummaryDetailExport_Result>();
                   
                    list = db.GET_AF_CSSummaryDetailExport(GroupSection,DateFrom,DateTo,Status).ToList();
                    
                    ExcelWorksheet ExportData = package.Workbook.Worksheets["AMSSheet"];
                    int start = 2;
                  
                   
                    for (int i = 0; i < list.Count; i++)
                    {
                        ExportData.Cells["A" + start].Value = i + 1;
                        ExportData.Cells["B" + start].Value = list[i].CS_RefNo;
                        ExportData.Cells["C" + start].Value = list[i].EmployeeNo;
                        ExportData.Cells["D" + start].Value = list[i].EmployeeName;
                        ExportData.Cells["E" + start].Value = list[i].Section;
                        ExportData.Cells["F" + start].Value = list[i].Reason;
                        ExportData.Cells["G" + start].Value = list[i].DateFrom;
                        ExportData.Cells["H" + start].Value = list[i].DateTo;
                        ExportData.Cells["I" + start].Value = list[i].CSin;
                        ExportData.Cells["J" + start].Value = list[i].CSout;
                        start++;
                    }
                    return File(package.GetAsByteArray(), "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", filename);
                }
            }
            catch (Exception err) { }
            return Json(new { }, JsonRequestBehavior.AllowGet);
        }
    }
}