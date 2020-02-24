using Brothers_WMS.Controllers;
using Brothers_WMS.Models;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.Entity;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using static Brothers_WMS.Controllers.SessionExpire;

namespace Brothers_WMS.Areas.Masters.Controllers
{
    [SessionExpire]
    public class AgencyController : Controller
    {
        // GET: Masters/Agency
        Brothers_AMSDBEntities db = new Brothers_AMSDBEntities();
        M_Users user = (M_Users)System.Web.HttpContext.Current.Session["user"];

        public ActionResult Agency()
        {
            db.M_SP_AgencyInsert();
            return View();
        }

        public ActionResult GetAgencyList()
        {
            //Server Side Parameter
            int start = Convert.ToInt32(Request["start"]);
            int length = Convert.ToInt32(Request["length"]);
            string searchValue = Request["search[value]"];
            string sortColumnName = Request["columns[" + Request["order[0][column]"] + "][name]"];
            string sortDirection = Request["order[0][dir]"];

            List<M_Agency> list = new List<M_Agency>();
            list = (from c in db.M_Agency
                    where c.IsDeleted == false
                    select c).ToList();

            if (!string.IsNullOrEmpty(searchValue))//filter
            {
                list = list.Where(x => x.AgencyName.ToLower().Contains(searchValue.ToLower())).ToList<M_Agency>();
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
            list = list.Skip(start).Take(length).ToList<M_Agency>();
            return Json(new { data = list, draw = Request["draw"], recordsTotal = totalrows, recordsFiltered = totalrowsafterfiltering }, JsonRequestBehavior.AllowGet);
        }
        public ActionResult CreateAgency(M_Agency data)
        {
            try
            {
                data.CreateID = user.UserName;
                data.CreateDate = DateTime.Now;
                data.UpdateID = user.UserName;
                data.UpdateDate = DateTime.Now;

                M_Agency checker = (from c in db.M_Agency
                                      where c.AgencyName == data.AgencyName
                                      && c.Address == data.Address
                                      //&& c.ISO == data.ISO
                                      && c.Status == data.Status
                                      && c.IsDeleted == false
                                      select c).FirstOrDefault();
                if (checker == null)
                {
                    db.M_Agency.Add(data);
                    db.SaveChanges();
                    return Json(new { msg = "Success" }, JsonRequestBehavior.AllowGet);
                }
                else
                {
                    return Json(new { msg = "Failed" }, JsonRequestBehavior.AllowGet);

                }
            }
            catch (Exception err)
            {
                Error_Logs error = new Error_Logs();
                error.PageModule = "Master - Agency";
                error.ErrorLog = err.Message;
                error.DateLog = DateTime.Now;
                error.Username = user.UserName;
                db.Error_Logs.Add(error);
                db.SaveChanges();
                return Json(new { msg = err.Message }, JsonRequestBehavior.AllowGet);
            }
        }
        public ActionResult DeleteAgency(int ID)
        {
            M_Agency agency = new M_Agency();
            agency = (from u in db.M_Agency.ToList()
                        where u.ID == ID
                        select u).FirstOrDefault();
            agency.IsDeleted = true;
            agency.UpdateDate = DateTime.Now;
            agency.UpdateID = user.UserName;
            db.Entry(agency).State = EntityState.Modified;
            db.SaveChanges();
            return Json(new { msg = "Success" }, JsonRequestBehavior.AllowGet);
        }
        public ActionResult EditAgency(M_Agency data)
        {
            try
            {
                M_Agency agency = new M_Agency();
                agency = (from u in db.M_Agency.ToList()
                            where u.ID == data.ID
                            select u).FirstOrDefault();
                agency.AgencyName = data.AgencyName;
                agency.Address = data.Address;
                agency.ISO_OT = data.ISO_OT;
                agency.ISO_CS = data.ISO_CS;
                agency.ISO_DTR = data.ISO_DTR;
                agency.Status = data.Status;
                //agency.EmailAddress = data.EmailAddress;

                agency.UpdateID = user.UserName;
                agency.UpdateDate = DateTime.Now;

                M_Agency checker = (from c in db.M_Agency
                                      where c.AgencyName == data.AgencyName
                                      && c.Address == data.Address
                                      //&& c.ISO == data.ISO
                                      && c.Status == data.Status
                                      && c.IsDeleted == false
                                    select c).FirstOrDefault();
                if (checker == null)
                {
                    db.Entry(agency).State = EntityState.Modified;
                    db.SaveChanges();
                }
                else
                {
                    return Json(new { msg = "Failed" }, JsonRequestBehavior.AllowGet);

                }
            }
            catch (Exception err) {
                Error_Logs error = new Error_Logs();
                error.PageModule = "Master - Agency";
                error.ErrorLog = err.Message;
                error.DateLog = DateTime.Now;
                error.Username = user.UserName;
                db.Error_Logs.Add(error);
                db.SaveChanges();
            }

            return Json(new { msg = "Success" }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult GetEmail(string AgencyCode)
        {
            List<M_Agency_Email> EmailAgency = (from c in db.M_Agency_Email where c.AgencyCode == AgencyCode select c).ToList();
            return Json(new
            {
                EmailAgency = EmailAgency
            }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult SaveAgencyMail(List<M_Agency_Email> EmailList)
        {
            try
            {
                if (EmailList[0].AgencyCode != null)
                {
                    db.M_AgencyReassign(EmailList[0].AgencyCode);
                    foreach (M_Agency_Email mail in EmailList)
                    {
                        mail.CreateID = user.UserName;
                        mail.CreateDate = DateTime.Now;
                        mail.UpdateID = user.UserName;
                        mail.UpdateDate = DateTime.Now;
                        db.M_Agency_Email.Add(mail);
                        db.SaveChanges();
                    }
                    return Json(new { msg = "" }, JsonRequestBehavior.AllowGet);
                }
                else
                {
                    return Json(new { msg = "Cannot Save" }, JsonRequestBehavior.AllowGet);
                }
            }
            catch (Exception err)
            {
                Error_Logs error = new Error_Logs();
                error.PageModule = "Master - Agency";
                error.ErrorLog = err.Message;
                error.DateLog = DateTime.Now;
                error.Username = user.UserName;
                db.Error_Logs.Add(error);
                db.SaveChanges();
                return Json(new { msg = err.Message }, JsonRequestBehavior.AllowGet);
            }
        }


        [HttpPost]
        public ActionResult UploadImagePackage(int AgencyID)
        {
           
            try
            {
                #region Save to Server
                //bool isSuccess = false;
                //string serverMessage = string.Empty;
                //var fileOne = Request.Files[0] as HttpPostedFileBase;
                // uploadPath = Server.MapPath(@"~/PictureResources/AgencyLogo/");
                // newFileOne = Path.Combine(uploadPath, fileOne.FileName);
                //fileOne.SaveAs(newFileOne);
                #endregion
                #region Save to Server
                bool isSuccess = false;
                string serverMessage = string.Empty;
                var fileOne = Request.Files[0] as HttpPostedFileBase;
                string uploadPath = Server.MapPath(@"~/PictureResources/AgencyLogo/");
                string newFileOne = Path.Combine(uploadPath, fileOne.FileName);
                //fileOne.SaveAs(newFileOne);
                fileOne.SaveAs(HttpContext.Server.MapPath("~/PictureResources/AgencyLogo/") + Path.GetFileName(fileOne.FileName));

                #endregion

                #region ImageSet
                M_Agency pack = (from c in db.M_Agency where c.ID == AgencyID select c).FirstOrDefault();
                //pack.Logo = fileOne.FileName;
                string[] data = fileOne.FileName.Split('\\');
                pack.Logo = data[data.Length - 1];//fileOne.FileName;
                db.Entry(pack).State = EntityState.Modified;
                db.SaveChanges();
                
                #endregion

            }
            catch (Exception err)
            {
                Error_Logs error = new Error_Logs();
                error.PageModule = "Master - Agency";
                error.ErrorLog = err.Message;
                error.DateLog = DateTime.Now;
                error.Username = user.UserName;
                db.Error_Logs.Add(error);
                db.SaveChanges();
            }
            return Json(new { wew = "" }, JsonRequestBehavior.AllowGet);
        }
    }
}