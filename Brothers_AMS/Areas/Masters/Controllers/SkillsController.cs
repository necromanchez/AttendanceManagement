using Brothers_WMS.Controllers;
using Brothers_WMS.Models;
using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.IO;
using System.Linq;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.Mvc;
using static Brothers_WMS.Controllers.SessionExpire;

namespace Brothers_WMS.Areas.Masters.Controllers
{
    [SessionExpire]
    public class SkillsController : Controller
    {
        // GET: Masters/Skills
        Brothers_AMSDBEntities db = new Brothers_AMSDBEntities();
        M_Users user = (M_Users)System.Web.HttpContext.Current.Session["user"];
        public ActionResult Skills()
        {
            return View();
        }

        public ActionResult GetSkillsList(long LineID)
        {
            //Server Side Parameter
            int start = Convert.ToInt32(Request["start"]);
            int length = Convert.ToInt32(Request["length"]);
            string searchValue = Request["search[value]"];
            string sortColumnName = Request["columns[" + Request["order[0][column]"] + "][name]"];
            string sortDirection = Request["order[0][dir]"];

            List<SkillsModel> list = new List<SkillsModel>();
            list = (from c in db.M_Skills
                    where c.IsDeleted == false && c.Line == LineID
                    select new SkillsModel
                    {
                        ID = c.ID,
                        LineID = c.Line,
                        Line = (from lin in db.M_LineTeam where lin.ID == c.Line select lin.Line).FirstOrDefault(),
                        Skill = c.Skill,
                        Count = c.Count,
                        //Status = c.Status,
                        Logo = c.SkillLogo
                    }).ToList();

            if (!string.IsNullOrEmpty(searchValue))//filter
            {
                list = list.Where(x => x.Skill.ToLower().Contains(searchValue.ToLower())).ToList<SkillsModel>();
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
            list = list.Skip(start).Take(length).ToList<SkillsModel>();
            return Json(new { data = list, draw = Request["draw"], recordsTotal = totalrows, recordsFiltered = totalrowsafterfiltering }, JsonRequestBehavior.AllowGet);
        }
        public ActionResult CreateSkills(M_Skills data)
        {
            try
            {
                
                data.CreateID = user.UserName;
                data.CreateDate = DateTime.Now;
                data.UpdateID = user.UserName;
                data.UpdateDate = DateTime.Now;
                data.IsDeleted = false;
                //data.Status = true;
                M_Skills checker = (from c in db.M_Skills
                                      where c.Skill == data.Skill
                                      && c.Line == data.Line
                                      //&& c.Status == data.Status
                                      && c.IsDeleted == false
                                      select c).FirstOrDefault();
                if (checker == null)
                {
                    db.M_Skills.Add(data);
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
                error.PageModule = "Master - Skills";
                error.ErrorLog = err.Message;
                error.DateLog = DateTime.Now;
                error.Username = user.UserName;
                db.Error_Logs.Add(error);
                db.SaveChanges();
                return Json(new { msg = err.Message }, JsonRequestBehavior.AllowGet);
            }
        }
        public ActionResult DeleteSkills(int ID)
        {
            M_Skills skill = new M_Skills();
            skill = (from u in db.M_Skills.ToList()
                        where u.ID == ID
                        select u).FirstOrDefault();
            skill.IsDeleted = true;
            skill.UpdateDate = DateTime.Now;
            skill.UpdateID = user.UserName;
            db.Entry(skill).State = EntityState.Modified;
            db.SaveChanges();
            return Json(new { msg = "Success" }, JsonRequestBehavior.AllowGet);
        }
        public ActionResult EditSkills(M_Skills data)
        {
            try
            {
                M_Skills skill = new M_Skills();
                skill = (from u in db.M_Skills.ToList()
                            where u.ID == data.ID
                            select u).FirstOrDefault();
                skill.Skill = data.Skill;
                skill.Count = data.Count;
                //skill.Status = data.Status;

                skill.UpdateID = user.UserName;
                skill.UpdateDate = DateTime.Now;

                M_Skills checker = (from c in db.M_Skills
                                      where c.Skill == data.Skill
                                      && c.Line == data.Line
                                      && c.Count == data.Count
                                      //&& c.Status == data.Status
                                      && c.IsDeleted == false
                                      select c).FirstOrDefault();
                if (checker == null)
                {
                    db.Entry(skill).State = EntityState.Modified;
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
                error.PageModule = "Master - Skills";
                error.ErrorLog = err.Message;
                error.DateLog = DateTime.Now;
                error.Username = user.UserName;
                db.Error_Logs.Add(error);
                db.SaveChanges();
            }

            return Json(new { msg = "Success" }, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        public ActionResult UploadImageLogo(int SkillID)
        {
            try
            {
                #region Save to Server
                //bool isSuccess = false;
                //string serverMessage = string.Empty;
                //var fileOne = Request.Files[0] as HttpPostedFileBase;
                //string uploadPath = Server.MapPath(@"~/PictureResources/ProcessLogo/");
                //string newFileOne = Path.Combine(uploadPath, fileOne.FileName);
                //fileOne.SaveAs(newFileOne);
                #endregion
                #region Save to Server
                bool isSuccess = false;
                string serverMessage = string.Empty;
                var fileOne = Request.Files[0] as HttpPostedFileBase;
                string uploadPath = Server.MapPath(@"~/PictureResources/ProcessLogo/");
                string newFileOne = Path.Combine(uploadPath, fileOne.FileName);
                //fileOne.SaveAs(newFileOne);
                //fileOne.SaveAs(HttpContext.Server.MapPath("~/PictureResources/ProcessLogo/") + Path.GetFileName(fileOne.FileName));
                fileOne.SaveAs(HttpContext.Server.MapPath("~/PictureResources/ProcessLogo/") + Path.GetFileName(Regex.Replace(fileOne.FileName, @"\s+", "")));

                #endregion

                #region ImageSet
                M_Skills pack = (from c in db.M_Skills where c.ID == SkillID select c).FirstOrDefault();
                string[] data = fileOne.FileName.Split('\\');
                //pack.SkillLogo = data[data.Length - 1];//fileOne.FileName;
                pack.SkillLogo = Regex.Replace(data[data.Length - 1], @"\s+", "");//fileOne.FileName;

                db.Entry(pack).State = EntityState.Modified;
                db.SaveChanges();
                #endregion
            }
            catch (Exception err)
            {
                Error_Logs error = new Error_Logs();
                error.PageModule = "Master - Skills";
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