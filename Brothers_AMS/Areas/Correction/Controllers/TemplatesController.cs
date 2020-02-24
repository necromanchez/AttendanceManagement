using Brothers_WMS.Controllers;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace Brothers_WMS.Areas.Correction.Controllers
{
    [SessionExpire]
    public class TemplatesController : Controller
    {
        // GET: Correction/Templates
        public ActionResult Templates()
        {
            return View();
        }

        public void DownloadTemplate(string filename)
        {
            string[] type = filename.Split('.');
            string[] IEName = filename.Split('\\');
            string realname = IEName[IEName.Length - 1];
            string fpath;
            fpath = Server.MapPath("~/TemplateFiles/" + realname);
            FileStream fs = new FileStream(fpath, FileMode.Open, FileAccess.Read);
            byte[] content = new byte[fs.Length];
            fs.Read(content, 0, (int)fs.Length);
            fs.Close();
            Response.Buffer = true;
            Response.ClearContent();
            Response.ClearHeaders();

            switch (type[type.Length - 1].ToUpper())
            {
                case "GIF":
                    Response.AddHeader("ContentType", "image/gif");
                    break;
                case "PNG":
                    Response.AddHeader("ContentType", "image/png");
                    break;
                case "PDF":
                    Response.AddHeader("ContentType", "application/pdf");
                    break;
                case "PPTX":
                    Response.AddHeader("ContentType", "application/vnd.openxmlformats-officedocument.presentationml.presentation");
                    break;
                case "XLSX":
                    Response.AddHeader("ContentType", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
                    break;
                case "DOCX":
                    Response.AddHeader("ContentType", "application/vnd.openxmlformats-officedocument.wordprocessingml.document");
                    break;
                case "DOC":
                    Response.AddHeader("ContentType", "application/msword");
                    break;
                case "PPT":
                    Response.AddHeader("ContentType", "application/vnd.ms-powerpoint");
                    break;
                case "JPG":
                    Response.AddHeader("ContentType", "image/jpeg");
                    break;
                case "JPEG":
                    Response.AddHeader("ContentType", "image/jpeg");
                    break;
                case "XLS":
                    Response.AddHeader("ContentType", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
                    break;

            }

            Response.AddHeader("Content-Disposition", "attachment;filename=" + realname);
            Response.TransmitFile(Server.MapPath("~/TemplateFiles/" + realname));
            Response.End();
        }

    }
}