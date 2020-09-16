using Brothers_WMS.Models;
using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Web;
using System.Web.Mvc;
using System.Web.Security;

namespace Brothers_WMS.Controllers
{
    public class LoginController : Controller
    {
        // GET: Login
        Brothers_AMSDBEntities db = new Brothers_AMSDBEntities();
        M_Users user = (M_Users)System.Web.HttpContext.Current.Session["user"];

        public ActionResult Login()
        {
            return View();
        }

        private string dec2Hex(long val)
        {
            return Convert.ToString(val, 16);
        }
        private double hex2Dec(string strHex)
        {
            return Convert.ToInt16(strHex, 16);
        }
        public ActionResult GetEmployeeNo(double RFID)
        {
            try
            {
                string SourceValue = dec2Hex(Convert.ToInt64(RFID));
                string Hexvalue = SourceValue.Substring(SourceValue.Length - 4);
                string Prefix = SourceValue.Remove(SourceValue.Length - 4).ToUpper();
                string THERFID = hex2Dec(Hexvalue).ToString();
                M_Employee_Master_List emp = (from c in db.M_Employee_Master_List
                                              where c.RFID == THERFID
                                              select c).FirstOrDefault();

                return Json(new { empno = emp.EmpNo }, JsonRequestBehavior.AllowGet);
            }
            catch(Exception err)
            {
                return Json(new { empno = "" }, JsonRequestBehavior.AllowGet);
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

        public class UsersLog
        {
            public string UserName { get; set; }
            public string Password { get; set; }
            public bool Rememberme { get; set; }
        }

        public ActionResult Authenticate(UsersLog user)
        {
            string result = "";
            db.Database.CommandTimeout = 0;
            try
            {
                string pass = EncodePasswordMd5(user.Password);
                M_Users check = (from c in db.M_Users
                                 where c.UserName == user.UserName 
                                 && c.Password == pass
                                 && c.IsDeleted == false
                                 select c).FirstOrDefault();
                check.Section = (from c in db.M_Cost_Center_List where c.Cost_Center == check.CostCode select c.GroupSection).FirstOrDefault();
                check.CostCode = (from c in db.M_Employee_CostCenter where c.EmployNo == user.UserName orderby c.UpdateDate_AMS descending select c.CostCenter_AMS).FirstOrDefault();
                if (check != null)
                {
                    bool rememberme = false;
                    if (user.Rememberme)
                    {
                        rememberme = true;
                    }
                    
                    string emailtemplatepath = Server.MapPath(@"~/Content/EmailForm/OTEmail.html");
                    System.Web.HttpContext.Current.Session["emailpath"] = emailtemplatepath;
                    System.Web.HttpContext.Current.Session["UserName"] = check.FirstName + ' ' + check.LastName;
                    System.Web.HttpContext.Current.Session["user"] = check;
                    FormsAuthentication.SetAuthCookie(user.UserName, true);
                    FormsAuthenticationTicket authTicket = new FormsAuthenticationTicket(
                             1,
                             user.UserName,
                             DateTime.Now,
                             DateTime.Now.AddMinutes(FormsAuthentication.Timeout.TotalMinutes),
                             rememberme,
                             user.ToString());

                    RefreshPageAccess(check.UserName, check.Section);

                 
                    List<CostCenterM> newCostCode = (from c in db.M_Cost_Center_List where c.GroupSection == "" || c.GroupSection == null
                                                     select new CostCenterM {
                                                         CostCodenew = c.Cost_Center,
                                                         CostCodenewname = c.Section
                                                     }).ToList();
                    System.Web.HttpContext.Current.Session["newCostCode"] = newCostCode;

                }
                result = (check == null) ? "Failed" : "Success";
                if (result == "Failed")
                {
                    //Error_Logs error = new Error_Logs();
                    //error.PageModule = "Login";
                    //error.ErrorLog = "Incorrect Username or Password";
                    //error.DateLog = db.TT_GETTIME().FirstOrDefault();//DateTime.Now;;
                    //error.Username = user.UserName;
                    //db.Error_Logs.Add(error);
                    //db.SaveChanges();
                }

                string urlmail = (Session["urlmail"] != null) ? Session["urlmail"].ToString() : "/";
                return Json(new { result = result, urlmail = urlmail }, JsonRequestBehavior.AllowGet);
            }
            catch(Exception err)
            {
                Error_Logs error = new Error_Logs();
                error.PageModule = "Login";
                error.ErrorLog = err.Message;
                error.DateLog = db.TT_GETTIME().FirstOrDefault();//DateTime.Now;;
                error.Username = user.UserName;
                db.Error_Logs.Add(error);
                 db.SaveChanges();
                return Json(new { result = result, urlmail = "" }, JsonRequestBehavior.AllowGet);

            }
        }

        public void RefreshPageAccess(string UserName, string Section)
        {
            #region For Page Access
            M_Users userchosen = (from c in db.M_Users where c.UserName == UserName select c).FirstOrDefault();

            //if (userchosen.Section == "Production Engineering")
            //{
            //    MasterPageList = db.M_SP_PageandAccess(UserName, "Master").Where(x => x.AccessType == true).ToList(); ;
            //}
            //else
            //{
            //    MasterPageList = db.M_SP_PageandAccess(UserName, "Master").Where(x => x.PageIndex != "CostCenter" && x.PageIndex != "FormatorTemplate" && x.PageIndex != "Section" && x.AccessType == true).ToList();

            //}
            List<M_SP_PageandAccess_Result> MasterPageList = db.M_SP_PageandAccess(UserName, "Master").Where(x => x.AccessType == true).ToList();
            List<M_SP_PageandAccess_Result> ApplicationFormPageList = db.M_SP_PageandAccess(UserName, "Application Form").Where(x => x.AccessType == true).ToList();
            List<M_SP_PageandAccess_Result> SummaryPageList = db.M_SP_PageandAccess(UserName, "Reports").Where(x=>x.AccessType == true).ToList();
            List<M_SP_PageandAccess_Result> ForeCastList = db.M_SP_PageandAccess(UserName, "ForeCast").Where(x => x.AccessType == true).ToList();


            #region FORCE REMOVE Form to super user
            if(Section == null || Section == "")
            {
                ApplicationFormPageList = ApplicationFormPageList.Where(x => x.PageIndex != "OT" && x.PageIndex != "ChangeSchedule" && x.PageIndex != "DTR").ToList();
            }
            #endregion

            System.Web.HttpContext.Current.Session["MasterPageList"] = MasterPageList;
            System.Web.HttpContext.Current.Session["ApplicationFormPageList"] = ApplicationFormPageList;
            System.Web.HttpContext.Current.Session["SummaryPageList"] = SummaryPageList;
            System.Web.HttpContext.Current.Session["ForeCastList"] = ForeCastList;
            #endregion
        }

        public ActionResult LogOff()
        {
            System.Web.HttpContext.Current.Response.AddHeader("Cache-Control", "no-cache, no-store, must-revalidate");
            System.Web.HttpContext.Current.Response.AddHeader("Pragma", "no-cache");
            System.Web.HttpContext.Current.Response.AddHeader("Expires", "0");
            Session.Clear();
            Session.Abandon();
            Session.RemoveAll();
            FormsAuthentication.SignOut();
            return Json(new { result = "Out" }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult Changepass(ChangePasswordModel pass)
        {
            string result = "Success";
            if (user.Password == EncodePasswordMd5(pass.currentpass))
            {
                user.Password = EncodePasswordMd5(pass.newpassword);
                db.Entry(user).State = EntityState.Modified;
                db.SaveChanges();
            }
            else
            {
                result = "Failed";
            }

            return Json(new {result= result }, JsonRequestBehavior.AllowGet);
        }
    }
}