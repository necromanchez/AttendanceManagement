using Brothers_WMS.Controllers;
using Brothers_WMS.Models;
using Newtonsoft.Json;
using OfficeOpenXml;
using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Data.Entity.Core.Objects;
using System.IO;
using System.Linq;
using System.Runtime.Serialization.Json;
using System.Text;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.Mvc;
using static Brothers_WMS.Controllers.SessionExpire;

namespace Brothers_WMS.Areas.Correction.Controllers
{
    [SessionExpire]
    public class OTController : Controller
    {
        // GET: Correction/OT
        Brothers_AMSDBEntities db = new Brothers_AMSDBEntities();
        
        M_Users user = (M_Users)System.Web.HttpContext.Current.Session["user"];
        HelperController helper = new HelperController();
        public ActionResult OT()
        {
            return View();
        }
        public JsonResult GetEmployeeNo(string Agency, string IDno)
        {

            List<GET_Employee_NoAutocompletes_Result> list = db.GET_Employee_NoAutocompletes(user.Section,IDno).ToList();
            //List<M_Employee_Master_List> list = (from c in db.M_Employee_Master_List where c.EmpNo.Contains(Agency) select c).ToList();
            //list = list.Where(x => x.Section == user.Section).ToList();
            return Json(new {list=list },JsonRequestBehavior.AllowGet);
        }
        public ActionResult GetEmployeeList(string Agency, string Section, Nullable<long> lINEID, string employeeNo, List<string> ChosenEmployees, long? Schedule, string TransType)
        {
            System.Web.HttpContext.Current.Session["Searchvalueot"] = Request["search[value]"];
            System.Web.HttpContext.Current.Session["lINEID"] = lINEID;

            int start = (Convert.ToInt32(Request["start"]) == 0) ? 0 : (Convert.ToInt32(Request["start"]) / Convert.ToInt32(Request["length"]));
            int length = Convert.ToInt32(Request["length"]);
            string searchValue = Request["search[value]"];
            searchValue = (searchValue == null) ? "" : searchValue;
            string sortColumnName = Request["columns[" + Request["order[0][column]"] + "][name]"];
            string sortDirection = Request["order[0][dir]"];
            ObjectParameter totalCount = new ObjectParameter("TotalCount", typeof(int));
            List<GET_Employee_OTFiling_Result> list = new List<GET_Employee_OTFiling_Result>();
              
            string currentRefno = "";
            switch (TransType)
            {
                case "OT":
                    currentRefno = helper.GenerateOTRef();
                    list = db.GET_Employee_OTFiling(Agency, user.CostCode, lINEID, employeeNo, start, length, searchValue, totalCount).ToList();
                    list = list.OrderBy(x => x.EmpNo).ToList();
                    //list = list.Where(x => x.Section == user.CostCode).ToList();
                    //List<AF_OTfiling> AlreadyApplied = (from c in db.AF_OTfiling where c.OT_RefNo == currentRefno && c.Status >= 0 select c).ToList();
                    //list = list.Where(p => !AlreadyApplied.Any(p2 => p2.EmployeeNo == p.EmpNo)).ToList();
                    break;
                case "CS":
                    currentRefno = helper.GenerateCSRef();
                    list = db.GET_Employee_OTFiling(Agency, user.CostCode, lINEID, employeeNo, start, length, searchValue, totalCount).ToList();
                    list = list.OrderBy(x => x.EmpNo).ToList();
                    //if (Schedule != null)
                    //{
                    //    string Schedulename = (from c in db.M_Schedule where c.ID == Schedule select c.Timein + " - " + c.TimeOut).FirstOrDefault();
                    //    list = list.Where(x => x.Schedule == Schedulename).ToList();
                    //}
                    // list = list.Where(x => x.Section == user.Section).ToList();
                    // List<AF_ChangeSchedulefiling> AlreadyAppliedcs = (from c in db.AF_ChangeSchedulefiling where c.CS_RefNo == currentRefno && c.Status >= 0 select c).ToList();
                    // list = list.Where(p => !AlreadyAppliedcs.Any(p2 => p2.EmployeeNo == p.EmpNo)).ToList();
                    break;
                case "DTR":
                    currentRefno = helper.GenerateDTRRef();
                    list = db.GET_Employee_OTFiling(Agency, user.CostCode, lINEID, employeeNo, start, length, searchValue, totalCount).ToList();
                    list = list.OrderBy(x => x.EmpNo).ToList();
                    // list = list.Where(x => x.Section == user.Section).ToList();
                    // List<AF_DTRfiling> AlreadyApplieddtr = (from c in db.AF_DTRfiling where c.DTR_RefNo == currentRefno && c.Status >= 0 select c).ToList();
                    // list = list.Where(p => !AlreadyApplieddtr.Any(p2 => p2.EmployeeNo == p.EmpNo)).ToList();
                    break;
            }
           
            if (ChosenEmployees != null)
            {
                #region null remover
                list = list.Where(xx => xx.EmpNo != null).ToList();
                list = list.Where(xx => xx.First_Name != null).ToList();
                list = list.Where(xx => xx.Family_Name != null).ToList();
                #endregion
                list = (from c in list
                       where ChosenEmployees.Contains(c.EmpNo)
                       select c).ToList();
            }
            int? totalrows = Convert.ToInt32(totalCount.Value);//list.Count;
            int? totalrowsafterfiltering = Convert.ToInt32(totalCount.Value);//list.Count;
            return Json(new { data = list, draw = Request["draw"], recordsTotal = totalrows, recordsFiltered = totalrowsafterfiltering }, JsonRequestBehavior.AllowGet);
        }
        public ActionResult SaveOT(AF_OTfiling Filing, string Purposes, string EmployeeNos)
        {
            try
            {
                List<string> PurposeList = Purposes.Split(',').ToList();
                List<string> EmployeeNosLis = EmployeeNos.Split(',').ToList();
                int emploCounter = 0;
                string OTRefnow = helper.GenerateOTRef();
                //long SectionID = 0;
                string Section = "";
                foreach (string purpose in PurposeList)
                {
                    string EmploNos = EmployeeNosLis[emploCounter];
                    AF_OTfiling otfile = new AF_OTfiling();
                    otfile.OT_RefNo = OTRefnow;
                    otfile.BIPH_Agency = Filing.BIPH_Agency;
                    otfile.EmployeeNo = EmploNos;
                    otfile.FileType = Filing.FileType;
                    long? Schedule_current = (from c in db.M_Employee_Master_List_Schedule where c.EmployeeNo == EmploNos orderby c.ID descending select c.ScheduleID).FirstOrDefault();
              
                    otfile.ScheduleID = Schedule_current;
                    otfile.Section = (from c in db.M_Employee_CostCenter where c.EmployNo == EmploNos orderby c.ID descending select c.CostCenter_AMS).FirstOrDefault();
                    //SectionID = otfile.Section;
                    Section = (from c in db.M_Cost_Center_List where c.Cost_Center == otfile.Section orderby c.ID descending select c.GroupSection).FirstOrDefault();//otfile.Section;
                    otfile.OvertimeType = Filing.OvertimeType;
                    otfile.DateFrom = Filing.DateFrom.Date;
                    otfile.DateTo = Filing.DateFrom.Date;
                    otfile.OTin = Filing.OTin;
                    otfile.OTout = Filing.OTout;
                    otfile.Purpose = purpose;
                    otfile.Status = 0;
                    otfile.StatusMax = (otfile.OvertimeType == "SundayHoliday") ? 4 : 2;
                    //if (EmploNos.Contains("BIPH"))
                    //{
                        otfile.EmployeeAccept = db.TT_GETTIME().FirstOrDefault();//DateTime.Now;;
                    //}
                    otfile.CreateID = user.UserName;
                    otfile.CreateDate = DateTime.Now;
                    otfile.UpdateID = user.UserName;
                    otfile.UpdateDate = DateTime.Now;;

                    try
                    {
                        db.AF_OTfiling.Add(otfile);
                        db.SaveChanges();
                     
                    }
                    catch (Exception err)
                    {
                        Error_Logs error = new Error_Logs();
                        error.PageModule = "Application Form - OT Request";
                        error.ErrorLog = err.Message;
                        error.DateLog = db.TT_GETTIME().FirstOrDefault();//DateTime.Now;;
                        error.Username = user.UserName;
                        db.Error_Logs.Add(error);
                        db.SaveChanges();
                    }
                    emploCounter++;



                }
                M_Section_ApproverStatus checker = (from c in db.M_Section_ApproverStatus where c.RefNo == OTRefnow && c.OverTimeType == Filing.OvertimeType select c).FirstOrDefault();
                if (checker == null)
                {
                    #region GET approver & Email
                    //string SectionID = (from c in db.M_Cost_Center_List
                    //                    where c.Cost_Center == Section
                    //                    select c.ID).FirstOrDefault().ToString();
                    List<M_Section_Approver> approver = (from c in db.M_Section_Approver where c.Section == Section select c).ToList();

                    #region EMAIL FUNCTION TRANSFER TO SERVER JOBS
                    //try
                    //{
                    //    db.AF_EmailOTRequest();
                    //}
                    //catch (Exception err)
                    //{
                    //    Error_Logs error = new Error_Logs();
                    //    error.PageModule = "Application Form - OT Request";
                    //    error.ErrorLog = err.Message;
                    //    error.DateLog = db.TT_GETTIME().FirstOrDefault();//DateTime.Now;;
                    //    error.Username = user.UserName;
                    //    db.Error_Logs.Add(error);
                    //    db.SaveChanges();
                    //}


                    //EmailApproverController email = new EmailApproverController();
                    ////M_Employee_Master_List getSupervisor = (from c in db.M_Employee_Master_List where c.EmpNo == approver.Supervisor select c).FirstOrDefault();
                    //email.sendMail("OT Approval", approver, OTRefnow, Session["emailpath"].ToString());
                    #endregion
                    #endregion

                    #region Generate OT Status
                    foreach (M_Section_Approver approv in approver)
                    {
                        M_Section_ApproverStatus approverstat = new M_Section_ApproverStatus();
                        approverstat.Position = approv.Position;
                        approverstat.EmployeeNo = approv.EmployeeNo;
                        approverstat.Section = Section;
                        approverstat.RefNo = OTRefnow;
                        approverstat.Approved = 0;
                        approverstat.OverTimeType = Filing.OvertimeType;
                        approverstat.CreateID = user.UserName;
                        approverstat.CreateDate = DateTime.Now;;
                        approverstat.UpdateID = user.UserName;
                        approverstat.UpdateDate = DateTime.Now;;
                        db.M_Section_ApproverStatus.Add(approverstat);
                        db.SaveChanges();
                    }

                    #endregion
                }

                return Json(new { OTRefnow = OTRefnow }, JsonRequestBehavior.AllowGet);
            }
            catch(Exception err)
            {
                Error_Logs error = new Error_Logs();
                error.PageModule = "Application Form - OT Request";
                error.ErrorLog = err.Message;
                error.DateLog = db.TT_GETTIME().FirstOrDefault();//DateTime.Now;;
                error.Username = user.UserName;
                db.Error_Logs.Add(error);
                db.SaveChanges();
                return Json(new { OTRefnow = "" }, JsonRequestBehavior.AllowGet);

            }

        }
       
