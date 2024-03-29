﻿using Brothers_WMS.Controllers;
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
    public class Approval_OTController : Controller
    {
        // GET: Correction/Approval_OT
        Brothers_AMSDBEntities db = new Brothers_AMSDBEntities();
        M_Users user = (M_Users)System.Web.HttpContext.Current.Session["user"];
        public ActionResult Approval_OT(string RefNo, string OverTimeType,string Approved)
        {
            Session["RefNoOT"] = RefNo;
            Session["OverTimeType"] = OverTimeType;
            if ((RefNo != null && OverTimeType != null) || Approved != null)
            {
                List<string> result = db.EmailPrompter(RefNo, OverTimeType, user.UserName,"OT").ToList();
                if (result.Count > 0)
                {
                    //return Redirect("http://apbiphwb08:2020/Correction/Approval_OT/Approval_OT?Approved=" + result[0]);
                    return Redirect("http://localhost:49710/Correction/Approval_OT/Approval_OT?Approved=" + result[0]);
                   
                }
              
            }
            return View();
        }

        public ActionResult GetApproverOTList()
        {
            int start = Convert.ToInt32(Request["start"]);
            int length = Convert.ToInt32(Request["length"]);
            //string searchValue = (Session["RNO"] != null)? Session["RNO"].ToString() : Request["search[value]"];
            string sortColumnName = Request["columns[" + Request["order[0][column]"] + "][name]"];
            string sortDirection = Request["order[0][dir]"];

            string searchValue = (Session["RefNoOT"] != null) ? Session["RefNoOT"].ToString() : Request["search[value]"];
            string searchOvertimetype = (Session["OverTimeType"] != null) ? Session["OverTimeType"].ToString() : "";
            List<GET_AF_OTRequest_Result> list = db.GET_AF_OTRequest().ToList();
            
            if (!string.IsNullOrEmpty(searchValue))//filter
            {
                list = list.Where(x => x.OT_RefNo.ToLower().Contains(searchValue.ToLower())).ToList<GET_AF_OTRequest_Result>();
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

            if(searchOvertimetype != "")
            {
                list = list.Where(x => x.OvertimeType == searchOvertimetype).ToList();
            }
           

            int totalrows = list.Count;
            int totalrowsafterfiltering = list.Count;
            //paging
            list = list.Skip(start).Take(length).ToList<GET_AF_OTRequest_Result>();
            
            return Json(new { data = list, draw = Request["draw"], recordsTotal = totalrows, recordsFiltered = totalrowsafterfiltering }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult GetApproverOTDetailsList(string OTRefNo, string OTType)
        {
            int start = Convert.ToInt32(Request["start"]);
            int length = Convert.ToInt32(Request["length"]);
            string searchValue = Request["search[value]"];
            string sortColumnName = Request["columns[" + Request["order[0][column]"] + "][name]"];
            string sortDirection = Request["order[0][dir]"];

            List<GET_AF_OTRequest_Detail_Result> list = db.GET_AF_OTRequest_Detail(OTRefNo, OTType).ToList();

            if (!string.IsNullOrEmpty(searchValue))//filter
            {
                list = list.Where(x => x.First_Name.ToLower().Contains(searchValue.ToLower())).ToList<GET_AF_OTRequest_Detail_Result>();
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
            list = list.Skip(start).Take(length).ToList<GET_AF_OTRequest_Detail_Result>();
            return Json(new { data = list, draw = Request["draw"], recordsTotal = totalrows, recordsFiltered = totalrowsafterfiltering }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult GetApproverList(string OTRefNo)
        {
            int start = Convert.ToInt32(Request["start"]);
            int length = Convert.ToInt32(Request["length"]);
            string searchValue = Request["search[value]"];
            string sortColumnName = Request["columns[" + Request["order[0][column]"] + "][name]"];
            string sortDirection = Request["order[0][dir]"];

            List<GET_AF_Approver_Result> list = db.GET_AF_Approver(OTRefNo).ToList();

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

        public ActionResult VerifyUser(string RefNo, string ifalter)
        {
            bool releasebtn = false;
            bool releasebtnCancel = false;
            AF_OTfiling getStatus = (from c in db.AF_OTfiling where c.OT_RefNo == RefNo orderby c.Status descending select c).FirstOrDefault();
            //M_Section_Approver approver = (from c in db.M_Section_Approver where c.Section == getStatus.Section select c).FirstOrDefault();

           
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
            foreach(M_Section_ApproverStatus username in approver)
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

            if(getStatus.CreateID == user.UserName)
            {
                releasebtnCancel = true;
            }
            
            return Json(new { releasebtn= releasebtn, releasebtnCancel= releasebtnCancel }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult ApprovedOT(List<AF_OTModel> GetApproved, string ifalter, string OTType)
        {
            string[] Position = { "Supervisor", "Manager", "GeneralManager", "FactoryGeneralManager" };
            int currentstatus = 0;
            int stat=0, statmax=0;
            foreach (AF_OTModel otrequest in GetApproved)
            {
                if (otrequest.Approved == true)
                {
                    AF_OTfiling otfile = new AF_OTfiling();
                    otfile = (from c in db.AF_OTfiling where c.Status > -1 && c.OT_RefNo == otrequest.OT_RefNo && c.EmployeeNo == otrequest.EmployeeNo && c.OvertimeType == OTType select c).FirstOrDefault();
                    currentstatus = otfile.Status + 1;
                    otfile.Status = (otrequest.Approved == true) ? currentstatus : currentstatus - (currentstatus * 2);
                    db.Entry(otfile).State = EntityState.Modified;


                    if (otfile.StatusMax == otfile.Status)
                    {
                        #region Cumulative OT
                        //Save Cummulative
                        AF_OTfiling_Cumulative Employee_Cumulative = new AF_OTfiling_Cumulative();
                        Employee_Cumulative.OT_RefNo = otfile.OT_RefNo;
                        Employee_Cumulative.Schedule = (from c in db.M_Employee_Master_List_Schedule where c.EmployeeNo == otrequest.EmployeeNo orderby c.ScheduleID descending select c.ScheduleID).FirstOrDefault();
                        Employee_Cumulative.ShiftIn = (from c in db.M_Schedule where c.ID == Employee_Cumulative.Schedule select c.Timein).FirstOrDefault();
                        Employee_Cumulative.ShiftOut = (from c in db.M_Schedule where c.ID == Employee_Cumulative.Schedule select c.TimeOut).FirstOrDefault();
                        Employee_Cumulative.OTIn = otfile.OTin;
                        Employee_Cumulative.OTOut = otfile.OTout;
                        Employee_Cumulative.OTDate = DateTime.ParseExact(DateTime.Now.ToString("yyyy-MM-dd HH:mm tt"), "yyyy-MM-dd HH:mm tt", System.Globalization.CultureInfo.InvariantCulture);

                        DateTime ShiftStart = DateTime.Parse(Employee_Cumulative.ShiftIn.ToString());
                        DateTime ShiftEnd = DateTime.Parse(Employee_Cumulative.ShiftOut.ToString());
                        DateTime OTStart = DateTime.Parse(Employee_Cumulative.OTIn.ToString());
                        DateTime OTEnd = DateTime.Parse(Employee_Cumulative.OTOut.ToString());
                        TimeSpan duration = new TimeSpan();
                        if (ShiftStart > ShiftEnd)
                        {
                            ShiftEnd = ShiftEnd.AddDays(1);
                        }
                        if (OTStart > OTEnd)
                        {
                            OTEnd = OTEnd.AddDays(1);
                        }
                        if (ShiftEnd == OTStart)
                        {
                            duration = OTEnd.Subtract(ShiftEnd);
                        }
                        else if (OTStart < ShiftEnd)
                        {
                            //  OTStart = ShiftEnd;
                            duration = OTEnd.Subtract(OTStart);
                        }
                        else
                        {
                            duration = OTEnd.Subtract(OTStart);
                        }
                        double Diffminutes = duration.TotalMinutes;
                        double Cummulativenow = Diffminutes / 60;
                        Employee_Cumulative.OTHours = Convert.ToDecimal(Cummulativenow);
                        Employee_Cumulative.EmployeeNo = otfile.EmployeeNo;
                        //Employee_Cumulative.OTDate = Filing.DateFrom;

                        Employee_Cumulative.CreateID = user.UserName;
                        Employee_Cumulative.CreateDate = DateTime.ParseExact(DateTime.Now.ToString("yyyy-MM-dd HH:mm tt"), "yyyy-MM-dd HH:mm tt", System.Globalization.CultureInfo.InvariantCulture);
                        Employee_Cumulative.UpdateID = user.UserName;
                        Employee_Cumulative.UpdateDate = DateTime.ParseExact(DateTime.Now.ToString("yyyy-MM-dd HH:mm tt"), "yyyy-MM-dd HH:mm tt", System.Globalization.CultureInfo.InvariantCulture);

                        db.AF_OTfiling_Cumulative.Add(Employee_Cumulative);

                        db.SaveChanges();

                        #endregion
                      
                    }
                    stat = otfile.Status;
                    statmax = otfile.StatusMax;
                    db.SaveChanges();
                }
                else
                {
                    AF_OTfiling otfile = new AF_OTfiling();
                    otfile = (from c in db.AF_OTfiling where c.Status > -1 && c.OT_RefNo == otrequest.OT_RefNo && c.EmployeeNo == otrequest.EmployeeNo && c.OvertimeType == OTType select c).FirstOrDefault();
                    currentstatus = otfile.Status + 1;
                    otfile.Status = (otrequest.Approved == true) ? currentstatus : currentstatus - (currentstatus * 2);
                    db.Entry(otfile).State = EntityState.Modified;
                    db.SaveChanges();
                }
            }

            if(stat == statmax)
            {
                SendTheMail(GetApproved[0].OT_RefNo);
            }

           
            #region update Approver Status
            string refno = GetApproved[0].OT_RefNo;
            string pos =(ifalter == "alter")? "Alternative "+Position[currentstatus-1] : Position[currentstatus - 1];
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
            
            db.AF_EmailOTRequest(refno);
            return Json(new { }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult RejectedOT(List<AF_OTModel> GetApproved, string ifalter)
        {
            string[] Position = { "Supervisor", "Manager", "GeneralManager", "FactoryGeneralManager" };
            int currentstatus = 0;
            foreach (AF_OTModel otrequest in GetApproved)
            {
                if (otrequest.Approved == true)
                {
                    AF_OTfiling otfile = new AF_OTfiling();
                    otfile = (from c in db.AF_OTfiling where c.OT_RefNo == otrequest.OT_RefNo && c.EmployeeNo == otrequest.EmployeeNo select c).FirstOrDefault();
                    currentstatus = (otfile.Status + 1) * -1;
                    otfile.Status = currentstatus;
                    db.Entry(otfile).State = EntityState.Modified;
                    db.SaveChanges();
                }

            }
            #region update Approver Status
            //string refno = GetApproved[0].OT_RefNo;
            //string pos = (ifalter == "alter") ? "Alternative " + Position[currentstatus - 1] : Position[currentstatus - 1];
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
            List<string> EmpnoCannotCancel = new List<string>();
            foreach(string data in RefNo)
            {
            
                long ID = Convert.ToInt64(data.Replace("OT_here_", ""));
                AF_OTfiling otrequest = (from c in db.AF_OTfiling where c.ID == ID select c).FirstOrDefault();
                if (otrequest.CreateID == user.UserName)
                {
                    otrequest.Status = -10;
                    db.Entry(otrequest).State = EntityState.Modified;
                    db.SaveChanges();
                }
                else
                {
                    EmpnoCannotCancel.Add(otrequest.EmployeeNo);
                }
            }

            return Json(new { EmpnoCannotCancel = EmpnoCannotCancel }, JsonRequestBehavior.AllowGet);
        }


        public void SendTheMail(string RefNo)
        {
            try
            {
                
                List<string> AgencyList = new List<string>();
                AgencyList = (from c in db.AF_OTfiling where c.OT_RefNo == RefNo select c.BIPH_Agency).ToList();
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
                    if (Agencycode == "BIPH")
                    {
                        templateFilename = "StandardizeOT_template.xlsx";
                    }
                    else
                    {
                        templateFilename = "StandardizeOT_Agencytemplate.xlsx";
                    }
                    string dir = Path.GetTempPath();
                    string datetimeToday = DateTime.Now.ToString("yyMMddhhmmss");
                    string filename = string.Format("StandardizeOT_template{0}.xlsx", datetimeToday);
                    FileInfo newFile = new FileInfo(Path.Combine(dir, filename));
                    FileInfo newFilecopy = new FileInfo(Path.Combine(dir, filename));
                    string apptemplatePath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, @"TemplateFiles\StandardTemplate\", templateFilename);
                    FileInfo templateFile = new FileInfo(apptemplatePath);
                    M_Employee_Master_List current = (from c in db.M_Employee_Master_List where c.EmpNo == user.UserName select c).FirstOrDefault();
                    using (ExcelPackage package = new ExcelPackage(newFile, templateFile))  //-- With template.
                    {
                        //List<GET_Employee_OTFiling_Result> list = new List<GET_Employee_OTFiling_Result>();
                        List<GET_AF_OTExport_Result> list = db.GET_AF_OTExport(RefNo, Agency).ToList();
                      //  list = db.GET_Employee_OTFiling(Agency, user.CostCode, lineID, "").ToList();
                        
                        int start = 16;
                        ExcelWorksheet ExportData = package.Workbook.Worksheets["Standardized-OT Form"];
                        for (int i = 0; i < list.Count; i++)
                        {
                            ExportData.Cells["C" + start].Value = list[i].EmployeeNo;
                            ExportData.Cells["D" + start].Value = list[i].Family_Name + ", " + list[i].First_Name;
                            ExportData.Cells["E" + start].Value = list[i].OTin;
                            ExportData.Cells["F" + start].Value = (list[i].Actual_Out == null)? list[i].OTout: list[i].Actual_Out;
                            ExportData.Cells["H" + start].Value = list[i].Purpose;
                            ExportData.Cells["I" + start].Value = list[i].Actual_Out;
                            start++;
                        }




                        ExportData.Cells["D5"].Value = current.Department;
                        ExportData.Cells["D6"].Value = user.Section;
                        ExportData.Cells["I5"].Value = DateTime.Now.ToShortDateString();
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
                error.PageModule = "Application Form - OT";
                error.ErrorLog = err.Message;
                error.DateLog = DateTime.Now;
                error.Username = user.UserName;
                db.Error_Logs.Add(error);
                db.SaveChanges();
            }
           
        }

        #region Remove for now
        //public ActionResult Resendmail(string RefNo, string Position, string EmployeeNo, string ResendAlter)
        //{
        //    M_Employee_Master_List getapprover = (from c in db.M_Employee_Master_List where c.EmpNo == EmployeeNo select c).FirstOrDefault();
        //    string msg;
        //    try
        //    {
        //        EmailApproverController email = new EmailApproverController();
        //        switch (ResendAlter)
        //        {
        //            case "Resend":
        //                email.sendMail("Resending Email", getapprover.Email, EmployeeNo, RefNo, Session["emailpath"].ToString());
        //                break;
        //            case "Alter":
        //                M_Section_ApproverStatus approverstat = new M_Section_ApproverStatus();
        //                approverstat.Position = "Alternative " + Position;
        //                approverstat.EmployeeNo = EmployeeNo;
        //                approverstat.Section = getapprover.Section;
        //                approverstat.RefNo = RefNo;
        //                approverstat.Approved = 0;

        //                approverstat.CreateID = user.UserName;
        //                approverstat.CreateDate = DateTime.Now;
        //                approverstat.UpdateID = user.UserName;
        //                approverstat.UpdateDate = DateTime.Now;
        //                db.M_Section_ApproverStatus.Add(approverstat);
        //                db.SaveChanges();


        //                email.sendMail("Alternative Approver", getapprover.Email, EmployeeNo, RefNo, Session["emailpath"].ToString());
        //                break;

        //        }
        //        msg = "Success";
        //    }
        //    catch(Exception err)
        //    {
        //        msg = err.Message;
        //    }
        //    return Json(new {msg = msg }, JsonRequestBehavior.AllowGet);

        //}

        #endregion
    }
}