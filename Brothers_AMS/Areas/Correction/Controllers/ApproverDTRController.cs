using Brothers_WMS.Controllers;
using Brothers_WMS.Models;
using Brothers_WMS.Models.AFModel;
using OfficeOpenXml;
using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using static Brothers_WMS.Controllers.SessionExpire;

namespace Brothers_WMS.Areas.Correction.Controllers
{
    [SessionExpire]
    public class ApproverDTRController : Controller
    {
        // GET: Correction/ApproverDTR
        Brothers_AMSDBEntities db = new Brothers_AMSDBEntities();
        M_Users user = (M_Users)System.Web.HttpContext.Current.Session["user"];
        public ActionResult ApproverDTR(string RefNo, string OverTimeType, string Approved)
        {
            Session["RefNoDTR"] = RefNo;
            Session["OverTimeType"] = OverTimeType;
            if ((RefNo != null && OverTimeType != null) || Approved != null)
            {
                List<string> result = db.EmailPrompter(RefNo, "Regular", user.UserName,"DTR").ToList();
                if (result.Count > 0)
                {
                    return Redirect("http://apbiphwb08:2020/Correction/ApproverDTR/ApproverDTR?Approved=" + result[0]);
                    //return Redirect("http://localhost:49710/Correction/ApproverDTR/ApproverDTR?Approved=" + result[0]);
                }
            }
            return View();
        }

