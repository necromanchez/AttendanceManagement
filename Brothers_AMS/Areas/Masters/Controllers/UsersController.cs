using Brothers_WMS.Controllers;
using Brothers_WMS.Models;
using OfficeOpenXml;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.Entity;
using System.Data.OleDb;
using System.IO;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.Mvc;
using static Brothers_WMS.Controllers.SessionExpire;

namespace Brothers_WMS.Areas.Masters.Controllers
{
    [SessionExpire]
    public class UsersController : Controller
    {
        // GET: Masters/Users

        Brothers_AMSDBEntities db = new Brothers_AMSDBEntities();
        M_Users user = (M_Users)System.Web.HttpContext.Current.Session["user"];
        public ActionResult Users()
        {
            return View();
        }

        public ActionResult GetUsersList(string supersection)
       {
            System.Web.HttpContext.Current.Session["SearchvalueUser"] = Request["search[value]"];

            //Server Side Parameter
            int start = Convert.ToInt32(Request["start"]);
            int length = Convert.ToInt32(Request["length"]);
            string searchValue = Request["search[value]"];
            string sortColumnName = Request["columns[" + Request["order[0][column]"] + "][name]"];
            string sortDirection = Request["order[0][dir]"];

            #region old User get
            //List<M_Users> list = (from c in db.M_Users where c.IsDeleted == false select c).ToList();
            //if (user.CostCode != "")
            //{
            //    list = (from c in db.M_Users
            //            where c.IsDeleted == false
            //            && (c.CostCode == user.CostCode
            //            || c.CostCode == "")
            //            select c).ToList();
            //}
            //else
            //{
            //    if (supersection != "")
            //    {
            //        list = list.Where(x => x.CostCode == supersection).ToList();
            //    }
            //    else
            //    {
            //        list = (from c in db.M_Users
            //                where c.IsDeleted == false
            //                select c).ToList();
            //    }
            //}
            #endregion

            string superusercost = (from d in db.M_Cost_Center_List where d.GroupSection == supersection select d.Cost_Center).FirstOrDefault();

            user.CostCode = (superusercost !=  null) ? superusercost : user.CostCode;
            List<GET_UserDetails_Result> list = db.GET_UserDetails(user.CostCode).ToList();
            if (!string.IsNullOrEmpty(searchValue))//filter
            {
                try
                {
                    #region null remover
                    list = list.Where(xx => xx.UserName != null).ToList();
                    list = list.Where(xx => xx.FirstName != null).ToList();
                    list = list.Where(xx => xx.LastName != null).ToList();
                    #endregion
                    //list = list.Where(x => x.UserName.ToLower().Contains(searchValue.ToLower()) || x.FirstName.ToLower().Contains(searchValue.ToLower())).ToList<M_Users>();
                    list = list.Where(x => x.FirstName.ToLower().Contains(searchValue.ToLower()) || x.LastName.ToLower().Contains(searchValue.ToLower())).ToList<GET_UserDetails_Result>();
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
            list = list.Skip(start).Take(length).ToList<GET_UserDetails_Result>();
            return Json(new { data = list, draw = Request["draw"], recordsTotal = totalrows, recordsFiltered = totalrowsafterfiltering }, JsonRequestBehavior.AllowGet);
        }
        public ActionResult CreateUsers(M_Users data)
        {
            try
            {
                data.Status = true;
                data.CreateID = user.UserName;
                data.CreateDate = DateTime.Now;
                data.UpdateID = user.UserName;
                data.UpdateDate = DateTime.Now;
                data.Password = "brotherpassword";
                data.Password = EncodePasswordMd5(data.Password);
                data.Section = "";
                data.CostCode = "";
                M_Users checker = (from c in db.M_Users
                                   where c.UserName == data.UserName
                                       && c.FirstName == data.FirstName
                                       && c.LastName == data.LastName
                                       && c.Status == data.Status
                                       && c.Section == data.Section
                                       && c.IsDeleted == false
                                      select c).FirstOrDefault();
                if (checker == null)
                {
                    db.M_Users.Add(data);
                    db.SaveChanges();

                    #region Give All Access
                    PageAccessGiver(data.UserName);
                    #endregion

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
                error.PageModule = "Master - Users";
                error.ErrorLog = err.Message;
                error.DateLog = DateTime.Now;
                error.Username = user.UserName;
                db.Error_Logs.Add(error);
                db.SaveChanges();
                return Json(new { msg = err.Message }, JsonRequestBehavior.AllowGet);
            }
        }
        public ActionResult DeleteUsers(string ID)
        {
            M_Users users = new M_Users();
            users = (from u in db.M_Users.ToList()
                        where u.UserName == ID
                     select u).FirstOrDefault();
            users.IsDeleted = true;
            users.UpdateDate = DateTime.Now;
            users.UpdateID = user.UserName;
            db.Entry(users).State = EntityState.Modified;
            db.SaveChanges();
            return Json(new { msg = "Success" }, JsonRequestBehavior.AllowGet);
        }
        public ActionResult EditUsers(M_Users data)
        {
            try
            {
                M_Users users = new M_Users();
                users = (from u in db.M_Users.ToList()
                            where u.ID == data.ID
                            select u).FirstOrDefault();
                users.UserName = data.UserName;
                users.FirstName = data.FirstName;
                users.LastName = data.LastName;
                users.Status = data.Status;

                users.UpdateID = user.UserName;
                users.UpdateDate = DateTime.Now;

                M_Users checker = (from c in db.M_Users
                                      where c.UserName == data.UserName
                                      && c.FirstName == data.FirstName
                                      && c.LastName == data.LastName
                                      && c.Status == data.Status
                                      && c.IsDeleted == false
                                      select c).FirstOrDefault();
                if (checker == null)
                {
                    db.Entry(users).State = EntityState.Modified;
                    db.SaveChanges();
                }
                else
                {
                    return Json(new { msg = "Failed" }, JsonRequestBehavior.AllowGet);

                }
            }
            catch (Exception err)
            {
                Error_Logs error = new Error_Logs();
                error.PageModule = "Master - Users";
                error.ErrorLog = err.Message;
                error.DateLog = DateTime.Now;
                error.Username = user.UserName;
                db.Error_Logs.Add(error);
                db.SaveChanges();
            }

            return Json(new { msg = "Success" }, JsonRequestBehavior.AllowGet);
        }
        public void PageAccessGiver(string UserName)
        {
            List<PA_Pages> pagelist = new List<PA_Pages>();
            pagelist = (from c in db.PA_Pages select c).ToList();

            foreach(PA_Pages page in pagelist)
            {
                PA_Users user = new PA_Users();
                user.PageID = page.ID;
                user.PageAccess = true;
                user.UserName = UserName;
                db.PA_Users.Add(user);
                db.SaveChanges();
            }
        }
        public string EncodePasswordMd5(string pass) //Encrypt using MD5    
        {
            Byte[] originalBytes;
            Byte[] encodedBytes;
            MD5 md5;
            //Instantiate MD5CryptoServiceProvider, get bytes for original password and compute hash (encoded password)    
            md5 = new MD5CryptoServiceProvider();
            originalBytes = ASCIIEncoding.Default.GetBytes(pass);
            encodedBytes = md5.ComputeHash(originalBytes);
            //Convert encoded bytes back to a 'readable' string    
            return BitConverter.ToString(encodedBytes).Replace("-", string.Empty);
        }
        public ActionResult GetPageAccess(string UserName)
        {
            M_Users userchosen = (from c in db.M_Users where c.UserName == UserName select c).FirstOrDefault();
            
            List<M_SP_PageandAccess_Result> MasterPageList = db.M_SP_PageandAccess(UserName, "Master").ToList();
            List<M_SP_PageandAccess_Result> ApplicationFormPageList = db.M_SP_PageandAccess(UserName, "Application Form").ToList();
            List<M_SP_PageandAccess_Result> SummaryPageList = db.M_SP_PageandAccess(UserName, "Reports").ToList();
            List<M_SP_PageandAccess_Result> ForeCastList = db.M_SP_PageandAccess(UserName, "ForeCast").ToList();

            int MasterGoodcount = MasterPageList.Where(x => x.AccessType == true).Count();
            int AFGoodcount = ApplicationFormPageList.Where(x => x.AccessType == true).Count();
            int REGoodcount = SummaryPageList.Where(x => x.AccessType == true).Count();
            int FCGoodcount = ForeCastList.Where(x => x.AccessType == true).Count();
            return Json(new
            {
                MasterPageList = MasterPageList,
                ApplicationFormPageList = ApplicationFormPageList,
                SummaryPageList = SummaryPageList,
                ForeCastList = ForeCastList,
                GoodCount = MasterGoodcount+AFGoodcount+REGoodcount+ FCGoodcount
            }, JsonRequestBehavior.AllowGet);
        }
        public ActionResult UpdatePageAccess(List<PA_Users> PA_userpage)
        {
           
            foreach (PA_Users u in PA_userpage)
            {
                db.M_PA_UserDuplicateRemover(u.UserName);
                PA_Users userp = new PA_Users();
                userp = (from c in db.PA_Users where c.PageID == u.PageID && c.UserName == u.UserName select c).FirstOrDefault();
                if (userp != null)
                {
                    userp.PageAccess = u.PageAccess;
                    db.Entry(userp).State = EntityState.Modified;
                    db.SaveChanges();
                }
                else
                {
                    userp = new PA_Users();
                    userp.UserName = u.UserName;
                    userp.PageID = u.PageID;
                    userp.PageAccess = u.PageAccess;
                    db.PA_Users.Add(userp);
                    db.SaveChanges();
                }
            }

            LoginController a = new LoginController();
            a.RefreshPageAccess(PA_userpage[0].UserName);
            return Json(new { msg = "Success" }, JsonRequestBehavior.AllowGet);
        }
        public ActionResult GetSectionAccess(string UserName)
        {
            List<M_SP_SectionAccess_Result> SectionList = db.M_SP_SectionAccess(UserName).ToList();
            return Json(new
            {
                SectionList = SectionList,
            }, JsonRequestBehavior.AllowGet);
        }
        public ActionResult UpdateSectionAccess(List<PA_Section> PA_section)
        {

            foreach (PA_Section u in PA_section)
            {
                PA_Section section = new PA_Section();
                section = (from c in db.PA_Section where c.SectionID == u.SectionID && c.UserName == u.UserName select c).FirstOrDefault();
                if (section != null)
                {
                    section.SectionAccess = u.SectionAccess;
                    db.Entry(section).State = EntityState.Modified;
                    db.SaveChanges();
                }
                else
                {
                    section = new PA_Section();
                    section.UserName = u.UserName;
                    section.SectionID = u.SectionID;
                    section.SectionAccess = u.SectionAccess;
                    db.PA_Section.Add(section);
                    db.SaveChanges();
                }
            }
            return Json(new { msg = "Success" }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult GetLineAccess(string UserName, string Section)
        {
            List<M_SP_LineAccess_Result> LineList = new List<M_SP_LineAccess_Result>();
            try
            {
                LineList = db.M_SP_LineAccess(UserName, Section).ToList();
            }
            catch(Exception err)
            {
                Error_Logs error = new Error_Logs();
                error.PageModule = "Master - Users";
                error.ErrorLog = err.Message;
                error.DateLog = DateTime.Now;
                error.Username = user.UserName;
                db.Error_Logs.Add(error);
                db.SaveChanges();
            }
            return Json(new
            {
                LineList = LineList,
            }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult UpdateLineAccess(List<PA_Line> PA_line)
        {

            foreach (PA_Line u in PA_line)
            {
                PA_Line line = new PA_Line();
                line = (from c in db.PA_Line where c.LineID == u.LineID && c.UserName == u.UserName select c).FirstOrDefault();
                if (line != null)
                {
                    line.LineAccess = u.LineAccess;
                    db.Entry(line).State = EntityState.Modified;
                    db.SaveChanges();
                }
                else
                {
                    line = new PA_Line();
                    line.UserName = u.UserName;
                    line.LineID = u.LineID;
                    line.LineAccess = u.LineAccess;
                    db.PA_Line.Add(line);
                    db.SaveChanges();
                }
            }
            return Json(new { msg = "Success" }, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        public ActionResult UploadEmployeePhoto()
        {
            #region Save to Server
            bool isSuccess = false;
            string serverMessage = string.Empty;
            var fileOne = Request.Files[0] as HttpPostedFileBase;
            string uploadPath = Server.MapPath(@"~/PictureResources/UsersPhoto/");
            string newFileOne = Path.Combine(uploadPath, fileOne.FileName);
            //fileOne.SaveAs(newFileOne);
            //fileOne.SaveAs(HttpContext.Server.MapPath("~/PictureResources/UsersPhoto/") + Path.GetFileName(fileOne.FileName));
            fileOne.SaveAs(HttpContext.Server.MapPath("~/PictureResources/UsersPhoto/") + Path.GetFileName(Regex.Replace(fileOne.FileName, @"\s+", "")));


            #endregion

            #region ImageSet
            M_Users pack = (from c in db.M_Users where c.UserName == user.UserName select c).FirstOrDefault();
            string[] data = fileOne.FileName.Split('\\');
            //pack.UserPhoto = data[data.Length - 1];//fileOne.FileName;
            pack.UserPhoto = Regex.Replace(data[data.Length - 1], @"\s+", "");//fileOne.FileName;

            db.Entry(pack).State = EntityState.Modified;
            db.SaveChanges();

            #endregion

            M_Users check = (from c in db.M_Users where c.UserName == user.UserName select c).FirstOrDefault();
            System.Web.HttpContext.Current.Session["user"] = check;

            return Json(new { wew = "" }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult UploadPageAccess()
        {
            try
            {
                var postedFile = Request.Files[0] as HttpPostedFileBase;
                string filePath = string.Empty;
                if (postedFile != null)
                {
                    string path = Server.MapPath("~/Uploads/");
                    if (!Directory.Exists(path))
                    {
                        Directory.CreateDirectory(path);
                    }
                    filePath = path + Path.GetFileName(postedFile.FileName);
                    string extension = Path.GetExtension(postedFile.FileName);
                    postedFile.SaveAs(filePath);
                    string conString = string.Empty;
                    switch (extension.ToLower())
                    {
                        case ".xls": //Excel 97-03.
                            conString = ConfigurationManager.ConnectionStrings["Excel03ConString"].ConnectionString;
                            break;
                        case ".xlsx": //Excel 07 and above.
                            conString = ConfigurationManager.ConnectionStrings["Excel07ConString"].ConnectionString;
                            break;
                    }
                    conString = string.Format(conString, filePath);

                    using (OleDbConnection connExcel = new OleDbConnection(conString))
                    {
                        using (OleDbCommand cmdExcel = new OleDbCommand())
                        {
                            using (OleDbDataAdapter odaExcel = new OleDbDataAdapter())
                            {
                                DataTable dt = new DataTable();
                                cmdExcel.Connection = connExcel;
                                string sheetName = "Modules";
                                try
                                {
                                    connExcel.Open();
                                }
                                catch (Exception err)
                                {
                                    Error_Logs error = new Error_Logs();
                                    error.PageModule = "Master - Users";
                                    error.ErrorLog = err.Message;
                                    error.DateLog = DateTime.Now;
                                    error.Username = user.UserName;
                                    db.Error_Logs.Add(error);
                                    db.SaveChanges();
                                }

                                string qry = "SELECT EmployeeNo," +
                                             "Employee," +
                                             "TimeKeepingFormat," +
                                             "SectionApprover," +
                                             "CostCenter," +
                                             "LineTeam," +
                                             "Schedule," +
                                             "Users," +
                                             "ErrorLogs," +
                                             "OTForm," +
                                             "OTFormRequest," +
                                             "ChangeScheduleForm," +
                                             "ChangeScheduleRequest," +
                                             "DTRCorrection," +
                                             "DTRCorrectionRequest," +
                                             "OTSummary," +
                                             "ChangeScheduleSummary," +
                                             "DTRSummary," +
                                             "ManPowerSkills," +
                                             "WorkTimeSummary," +
                                             "Forecast,"+
                                             "ForecastSetting";

                                cmdExcel.CommandText = qry + " FROM [" + sheetName + "$]";//ung * is column name, ung sheetname ay settings
                                odaExcel.SelectCommand = cmdExcel;
                                odaExcel.Fill(dt);
                                connExcel.Close();
                                for (int x = 0; x < dt.Rows.Count; x++)
                                {
                                    List<bool> result = new List<bool>();
                                    try
                                    {
                                        string EmployeeNo = dt.Rows[x]["EmployeeNo"].ToString();
                                        bool Employee = (dt.Rows[x]["Employee"].ToString() == "1")?true:false; result.Add(Employee);
                                        bool TimeKeepingFormat = (dt.Rows[x]["TimeKeepingFormat"].ToString() == "1") ? true : false; result.Add(TimeKeepingFormat);
                                        bool SectionApprover = (dt.Rows[x]["SectionApprover"].ToString() == "1") ? true : false; result.Add(SectionApprover);
                                        bool CostCenter = (dt.Rows[x]["CostCenter"].ToString() == "1") ? true : false; result.Add(CostCenter);
                                        bool LineTeam = (dt.Rows[x]["LineTeam"].ToString() == "1") ? true : false; result.Add(LineTeam);
                                        bool Schedule = (dt.Rows[x]["Schedule"].ToString() == "1") ? true : false; result.Add(Schedule);
                                        bool Users = (dt.Rows[x]["Users"].ToString() == "1") ? true : false; result.Add(Users);
                                        bool ErrorLogs = (dt.Rows[x]["ErrorLogs"].ToString() == "1") ? true : false; result.Add(ErrorLogs);
                                        bool OTForm = (dt.Rows[x]["OTForm"].ToString() == "1") ? true : false; result.Add(OTForm);
                                        bool OTFormRequest = (dt.Rows[x]["OTFormRequest"].ToString() == "1") ? true : false; result.Add(OTFormRequest);
                                        bool ChangeScheduleForm = (dt.Rows[x]["ChangeScheduleForm"].ToString() == "1") ? true : false; result.Add(ChangeScheduleForm);
                                        bool ChangeScheduleRequest = (dt.Rows[x]["ChangeScheduleRequest"].ToString() == "1") ? true : false; result.Add(ChangeScheduleRequest);
                                        bool DTRCorrection = (dt.Rows[x]["DTRCorrection"].ToString() == "1") ? true : false; result.Add(DTRCorrection);
                                        bool DTRCorrectionRequest = (dt.Rows[x]["DTRCorrectionRequest"].ToString() == "1") ? true : false; result.Add(DTRCorrectionRequest);
                                        bool OTSummary = (dt.Rows[x]["OTSummary"].ToString() == "1") ? true : false; result.Add(OTSummary);
                                        bool ChangeScheduleSummary = (dt.Rows[x]["ChangeScheduleSummary"].ToString() == "1") ? true : false; result.Add(ChangeScheduleSummary);
                                        bool DTRSummary = (dt.Rows[x]["DTRSummary"].ToString() == "1") ? true : false; result.Add(DTRSummary);
                                        bool ManPowerSkills = (dt.Rows[x]["ManPowerSkills"].ToString() == "1") ? true : false; result.Add(ManPowerSkills);
                                        bool WorkTimeSummary = (dt.Rows[x]["WorkTimeSummary"].ToString() == "1") ? true : false; result.Add(WorkTimeSummary);
                                        bool Forecast = (dt.Rows[x]["Forecast"].ToString() == "1") ? true : false; result.Add(Forecast);
                                        bool ForecastSetting = (dt.Rows[x]["ForecastSetting"].ToString() == "1") ? true : false; result.Add(ForecastSetting);


                                        string[] Pages = {  "Employee",
                                                            "FormatorTemplate",
                                                            "Section",
                                                            "CostCenter",
                                                            "Process",
                                                            "Schedule",
                                                            "Users",
                                                            "ErrorLogs",
                                                            "OT",
                                                            "Approval_OT",
                                                            "ChangeSchedule",
                                                            "ApproverChangeSchedule",
                                                            "DTR",
                                                            "ApproverDTR",
                                                            "OTSummary",
                                                            "ChangeScheduleSummary",
                                                            "DTRSummary",
                                                            "MPCertificate",
                                                            "WorkTimeSummary",
                                                            "Forecast",
                                                            "ForecastSetting"

                                                          };
                                        for (int y = 0; y < 20; y++)
                                        {
                                            string currentpage = Pages[y];
                                            long pageid = (from c in db.PA_Pages where c.PageIndex == currentpage select c.ID).FirstOrDefault();
                                            PA_Users employee = (from c in db.PA_Users
                                                                 where c.UserName == EmployeeNo
                                                                 && c.PageID == pageid
                                                                 select c).FirstOrDefault();
                                            employee.PageAccess = result[y];
                                            db.Entry(employee).State = EntityState.Modified;
                                            db.SaveChanges();
                                        }
                                    }
                                    catch (Exception err)
                                    {
                                        Error_Logs error = new Error_Logs();
                                        error.PageModule = "Master - Employee";
                                        error.ErrorLog = err.Message;
                                        error.DateLog = DateTime.Now;
                                        error.Username = user.UserName;
                                        db.Error_Logs.Add(error);
                                        db.SaveChanges();

                                    }

                                }
                            }
                        }
                    }
                }
            }
            catch (Exception err)
            {
                Error_Logs error = new Error_Logs();
                error.PageModule = "Master - Employee";
                error.ErrorLog = err.Message;
                error.DateLog = DateTime.Now;
                error.Username = user.UserName;
                db.Error_Logs.Add(error);
                db.SaveChanges();
                return Json(new { result = "failed" }, JsonRequestBehavior.AllowGet);
            }
            LoginController a = new LoginController();
            a.RefreshPageAccess(user.UserName);
            return Json(new { result = "success" }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult ExportUsers(string Section)
        {
            try
            {
                string searchnow = System.Web.HttpContext.Current.Session["SearchvalueUser"].ToString();

                Section = (Section == "undefined") ? user.Section : Section;
                string templateFilename = "PageAccessTemplate.xlsx";
                string dir = Path.GetTempPath();
                string datetimeToday = DateTime.Now.ToString("yyMMddhhmmss");
                string filename = string.Format("PageAccessTemplate{0}_{1}.xlsx", datetimeToday, Section);
                FileInfo newFile = new FileInfo(Path.Combine(dir, filename));
                string apptemplatePath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, @"TemplateFiles\", templateFilename);
                FileInfo templateFile = new FileInfo(apptemplatePath);

                using (ExcelPackage package = new ExcelPackage(newFile, templateFile))  //-- With template.
                {

                    //List<M_Users> list = (from c in db.M_Users select c).ToList();
                   
                    List<GET_UserDetails_Result> list = db.GET_UserDetails(user.CostCode).Where(x => x.UserName.ToLower().Contains("biph") && x.Status.ToLower() == "active").ToList();
                    ExcelWorksheet ExportData = package.Workbook.Worksheets["Modules"];
                    int start = 2;
                    if (!string.IsNullOrEmpty(searchnow))//filter
                    {
                        #region null remover
                        list = list.Where(xx => xx.UserName != null).ToList();
                        list = list.Where(xx => xx.FirstName != null).ToList();
                        list = list.Where(xx => xx.LastName != null).ToList();
                        #endregion
                        list = list.Where(x => x.FirstName.ToLower().Contains(searchnow.ToLower())
                        || x.LastName.ToLower().Contains(searchnow.ToLower())
                        || x.UserName.Contains(searchnow)
                        ).ToList<GET_UserDetails_Result>();
                        list = list.Where(x => x.Section == Section).ToList();

                    }
                    else
                    {
                        list = db.GET_UserDetails(user.CostCode).ToList();//(from c in db.M_Users where c.Section == Section select c).ToList();
                    }
                    for (int i = 0; i < list.Count; i++)
                    {
                        ExportData.Cells["A" + start].Value = list[i].UserName;
                        ExportData.Cells["B" + start].Value = list[i].FirstName + ", " + list[i].LastName;
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