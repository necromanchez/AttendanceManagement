using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Text;
using Brothers_WMS.Controllers;
using Brothers_WMS.Models;
using System.IO;
using OfficeOpenXml;
using System.Data.Entity;
using System.Data.Entity.Core.Objects;

namespace Brothers_WMS.Areas.Correction.Controllers
{
    [SessionExpire]
    public class DTRController : Controller
    {
        // GET: Correction/DTR
        Brothers_AMSDBEntities db = new Brothers_AMSDBEntities();
        M_Users user = (M_Users)System.Web.HttpContext.Current.Session["user"];
        HelperController helper = new HelperController();
        public ActionResult DTR()
        {
            return View();
        }
        
        public ActionResult SaveDTR(AF_DTRfiling Filing, string Reasons, string EmployeeNos, string DTRType, string concerns)
        {
            List<string> concernsList = concerns.Split(',').ToList();
            List<string> ReasonsList = Reasons.Split(',').ToList();
            List<string> EmployeeNosLis = EmployeeNos.Split(',').ToList();
            int emploCounter = 0;
            string DTRRefNo = helper.GenerateDTRRef();
            string Section = "";
            foreach (string reason in ReasonsList)
            {
                string EmploNos = EmployeeNosLis[emploCounter];
                string Concern = concernsList[emploCounter];
                AF_DTRfiling dtrfile = new AF_DTRfiling();
                dtrfile.DTR_RefNo = DTRRefNo;
                dtrfile.BIPH_Agency = Filing.BIPH_Agency;
                dtrfile.EmployeeNo = EmploNos;
                dtrfile.FileType = Filing.FileType;
                dtrfile.Section = (from c in db.M_Employee_CostCenter where c.EmployNo == EmploNos orderby c.ID descending select c.CostCenter_AMS).FirstOrDefault();
                Section = (from c in db.M_Cost_Center_List where c.Cost_Center == dtrfile.Section orderby c.ID descending select c.GroupSection).FirstOrDefault();//otfile.Section;//dtrfile.Section;
                //dtrfile.Line_Team = 1;// (from c in db.M_Employee_Master_List where c.EmpNo == EmploNos select c.LineID).FirstOrDefault();
                dtrfile.OvertimeType = Filing.OvertimeType;
                dtrfile.DateFrom = Filing.DateFrom.Date;
                dtrfile.DateTo = Filing.DateTo.AddHours(23).AddMinutes(59).AddSeconds(59);
                dtrfile.OTin = Filing.OTin;
                dtrfile.OTout = Filing.OTout;
                dtrfile.Timein = Filing.Timein;
                dtrfile.TimeOut = Filing.TimeOut;
                dtrfile.Reason = reason;
                dtrfile.Concerns = Concern;
                dtrfile.Status = 0;
                //if (EmploNos.Contains("BIPH"))
                //{
                    dtrfile.EmployeeAccept = db.TT_GETTIME().FirstOrDefault();//DateTime.Now;;
                //}
                if (DTRType == "HR")
                {
                    dtrfile.StatusMax = (Filing.OvertimeType == "SundayHoliday") ? 4 : 2;
                }
                else
                {
                    dtrfile.StatusMax = 1; //Supervisor only
                }
                dtrfile.CreateID = user.UserName;
                dtrfile.CreateDate = DateTime.Now;
                dtrfile.UpdateID = user.UserName;
                dtrfile.UpdateDate = DateTime.Now;
                try
                {
                    db.AF_DTRfiling.Add(dtrfile);
                    db.SaveChanges();
                }
                catch (Exception err) {
                    Error_Logs error = new Error_Logs();
                    error.PageModule = "Application Form - DTR";
                    error.ErrorLog = err.Message;
                    error.DateLog = DateTime.Now;
                    error.Username = user.UserName;
                    db.Error_Logs.Add(error);
                    db.SaveChanges();
                }
                emploCounter++;


            }

            #region GET approver & Email
           
            List<M_Section_Approver> approver = (from c in db.M_Section_Approver
                                                 where c.Section == Section
                                                 && c.Position != "GeneralManager"
                                                 && c.Position != "FactoryGeneralManager"
                                                 select c).ToList();


            #endregion

            #region Generate OT Status
            foreach (M_Section_Approver approv in approver)
            {
                M_Section_ApproverStatus approverstat = new M_Section_ApproverStatus();
                approverstat.Position = approv.Position;
                approverstat.EmployeeNo = approv.EmployeeNo;
                approverstat.Section = Section;
                approverstat.RefNo = DTRRefNo;
                approverstat.Approved = 0;
                approverstat.OverTimeType = Filing.OvertimeType;
                approverstat.CreateID = user.UserName;
                approverstat.CreateDate = DateTime.Now;
                approverstat.UpdateID = user.UserName;
                approverstat.UpdateDate = DateTime.Now;
                db.M_Section_ApproverStatus.Add(approverstat);
                db.SaveChanges();
            }

            #endregion
            return Json(new { DTRRefNo = DTRRefNo }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult DownloadTemplate(string Agency)
        {
            try
            {
                long? lineID, a;
                string searchnow = System.Web.HttpContext.Current.Session["Searchvalueot"].ToString();
                string lineid = "";
                if (System.Web.HttpContext.Current.Session["lINEID"] == null)
                {
                    lineID = null;
                }
                else
                {
                    a = null;
                    lineid = System.Web.HttpContext.Current.Session["lINEID"].ToString();
                    lineID = (lineid == "") ? a : Convert.ToInt64(lineid);
                }
                Agency = (Agency == "") ? "BIPH" : Agency;
                M_Agency AgencyDetails = (from c in db.M_Agency where c.AgencyCode == Agency select c).FirstOrDefault();
                string templateFilename = "StandardizeDTR_template.xlsx";
                string dir = Path.GetTempPath();
                string filename = string.Format("StandardizeDTR_template.xlsx");
                FileInfo newFile = new FileInfo(Path.Combine(dir, filename));
                string apptemplatePath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, @"TemplateFiles\StandardTemplate\", templateFilename);
                FileInfo templateFile = new FileInfo(apptemplatePath);
                M_Employee_Master_List current = (from c in db.M_Employee_Master_List where c.EmpNo == user.UserName select c).FirstOrDefault();
                ObjectParameter totalCount = new ObjectParameter("TotalCount", typeof(int));

                using (ExcelPackage package = new ExcelPackage(newFile, templateFile))  //-- With template.
                {
                    List<GET_Employee_OTFiling_Result> list = new List<GET_Employee_OTFiling_Result>();
                    list = db.GET_Employee_OTFiling(Agency, user.CostCode, lineID, "",0,100000,"", totalCount).ToList();
                    if (!string.IsNullOrEmpty(searchnow))//filter
                    {
                        #region null remover
                        list = list.Where(xx => xx.EmpNo != null).ToList();
                        list = list.Where(xx => xx.First_Name != null).ToList();
                        list = list.Where(xx => xx.Family_Name != null).ToList();
                        #endregion
                        list = list.Where(x => x.First_Name.ToLower().Contains(searchnow.ToLower())
                          || x.Family_Name.ToLower().Contains(searchnow.ToLower())
                          || x.EmpNo.Contains(searchnow)
                          ).ToList<GET_Employee_OTFiling_Result>();
                    }
                    int start = 12;
                    ExcelWorksheet ExportData = package.Workbook.Worksheets["DTR Correction"];
                    if (list.Count < 30)
                    {
                        for (int i = 0; i < list.Count; i++)
                        {
                            ExportData.Cells["B" + start].Value = list[i].EmpNo;
                            ExportData.Cells["C" + start].Value = list[i].Family_Name + ", " + list[i].First_Name;
                            start++;
                        }
                    }
                    ExportData.Cells["C5"].Value = current.Department;
                    ExportData.Cells["C6"].Value = user.Section;
                    ExportData.Cells["C1"].Value = AgencyDetails.AgencyName;
                    ExportData.Cells["C2"].Value = AgencyDetails.Address;
                    ExportData.Cells["C3"].Value = AgencyDetails.TelNo;
                    ExportData.Cells["I49"].Value = AgencyDetails.ISO_DTR;

                    string path = Server.MapPath(@"/PictureResources/AgencyLogo/" + AgencyDetails.Logo);


                    #region IMAGE
                    using (System.Drawing.Image image = System.Drawing.Image.FromFile(path))
                    {
                        var excelImage = ExportData.Drawings.AddPicture("logohere", image);
                        excelImage.SetSize(120, 69);
                        excelImage.SetPosition(0, 0, 0, 0);
                       
                    }

                    #endregion



                    return File(package.GetAsByteArray(), "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", filename);
                }
            }
            catch (Exception err) {
                Error_Logs error = new Error_Logs();
                error.PageModule = "Application Form - DTR";
                error.ErrorLog = err.Message;
                error.DateLog = db.TT_GETTIME().FirstOrDefault();//DateTime.Now;
                error.Username = user.UserName;
                db.Error_Logs.Add(error);
                db.SaveChanges();
            }
            return Json(new { }, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        public JsonResult ReadUploadedFile()
        {
            try {
                var file = Request.Files[0];
                int fileSize = file.ContentLength;
                string fileName = file.FileName;
                string TodayRefno = helper.GenerateDTRRef();
                string Section = "";
                List<string> Unregistered = new List<string>();
                using (var package = new ExcelPackage(file.InputStream))
                {
                    ExcelWorksheet worksheet = package.Workbook.Worksheets[1];
                    int noOfCol = worksheet.Dimension.End.Column;
                    int noOfRow = worksheet.Dimension.End.Row;
                    int endColumn = worksheet.Dimension.Start.Column;
                    int startColumn = endColumn;
                    int startRowForTable = 12;
                    int totalNoOfTableRow = 30;

                    for (int x = 0; x < totalNoOfTableRow; x++)
                    {
                        string Empno = "";

                        try
                        {
                            Empno = worksheet.Cells[startRowForTable, 2].Value.ToString();
                            M_Employee_Master_List Employee = (from c in db.M_Employee_Master_List
                                                               where c.EmpNo == Empno
                                                               select c).FirstOrDefault();

                            if (Employee != null)
                            {
                                AF_DTRfiling bemodify = (from c in db.AF_DTRfiling where c.EmployeeNo == Employee.EmpNo && c.DTR_RefNo == TodayRefno select c).FirstOrDefault();

                                if (bemodify == null)
                                {
                                    #region Creating via upload
                                    //Section = user.Section;//Employee.Section;
                                    AF_DTRfiling DTRrequest = new AF_DTRfiling();
                                    DTRrequest.DTR_RefNo = TodayRefno;
                                    DTRrequest.BIPH_Agency = Employee.Company;
                                    DTRrequest.FileType = 3; //Upload
                                    DTRrequest.Section = (from c in db.M_Employee_CostCenter where c.EmployNo == Empno orderby c.ID descending select c.CostCenter_AMS).FirstOrDefault();
                                    Section = (from c in db.M_Cost_Center_List where c.Cost_Center == DTRrequest.Section orderby c.ID descending select c.GroupSection).FirstOrDefault();//otfile.Section;

                                    DTRrequest.EmployeeNo = Employee.EmpNo;
                                    DTRrequest.OvertimeType = "";
                                    DTRrequest.DateFrom = Convert.ToDateTime(worksheet.Cells[startRowForTable, 6].Value);
                                    DTRrequest.DateTo = Convert.ToDateTime(worksheet.Cells[startRowForTable, 7].Value);
                                    DTRrequest.Timein = worksheet.Cells[startRowForTable, 8].Value.ToString();
                                    DTRrequest.TimeOut = worksheet.Cells[startRowForTable, 9].Value.ToString();
                                    DTRrequest.OTin = "";
                                    DTRrequest.OTout = "";
                                    //if (Employee.EmpNo.Contains("BIPH"))
                                    //{
                                        DTRrequest.EmployeeAccept = db.TT_GETTIME().FirstOrDefault();//DateTime.Now;
                                    //}

                                    DTRrequest.Reason = worksheet.Cells[startRowForTable, 5].Value.ToString();
                                    DTRrequest.Status = 0;
                                    DTRrequest.StatusMax = 2;

                                    DTRrequest.CreateID = user.UserName;
                                    DTRrequest.CreateDate = DateTime.Now;
                                    DTRrequest.UpdateID = user.UserName;
                                    DTRrequest.UpdateDate = DateTime.Now;

                                    try
                                    {
                                        db.AF_DTRfiling.Add(DTRrequest);
                                        db.SaveChanges();
                                    }
                                    catch (Exception err)
                                    {
                                        Error_Logs error = new Error_Logs();
                                        error.PageModule = "Application Form - OT Request";
                                        error.ErrorLog = err.Message;
                                        error.DateLog = db.TT_GETTIME().FirstOrDefault();//DateTime.Now;
                                        error.Username = user.UserName;
                                        db.Error_Logs.Add(error);
                                        db.SaveChanges();
                                    }
                                    #endregion
                                }
                                else
                                {
                                    #region modifying via upload
                                    //Section = Employee.Section;
                                    bemodify.DTR_RefNo = TodayRefno;
                                    bemodify.BIPH_Agency = Employee.Company;
                                    bemodify.FileType = 3; //Upload
                                    bemodify.Section = (from c in db.M_Employee_CostCenter where c.EmployNo == Empno orderby c.ID descending select c.CostCenter_AMS).FirstOrDefault();
                                    Section = (from c in db.M_Cost_Center_List where c.Cost_Center == bemodify.Section orderby c.ID descending select c.GroupSection).FirstOrDefault();//otfile.Section;
                                    bemodify.EmployeeNo = Employee.EmpNo;
                                    bemodify.OvertimeType = "";
                                    bemodify.DateFrom = Convert.ToDateTime(worksheet.Cells[startRowForTable, 6].Value);
                                    bemodify.DateTo = Convert.ToDateTime(worksheet.Cells[startRowForTable, 7].Value);
                                    bemodify.Timein = worksheet.Cells[startRowForTable, 8].Value.ToString();
                                    bemodify.TimeOut = worksheet.Cells[startRowForTable, 9].Value.ToString();
                                    bemodify.OTin = "";
                                    bemodify.OTout = "";
                                    //if (Employee.EmpNo.Contains("BIPH"))
                                    //{
                                        bemodify.EmployeeAccept = db.TT_GETTIME().FirstOrDefault();//DateTime.Now;
                                    //}
                                    bemodify.Reason = worksheet.Cells[startRowForTable, 5].Value.ToString();
                                    bemodify.Status = 0;
                                    bemodify.StatusMax = 2;
                                    bemodify.UpdateID = user.UserName;
                                    bemodify.UpdateDate =DateTime.Now;

                                    try
                                    {
                                        db.Entry(bemodify).State = EntityState.Modified;
                                        db.SaveChanges();
                                    }
                                    catch (Exception err)
                                    {
                                        Error_Logs error = new Error_Logs();
                                        error.PageModule = "Application Form - DTR Request";
                                        error.ErrorLog = err.Message;
                                        error.DateLog = db.TT_GETTIME().FirstOrDefault();//DateTime.Now;
                                        error.Username = user.UserName;
                                        db.Error_Logs.Add(error);
                                        db.SaveChanges();
                                    }
                                    #endregion
                                }
                            }
                            else
                            {
                                if (Empno != "")
                                {
                                    Unregistered.Add(Empno);
                                }
                            }
                        }
                        catch (Exception err)
                        {
                            if (Empno != "")
                            {
                                Unregistered.Add(Empno);
                            }

                        }

                        startRowForTable++;
                    }

                    M_Section_ApproverStatus checker = (from c in db.M_Section_ApproverStatus where c.RefNo == TodayRefno select c).FirstOrDefault();
                    if (checker == null)
                    {
                        #region GET approver & Email
                        //string SectionID = (from c in db.M_Cost_Center_List
                        //                    where c.Section == Section
                        //                    select c.ID).FirstOrDefault().ToString();
                        List<M_Section_Approver> approver = (from c in db.M_Section_Approver where c.Section == Section select c).ToList();


                        #endregion
                        #region Generate CS Status
                        foreach (M_Section_Approver approv in approver)
                        {
                            M_Section_ApproverStatus approverstat = new M_Section_ApproverStatus();
                            approverstat.Position = approv.Position;
                            approverstat.EmployeeNo = approv.EmployeeNo;
                            approverstat.Section = Section;
                            approverstat.RefNo = TodayRefno;
                            approverstat.Approved = 0;
                            approverstat.OverTimeType = "";
                            approverstat.CreateID = user.UserName;
                            approverstat.CreateDate = DateTime.Now;
                            approverstat.UpdateID = user.UserName;
                            approverstat.UpdateDate = DateTime.Now;
                            db.M_Section_ApproverStatus.Add(approverstat);
                            db.SaveChanges();
                        }

                        #endregion
                    }



                    return Json(new { Unregistered = Unregistered, Failed = "" }, JsonRequestBehavior.AllowGet);
                }
            }
            catch (Exception Err)
            {
                return Json(new { Failed = "Failed" }, JsonRequestBehavior.AllowGet);
            }
        }
          
    }
}