        public ActionResult GetApproverDTRList()
        {
            int start = Convert.ToInt32(Request["start"]);
            int length = Convert.ToInt32(Request["length"]);
            //string searchValue = Request["search[value]"];
            string sortColumnName = Request["columns[" + Request["order[0][column]"] + "][name]"];
            string sortDirection = Request["order[0][dir]"];

            List<GET_AF_DTRRequest_Result> list = db.GET_AF_DTRRequest().ToList();
            string searchValue = (Session["RefNoDTR"] != null) ? Session["RefNoDTR"].ToString() : Request["search[value]"];

            if (!string.IsNullOrEmpty(searchValue))//filter
            {
                list = list.Where(x => x.DTR_RefNo.ToLower().Contains(searchValue.ToLower())).ToList<GET_AF_DTRRequest_Result>();
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
            list = list.Skip(start).Take(length).ToList<GET_AF_DTRRequest_Result>();
            return Json(new { data = list, draw = Request["draw"], recordsTotal = totalrows, recordsFiltered = totalrowsafterfiltering }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult GetApproverDTRDetailsList(string DTRRefNo, string OTType)
        {
            int start = Convert.ToInt32(Request["start"]);
            int length = Convert.ToInt32(Request["length"]);
            string searchValue = Request["search[value]"];
            string sortColumnName = Request["columns[" + Request["order[0][column]"] + "][name]"];
            string sortDirection = Request["order[0][dir]"];

            List<GET_AF_DTRRequest_Detail_Result> list = db.GET_AF_DTRRequest_Detail(DTRRefNo).ToList();

            if (!string.IsNullOrEmpty(searchValue))//filter
            {
                #region null remover
                list = list.Where(xx => xx.EmployeeNo != null).ToList();
                list = list.Where(xx => xx.First_Name != null).ToList();
                list = list.Where(xx => xx.Family_Name != null).ToList();
                #endregion
                list = list.Where(x => x.First_Name.ToLower().Contains(searchValue.ToLower())
                || x.Family_Name.ToLower().Contains(searchValue.ToLower())).ToList<GET_AF_DTRRequest_Detail_Result>();
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
            list = list.Skip(start).Take(length).ToList<GET_AF_DTRRequest_Detail_Result>();
            return Json(new { data = list, draw = Request["draw"], recordsTotal = totalrows, recordsFiltered = totalrowsafterfiltering }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult VerifyUser(string RefNo)
        {
            bool releasebtn = false;
            AF_DTRfiling getStatus = (from c in db.AF_DTRfiling where c.DTR_RefNo == RefNo orderby c.Status descending select c).FirstOrDefault();

            List<M_Section_ApproverStatus> approver = (from c in db.M_Section_ApproverStatus where c.RefNo == RefNo select c).ToList();
            switch (getStatus.Status)
            {
                case 0:
                    approver = approver.Where(x => x.Position == "Supervisor").ToList();
                    break;
                case 1:
                    approver = approver.Where(x => x.Position == "Manager").ToList();
                    break;
                case 2:
                    approver = approver.Where(x => x.Position == "GeneralManager").ToList();
                    break;
            }
            List<string> userlist = new List<string>();
            foreach (M_Section_ApproverStatus username in approver)
            {
                userlist.Add(username.EmployeeNo);
            }
            //Checker if allowed to approved yet
            var dateAndTime = DateTime.Now;
            var date = dateAndTime.Date;
            var Requestdate = getStatus.CreateDate.Date;

            if (userlist.Contains(user.UserName) && Requestdate < date)
            {
                releasebtn = true;
            }

            return Json(new { releasebtn = releasebtn }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult GetApproverList(string DTRRefNo)
        {
            int start = Convert.ToInt32(Request["start"]);
            int length = Convert.ToInt32(Request["length"]);
            string searchValue = Request["search[value]"];
            string sortColumnName = Request["columns[" + Request["order[0][column]"] + "][name]"];
            string sortDirection = Request["order[0][dir]"];

            List<GET_AF_Approver_Result> list = db.GET_AF_Approver(DTRRefNo).ToList();

            if (!string.IsNullOrEmpty(searchValue))//filter
            {
                list = list.Where(x => x.EmployeeName.ToLower().Contains(searchValue.ToLower())).ToList<GET_AF_Approver_Result>();
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
            list = list.Skip(start).Take(length).ToList<GET_AF_Approver_Result>();
            return Json(new { data = list, draw = Request["draw"], recordsTotal = totalrows, recordsFiltered = totalrowsafterfiltering }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult ApprovedDTR(List<AF_DTRModel> GetApproved, string ifalter, string OTType)
        {
            OTType = (OTType == null) ? "Regular":OTType;
            string[] Position = {"Supervisor", "Manager", "GeneralManager" };
            int currentstatus = 0;
            int stat = 0, statmax = 0;
            foreach (AF_DTRModel csrequest in GetApproved)
            {
                if (csrequest.Approved == true)
                {
                    AF_DTRfiling dtrfile = new AF_DTRfiling();
                    dtrfile = (from c in db.AF_DTRfiling where c.Status > -1 && c.DTR_RefNo == csrequest.DTR_RefNo && c.EmployeeNo == csrequest.EmployeeNo && c.OvertimeType == OTType select c).FirstOrDefault();
                    currentstatus = dtrfile.Status + 1;
                    dtrfile.Status = (csrequest.Approved == true) ? currentstatus : currentstatus - (currentstatus * 2);
                    db.Entry(dtrfile).State = EntityState.Modified;

                 
                    db.SaveChanges();
                    stat = dtrfile.Status;
                    statmax = dtrfile.StatusMax;
                }
                else
                {
                    AF_DTRfiling dtrfile = new AF_DTRfiling();
                    dtrfile = (from c in db.AF_DTRfiling where c.Status > -1 && c.DTR_RefNo == csrequest.DTR_RefNo && c.EmployeeNo == csrequest.EmployeeNo && c.OvertimeType == OTType select c).FirstOrDefault();
                    currentstatus = dtrfile.Status + 1;
                    dtrfile.Status = (csrequest.Approved == true) ? currentstatus : currentstatus - (currentstatus * 2);
                    db.Entry(dtrfile).State = EntityState.Modified;
                    
                    db.SaveChanges();
                }
            }
            
             

            if (stat == statmax)
            {
                SendTheMail(GetApproved[0].DTR_RefNo);
            }

            #region update Approver Status
            string refno = GetApproved[0].DTR_RefNo;
            string pos = (ifalter == "alter") ? "Alternative " + Position[currentstatus - 1] : Position[currentstatus - 1];
            M_Section_ApproverStatus approverstatus = (from c in db.M_Section_ApproverStatus
                                                       where c.RefNo == refno
                                                       && c.EmployeeNo == user.UserName
                                                       && c.Position == pos
                                                       && c.OverTimeType == OTType
                                                       select c).FirstOrDefault();


            approverstatus.Approved = 1;
            db.Entry(approverstatus).State = EntityState.Modified;
            db.SaveChanges();

            #endregion

            db.AF_EmailDTRRequest(refno);
            return Json(new { }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult RejectedDTR(List<AF_DTRModel> GetApproved, string ifalter)
        {
            string[] Position = { "", "Supervisor", "Manager", "GeneralManager" };
            int currentstatus = 0;
            foreach (AF_DTRModel dtrrequest in GetApproved)
            {
                if (dtrrequest.Approved == true)
                {
                    AF_DTRfiling otfile = new AF_DTRfiling();
                    otfile = (from c in db.AF_DTRfiling where c.DTR_RefNo == dtrrequest.DTR_RefNo && c.EmployeeNo == dtrrequest.EmployeeNo select c).FirstOrDefault();
                    currentstatus = (otfile.Status + 1) *-1;
                    otfile.Status =  currentstatus;
                    db.Entry(otfile).State = EntityState.Modified;
                    db.SaveChanges();
                }

            }
            #region update Approver Status
            //string refno = GetApproved[0].DTR_RefNo;
            //string pos = (ifalter == "alter") ? "Alternative " + Position[currentstatus] : Position[currentstatus];
            //M_Section_ApproverStatus approverstatus = (from c in db.M_Section_ApproverStatus
            //                                           where c.RefNo == refno
            //                                           && c.EmployeeNo == user.UserName
            //                                           && c.Position == pos
            //                                           select c).FirstOrDefault();


            //approverstatus.Approved = -1;
            //db.Entry(approverstatus).State = EntityState.Modified;
            //db.SaveChanges();

            #endregion

            return Json(new { }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult CancelledRefNo(List<string> RefNo)
        {
            #region Old
            //string REFNO = RefNo[0];
            //List<AF_DTRfiling> list = (from c in db.AF_DTRfiling
            //                           where c.DTR_RefNo == REFNO
            //                           select c).ToList();
            //foreach (AF_DTRfiling request in list)
            //{
            //    request.Status = -10;
            //    request.UpdateDate = DateTime.Now;
            //    request.UpdateID = user.UserName;
            //    db.Entry(request).State = EntityState.Modified;
            //    db.SaveChanges();
            //}
            #endregion
            List<string> EmpnoCannotCancel = new List<string>();
            foreach (string data in RefNo)
            {
                long ID = Convert.ToInt64(data.Replace("DTR_here_", ""));
                AF_DTRfiling dtrrequest = (from c in db.AF_DTRfiling where c.ID == ID select c).FirstOrDefault();
                if (dtrrequest.CreateID == user.UserName)
                {
                    dtrrequest.Status = -10;
                    db.Entry(dtrrequest).State = EntityState.Modified;
                    db.SaveChanges();
                }
                else
                {
                    EmpnoCannotCancel.Add(dtrrequest.EmployeeNo);
                }
            }
            return Json(new { EmpnoCannotCancel = EmpnoCannotCancel }, JsonRequestBehavior.AllowGet);
        }

        public void SendTheMail(string RefNo)
        {
            try
            {
                List<string> AgencyList = new List<string>();
                AgencyList = (from c in db.AF_DTRfiling where c.DTR_RefNo == RefNo select c.BIPH_Agency).ToList();
                AgencyList = AgencyList.Distinct().ToList();
                foreach (string Agency in AgencyList)
                {

                    long? lineID, a;
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
                    string Agencycode = (Agency == "") ? "BIPH" : Agency;
                    M_Agency AgencyDetails = (from c in db.M_Agency where c.AgencyCode == Agencycode select c).FirstOrDefault();
                    string templateFilename = "";

                    templateFilename = "StandardizeDTR_template.xlsx";

                    string dir = Path.GetTempPath();
                    string datetimeToday = DateTime.Now.ToString("yyMMddhhmmss");
                    string filename = string.Format("StandardizeDTR_template{0}.xlsx", datetimeToday);
                    FileInfo newFile = new FileInfo(Path.Combine(dir, filename));
                    FileInfo newFilecopy = new FileInfo(Path.Combine(dir, filename));
                    string apptemplatePath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, @"TemplateFiles\StandardTemplate\", templateFilename);
                    FileInfo templateFile = new FileInfo(apptemplatePath);
                    M_Employee_Master_List current = (from c in db.M_Employee_Master_List where c.EmpNo == user.UserName select c).FirstOrDefault();
                    using (ExcelPackage package = new ExcelPackage(newFile, templateFile))  //-- With template.
                    {
                        List<GET_AF_DTRExport_Result> list = db.GET_AF_DTRExport(RefNo, Agency).ToList();
                        int start = 12;
                        ExcelWorksheet ExportData = package.Workbook.Worksheets["Standardized-DTR Form"];
                        for (int i = 0; i < list.Count; i++)
                        {
                            ExportData.Cells["B" + start].Value = list[i].EmployeeNo;
                            ExportData.Cells["C" + start].Value = list[i].Family_Name + ", " + list[i].First_Name;
                            ExportData.Cells["D" + start].Value = list[i].Concerns;
                            ExportData.Cells["E" + start].Value = list[i].Reason;
                            ExportData.Cells["F" + start].Value = list[i].DateFrom;
                            ExportData.Cells["G" + start].Value = list[i].DateTo;
                            ExportData.Cells["H" + start].Value = list[i].Timein;
                            ExportData.Cells["I" + start].Value = list[i].TimeOut;
                            ExportData.Cells["J" + start].Value = list[i].EmployeeAccept;
                            start++;
                        }




                        ExportData.Cells["C5"].Value = current.Department;
                        ExportData.Cells["J6"].Value = user.Section;
                        ExportData.Cells["J5"].Value = DateTime.Now.ToShortDateString();
                        ExportData.Cells["C1"].Value = AgencyDetails.AgencyName;
                        ExportData.Cells["C2"].Value = AgencyDetails.Address;
                        ExportData.Cells["C3"].Value = AgencyDetails.TelNo;
                        ExportData.Cells["I51"].Value = AgencyDetails.ISO_DTR;

                        string path = Server.MapPath(@"/PictureResources/AgencyLogo/" + AgencyDetails.Logo);


                        #region IMAGE
                        using (System.Drawing.Image image = System.Drawing.Image.FromFile(path))
                        {
                            var excelImage = ExportData.Drawings.AddPicture("logohere", image);
                            excelImage.SetSize(140, 69);
                            excelImage.SetPosition(0, 0, 1, 1);

                        }

                        #endregion



                        //string paths = @"\\192.168.200.100\Published Files\Brothers_AMS\" + filename;
                        //Stream stream = System.IO.File.Create(paths);
                        //package.SaveAs(stream);
                        //stream.Close();
                        //try
                        //{
                        //    db.AF_SendAgency("ce.ragas@seiko-it.com.ph", filename);
                        //}
                        //catch (Exception err) { }
                    }
                }
            }
            catch (Exception err)
            {
                Error_Logs error = new Error_Logs();
                error.PageModule = "Application Form - CS";
                error.ErrorLog = err.Message;
                error.DateLog = DateTime.Now;
                error.Username = user.UserName;
                db.Error_Logs.Add(error);
                db.SaveChanges();
            }

        }

    }
}