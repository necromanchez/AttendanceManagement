using Brothers_WMS.Controllers;
using Brothers_WMS.Models;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.Entity;
using System.Data.OleDb;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using static Brothers_WMS.Controllers.SessionExpire;

namespace Brothers_WMS.Areas.Masters.Controllers
{
    [SessionExpire]
    public class ProcessController : Controller
    {
        // GET: Masters/Process
        Brothers_AMSDBEntities db = new Brothers_AMSDBEntities();
        M_Users user = (M_Users)System.Web.HttpContext.Current.Session["user"];
        public ActionResult Process()
        {
            db.M_SP_SectionInsert();
            return View();
        }
        public ActionResult GetLineProcessTeamList(string GroupSection)
        {
            //Server Side Parameter
            int start = Convert.ToInt32(Request["start"]);
            int length = Convert.ToInt32(Request["length"]);
            string searchValue = Request["search[value]"];
            string sortColumnName = Request["columns[" + Request["order[0][column]"] + "][name]"];
            string sortDirection = Request["order[0][dir]"];

            string co =(user.CostCode == null)? "" :user.CostCode;

            if (GroupSection != "" && GroupSection != null)
            {
                co = (from c in db.M_Cost_Center_List where c.GroupSection == GroupSection select c.Cost_Center).FirstOrDefault();
            }
            else if(co != null)
            {
                GroupSection = (from c in db.M_Cost_Center_List where c.Cost_Center == co select c.GroupSection).FirstOrDefault();
            }

            List<GET_M_Process_Result> list = db.GET_M_Process(GroupSection).ToList();//List<M_LineTeam> list = new List<M_LineTeam>();

            //list = list.Where(x => x.SectionName != null).ToList();
            if (!string.IsNullOrEmpty(searchValue))//filter
            {
                list = list.Where(x => x.SectionName.ToLower().Contains(searchValue.ToLower())
                || x.Line.ToLower().Contains(searchValue.ToLower())).ToList<GET_M_Process_Result>();
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
            list = list.Skip(start).Take(length).ToList<GET_M_Process_Result>();
            return Json(new { data = list, draw = Request["draw"], recordsTotal = totalrows, recordsFiltered = totalrowsafterfiltering }, JsonRequestBehavior.AllowGet);
        }
        public ActionResult CreateLineProcessTeam(M_LineTeam data)
        {
            try
            {
                data.CreateID = user.UserName;
                data.CreateDate = DateTime.Now;
                data.UpdateID = user.UserName;
                data.UpdateDate = DateTime.Now;

                M_LineTeam checker = (from c in db.M_LineTeam
                                      where c.Section == data.Section
                                      && c.Line == data.Line
                                      && c.Status == data.Status
                                      && c.IsDeleted == false
                                      select c).FirstOrDefault();
                if (checker == null)
                {
                    db.M_LineTeam.Add(data);
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
                error.PageModule = "Master - Process";
                error.ErrorLog = err.Message;
                error.DateLog = DateTime.Now;
                error.Username = user.UserName;
                db.Error_Logs.Add(error);
                db.SaveChanges();
                return Json(new { msg = err.Message }, JsonRequestBehavior.AllowGet);
            }
        }
        public ActionResult DeleteLineProcessTeam(int ID)
        {
            M_LineTeam process = new M_LineTeam();
            process = (from u in db.M_LineTeam.ToList()
                        where u.ID == ID
                        select u).FirstOrDefault();
            process.IsDeleted = true;
            process.UpdateDate = DateTime.Now;
            process.UpdateID = user.UserName;
            db.Entry(process).State = EntityState.Modified;
            db.SaveChanges();
            return Json(new { msg = "Success" }, JsonRequestBehavior.AllowGet);
        }
        public ActionResult EditLineProcessTeam(M_LineTeam data)
        {
            try
            {
                M_LineTeam process = new M_LineTeam();
                process = (from u in db.M_LineTeam.ToList()
                            where u.ID == data.ID
                            select u).FirstOrDefault();
                process.Section = data.Section;
                process.Line = data.Line;
                process.Status = data.Status;

                process.UpdateID = user.UserName;
                process.UpdateDate = DateTime.Now;

                M_LineTeam checker = (from c in db.M_LineTeam
                                      where c.Section == data.Section
                                      && c.Line == data.Line
                                      && c.Status == data.Status
                                      && c.IsDeleted == false
                                      select c).FirstOrDefault();
                if (checker == null)
                {
                    db.Entry(process).State = EntityState.Modified;
                    db.SaveChanges();
                }
                else
                {
                    return Json(new { msg = "Failed" }, JsonRequestBehavior.AllowGet);

                }
            }
            catch (Exception err) {
                Error_Logs error = new Error_Logs();
                error.PageModule = "Master - Process";
                error.ErrorLog = err.Message;
                error.DateLog = DateTime.Now;
                error.Username = user.UserName;
                db.Error_Logs.Add(error);
                db.SaveChanges();
            }

            return Json(new { msg = "Success" }, JsonRequestBehavior.AllowGet);
        }
        public ActionResult UploadSkills(long LineID)
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
                            string sheetName = "Process";
                            try
                            {
                                connExcel.Open();
                           
                                cmdExcel.CommandText = "SELECT Process, IdealManPower FROM [" + sheetName + "$]";//ung * is column name, ung sheetname ay settings
                                odaExcel.SelectCommand = cmdExcel;
                            
                                odaExcel.Fill(dt);
                                connExcel.Close();
                            

                            #region Additional Column
                            DataColumn col_CreateID = new System.Data.DataColumn("CreateID", typeof(System.String));
                            col_CreateID.DefaultValue = user.UserName;
                            dt.Columns.Add(col_CreateID);

                            DataColumn col_CreateDate = new System.Data.DataColumn("CreateDate", typeof(System.DateTime));
                            col_CreateDate.DefaultValue = DateTime.Now;
                            dt.Columns.Add(col_CreateDate);

                            DataColumn col_UpdateID = new System.Data.DataColumn("UpdateID", typeof(System.String));
                            col_UpdateID.DefaultValue = user.UserName;
                            dt.Columns.Add(col_UpdateID);

                            DataColumn col_UpdateDate = new System.Data.DataColumn("UpdateDate", typeof(System.DateTime));
                            col_UpdateDate.DefaultValue = DateTime.Now;
                            dt.Columns.Add(col_UpdateDate);

                            DataColumn Line = new System.Data.DataColumn("Line", typeof(long));
                            Line.DefaultValue = LineID;
                            dt.Columns.Add(Line);

                            DataColumn Status = new System.Data.DataColumn("Status", typeof(bool));
                            Status.DefaultValue = true;
                            dt.Columns.Add(Status);
                           

                            DataColumn IsDeleted = new System.Data.DataColumn("IsDeleted", typeof(bool));
                            IsDeleted.DefaultValue = false;
                            dt.Columns.Add(IsDeleted);
                                #endregion
                            }
                            catch (Exception err)
                            {
                                Error_Logs error = new Error_Logs();
                                error.PageModule = "Master - Process";
                                error.ErrorLog = err.Message;
                                error.DateLog = DateTime.Now;
                                error.Username = user.UserName;
                                db.Error_Logs.Add(error);
                                db.SaveChanges();
                            }

                            try
                            {
                                //string conString2 = ConfigurationManager.ConnectionStrings["Brothers_AMSDB"].ConnectionString;
                                //using (SqlBulkCopy bulk = new SqlBulkCopy(conString2))
                                //{
                                //    bulk.ColumnMappings.Add("Line", "Line");
                                //    bulk.ColumnMappings.Add("Skill", "Skill");
                                //    bulk.ColumnMappings.Add("IdealManPower", "Count");
                                //    bulk.ColumnMappings.Add("IsDeleted", "IsDeleted");
                                //    bulk.ColumnMappings.Add("CreateID", "CreateID");
                                //    bulk.ColumnMappings.Add("CreateDate", "CreateDate");
                                //    bulk.ColumnMappings.Add("UpdateID", "UpdateID");
                                //    bulk.ColumnMappings.Add("UpdateDate", "UpdateDate");
                                //    bulk.DestinationTableName = "M_Skills";
                                //    bulk.WriteToServer(dt);
                                //}
                                for (int x = 0; x < dt.Rows.Count; x++)
                                {
                                    try
                                    {
                                        M_Skills Skilltb = new M_Skills();
                                        Skilltb.Line = LineID;
                                        Skilltb.Skill = dt.Rows[x]["Process"].ToString();
                                        Skilltb.Count = Convert.ToInt32(dt.Rows[x]["IdealManPower"]);
                                        Skilltb.IsDeleted = false;
                                        Skilltb.CreateDate = DateTime.Now;
                                        Skilltb.CreateID = user.UserName;
                                        Skilltb.UpdateDate = DateTime.Now;
                                        Skilltb.UpdateID = user.UserName;

                                        db.M_Skills.Add(Skilltb);
                                        db.SaveChanges();
                                    }
                                    catch (Exception err)
                                    {
                                        Error_Logs error = new Error_Logs();
                                        error.PageModule = "Master - Process";
                                        error.ErrorLog = err.Message;
                                        error.DateLog = DateTime.Now;
                                        error.Username = user.UserName;
                                        db.Error_Logs.Add(error);
                                        db.SaveChanges();
                                    }
                                }



                                    db.M_SP_Skillduplicateremover(LineID);
                            }
                            catch (Exception err)
                            {
                                Error_Logs error = new Error_Logs();
                                error.PageModule = "Master - Process";
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

            return Json(new { }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult GetLineName(long ID)
        {
            string linename = (from c in db.M_LineTeam where c.ID == ID select c.Line).FirstOrDefault();
            return Json(new { linename = linename });
        }
    }
}