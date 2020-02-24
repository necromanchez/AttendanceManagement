using Brothers_WMS.Controllers;
using Brothers_WMS.Models;
using OfficeOpenXml;
using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace Brothers_WMS.Areas.Correction.Controllers
{
    [SessionExpire]
    public class ChangeScheduleController : Controller
    {
        // GET: Correction/ChangeSchedule
        Brothers_AMSDBEntities db = new Brothers_AMSDBEntities();
        M_Users user = (M_Users)System.Web.HttpContext.Current.Session["user"];
        HelperController helper = new HelperController();
        public ActionResult ChangeSchedule()
        {
            return View();
        }

        public ActionResult GetShift(long ScheduleID)
        {
            string Shiftname = (from c in db.M_Schedule where c.ID == ScheduleID select c.Type).FirstOrDefault();
            return Json(new { Shiftname= Shiftname }, JsonRequestBehavior.AllowGet);
        }

      

        public ActionResult SaveCS(AF_ChangeSchedulefiling Filing, string Reasons, string EmployeeNos)
        {
            List<string> ReasonList = Reasons.Split(',').ToList();
            List<string> EmployeeNosLis = EmployeeNos.Split(',').ToList();
            int emploCounter = 0;
            string CSRefnow = helper.GenerateCSRef();
            string Section = "";
            foreach (string reason in ReasonList)
            {
                    string EmploNos = EmployeeNosLis[emploCounter];
                    AF_ChangeSchedulefiling csfile = new AF_ChangeSchedulefiling();
                    csfile.CS_RefNo = CSRefnow;
                    csfile.CSType = Filing.CSType;
                    csfile.BIPH_Agency = Filing.BIPH_Agency;
                    csfile.EmployeeNo = EmploNos;
                    csfile.FileType = Filing.FileType;
                    csfile.Section = (from c in db.M_Employee_CostCenter where c.EmployNo == EmploNos orderby c.ID descending select c.CostCenter_AMS).FirstOrDefault();
                    Section = csfile.Section;
                    csfile.DateFrom = Filing.DateFrom;
                    csfile.DateTo = Filing.DateTo;
                    csfile.CSin = Filing.CSin;
                    csfile.CSout = Filing.CSout;
                    csfile.Reason = reason;
                    csfile.Status = 0;
                    csfile.StatusMax = 2;
                    csfile.CreateID = user.UserName;
                    csfile.CreateDate = DateTime.Now;
                    csfile.UpdateID = user.UserName;
                    csfile.UpdateDate = DateTime.Now;
                    csfile.Schedule = Filing.Schedule;
                    try
                    {
                        db.AF_ChangeSchedulefiling.Add(csfile);
                        db.SaveChanges();
                    }
                    catch (Exception err)
                    {
                        Error_Logs error = new Error_Logs();
                        error.PageModule = "Application Form - Change Schedule";
                        error.ErrorLog = err.Message;
                        error.DateLog = DateTime.Now;
                        error.Username = user.UserName;
                        db.Error_Logs.Add(error);
                        db.SaveChanges();
                    }
               
                emploCounter++;

               

            }
            M_Section_ApproverStatus checker = (from c in db.M_Section_ApproverStatus where c.RefNo == CSRefnow select c).FirstOrDefault();

            if (checker == null)
            {
                #region GET approver & Email
                string SectionID = (from c in db.M_Cost_Center_List
                                    where c.Cost_Center == Section
                                    select c.ID).FirstOrDefault().ToString();
                List<M_Section_Approver> approver = (from c in db.M_Section_Approver
                                                     where c.Section == SectionID
                                                     && c.Position != "GeneralManager"
                                                     select c).ToList();


                #endregion
                #region Generate OT Status
                foreach (M_Section_Approver approv in approver)
                {
                    M_Section_ApproverStatus approverstat = new M_Section_ApproverStatus();
                    approverstat.Position = approv.Position;
                    approverstat.EmployeeNo = approv.EmployeeNo;
                    approverstat.Section = SectionID;
                    approverstat.RefNo = CSRefnow;
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

            return Json(new { CSRefnow = CSRefnow }, JsonRequestBehavior.AllowGet);
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
                string templateFilename = "StandardizeCS_template.xlsx";
                string dir = Path.GetTempPath();
                string filename = string.Format("StandardizeCS_template.xlsx");
                FileInfo newFile = new FileInfo(Path.Combine(dir, filename));
                string apptemplatePath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, @"TemplateFiles\StandardTemplate\", templateFilename);
                FileInfo templateFile = new FileInfo(apptemplatePath);
                M_Employee_Master_List current = (from c in db.M_Employee_Master_List where c.EmpNo == user.UserName select c).FirstOrDefault();

                using (ExcelPackage package = new ExcelPackage(newFile, templateFile))  //-- With template.
                {
                    List<GET_Employee_OTFiling_Result> list = new List<GET_Employee_OTFiling_Result>();
                    list = db.GET_Employee_OTFiling(Agency, user.CostCode, lineID, "").ToList();
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
                    int start = 14;
                    ExcelWorksheet ExportData = package.Workbook.Worksheets["Change shift"];
                    for (int i = 0; i < list.Count; i++)
                    {
                        ExportData.Cells["B" + start].Value = list[i].EmpNo;
                        ExportData.Cells["C" + start].Value = list[i].Family_Name + ", " + list[i].First_Name;
                        start++;
                    }
                    ExportData.Cells["C5"].Value = current.Department;
                    ExportData.Cells["J5"].Value = user.Section;
                    ExportData.Cells["C1"].Value = AgencyDetails.AgencyName;
                    ExportData.Cells["C2"].Value = AgencyDetails.Address;
                    ExportData.Cells["C3"].Value = AgencyDetails.TelNo;
                    ExportData.Cells["H51"].Value = AgencyDetails.ISO_CS;

                    string path = Server.MapPath(@"/PictureResources/AgencyLogo/" + AgencyDetails.Logo);


                    #region IMAGE
                    using (System.Drawing.Image image = System.Drawing.Image.FromFile(path))
                    {
                        var excelImage = ExportData.Drawings.AddPicture("logohere", image);
                        excelImage.SetSize(140, 69);
                        excelImage.SetPosition(0, 0, 0, 10);
                        
                    }

                    #endregion
                    
                    return File(package.GetAsByteArray(), "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", filename);
                }
            }
            catch (Exception err) {
                Error_Logs error = new Error_Logs();
                error.PageModule = "Application Form - Change Schedule";
                error.ErrorLog = err.Message;
                error.DateLog = DateTime.Now;
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
            string TodayRefno = helper.GenerateCSRef();
            string Section = "";
            List<string> Unregistered = new List<string>();
                using (var package = new ExcelPackage(file.InputStream))
                {
                    ExcelWorksheet worksheet = package.Workbook.Worksheets[1];
                    int noOfCol = worksheet.Dimension.End.Column;
                    int noOfRow = worksheet.Dimension.End.Row;
                    int endColumn = worksheet.Dimension.Start.Column;
                    int startColumn = endColumn;
                    int startRowForTable = 14;
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
                                AF_ChangeSchedulefiling bemodify = (from c in db.AF_ChangeSchedulefiling where c.EmployeeNo == Employee.EmpNo && c.CS_RefNo == TodayRefno select c).FirstOrDefault();

                                if (bemodify == null)
                                {
                                    #region Creating via upload
                                    Section = user.Section;//Employee.Section;
                                    AF_ChangeSchedulefiling CSrequest = new AF_ChangeSchedulefiling();
                                    CSrequest.CS_RefNo = TodayRefno;
                                    CSrequest.BIPH_Agency = Employee.Company;
                                    CSrequest.FileType = 3; //Upload
                                    CSrequest.Section = Employee.CostCode;
                                    CSrequest.EmployeeNo = Employee.EmpNo;
                                    CSrequest.CSType = worksheet.Cells[startRowForTable, 4].Value.ToString();
                                    CSrequest.DateFrom = Convert.ToDateTime(worksheet.Cells[startRowForTable, 5].Value);
                                    CSrequest.DateTo = Convert.ToDateTime(worksheet.Cells[startRowForTable, 6].Value);
                                    DateTime csin = Convert.ToDateTime(worksheet.Cells[startRowForTable, 7].Value.ToString());
                                    DateTime csout = Convert.ToDateTime(worksheet.Cells[startRowForTable, 8].Value.ToString());
                                    CSrequest.CSin = csin.ToString("HH:mm");
                                    CSrequest.CSout = csout.ToString("HH:mm");


                                    CSrequest.Reason = worksheet.Cells[startRowForTable, 9].Value.ToString();
                                    CSrequest.Status = 0;
                                    CSrequest.StatusMax = 2;

                                    CSrequest.CreateID = user.UserName;
                                    CSrequest.CreateDate = DateTime.Now;
                                    CSrequest.UpdateID = user.UserName;
                                    CSrequest.UpdateDate = DateTime.Now;

                                    try
                                    {
                                        db.AF_ChangeSchedulefiling.Add(CSrequest);
                                        db.SaveChanges();
                                    }
                                    catch (Exception err)
                                    {
                                        Error_Logs error = new Error_Logs();
                                        error.PageModule = "Application Form - OT Request";
                                        error.ErrorLog = err.Message;
                                        error.DateLog = DateTime.Now;
                                        error.Username = user.UserName;
                                        db.Error_Logs.Add(error);
                                        db.SaveChanges();
                                    }
                                    #endregion
                                }
                                else
                                {
                                    #region modifying via upload
                                    Section = Employee.Section;
                                    bemodify.CS_RefNo = TodayRefno;
                                    bemodify.BIPH_Agency = Employee.Company;
                                    bemodify.FileType = 3; //Upload
                                    bemodify.Section = Employee.CostCode;
                                    bemodify.EmployeeNo = Employee.EmpNo;
                                    bemodify.CSType = worksheet.Cells[startRowForTable, 4].Value.ToString();
                                    bemodify.DateFrom = Convert.ToDateTime(worksheet.Cells[startRowForTable, 5].Value);
                                    bemodify.DateTo = Convert.ToDateTime(worksheet.Cells[startRowForTable, 6].Value);
                                    DateTime csin = Convert.ToDateTime(worksheet.Cells[startRowForTable, 7].Value.ToString());
                                    DateTime csout = Convert.ToDateTime(worksheet.Cells[startRowForTable, 8].Value.ToString());
                                    bemodify.CSin = csin.ToString("HH:mm");
                                    bemodify.CSout = csout.ToString("HH:mm");
                                    bemodify.Reason = worksheet.Cells[startRowForTable, 9].Value.ToString();
                                    bemodify.Status = 0;
                                    bemodify.StatusMax = 2;
                                    bemodify.UpdateID = user.UserName;
                                    bemodify.UpdateDate = DateTime.Now;

                                    try
                                    {
                                        db.Entry(bemodify).State = EntityState.Modified;
                                        db.SaveChanges();
                                    }
                                    catch (Exception err)
                                    {
                                        Error_Logs error = new Error_Logs();
                                        error.PageModule = "Application Form - CS Request";
                                        error.ErrorLog = err.Message;
                                        error.DateLog = DateTime.Now;
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
                        string SectionID = (from c in db.M_Cost_Center_List
                                            where c.Cost_Center == Section
                                            select c.ID).FirstOrDefault().ToString();
                        List<M_Section_Approver> approver = (from c in db.M_Section_Approver where c.Section == SectionID select c).ToList();


                        #endregion
                        #region Generate CS Status
                        foreach (M_Section_Approver approv in approver)
                        {
                            M_Section_ApproverStatus approverstat = new M_Section_ApproverStatus();
                            approverstat.Position = approv.Position;
                            approverstat.EmployeeNo = approv.EmployeeNo;
                            approverstat.Section = SectionID;
                            approverstat.RefNo = helper.GenerateCSRef();
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
            catch (Exception err)
            {
                return Json(new { Failed = "Failed" }, JsonRequestBehavior.AllowGet);

            }

        }
    }
}