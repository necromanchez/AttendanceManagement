using Brothers_WMS.Controllers;
using Brothers_WMS.Models;
using System;
using OfficeOpenXml;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using static Brothers_WMS.Controllers.SessionExpire;

namespace Brothers_WMS.Areas.Summary.Controllers
{
    [SessionExpire]
    public class DTRSummaryController : Controller
    {
        // GET: Summary/DTRSummary
        Brothers_AMSDBEntities db = new Brothers_AMSDBEntities();
        M_Users user = (M_Users)System.Web.HttpContext.Current.Session["user"];
        public ActionResult DTRSummary()
        {
            return View();
        }

        public JsonResult GetDTRRefnoList(string dtrrefno)
        {
            var list = (from c in db.AF_DTRfiling where c.DTR_RefNo.Contains(dtrrefno) select new { text = c.DTR_RefNo }).Distinct().ToList();
            return Json(new { list = list }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult GetApproverDTRSummaryList(string Refno, string Section, DateTime? DateFrom, DateTime? DateTo, string Type, string Status)
        {
            DateFrom = (DateFrom == null) ? new DateTime(1990, 1, 1) : DateFrom;
            DateTo = (DateTo == null) ? db.TT_GETTIME().FirstOrDefault() : DateTo;
            int start = Convert.ToInt32(Request["start"]);
            int length = Convert.ToInt32(Request["length"]);
            string searchValue = (Session["RNO"] != null) ? Session["RNO"].ToString() : Request["search[value]"];
            string sortColumnName = Request["columns[" + Request["order[0][column]"] + "][name]"];
            string sortDirection = Request["order[0][dir]"];

            List<GET_AF_DTRSummary_Result> list = db.GET_AF_DTRSummary(Refno, Section, DateFrom, DateTo, Type, Status).ToList();

            if (!string.IsNullOrEmpty(searchValue))//filter
            {
                list = list.Where(x => x.DTR_RefNo.ToLower().Contains(searchValue.ToLower())).ToList<GET_AF_DTRSummary_Result>();
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
            list = list.Skip(start).Take(length).ToList<GET_AF_DTRSummary_Result>();

            return Json(new { data = list, draw = Request["draw"], recordsTotal = totalrows, recordsFiltered = totalrowsafterfiltering }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult GetApproverDTRDetailsList(string DTRRefNo, int status)
        {
            int start = Convert.ToInt32(Request["start"]);
            int length = Convert.ToInt32(Request["length"]);
            string searchValue = Request["search[value]"];
            string sortColumnName = Request["columns[" + Request["order[0][column]"] + "][name]"];
            string sortDirection = Request["order[0][dir]"];

            List<GET_AF_DTRSummaryDetail_Result> list = db.GET_AF_DTRSummaryDetail(DTRRefNo, status).ToList();

            if (!string.IsNullOrEmpty(searchValue))//filter
            {
                list = list.Where(x => x.EmployeeNo.ToLower().Contains(searchValue.ToLower())
                || x.EmployeeName.ToLower().Contains(searchValue.ToLower())).ToList<GET_AF_DTRSummaryDetail_Result>();
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
            list = list.Skip(start).Take(length).ToList<GET_AF_DTRSummaryDetail_Result>();
            return Json(new { data = list, draw = Request["draw"], recordsTotal = totalrows, recordsFiltered = totalrowsafterfiltering }, JsonRequestBehavior.AllowGet);

            //return Json(new { }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult ExportBatchDTR(List<string> DTR_RefNo)
        {


            return Json(new { }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult ExportDTRSum(string RefNo, string Status)
        {
            try
            {
                string templateFilename = "DTR_template.xlsx";
                string dir = Path.GetTempPath();
                string datetimeToday = DateTime.Now.ToString("yyMMddhhmmss");
                string filename = string.Format("DTR_template{0}.xlsx", datetimeToday);
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

                    ExcelWorksheet ExportData = package.Workbook.Worksheets["DTR Summary"];

                    var dateFile = string.Format("{0}", datetimeToday);
                    int start = 3;
                    for (int i = 0; i <= b; i++)
                    { 
                        List<GET_AF_DTRSummaryDetail_Result> list = db.GET_AF_DTRSummaryDetail(ARefno[i], int.Parse(AStatus[i])).ToList();

                        if (list.Count > 0)
                        { 
                            foreach (GET_AF_DTRSummaryDetail_Result item in list)
                            {
                                string Department = (from c in db.M_Employee_Master_List where c.EmpNo == item.EmployeeNo select c.Department + "/" + item.Section).FirstOrDefault();
                                string DatePrepared = (from c in db.AF_DTRfiling where c.DTR_RefNo == item.DTR_RefNo select c.CreateDate).FirstOrDefault().ToString("MM-dd-yyyy");

                                string PreparedBy = (from c in db.M_Users where c.UserName == user.UserName select c.FirstName + " " + c.LastName).FirstOrDefault();


                                //ExportData.Cells["E7"].Value = PreparedBy;
                                //ExportData.Cells["D7"].Value = DatePrepared;
                                //ExportData.Cells["C7"].Value = Department;
                                //ExportData.Cells["C7"].Style.WrapText = true;

                                ExportData.Cells["B" + start].Value = item.EmployeeNo;
                                ExportData.Cells["D" + start].Value = item.EmployeeName;
                                //ExportData.Cells["F" + start].Value = item.Reason;
                                ExportData.Cells["H" + start].Value = item.DateFrom.ToString("MM-dd-yyyy");
                                ExportData.Cells["I" + start].Value = item.DateTo.ToString("MM-dd-yyyy");
                                ExportData.Cells["J" + start].Value = item.Timein;
                                ExportData.Cells["K" + start].Value = item.TimeOut;


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
    }
}