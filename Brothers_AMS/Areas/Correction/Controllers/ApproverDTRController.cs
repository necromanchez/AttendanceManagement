using Brothers_WMS.Controllers;
using Brothers_WMS.Models;
using Brothers_WMS.Models.AFModel;
using System;
using System.Collections.Generic;
using System.Data.Entity;
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
                    return Redirect("http://apbiphap05:2020/Correction/ApproverDTR/ApproverDTR?Approved=" + result[0]);
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
            foreach (AF_DTRModel csrequest in GetApproved)
            {
                AF_DTRfiling dtrfile = new AF_DTRfiling();
                dtrfile = (from c in db.AF_DTRfiling where c.DTR_RefNo == csrequest.DTR_RefNo && c.EmployeeNo == csrequest.EmployeeNo && c.OvertimeType == OTType select c).FirstOrDefault();
                currentstatus = dtrfile.Status + 1;
                dtrfile.Status = (csrequest.Approved == true) ? currentstatus : currentstatus - (currentstatus * 2);
                db.Entry(dtrfile).State = EntityState.Modified;
               
                if (dtrfile.Status > 0)
                {
                    db.AF_EmailDTRRequest(dtrfile.DTR_RefNo);
                }
                db.SaveChanges();
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
                    currentstatus = otfile.Status + 1;
                    otfile.Status = (dtrrequest.Approved == true) ? currentstatus - (currentstatus * 2): currentstatus;
                    db.Entry(otfile).State = EntityState.Modified;
                    db.SaveChanges();
                }

            }
            #region update Approver Status
            string refno = GetApproved[0].DTR_RefNo;
            string pos = (ifalter == "alter") ? "Alternative " + Position[currentstatus] : Position[currentstatus];
            M_Section_ApproverStatus approverstatus = (from c in db.M_Section_ApproverStatus
                                                       where c.RefNo == refno
                                                       && c.EmployeeNo == user.UserName
                                                       && c.Position == pos
                                                       select c).FirstOrDefault();


            approverstatus.Approved = -1;
            db.Entry(approverstatus).State = EntityState.Modified;
            db.SaveChanges();

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
    }
}