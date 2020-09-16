using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Mail;
using System.Web;
using System.Web.Mvc;
using System.Net;
using System.IO;
using System.Text;
using System.Configuration;
using Brothers_WMS.Models;

namespace Brothers_WMS.Controllers
{
    [SessionExpire]
    public class EmailApproverController : Controller
    {
        // GET: EmailApprover
        Brothers_AMSDBEntities db = new Brothers_AMSDBEntities();

        public ActionResult EmailApprover()
        {

            return View();
        }
        
        private SmtpClient smtpClient;

        public void sendMail(string subject, List<M_Section_Approver> Approver, string RefNo, string Directory)
        {

            try
            {
                #region BIPH
                MailMessage mail = new MailMessage("wms@brother-biph.com.ph", "ce.ragas@seiko-it.com.ph");
                SmtpClient client = new SmtpClient();
                client.Port = 25;
                client.DeliveryMethod = SmtpDeliveryMethod.Network;
                client.UseDefaultCredentials = false;
                client.Host = "10.113.10.1";
                mail.Subject = "Brother User Reset Password";
                string msg = "Hi " + "Test User" + "!<br /><br />";
                msg = msg + "Your account has been locked due to 3 failed attempts, kindly change your password after your login. <br /><br />";
                msg = msg + " Username: " + "Test User" + "<br />";
                msg = msg + " Reset Login Password: " + "Test pass";
                String vhtml = String.Empty;
                //StreamReader reader = new StreamReader(Server.MapPath("/Template/email.html"));
                //vhtml = reader.ReadToEnd();
                //vhtml = vhtml.Replace("{{{body}}}", msg);
                mail.IsBodyHtml = true;
                mail.Body = vhtml;
                client.Send(mail);
                #endregion
            }
            catch(Exception err)
            {
                Error_Logs error = new Error_Logs();
                error.PageModule = "Mail";
                error.ErrorLog = err.Message;
                error.DateLog = db.TT_GETTIME().FirstOrDefault();//DateTime.Now;;
                error.Username = "Test";
                db.Error_Logs.Add(error);
                db.SaveChanges();
            }
        }

        public void sendMailOrig(string subject, List<M_Section_Approver> Approver, string RefNo, string Directory)
        {
            
                this.smtpClient = new SmtpClient();
                this.smtpClient.EnableSsl = true; //true;                        //-- SET TO FALSE IF DEPLOYED IN BIPH PRODUCTION
                this.smtpClient.UseDefaultCredentials = false;
                this.smtpClient.DeliveryMethod = SmtpDeliveryMethod.Network;            //-- COMMENT THIS LINE IF DEPLOYED IN BIPH PRODUCTION
            this.smtpClient.Host = "smtp.gmail.com";//"mail2.seiko-it.com.ph";
                this.smtpClient.Port = 587;
                this.smtpClient.Credentials = new NetworkCredential("chestertest27@gmail.com", "Chestertest0227");//new NetworkCredential("dbsvr@seiko-it.com.ph", "logmein@dbsvr");
                this.smtpClient.UseDefaultCredentials = true;
                MailMessage mail = new MailMessage();
                string msg = string.Empty;

                #region HTML Email          
                var fileStream = new FileStream(@""+ Directory, FileMode.Open, FileAccess.Read);

                using (var streamReader = new StreamReader(fileStream, Encoding.UTF8))
                {
                    msg += streamReader.ReadToEnd();
                }
                string status = (subject.Contains("Alternative")) ? "alter" : "norm";
                msg = msg.Replace("localhosthere", "http://localhost:9090/Correction/Approval_OT/Approval_OT?RNO="+ RefNo + "&status="+ status);

            #endregion
            /* RECIPIENT */
            //mail.To.Add(recipient);
                foreach (M_Section_Approver item in Approver)
                {
                    string email = (from c in db.M_Users where c.UserName == item.EmployeeNo select c.Email).FirstOrDefault();
                    mail.To.Add(email);
                }
                mail.From = new MailAddress("chestertest27@gmail.com");
                mail.Subject = subject;
                mail.IsBodyHtml = true;
                mail.Body = msg;

            using (SmtpClient smtp = new SmtpClient("smtp.gmail.com", 587))
            {
                smtp.Credentials = new NetworkCredential("chestertest27@gmail.com", "Chestertest0227");
                smtp.EnableSsl = true;
                smtp.Send(mail);
            }

            //-- ACCEPTS ALL CERTIFICATES
            //-- COMMENT THIS LINE IF DEPLOYED IN BIPH PRODUCTION
            //ServicePointManager.ServerCertificateValidationCallback = new RemoteCertificateValidationCallback(ValidateServerCertificate);
            //try
            //{
            //    this.smtpClient.Send(mail);
            //}
            //catch(Exception err) { }
            //FOR Brothers2
            



        }
    }
}