        public ActionResult DownloadTemplate(string Agency)
        {
            try
            {
                long? lineID,a;
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
                string templateFilename = "";
                if (Agency == "BIPH")
                {
                    templateFilename = "StandardizeOT_template.xlsx";
                }
                else
                {
                    templateFilename = "StandardizeOT_Agencytemplate.xlsx";
                }
                string dir = Path.GetTempPath();
                string filename = string.Format("StandardizeOT_template.xlsx");
                FileInfo newFile = new FileInfo(Path.Combine(dir, filename));
                FileInfo newFilecopy = new FileInfo(Path.Combine(dir, filename));
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
                    int start = 16;
                    ExcelWorksheet ExportData = package.Workbook.Worksheets["Standardized-OT Form"];
                    if (list.Count < 25)
                    {
                        for (int i = 0; i < list.Count; i++)
                        {
                            ExportData.Cells["C" + start].Value = list[i].EmpNo;
                            ExportData.Cells["D" + start].Value = list[i].Family_Name + ", " + list[i].First_Name;
                            start++;
                        }
                    }




                    ExportData.Cells["D5"].Value = current.Department;
                    ExportData.Cells["D6"].Value = user.Section;
                    ExportData.Cells["I5"].Value = db.TT_GETTIME().FirstOrDefault();//DateTime.Now;.ToShortDateString();
                    ExportData.Cells["D1"].Value = AgencyDetails.AgencyName;
                    ExportData.Cells["D2"].Value = AgencyDetails.Address;
                    ExportData.Cells["D3"].Value = AgencyDetails.TelNo;
                    ExportData.Cells["I63"].Value = AgencyDetails.ISO_OT;

                    string path = Server.MapPath(@"/PictureResources/AgencyLogo/" + AgencyDetails.Logo);


                    #region IMAGE
                    using (System.Drawing.Image image = System.Drawing.Image.FromFile(path))
                    {
                            var excelImage = ExportData.Drawings.AddPicture("logohere", image);
                            excelImage.SetSize(140, 69);
                            excelImage.SetPosition(0, 0, 1, 1);
                            
                    }

                    #endregion


                    //package.SaveAs(newFilecopy);

                    string paths = @"\\192.168.200.100\Published Files\Brothers_AMS\" + filename;
                    Stream stream = System.IO.File.Create(paths);
                    package.SaveAs(stream);
                    stream.Close();


                    return File(package.GetAsByteArray(), "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", filename);
                }
            }
            catch (Exception err) {
                Error_Logs error = new Error_Logs();
                error.PageModule = "Application Form - OT";
                error.ErrorLog = err.Message;
                error.DateLog = db.TT_GETTIME().FirstOrDefault();//DateTime.Now;;
                error.Username = user.UserName;
                db.Error_Logs.Add(error);
                db.SaveChanges();
            }
            return Json(new { }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult TimeValidate(List<string> list,DateTime DateFrom, string OTin,string OTOut, string Type)
        {
            bool Allow = true;
            List<string> EmpConflict = new List<string>();
            List<string> EmpAlready = new List<string>();
            long? GetSchedID;
            if (Type != "Regular")
            {
                foreach (string emp in list)
                {
                    string currentRefno = helper.GenerateOTRef();
                    DateTime a = DateFrom.Date;
                    AF_OTfiling otnow = (from c in db.AF_OTfiling where c.DateFrom == a && c.EmployeeNo == emp select c).FirstOrDefault();
                    //AF_OTfiling otnow2 = (from c in db.AF_OTfiling where c.OT_RefNo == currentRefno && c.OTout == OTOut && c.Status >= 0 && c.EmployeeNo == emp select c).FirstOrDefault();

                    if (otnow != null)// || otnow2 != null)
                    {
                        EmpAlready.Add(list[0]);
                        Allow = false;
                    }
                    else
                    {
                        Allow = true;
                    }
                }
            }
            else
            {
                foreach (string emp in list) {
                    M_Employee_Master_List Employee = (from c in db.M_Employee_Master_List where c.EmpNo == emp select c).FirstOrDefault();
                    GetSchedID = (from c in db.M_Employee_Master_List_Schedule where c.EmployeeNo == emp orderby c.ID descending select c.ScheduleID).FirstOrDefault();
                   
                    string Schedule = (from c in db.M_Schedule where c.ID == GetSchedID select c.Type).FirstOrDefault();

                    M_Schedule schedcheck = (from c in db.M_Schedule where c.Type == Schedule select c).FirstOrDefault();
                    DateTime ShiftStart = DateTime.Parse(schedcheck.Timein.ToString());
                    DateTime ShiftEnd = DateTime.Parse(schedcheck.TimeOut.ToString());
                    DateTime TimecheckIN = DateTime.Parse(OTin);
                    DateTime TimecheckOUT = DateTime.Parse(OTOut);
                    if (ShiftStart > ShiftEnd)
                    {
                        ShiftEnd = ShiftEnd.AddDays(1);
                    }
                    //if ((ShiftStart > TimecheckIN
                    //    && TimecheckIN < ShiftEnd)
                    //    ||( ShiftStart > TimecheckOUT
                    //    && TimecheckOUT < ShiftEnd))
                    //{
                    if (TimecheckIN.ToString("HH:mm") == ShiftEnd.ToString("HH:mm") || TimecheckOUT.ToString("HH:mm") == ShiftStart.ToString("HH:mm"))
                    {
                        Allow = (Allow == false) ? false : true;
                    }
                    else
                    {
                        EmpConflict.Add(emp);
                        Allow = false;
                        //break;
                    }
                    string currentRefno = helper.GenerateOTRef();
                    DateTime a = DateFrom.Date;
                    AF_OTfiling otnow = (from c in db.AF_OTfiling where c.OT_RefNo == currentRefno && c.OTin == OTin && c.Status >= 0 && c.DateFrom == a && c.EmployeeNo == emp select c).FirstOrDefault();
                    //AF_OTfiling otnow2 = (from c in db.AF_OTfiling where c.OT_RefNo == currentRefno && c.OTout == OTOut && c.Status >= 0 && c.EmployeeNo == emp select c).FirstOrDefault();

                    if (otnow != null)// || otnow2 != null)
                    {
                        EmpAlready.Add(list[0]);
                        Allow = false;
                    }

                }
            }
            return Json(new { Allow = Allow, EmpConflict = EmpConflict, EmpAlready= EmpAlready }, JsonRequestBehavior.AllowGet);
        }
        [HttpPost]
        public JsonResult ReadUploadedFile()
        {
            try { 
            var file = Request.Files[0];
            int fileSize = file.ContentLength;
            string fileName = file.FileName;
            string TodayRefno = helper.GenerateOTRef();
            string Section = "";
            string OTType = "";
            List<AF_OTfiling> OTFilingList = new List<AF_OTfiling>();
            List<string> Unregistered = new List<string>();
                using (var package = new ExcelPackage(file.InputStream))
                {
                    ExcelWorksheet worksheet = package.Workbook.Worksheets[1];
                    int noOfCol = worksheet.Dimension.End.Column;
                    int noOfRow = worksheet.Dimension.End.Row;
                    int endColumn = worksheet.Dimension.Start.Column;
                    int startColumn = endColumn;
                    int startRowForTable = 16;
                    int totalNoOfTableRow = 25;

                    #region Find Type
                    if (worksheet.Cells[12, 3].Value.ToString().ToLower().Contains("x"))
                    {
                        OTType = "SundayHoliday";
                    }
                    else if (worksheet.Cells[11,6].Value.ToString().ToLower().Contains("x"))
                    {
                        OTType = "LegalHoliday";
                    }
                    else if (worksheet.Cells[12, 6].Value.ToString().ToLower().Contains("x"))
                    {
                        OTType = "SpecialHoliday";
                    }
                    else
                    {
                        OTType = "Regular";
                    }
                    #endregion


                    for (int x = 0; x < totalNoOfTableRow; x++)
                    {
                        string Empno = "";

                        try
                        {
                            Empno = worksheet.Cells[startRowForTable, 3].Value.ToString();
                            M_Employee_Master_List Employee = (from c in db.M_Employee_Master_List
                                                               where c.EmpNo == Empno
                                                               select c).FirstOrDefault();

                            if (Employee != null)
                            {
                                AF_OTfiling bemodify = (from c in db.AF_OTfiling where c.EmployeeNo == Employee.EmpNo && c.OT_RefNo == TodayRefno select c).FirstOrDefault();

                                if (bemodify == null)
                                {
                                    #region Creating via upload
                                    AF_OTfiling OTrequest = new AF_OTfiling();
                                    OTrequest.OT_RefNo = TodayRefno;
                                    OTrequest.BIPH_Agency = Employee.Company;
                                    OTrequest.FileType = 3; //Upload
                                    OTrequest.Section = (from c in db.M_Employee_CostCenter where c.EmployNo == Empno orderby c.ID descending select c.CostCenter_AMS).FirstOrDefault();
                                    Section = (from c in db.M_Cost_Center_List where c.Cost_Center == OTrequest.Section orderby c.ID descending select c.GroupSection).FirstOrDefault();//otfile.Section;

                                    OTrequest.EmployeeNo = Employee.EmpNo;
                                    OTrequest.OvertimeType = OTType;
                                    OTrequest.DateFrom = Convert.ToDateTime(worksheet.Cells[6, 9].Value);
                                    OTrequest.DateTo = Convert.ToDateTime(worksheet.Cells[6, 9].Value);

                                    OTrequest.OTin = worksheet.Cells[startRowForTable, 5].Value.ToString();
                                    OTrequest.OTout = worksheet.Cells[startRowForTable, 6].Value.ToString();
                                    
                                    OTrequest.Purpose = worksheet.Cells[startRowForTable, 8].Value.ToString();
                                    OTrequest.Status = 0;
                                    OTrequest.StatusMax = (OTrequest.OvertimeType == "SundayHoliday") ? 4 : 2;

                                    OTrequest.EmployeeAccept = db.TT_GETTIME().FirstOrDefault();

                                    OTrequest.CreateID = user.UserName;
                                    OTrequest.CreateDate = DateTime.Now;;
                                    OTrequest.UpdateID = user.UserName;
                                    OTrequest.UpdateDate = DateTime.Now;;

                                    try
                                    {
                                        db.AF_OTfiling.Add(OTrequest);
                                        db.SaveChanges();
                                    }
                                    catch (Exception err)
                                    {
                                        Error_Logs error = new Error_Logs();
                                        error.PageModule = "Application Form - OT Request";
                                        error.ErrorLog = err.Message;
                                        error.DateLog = db.TT_GETTIME().FirstOrDefault();//DateTime.Now;;
                                        error.Username = user.UserName;
                                        db.Error_Logs.Add(error);
                                        db.SaveChanges();
                                    }
                                    #endregion
                                }
                                else
                                {
                                    #region modifying via upload
                                    //Section = Employee.CostCode;
                                    bemodify.OT_RefNo = TodayRefno;
                                    bemodify.BIPH_Agency = Employee.Company;
                                    bemodify.FileType = 3; //Upload
                                    bemodify.Section = (from c in db.M_Employee_CostCenter where c.EmployNo == Empno orderby c.ID descending select c.CostCenter_AMS).FirstOrDefault();
                                    Section = (from c in db.M_Cost_Center_List where c.Cost_Center == bemodify.Section orderby c.ID descending select c.GroupSection).FirstOrDefault();//otfile.Section;

                                    bemodify.EmployeeNo = Employee.EmpNo;
                                    bemodify.OvertimeType = OTType;
                                    bemodify.DateFrom = Convert.ToDateTime(worksheet.Cells[6, 8].Value);
                                    bemodify.DateTo = Convert.ToDateTime(worksheet.Cells[6, 8].Value);
                                    bemodify.OTin = worksheet.Cells[startRowForTable, 4].Value.ToString();
                                    bemodify.OTout = worksheet.Cells[startRowForTable, 5].Value.ToString();
                                    bemodify.Purpose = worksheet.Cells[startRowForTable, 7].Value.ToString();
                                    bemodify.Status = 0;
                                    bemodify.StatusMax = (bemodify.OvertimeType == "SundayHoliday") ? 4 : 2;

                                    bemodify.EmployeeAccept = db.TT_GETTIME().FirstOrDefault();

                                    bemodify.UpdateID = user.UserName;
                                    bemodify.UpdateDate = DateTime.Now;;

                                    try
                                    {
                                        db.Entry(bemodify).State = EntityState.Modified;
                                        db.SaveChanges();
                                    }
                                    catch (Exception err)
                                    {
                                        Error_Logs error = new Error_Logs();
                                        error.PageModule = "Application Form - OT Request";
                                        error.ErrorLog = err.Message;
                                        error.DateLog = db.TT_GETTIME().FirstOrDefault();//DateTime.Now;;
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
                            Error_Logs error = new Error_Logs();
                            error.PageModule = "Application Form - OT Request";
                            error.ErrorLog = err.Message;
                            error.DateLog = db.TT_GETTIME().FirstOrDefault();//DateTime.Now;;
                            error.Username = user.UserName;
                            db.Error_Logs.Add(error);
                            db.SaveChanges();
                            //return Json(new { Failed = "Failed" }, JsonRequestBehavior.AllowGet);

                        }

                        startRowForTable++;
                    }

                    M_Section_ApproverStatus checker = (from c in db.M_Section_ApproverStatus where c.RefNo == TodayRefno select c).FirstOrDefault();
                    if (checker == null) {
                        #region GET approver & Email
                        //string SectionID = (from c in db.M_Cost_Center_List
                        //                    where c.Cost_Center == Section
                        //                    select c.ID).FirstOrDefault().ToString();
                        List<M_Section_Approver> approver = (from c in db.M_Section_Approver where c.Section == Section select c).ToList();


                        #endregion
                        #region Generate OT Status
                        foreach (M_Section_Approver approv in approver)
                        {
                            M_Section_ApproverStatus approverstat = new M_Section_ApproverStatus();
                            approverstat.Position = approv.Position;
                            approverstat.EmployeeNo = approv.EmployeeNo;
                            approverstat.Section = Section;
                            approverstat.RefNo = helper.GenerateOTRef();
                            approverstat.Approved = 0;
                            approverstat.OverTimeType = OTType;
                            approverstat.CreateID = user.UserName;
                            approverstat.CreateDate = DateTime.Now;;
                            approverstat.UpdateID = user.UserName;
                            approverstat.UpdateDate = DateTime.Now;;
                            db.M_Section_ApproverStatus.Add(approverstat);
                            db.SaveChanges();
                        }

                        #endregion
                    }



                    return Json(new { Unregistered = Unregistered, Failed= "" }, JsonRequestBehavior.AllowGet);
              
            }
            }
            catch (Exception err)
            {
                return Json(new { Failed = "Failed" }, JsonRequestBehavior.AllowGet);

            }

        }
    }
}