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
    public class ApproverChangeScheduleController : Controller
    {
        // GET: Correction/ApproverChangeSchedule
        Brothers_AMSDBEntities db = new Brothers_AMSDBEntities();
        M_Users user = (M_Users)System.Web.HttpContext.Current.Session["user"];
        public ActionResult ApproverChangeSchedule(string RefNo, string CSType, string Approved)
        {
            Session["RefNoCS"] = RefNo;
            Session["CSType"] = (CSType == null)?"":CSType;
            CSType = (CSType == null) ? "" : CSType;
            //if ((RefNo != null && CSType != null) || Approved != null)
            //{
            //    List<string> result = db.EmailPrompter(RefNo, "", user.UserName,"CS").ToList();
            //    if (result.Count > 0)
            //    {
            //        return Redirect("http://apbiphwb08:2020/Correction/ApproverChangeSchedule/ApproverChangeSchedule?Approved=" + result[0]);
            //        //return Redirect("http://apbiphwb08:2020/Correction/ApproverChangeSchedule/ApproverChangeSchedule?Approved=" + result[0]);
            //        //return Redirect("http://localhost:49710/Correction/ApproverChangeSchedule/ApproverChangeSchedule?Approved=" + result[0]);
            //    }
            //}
            return View();
        }

        public ActionResult GetApproverCSList(string Section, DateTime? DateFrom, DateTime? DateTo)
        {
            int start = Convert.ToInt32(Request["start"]);
            int length = Convert.ToInt32(Request["length"]);
            //string searchValue = Request["search[value]"];
            string sortColumnName = Request["columns[" + Request["order[0][column]"] + "][name]"];
            string sortDirection = Request["order[0][dir]"];

            string supersection = (user.CostCode != null) ? (from c in db.M_Cost_Center_List where c.Cost_Center == user.CostCode select c.GroupSection).FirstOrDefault() : Section;
            List<GET_AF_CSRequest_Result> list = db.GET_AF_CSRequest(supersection, DateFrom, DateTo).ToList();
            string searchValue = (Session["RefNoCS"] != null) ? Session["RefNoCS"].ToString() : Request["search[value]"];

            if (!string.IsNullOrEmpty(searchValue))//filter
            {
                list = list.Where(x => x.CS_RefNo.ToLower().Contains(searchValue.ToLower())).ToList<GET_AF_CSRequest_Result>();
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
            list = list.Skip(start).Take(length).ToList<GET_AF_CSRequest_Result>();
            return Json(new { data = list, draw = Request["draw"], recordsTotal = totalrows, recordsFiltered = totalrowsafterfiltering }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult GetApproverCSDetailsList(string CSRefNo)
        {
            int start = Convert.ToInt32(Request["start"]);
            int length = Convert.ToInt32(Request["length"]);
            string searchValue = Request["search[value]"];
            string sortColumnName = Request["columns[" + Request["order[0][column]"] + "][name]"];
            string sortDirection = Request["order[0][dir]"];

            List<GET_AF_CSRequest_Detail_Result> list = db.GET_AF_CSRequest_Detail(CSRefNo).ToList();

            if (!string.IsNullOrEmpty(searchValue))//filter
            {
                #region null remover
                list = list.Where(xx => xx.EmployeeNo != null).ToList();
                list = list.Where(xx => xx.First_Name != null).ToList();
                list = list.Where(xx => xx.Family_Name != null).ToList();
                #endregion
                list = list.Where(x => x.First_Name.ToLower().Contains(searchValue.ToLower())
                        || x.Family_Name.ToLower().Contains(searchValue.ToLower())).ToList<GET_AF_CSRequest_Detail_Result>();
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
            list = list.Skip(start).Take(length).ToList<GET_AF_CSRequest_Detail_Result>();
            return Json(new { data = list, draw = Request["draw"], recordsTotal = totalrows, recordsFiltered = totalrowsafterfiltering }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult GetApproverList(string CSRefNo)
        {
            int start = Convert.ToInt32(Request["start"]);
            int length = Convert.ToInt32(Request["length"]);
            string searchValue = Request["search[value]"];
            string sortColumnName = Request["columns[" + Request["order[0][column]"] + "][name]"];
            string sortDirection = Request["order[0][dir]"];

            List<GET_AF_Approver_Result> list = db.GET_AF_Approver(CSRefNo).ToList();

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
        
        public ActionResult VerifyUser(string RefNo)
        {
            bool releasebtn = false;
            bool releasebtnCancel = false;
            AF_ChangeSchedulefiling getStatus = (from c in db.AF_ChangeSchedulefiling where c.CS_RefNo == RefNo orderby c.Status descending select c).FirstOrDefault();

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

            if (userlist.Contains(user.UserName) )// && Requestdate < date)
            {
                releasebtn = true;
            }

            if (getStatus.CreateID == user.UserName)
            {
                releasebtnCancel = true;
            }

            return Json(new { releasebtn = releasebtn, releasebtnCancel = releasebtnCancel }, JsonRequestBehavior.AllowGet);
        }
        
        public ActionResult ApprovedCS(List<AF_CSModel> GetApproved, string ifalter)
        {
            string[] Position = {"Supervisor", "Manager"};
            int currentstatus = 0;
            int stat = 0, statmax = 0;
            string refno = GetApproved[0].CS_RefNo;
            foreach (AF_CSModel csrequest in GetApproved)
            {
                if (csrequest.Approved == true)
                {
                    AF_ChangeSchedulefiling csfile = new AF_ChangeSchedulefiling();
                    csfile = (from c in db.AF_ChangeSchedulefiling where c.Status > -1 && c.CS_RefNo == csrequest.CS_RefNo && c.EmployeeNo == csrequest.EmployeeNo select c).FirstOrDefault();
                    currentstatus = csfile.Status + 1;
                    csfile.Status = (csrequest.Approved == true) ? currentstatus : currentstatus - (currentstatus * 2);

                    if (csfile.Status >= csfile.StatusMax)
                    {
                        csfile.Status = 2;
                    }
                    db.Entry(csfile).State = EntityState.Modified;
                    db.SaveChanges();

                    stat = csfile.Status;
                    statmax = csfile.StatusMax;


                   
                }
                else
                {
                    AF_ChangeSchedulefiling csfile = new AF_ChangeSchedulefiling();
                    csfile = (from c in db.AF_ChangeSchedulefiling where c.Status > -1 && c.CS_RefNo == csrequest.CS_RefNo && c.EmployeeNo == csrequest.EmployeeNo select c).FirstOrDefault();
                    currentstatus = csfile.Status + 1;
                    csfile.Status = (csrequest.Approved == true) ? currentstatus : currentstatus - (currentstatus * 2);
                    if (csfile.Status >= csfile.StatusMax)
                    {
                        csfile.Status = 2;
                    }
                    db.Entry(csfile).State = EntityState.Modified;
                    db.SaveChanges();
                }


            }
            
            #region update Approver Status

            //string pos = (ifalter == "alter") ? "Alternative " + Position[currentstatus] : Position[currentstatus - 1];
            M_Section_ApproverStatus approverstatus = (from c in db.M_Section_ApproverStatus
                                                       where c.RefNo == refno
                                                       && c.EmployeeNo == user.UserName
                                                       //&& c.EmployeeNo_CSRequest == csrequest.EmployeeNo
                                                       //&& c.Position == pos
                                                       select c).FirstOrDefault();

            approverstatus.ApprovedDate = db.TT_GETTIME().FirstOrDefault();
            approverstatus.Approved = 1;
            db.Entry(approverstatus).State = EntityState.Modified;
            db.SaveChanges();


            #endregion
            db.AF_EmailCSRequest(refno);
            if (stat == statmax)
            {
                db.AF_UpdateApprovedSchedule();
                //SendTheMail(GetApproved[0].CS_RefNo);
            }
            return Json(new { }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult RejectedCS(List<AF_CSModel> GetApproved, string ifalter)
        {
            string[] Position = { "Supervisor", "Manager" };
            int currentstatus = 0;
            string CSRefNo = "";
            foreach (AF_CSModel otrequest in GetApproved)
            {
                if (otrequest.Approved == true)
                {
                    CSRefNo = otrequest.CS_RefNo;
                    AF_ChangeSchedulefiling otfile = new AF_ChangeSchedulefiling();
                    otfile = (from c in db.AF_ChangeSchedulefiling where c.CS_RefNo == otrequest.CS_RefNo && c.EmployeeNo == otrequest.EmployeeNo select c).FirstOrDefault();
                    currentstatus = (otfile.Status + 1) * -1;
                    otfile.Status =  currentstatus; 
                    db.Entry(otfile).State = EntityState.Modified;
                    db.SaveChanges();
                }
              
            }
            #region update Approver Status
            string refno = GetApproved[0].CS_RefNo;
            db.AF_EmailCSRequest_Rejected(CSRefNo);
            //string pos = (ifalter == "alter") ? "Alternative " + Position[currentstatus*-1] : Position[currentstatus*-1];
            M_Section_ApproverStatus approverstatus = (from c in db.M_Section_ApproverStatus
                                                       where c.RefNo == refno
                                                       && c.EmployeeNo == user.UserName
                                                       //&& c.Position == pos
                                                       select c).FirstOrDefault();


            approverstatus.Approved = 1;
            approverstatus.ApprovedDate = db.TT_GETTIME().FirstOrDefault();
            db.Entry(approverstatus).State = EntityState.Modified;
            db.SaveChanges();

            #endregion

            return Json(new { }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult CancelledRefNo(List<string> RefNo)
        {
            List<string> EmpnoCannotCancel = new List<string>();
            foreach (string data in RefNo)
            {
                long ID = Convert.ToInt64(data.Replace("CS_here_", ""));
                AF_ChangeSchedulefiling csrequest = (from c in db.AF_ChangeSchedulefiling where c.ID == ID select c).FirstOrDefault();
                if (csrequest.CreateID == user.UserName)
                {
                    csrequest.Status = -10;
                    db.Entry(csrequest).State = EntityState.Modified;
                    db.SaveChanges();
                }
                else
                {
                    EmpnoCannotCancel.Add(csrequest.EmployeeNo);
                }
            }
            return Json(new { EmpnoCannotCancel = EmpnoCannotCancel }, JsonRequestBehavior.AllowGet);
        }

        //public ActionResult CancelledRefNo(string RefNo)
        //{

        //        List<AF_ChangeSchedulefiling> csrequest = (from c in db.AF_ChangeSchedulefiling where c.CS_RefNo == RefNo select c).ToList();
        //        foreach(AF_ChangeSchedulefiling a in csrequest)
        //        {

        //            a.Status = -10;
        //            db.Entry(a).State = EntityState.Modified;
        //            db.SaveChanges();


        //        }


        //    return Json(new { EmpnoCannotCancel = "" }, JsonRequestBehavior.AllowGet);
        //}


        public void SendTheMail(string RefNo)
        {
            try
            {

                List<string> AgencyList = new List<string>();
                AgencyList = (from c in db.AF_ChangeSchedulefiling where c.CS_RefNo == RefNo select c.BIPH_Agency).ToList();
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
                   
                    templateFilename = "StandardizeCS_template.xlsx";
                   
                    string dir = Path.GetTempPath();
                    string datetimeToday = DateTime.Now.ToString("yyMMddhhmmss");
                    string filename = string.Format("StandardizeCS_template{0}.xlsx", datetimeToday);
                    FileInfo newFile = new FileInfo(Path.Combine(dir, filename));
                    FileInfo newFilecopy = new FileInfo(Path.Combine(dir, filename));
                    string apptemplatePath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, @"TemplateFiles\StandardTemplate\", templateFilename);
                    FileInfo templateFile = new FileInfo(apptemplatePath);
                    M_Employee_Master_List current = (from c in db.M_Employee_Master_List where c.EmpNo == user.UserName select c).FirstOrDefault();
                    using (ExcelPackage package = new ExcelPackage(newFile, templateFile))  //-- With template.
                    {
                        List<GET_AF_CSExport_Result> list = db.GET_AF_CSExport(RefNo, Agency).ToList();
                        int start = 14;
                        ExcelWorksheet ExportData = package.Workbook.Worksheets["Standardized-CS Form"];
                        for (int i = 0; i < list.Count; i++)
                        {
                            ExportData.Cells["B" + start].Value = list[i].EmployeeNo;
                            ExportData.Cells["C" + start].Value = list[i].Family_Name + ", " + list[i].First_Name;
                            ExportData.Cells["D" + start].Value = list[i].CSType;
                            ExportData.Cells["E" + start].Value = list[i].DateFrom;
                            ExportData.Cells["F" + start].Value = list[i].DateTo;
                            ExportData.Cells["G" + start].Value = list[i].CSin;
                            ExportData.Cells["H" + start].Value = list[i].CSout;
                            ExportData.Cells["I" + start].Value = list[i].Reason;
                            ExportData.Cells["J" + start].Value = list[i].EmployeeAccept;
                            start++;
                        }




                        ExportData.Cells["C5"].Value = current.Department;
                        ExportData.Cells["J6"].Value = user.Section;
                        ExportData.Cells["J6"].Value = DateTime.Now.ToShortDateString();
                        ExportData.Cells["C1"].Value = AgencyDetails.AgencyName;
                        ExportData.Cells["C2"].Value = AgencyDetails.Address;
                        ExportData.Cells["C3"].Value = AgencyDetails.TelNo;
                        ExportData.Cells["I51"].Value = AgencyDetails.ISO_CS;

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