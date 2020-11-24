using Brothers_WMS.Controllers;
using Brothers_WMS.Models;
using OfficeOpenXml;
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
    public class EmployeeController : Controller
    {
        Brothers_AMSDBEntities db = new Brothers_AMSDBEntities();
        M_Users user = (M_Users)System.Web.HttpContext.Current.Session["user"];

        // GET: Masters/Employee
        public ActionResult Employee()
        {
            //db.M_SP_ImportEmployeeStatus();

            List<GET_DuplicateRFID_Result> dup = db.GET_DuplicateRFID().ToList();

            System.Web.HttpContext.Current.Session["DupRFID"] = dup;

            return View();
        }

        public ActionResult GetDuplicateRFIDList()
        {
            //Server Side Parameter
            int start = Convert.ToInt32(Request["start"]);
            int length = Convert.ToInt32(Request["length"]);
            string searchValue = Request["search[value]"];
            string sortColumnName = Request["columns[" + Request["order[0][column]"] + "][name]"];
            string sortDirection = Request["order[0][dir]"];
            List<GET_DuplicateRFID_Result> list = (List<GET_DuplicateRFID_Result>)System.Web.HttpContext.Current.Session["DupRFID"];
            if (!string.IsNullOrEmpty(searchValue))//filter
            {
                #region null remover
                list = list.Where(xx => xx.EmpNo != null).ToList();
                list = list.Where(xx => xx.RFID != null).ToList();
                list = list.Where(xx => xx.EmployeeName != null).ToList();
                list = list.Where(xx => xx.CostCode != null).ToList();
                list = list.Where(xx => xx.Section != null).ToList();
                #endregion
                list = list.Where(x => x.RFID.ToLower().Contains(searchValue.ToLower())
                                   || x.EmpNo.ToLower().Contains(searchValue.ToLower())
                                   || x.EmployeeName.ToLower().Contains(searchValue.ToLower())
                                   || x.CostCode.ToLower().Contains(searchValue.ToLower())
                                   || x.Section.ToLower().Contains(searchValue.ToLower())

                ).ToList<GET_DuplicateRFID_Result>();

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
            list = list.Skip(start).Take(length).ToList<GET_DuplicateRFID_Result>();
            // return Json(new { data = list, draw = Request["draw"], recordsTotal = totalrows, recordsFiltered = totalrowsafterfiltering }, JsonRequestBehavior.AllowGet);
            var jsonResult = Json(new { data = list, draw = Request["draw"], recordsTotal = totalrows, recordsFiltered = totalrowsafterfiltering }, JsonRequestBehavior.AllowGet);
            jsonResult.MaxJsonLength = int.MaxValue;
            return jsonResult;

        }

        public ActionResult GetEmployee_StatusProcessShift(string Section)
        {
            Section = (Section == null) ? (from c in db.M_Cost_Center_List where c.Cost_Center == user.CostCode select c.GroupSection).FirstOrDefault() : Section;
            GET_EmployeeShift_Process_Result EmployeeCount = db.GET_EmployeeShift_Process(Section).FirstOrDefault();
            return Json(new { EmployeeCount= EmployeeCount }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult SyncIT()
        {
            try
            {
                db.M_SP_ImportEmployeeFromITSystem();
                db.M_SP_ImportEmployeeFromITSystem_forMaintenance(user.UserName);
                return Json(new { msg = "Success" }, JsonRequestBehavior.AllowGet);
            }
            catch (Exception err)
            {
                Error_Logs error = new Error_Logs();
                error.PageModule = "Master - Employee";
                error.ErrorLog = err.InnerException.Message;
                error.DateLog = DateTime.Now;
                error.Username = user.UserName;
                db.Error_Logs.Add(error);
                db.SaveChanges();
                return Json(new { msg = "Failed" }, JsonRequestBehavior.AllowGet);
            }
        }
        public ActionResult GetEmployeeList(string supersection, string Status, string MStatus)

        {
            System.Web.HttpContext.Current.Session["Searchvaluenow"] = Request["search[value]"];

            //Server Side Parameter
            int start = (Convert.ToInt32(Request["start"]) == 0) ? 0 : (Convert.ToInt32(Request["start"]) / Convert.ToInt32(Request["length"]));
            int length = Convert.ToInt32(Request["length"]);
            string searchValue = Request["search[value]"];
            string sortColumnName = Request["columns[" + Request["order[0][column]"] + "][name]"];
            string sortDirection = Request["order[0][dir]"];

            List<GET_Employee_Details_Result> list = new List<GET_Employee_Details_Result>();
            supersection = (supersection == null) ? (from c in db.M_Cost_Center_List where c.Cost_Center == user.CostCode select c.GroupSection).FirstOrDefault() : supersection;
            list = db.GET_Employee_Details(supersection, start, length, searchValue,Status, MStatus).ToList();
            GET_Employee_Details_Count_Result totalCount = db.GET_Employee_Details_Count(supersection, start, length, searchValue,Status,MStatus).FirstOrDefault();
            
            //if (!string.IsNullOrEmpty(MStatus))
            //{
               
            //        list = list.Where(x => x.ModifiedStatus.ToLower() == MStatus.ToLower()).ToList();
                
            //}
           
            //if (!string.IsNullOrEmpty(Status))
            //{
                
            //        list = list.Where(x => x.Status.ToLower() == Status.ToLower()).ToList();
               
            //}




            //if (sortColumnName != "" && sortColumnName != null)
            //{
            //    if (sortDirection == "asc")
            //    {
            //        list = list.OrderBy(x => TypeHelper.GetPropertyValue(x, sortColumnName)).ToList();
            //    }
            //    else
            //    {
            //        list = list.OrderByDescending(x => TypeHelper.GetPropertyValue(x, sortColumnName)).ToList();
            //    }
            //}
            int? totalrows = totalCount.TotalCount;// list.Count;
            int? totalrowsafterfiltering = totalCount.TotalCount;// list.Count;


            //paging
            //list = list.Skip(start).Take(length).ToList<GET_Employee_Details_Result>();
           // return Json(new { data = list, draw = Request["draw"], recordsTotal = totalrows, recordsFiltered = totalrowsafterfiltering }, JsonRequestBehavior.AllowGet);
            var jsonResult = Json(new { data = list, draw = Request["draw"], recordsTotal = totalrows, recordsFiltered = totalrowsafterfiltering }, JsonRequestBehavior.AllowGet);
            jsonResult.MaxJsonLength = int.MaxValue;
            return jsonResult;
        }
        public ActionResult GetEmployeeSkill(string EmployeeNo)
        {
            //Server Side Parameter

            int start = Convert.ToInt32(Request["start"]);
            int length = Convert.ToInt32(Request["length"]);
            string searchValue = Request["search[value]"];
            string sortColumnName = Request["columns[" + Request["order[0][column]"] + "][name]"];
            string sortDirection = Request["order[0][dir]"];

            List<GET_Employee_Skills_Result> list = new List<GET_Employee_Skills_Result>();
            list = db.GET_Employee_Skills(EmployeeNo).ToList();

            if (!string.IsNullOrEmpty(searchValue))//filter
            {
                list = list.Where(x => x.Skill.ToLower().Contains(searchValue.ToLower())
                || x.Line.ToLower().Contains(searchValue.ToLower())).ToList<GET_Employee_Skills_Result>();
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
            list = list.Skip(start).Take(length).ToList<GET_Employee_Skills_Result>();
            return Json(new { data = list, draw = Request["draw"], recordsTotal = totalrows, recordsFiltered = totalrowsafterfiltering }, JsonRequestBehavior.AllowGet);
        }
        public ActionResult AddSkill(M_Employee_Skills EmploySkill)
        {
            try
            {
                EmploySkill.CreateID = user.UserName;
                EmploySkill.CreateDate = DateTime.Now;
                EmploySkill.UpdateID = user.UserName;
                EmploySkill.UpdateDate = DateTime.Now;

                M_Employee_Skills checker = (from c in db.M_Employee_Skills
                                             where c.LineID == EmploySkill.LineID
                                             && c.SkillID == EmploySkill.SkillID
                                             && c.EmpNo == EmploySkill.EmpNo
                                             select c).FirstOrDefault();
                if (checker == null)
                {
                    db.M_Employee_Skills.Add(EmploySkill);
                    db.SaveChanges();
                    return Json(new { msg = "Success", employno = EmploySkill.EmpNo }, JsonRequestBehavior.AllowGet);
                }
                else
                {
                    return Json(new { msg = "Failed", employno = EmploySkill.EmpNo }, JsonRequestBehavior.AllowGet);

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
                return Json(new { msg = err.Message }, JsonRequestBehavior.AllowGet);
            }
        }

        public ActionResult DeleteSkills(string EmpNo, long SkillID)
        {
            M_Employee_Skills EmploySkill = (from c in db.M_Employee_Skills where c.EmpNo == EmpNo && c.SkillID == SkillID select c).FirstOrDefault();
            db.M_Employee_Skills.Remove(EmploySkill);
            db.SaveChanges();
            return Json(new { msg = "Success" }, JsonRequestBehavior.AllowGet);
        }
        public ActionResult GetEmployeeCostCenter(string EmployeeNo)
        {
            //Server Side Parameter
            int start = Convert.ToInt32(Request["start"]);
            int length = Convert.ToInt32(Request["length"]);
            string searchValue = Request["search[value]"];
            string sortColumnName = Request["columns[" + Request["order[0][column]"] + "][name]"];
            string sortDirection = Request["order[0][dir]"];

            List<GET_Employee_CostCenter_Result> list = db.GET_Employee_CostCenter(EmployeeNo).ToList();

            if (!string.IsNullOrEmpty(searchValue))//filter
            {
                list = list.Where(x => x.CostCenter_AMS.ToLower().Contains(searchValue.ToLower())).ToList<GET_Employee_CostCenter_Result>();
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
            list = list.Skip(start).Take(length).ToList<GET_Employee_CostCenter_Result>();
            return Json(new { data = list, draw = Request["draw"], recordsTotal = totalrows, recordsFiltered = totalrowsafterfiltering }, JsonRequestBehavior.AllowGet);
        }
        public ActionResult ModifyCostCenter(M_Employee_CostCenter EmployCostCenter)
        {
            try
            {
                M_Employee_CostCenter oldCostCenterIT = (from c in db.M_Employee_CostCenter where c.EmployNo == EmployCostCenter.EmployNo orderby c.UpdateDate_IT descending select c).FirstOrDefault();
                M_Employee_CostCenter oldCostCenterAMS = (from c in db.M_Employee_CostCenter where c.EmployNo == EmployCostCenter.EmployNo orderby c.UpdateDate_AMS descending select c).FirstOrDefault();



                M_Employee_CostCenter newCostCenter = new M_Employee_CostCenter();
                if (oldCostCenterIT != null && oldCostCenterAMS != null)
                {
                    newCostCenter.EmployNo = EmployCostCenter.EmployNo;

                    newCostCenter.UpdateDate_IT = oldCostCenterIT.UpdateDate_IT;
                    newCostCenter.CostCenter_IT = oldCostCenterIT.CostCenter_IT;

                    //Only update this
                    newCostCenter.UpdateDate_AMS = DateTime.Now;
                    newCostCenter.CostCenter_AMS = EmployCostCenter.CostCenter_AMS;
                    newCostCenter.UpdateDate_EXPROD = DateTime.Now;
                    newCostCenter.CostCenter_EXPROD = EmployCostCenter.CostCenter_EXPROD;
                    newCostCenter.Update_ID = user.UserName;
                }
                else
                {
                    newCostCenter.EmployNo = EmployCostCenter.EmployNo;
                    //Only update this
                    newCostCenter.UpdateDate_AMS = DateTime.Now;
                    newCostCenter.CostCenter_AMS = EmployCostCenter.CostCenter_AMS;
                    newCostCenter.UpdateDate_EXPROD = DateTime.Now;
                    newCostCenter.CostCenter_EXPROD = EmployCostCenter.CostCenter_EXPROD;
                    newCostCenter.Update_ID = user.UserName;

                }
                db.M_Employee_CostCenter.Add(newCostCenter);
                db.SaveChanges();
                return Json(new { msg = "Success", employno = EmployCostCenter.EmployNo }, JsonRequestBehavior.AllowGet);

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
                return Json(new { msg = err.Message }, JsonRequestBehavior.AllowGet);
            }
        }

        public ActionResult GetSkillLogo(long SkillID)
        {
            string skillLogo = (from c in db.M_Skills where c.ID == SkillID select c.SkillLogo).FirstOrDefault();

            return Json(new { skillLogo = skillLogo }, JsonRequestBehavior.AllowGet);
        }

        #region old exprod upload
        //public ActionResult UploadExprodOLD()
        //{
        //    try
        //    {
        //        var postedFile = Request.Files[0] as HttpPostedFileBase;
        //        string filePath = string.Empty;
        //        if (postedFile != null)
        //        {
        //            Z_UploadTracker uploaddetails = new Z_UploadTracker();
        //            uploaddetails.Uploaddate = db.TT_GETTIME().FirstOrDefault();
        //            uploaddetails.Uploader = user.UserName;
        //            uploaddetails.UploadFile = postedFile.FileName;
        //            db.Z_UploadTracker.Add(uploaddetails);
        //            db.SaveChanges();


        //            string dividerpath = (user.Section == "" || user.Section == null) ? "SuperUser" : user.Section;
        //            string path = Server.MapPath("~/Uploads/" + dividerpath + "/");
        //            if (!Directory.Exists(path))
        //            {
        //                Directory.CreateDirectory(path);
        //            }
        //            filePath = path + Path.GetFileName(postedFile.FileName);
        //            string extension = Path.GetExtension(postedFile.FileName);
        //            postedFile.SaveAs(filePath);
        //            string conString = string.Empty;
        //            switch (extension.ToLower())
        //            {
        //                case ".xls": //Excel 97-03.
        //                    conString = ConfigurationManager.ConnectionStrings["Excel03ConString"].ConnectionString;
        //                    break;
        //                case ".xlsx": //Excel 07 and above.
        //                    conString = ConfigurationManager.ConnectionStrings["Excel07ConString"].ConnectionString;
        //                    break;
        //            }
        //            conString = string.Format(conString, filePath);

        //            using (OleDbConnection connExcel = new OleDbConnection(conString))
        //            {
        //                using (OleDbCommand cmdExcel = new OleDbCommand())
        //                {
        //                    using (OleDbDataAdapter odaExcel = new OleDbDataAdapter())
        //                    {
        //                        DataTable dt = new DataTable();
        //                        cmdExcel.Connection = connExcel;
        //                        string sheetName = "AMSSheet";
        //                        try
        //                        {
        //                            connExcel.Open();
        //                        }
        //                        catch (Exception err)
        //                        {
        //                            Error_Logs error = new Error_Logs();
        //                            error.PageModule = "Master - Employee";
        //                            error.ErrorLog = err.Message;
        //                            error.DateLog = DateTime.Now;
        //                            error.Username = user.UserName;
        //                            db.Error_Logs.Add(error);
        //                            db.SaveChanges();
        //                        }
        //                        cmdExcel.CommandText = "SELECT EmployeeNumber, AMS_CostCenter FROM [" + sheetName + "$]";//ung * is column name, ung sheetname ay settings
        //                        odaExcel.SelectCommand = cmdExcel;
        //                        odaExcel.Fill(dt);
        //                        connExcel.Close();
        //                        for (int x = 0; x < dt.Rows.Count; x++)
        //                        {
        //                            try
        //                            {
        //                                string EmployeeNo = dt.Rows[x]["EmployeeNumber"].ToString();
        //                                //string CostCenter_EXPROD = dt.Rows[x]["EXPROD_CostCenter"].ToString();
        //                                string CostCenter_AMS = dt.Rows[x]["AMS_CostCenter"].ToString();
        //                                M_Employee_CostCenter employee = (from c in db.M_Employee_CostCenter
        //                                                                  where c.EmployNo == EmployeeNo && c.CostCenter_AMS == CostCenter_AMS
        //                                                                  && c.UpdateDate_AMS.Value < DateTime.Now
        //                                                                  select c).FirstOrDefault();
        //                                if (employee != null)
        //                                {
        //                                    employee.CostCenter_EXPROD = "";
        //                                    employee.CostCenter_AMS = CostCenter_AMS;

        //                                    employee.UpdateDate_AMS = db.TT_GETTIME().FirstOrDefault();
        //                                    employee.UpdateDate_IT = db.TT_GETTIME().FirstOrDefault();
        //                                    employee.Update_ID = user.UserName;
        //                                    db.Entry(employee).State = EntityState.Modified;
        //                                    db.SaveChanges();
        //                                }
        //                                else
        //                                {
        //                                    employee = new M_Employee_CostCenter();
        //                                    employee.EmployNo = EmployeeNo;
        //                                    employee.CostCenter_AMS = CostCenter_AMS;
        //                                    employee.CostCenter_EXPROD = "";
        //                                    employee.CostCenter_IT = "";
        //                                    employee.UpdateDate_AMS = db.TT_GETTIME().FirstOrDefault();
        //                                    employee.UpdateDate_IT = db.TT_GETTIME().FirstOrDefault();
        //                                    employee.UpdateDate_EXPROD = db.TT_GETTIME().FirstOrDefault();
        //                                    employee.Update_ID = user.UserName;
        //                                    db.M_Employee_CostCenter.Add(employee);
        //                                    db.SaveChanges();
        //                                }
        //                            }
        //                            catch (Exception err)
        //                            {
        //                                Error_Logs error = new Error_Logs();
        //                                error.PageModule = "Master - Employee";
        //                                error.ErrorLog = err.Message;
        //                                error.DateLog = DateTime.Now;
        //                                error.Username = user.UserName;
        //                                db.Error_Logs.Add(error);
        //                                db.SaveChanges();

        //                            }

        //                        }
        //                    }
        //                }
        //            }
        //        }
        //    }
        //    catch (Exception err)
        //    {
        //        Error_Logs error = new Error_Logs();
        //        error.PageModule = "Master - Employee";
        //        error.ErrorLog = err.Message;
        //        error.DateLog = DateTime.Now;
        //        error.Username = user.UserName;
        //        db.Error_Logs.Add(error);
        //        db.SaveChanges();
        //        return Json(new { result = "failed" }, JsonRequestBehavior.AllowGet);
        //    }
        //    return Json(new { result = "success" }, JsonRequestBehavior.AllowGet);
        //}
        #endregion

        public ActionResult UploadExprod()
        {
            try
            {
                var postedFile = Request.Files[0] as HttpPostedFileBase;
                string filePath = string.Empty;
                if (postedFile != null)
                {
                    Z_UploadTracker uploaddetails = new Z_UploadTracker();
                    uploaddetails.Uploaddate = db.TT_GETTIME().FirstOrDefault();
                    uploaddetails.Uploader = user.UserName;
                    uploaddetails.UploadFile = postedFile.FileName;
                    db.Z_UploadTracker.Add(uploaddetails);
                    db.SaveChanges();


                    string dividerpath = (user.Section == "" || user.Section == null) ? "SuperUser" : user.Section;
                    string path = Server.MapPath("~/Uploads/" + dividerpath + "/");
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
                                DataTable dtchecker = new DataTable();
                                cmdExcel.Connection = connExcel;
                                string sheetName = "AMSSheet";
                                try
                                {
                                    connExcel.Open();
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
                                cmdExcel.CommandText = "SELECT EmployeeNumber, AMS_CostCenter, IT_CostCenter FROM [" + sheetName + "$]";
                                odaExcel.SelectCommand = cmdExcel;
                                odaExcel.Fill(dt);
                                dt = DataRequiredExprod(dt);


                                cmdExcel.CommandText = "SELECT EmployeeNumber, AMS_CostCenter, IT_CostCenter FROM [" + sheetName + "$] WHERE EmployeeNumber <> '' AND (AMS_CostCenter IS NULL OR AMS_CostCenter = '')";
                                odaExcel.SelectCommand = cmdExcel;
                                odaExcel.Fill(dtchecker);
                                
                                connExcel.Close();

                                if (dtchecker.Rows.Count > 0)
                                {
                                    return Json(new { result = "failed" }, JsonRequestBehavior.AllowGet);
                                }
                                else
                                {
                                    #region NEW BULK INSERT
                                    try
                                    {
                                        string conString2 = ConfigurationManager.ConnectionStrings["Brothers_AMSDB"].ConnectionString;
                                        using (SqlBulkCopy bulk = new SqlBulkCopy(conString2))
                                        {
                                            bulk.ColumnMappings.Add("EmployeeNumber", "EmployNo");
                                            bulk.ColumnMappings.Add("AMS_CostCenter", "CostCenter_AMS");
                                            bulk.ColumnMappings.Add("IT_CostCenter", "CostCenter_IT");

                                            bulk.ColumnMappings.Add("UpdateID", "Update_ID");
                                            bulk.ColumnMappings.Add("UpdateDate_AMS", "UpdateDate_AMS");
                                            bulk.ColumnMappings.Add("UpdateDate_IT", "UpdateDate_IT");
                                            bulk.DestinationTableName = "M_Employee_CostCenter";
                                            bulk.WriteToServer(dt);
                                        }
                                    }
                                    catch (Exception err)
                                    {
                                        return Json(new { result = "failed" }, JsonRequestBehavior.AllowGet);
                                    }


                                    #endregion
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
            return Json(new { result = "success" }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult UploadSkills(long LineID)
        {
            List<UploadError> uploaderror = new List<UploadError>();
            try
            {
                var postedFile = Request.Files[0] as HttpPostedFileBase;
                string filePath = string.Empty;
                if (postedFile != null)
                {
                    Z_UploadTracker uploaddetails = new Z_UploadTracker();
                    uploaddetails.Uploaddate = db.TT_GETTIME().FirstOrDefault();
                    uploaddetails.Uploader = user.UserName;
                    uploaddetails.UploadFile = postedFile.FileName;
                    db.Z_UploadTracker.Add(uploaddetails);
                    db.SaveChanges();


                    string dividerpath = (user.Section == "" || user.Section == null) ? "SuperUser" : user.Section;
                    string path = Server.MapPath("~/Uploads/" + dividerpath + "/");
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
                                string sheetName = "AMSSheet";
                                try
                                {
                                    connExcel.Open();
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
                                cmdExcel.CommandText = "SELECT EmployeeNumber, Process FROM [" + sheetName + "$]";//ung * is column name, ung sheetname ay settings
                                odaExcel.SelectCommand = cmdExcel;
                                odaExcel.Fill(dt);
                                connExcel.Close();

                                long ROWcount = 0;
                                string Linename = (from m in db.M_LineTeam where m.ID == LineID && m.IsDeleted == false select m.Line).FirstOrDefault();
                                for (int x = 0; x < dt.Rows.Count; x++)
                                {
                                    try
                                    {
                                        ROWcount++;
                                        string EmployeeNo = dt.Rows[x]["EmployeeNumber"].ToString();
                                        string Skill = dt.Rows[x]["Process"].ToString();
                                        long SkillID = (from c in db.M_Skills
                                                        where c.Line == LineID
                                                        && c.Skill == Skill
                                                        && c.IsDeleted == false
                                                        select c.ID).FirstOrDefault();
                                        M_Employee_Skills employee = (from c in db.M_Employee_Skills
                                                                      where c.EmpNo == EmployeeNo
                                                                      && c.SkillID == SkillID
                                                                      select c).FirstOrDefault();

                                        if (SkillID != 0) // Skill not in line
                                        {
                                            if (employee == null)
                                            {
                                                M_Employee_Skills addSkill = new M_Employee_Skills();
                                                addSkill.EmpNo = EmployeeNo;
                                                addSkill.LineID = LineID;
                                                addSkill.SkillID = SkillID;

                                                addSkill.CreateID = user.UserName;
                                                addSkill.CreateDate = DateTime.Now;
                                                addSkill.UpdateID = user.UserName;
                                                addSkill.UpdateDate = DateTime.Now;

                                                db.M_Employee_Skills.Add(addSkill);
                                                db.SaveChanges();
                                            }
                                        }
                                        else
                                        {
                                            UploadError errorUP = new UploadError();
                                            errorUP.Row = ROWcount.ToString();
                                            errorUP.Message = Skill + " not in existing in " + Linename;
                                            uploaderror.Add(errorUP);

                                            Error_Logs error = new Error_Logs();
                                            error.PageModule = "Master - Employee";
                                            error.ErrorLog = Skill + " not in existing in " + Linename;
                                            error.DateLog = DateTime.Now;
                                            error.Username = user.UserName;
                                            db.Error_Logs.Add(error);
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
            return Json(new { result = "success", uploaderror = uploaderror }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult UploadScheduleold(string EffectivitySched)
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
                                string sheetName = "AMSSheet";
                                try
                                {
                                    connExcel.Open();
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
                                cmdExcel.CommandText = "SELECT EmployeeNumber, ScheduleName FROM [" + sheetName + "$]";//ung * is column name, ung sheetname ay settings
                                odaExcel.SelectCommand = cmdExcel;
                                odaExcel.Fill(dt);
                                connExcel.Close();
                                for (int x = 0; x < dt.Rows.Count; x++)
                                {
                                    try
                                    {
                                        string EmployeeNo = dt.Rows[x]["EmployeeNumber"].ToString();
                                        string ScheduleName = dt.Rows[x]["ScheduleName"].ToString();
                                        long ScheduleID = (from c in db.M_Schedule where c.Type == ScheduleName && c.IsDeleted == false select c.ID).FirstOrDefault();
                                       
                                        if (ScheduleName != "" && ScheduleID != 0)
                                        {
                                            M_Employee_Master_List_Schedule employeesched = new M_Employee_Master_List_Schedule();
                                            employeesched.EmployeeNo = EmployeeNo;
                                            employeesched.ScheduleID = ScheduleID;
                                            employeesched.UpdateDate = db.TT_GETTIME().FirstOrDefault();
                                            employeesched.UpdateID = user.UserName;
                                            employeesched.EffectivityDate = Convert.ToDateTime(EffectivitySched);
                                            db.M_Employee_Master_List_Schedule.Add(employeesched);
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
            return Json(new { result = "success" }, JsonRequestBehavior.AllowGet);
        }

        public DataTable DataRequired(DataTable dt, string EffectivityDate)
        {
            #region Add columns to Datatable

            DataColumn col_EffectivityDate = new System.Data.DataColumn("EffectivityDate", typeof(System.DateTime));
            col_EffectivityDate.DefaultValue = EffectivityDate;
            dt.Columns.Add(col_EffectivityDate);

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

            DataColumn col_HRUpdateDate = new System.Data.DataColumn("HRUpdateDate", typeof(System.DateTime));
            col_HRUpdateDate.DefaultValue = DateTime.Now;
            dt.Columns.Add(col_HRUpdateDate);

            //DataColumn col_Row = new System.Data.DataColumn("Row", typeof(System.Int32));
            //col_Row.AutoIncrement = true;
            //col_Row.AutoIncrementSeed = 1;
            //col_Row.AutoIncrementStep = 1;
            //dt.Columns.Add(col_Row);


            #endregion
            return dt;
        }

        public DataTable DataRequiredExprod(DataTable dt)
        {
            #region Add columns to Datatable
            
       
            DataColumn col_UpdateDate_AMS = new System.Data.DataColumn("UpdateDate_AMS", typeof(System.DateTime));
            col_UpdateDate_AMS.DefaultValue = DateTime.Now;
            dt.Columns.Add(col_UpdateDate_AMS);

            DataColumn col_UpdateID = new System.Data.DataColumn("UpdateID", typeof(System.String));
            col_UpdateID.DefaultValue = user.UserName;
            dt.Columns.Add(col_UpdateID);

            DataColumn col_UpdateDate_IT = new System.Data.DataColumn("UpdateDate_IT", typeof(System.DateTime));
            col_UpdateDate_IT.DefaultValue = DateTime.Now;
            dt.Columns.Add(col_UpdateDate_IT);

            //DataColumn col_Row = new System.Data.DataColumn("Row", typeof(System.Int32));
            //col_Row.AutoIncrement = true;
            //col_Row.AutoIncrementSeed = 1;
            //col_Row.AutoIncrementStep = 1;
            //dt.Columns.Add(col_Row);


            #endregion
            return dt;
        }

        public ActionResult UploadSchedule(string EffectivitySched)
        {
            try
            {
                var postedFile = Request.Files[0] as HttpPostedFileBase;
                string filePath = string.Empty;
                if (postedFile != null)
                {

                    Z_UploadTracker uploaddetails = new Z_UploadTracker();
                    uploaddetails.Uploaddate = db.TT_GETTIME().FirstOrDefault();
                    uploaddetails.Uploader = user.UserName;
                    uploaddetails.UploadFile = postedFile.FileName;
                    db.Z_UploadTracker.Add(uploaddetails);
                    db.SaveChanges();


                    string dividerpath = (user.Section == "" || user.Section == null)?"SuperUser":user.Section;
                    string path = Server.MapPath("~/Uploads/"+ dividerpath + "/");
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
                                DataTable dtchecker = new DataTable();
                                cmdExcel.Connection = connExcel;
                                string sheetName = "AMSSheet";
                                try
                                {
                                    connExcel.Open();
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
                                cmdExcel.CommandText = "SELECT EmployeeNumber, ScheduleName, ScheduleID FROM [" + sheetName + "$] WHERE EmployeeNumber <> '' AND ScheduleName <> ''";//ung * is column name, ung sheetname ay settings
                                odaExcel.SelectCommand = cmdExcel;

                                odaExcel.Fill(dt);
                                dt = DataRequired(dt, EffectivitySched);


                                cmdExcel.CommandText = "SELECT EmployeeNumber, ScheduleName, ScheduleID FROM [" + sheetName + "$] WHERE EmployeeNumber <> '' AND (ScheduleName IS NULL OR ScheduleName = '')";//ung * is column name, ung sheetname ay settings
                                odaExcel.SelectCommand = cmdExcel;
                                odaExcel.Fill(dtchecker);
                                connExcel.Close();
                                if (dtchecker.Rows.Count > 0)
                                {
                                    return Json(new { result = "failed" }, JsonRequestBehavior.AllowGet);
                                }
                                else
                                {
                                    #region NEW BULK INSERT
                                    try
                                    {
                                        DateTime EffectivityDate = Convert.ToDateTime(EffectivitySched);
                                        string conString2 = ConfigurationManager.ConnectionStrings["Brothers_AMSDB"].ConnectionString;
                                        using (SqlBulkCopy bulk = new SqlBulkCopy(conString2))
                                        {
                                            bulk.ColumnMappings.Add("EmployeeNumber", "EmployeeNo");
                                            bulk.ColumnMappings.Add("ScheduleID", "ScheduleID");
                                            bulk.ColumnMappings.Add("EffectivityDate", "EffectivityDate");
                                            bulk.ColumnMappings.Add("UpdateID", "UpdateID");
                                            bulk.ColumnMappings.Add("UpdateDate", "UpdateDate");
                                            bulk.DestinationTableName = "M_Employee_Master_List_Schedule";
                                            bulk.WriteToServer(dt);
                                        }
                                    }
                                    catch (Exception err) { }


                                    #endregion
                                }
                               

                                //for (int x = 0; x < dt.Rows.Count; x++)
                                //{
                                //    try
                                //    {
                                //        string EmployeeNo = dt.Rows[x]["EmployeeNumber"].ToString();
                                //        string ScheduleName = dt.Rows[x]["ScheduleName"].ToString();
                                //        long ScheduleID = (from c in db.M_Schedule where c.Type == ScheduleName && c.IsDeleted == false select c.ID).FirstOrDefault();

                                //        if (ScheduleName != "" && ScheduleID != 0)
                                //        {
                                //            M_Employee_Master_List_Schedule employeesched = new M_Employee_Master_List_Schedule();
                                //            employeesched.EmployeeNo = EmployeeNo;
                                //            employeesched.ScheduleID = ScheduleID;
                                //            employeesched.UpdateDate = db.TT_GETTIME().FirstOrDefault();
                                //            employeesched.UpdateID = user.UserName;
                                //            employeesched.EffectivityDate = Convert.ToDateTime(EffectivitySched);
                                //            db.M_Employee_Master_List_Schedule.Add(employeesched);
                                //            db.SaveChanges();
                                //        }
                                //    }
                                //    catch (Exception err)
                                //    {
                                //        Error_Logs error = new Error_Logs();
                                //        error.PageModule = "Master - Employee";
                                //        error.ErrorLog = err.Message;
                                //        error.DateLog = DateTime.Now;
                                //        error.Username = user.UserName;
                                //        db.Error_Logs.Add(error);
                                //        db.SaveChanges();
                                //    }
                                //}
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
            return Json(new { result = "success" }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult UploadStatus()
        {
            try
            {
                var postedFile = Request.Files[0] as HttpPostedFileBase;
                string filePath = string.Empty;
                if (postedFile != null)
                {
                    Z_UploadTracker uploaddetails = new Z_UploadTracker();
                    uploaddetails.Uploaddate = db.TT_GETTIME().FirstOrDefault();
                    uploaddetails.Uploader = user.UserName;
                    uploaddetails.UploadFile = postedFile.FileName;
                    db.Z_UploadTracker.Add(uploaddetails);
                    db.SaveChanges();


                    string dividerpath = (user.Section == "" || user.Section == null) ? "SuperUser" : user.Section;
                    string path = Server.MapPath("~/Uploads/" + dividerpath + "/");
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
                                DataTable dtchecker = new DataTable();
                                cmdExcel.Connection = connExcel;
                                string sheetName = "AMSSheet";
                                try
                                {
                                    connExcel.Open();
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
                                cmdExcel.CommandText = "SELECT EmployeeNumber, HRStatus, Status FROM [" + sheetName + "$] WHERE EmployeeNumber <> '' AND Status <> ''";//ung * is column name, ung sheetname ay settings
                                odaExcel.SelectCommand = cmdExcel;
                                odaExcel.Fill(dt);
                                dt = DataRequired(dt, DateTime.Now.ToLongDateString());


                                cmdExcel.CommandText = "SELECT EmployeeNumber, Status FROM [" + sheetName + "$] WHERE EmployeeNumber <> '' AND (Status IS NULL OR Status = '' OR HRStatus IS NULL OR HRStatus = '')";//ung * is column name, ung sheetname ay settings
                                odaExcel.SelectCommand = cmdExcel;
                                odaExcel.Fill(dtchecker);

                                connExcel.Close();

                                if (dtchecker.Rows.Count > 0)
                                {
                                    return Json(new { result = "failed" }, JsonRequestBehavior.AllowGet);
                                }
                                else
                                {
                                    #region NEW BULK INSERT
                                    try
                                    {

                                        string conString2 = ConfigurationManager.ConnectionStrings["Brothers_AMSDB"].ConnectionString;
                                        using (SqlBulkCopy bulk = new SqlBulkCopy(conString2))
                                        {
                                            bulk.ColumnMappings.Add("EmployeeNumber", "EmployNo");
                                            bulk.ColumnMappings.Add("HRStatus", "HRStatus");
                                            bulk.ColumnMappings.Add("Status", "Status");
                                            bulk.ColumnMappings.Add("UpdateID", "Update_ID");
                                            bulk.ColumnMappings.Add("UpdateDate", "UpdateDate");
                                            bulk.ColumnMappings.Add("HRUpdateDate", "HRUpdateDate");
                                            bulk.DestinationTableName = "M_Employee_Status";
                                            bulk.WriteToServer(dt);
                                        }
                                    }
                                    catch (Exception err) { }


                                    #endregion
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
            return Json(new { result = "success" }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult UploadPosition()
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
                                DataTable dtchecker = new DataTable();
                                cmdExcel.Connection = connExcel;
                                string sheetName = "AMSSheet";
                                try
                                {
                                    connExcel.Open();
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
                                cmdExcel.CommandText = "SELECT EmployeeNumber, PositionName FROM [" + sheetName + "$]";//ung * is column name, ung sheetname ay settings
                                odaExcel.SelectCommand = cmdExcel;
                                odaExcel.Fill(dt);


                                cmdExcel.CommandText = "SELECT EmployeeNumber, PositionName FROM [" + sheetName + "$] WHERE EmployeeNumber <> '' AND (PositionName IS NULL OR PositionName = '')";//ung * is column name, ung sheetname ay settings
                                odaExcel.SelectCommand = cmdExcel;
                                odaExcel.Fill(dtchecker);
                                connExcel.Close();

                                if (dtchecker.Rows.Count > 0)
                                {
                                    return Json(new { result = "failed" }, JsonRequestBehavior.AllowGet);

                                }
                                else
                                {
                                    for (int x = 0; x < dt.Rows.Count; x++)
                                    {
                                        try
                                        {
                                            string EmployeeNo = dt.Rows[x]["EmployeeNumber"].ToString();
                                            string Status = dt.Rows[x]["PositionName"].ToString();

                                            M_Employee_Position EmpStatus = new M_Employee_Position();
                                            EmpStatus.EmployNo = EmployeeNo;
                                            EmpStatus.Position = Status;
                                            EmpStatus.UpdateDate = db.TT_GETTIME().FirstOrDefault();
                                            EmpStatus.Update_ID = user.UserName;

                                            db.M_Employee_Position.Add(EmpStatus);
                                            db.SaveChanges();
                                        }
                                        catch (Exception err)
                                        {
                                            Error_Logs error = new Error_Logs();
                                            error.PageModule = "Master - Employee";
                                            error.ErrorLog = err.Message;
                                            error.DateLog = db.TT_GETTIME().FirstOrDefault();
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
            return Json(new { result = "success" }, JsonRequestBehavior.AllowGet);
        }
        public ActionResult RemoveSkillAll(string Section)
        {
            Z_SkillRemoverAll usernow = new Z_SkillRemoverAll();
            usernow.Username = user.UserName;
            usernow.DatePerform = db.TT_GETTIME().FirstOrDefault();
            usernow.Section = Section;
            db.Z_SkillRemoverAll.Add(usernow);
            db.SaveChanges();

            db.M_SP_SkillSectionDeletion(Section);
            return Json(new { msg = "Success" }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult ExportExpro(string CostCode)
        {
            try
            {
                string searchnow = System.Web.HttpContext.Current.Session["Searchvaluenow"].ToString();
                CostCode = (user.CostCode == null) ? CostCode : user.CostCode;
                //CostCode = (CostCode == "undefined") ? "" : CostCode;
                string templateFilename = "UploadExprod_AMSTemplate.xlsx";
                string dir = Path.GetTempPath();
                string datetimeToday = DateTime.Now.ToString("yyMMddhhmmss");
                string GroupSection = (user.CostCode != CostCode) ? CostCode : (from c in db.M_Cost_Center_List where c.Cost_Center == CostCode && c.GroupSection != "" select c.GroupSection).FirstOrDefault();

                string filename = string.Format("Employee_CostCenterCode{0}_{1}.xlsx", datetimeToday, GroupSection);
                FileInfo newFile = new FileInfo(Path.Combine(dir, filename));
                string apptemplatePath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, @"TemplateFiles\", templateFilename);
                FileInfo templateFile = new FileInfo(apptemplatePath);

                using (ExcelPackage package = new ExcelPackage(newFile, templateFile))  //-- With template.
                {
                    List<GET_Employee_Details_Result> list = new List<GET_Employee_Details_Result>();
                    CostCode = (user.CostCode == CostCode) ? "" : CostCode;
                    list = db.GET_Employee_Details(GroupSection, 0, 100000, "","","").ToList();
                    list = list.Where(xx => xx.ModifiedStatus != null).ToList();
                    list = list.Where(x => x.ModifiedStatus.ToLower() == "active").ToList();
                    ExcelWorksheet ExportData = package.Workbook.Worksheets["AMSSheet"];
                    ExcelWorksheet ExportData2 = package.Workbook.Worksheets["Instructions"];
                    int start = 2;
                    if (!string.IsNullOrEmpty(searchnow))//filter
                    {
                        #region null remover
                        list = list.Where(xx => xx.EmpNo != null).ToList();
                        list = list.Where(xx => xx.First_Name != null).ToList();
                        list = list.Where(xx => xx.Family_Name != null).ToList();
                        #endregion
                        list = list.Where(x => x.First_Name.ToLower().Contains(searchnow.ToLower())
                        || x.Family_Name.ToLower().Contains(searchnow.ToLower())
                        || x.EmpNo.Contains(searchnow)
                        ).ToList<GET_Employee_Details_Result>();
                        // list = list.Where(x => x.CostCode == CostCode).ToList();

                    }
                    //else
                    //{
                    //   list = (from c in list where c.CostCode == CostCode select c).ToList();
                    //}
                    for (int i = 0; i < list.Count; i++)
                    {
                        ExportData.Cells["A" + start].Value = i+1;
                        ExportData.Cells["B" + start].Value = list[i].EmpNo;
                        ExportData.Cells["C" + start].Value = list[i].Family_Name + ", " + list[i].First_Name;
                        ExportData.Cells["D" + start].Value = list[i].CostCenter_IT;
                        ExportData.Cells["E" + start].Value = list[i].CostCenter_AMS;
                        start++;
                    }

                    List<M_Cost_Center_List> costcodelist = (from c in db.M_Cost_Center_List
                                                             orderby c.Cost_Center
                                                             select c).ToList();
                    int d = 8;
                    
                    for (int i = 0; i < costcodelist.Count; i++)
                    {
                        ExportData2.Cells["A" + d].Value = i+1;
                        ExportData2.Cells["B" + d].Value = costcodelist[i].Cost_Center;
                        ExportData2.Cells["C" + d].Value = costcodelist[i].Section;
                        ExportData2.Cells["D" + d].Value = costcodelist[i].GroupSection;
                        ExportData2.Cells["E" + d].Value = costcodelist[i].DepartmentGroup;

                        d++;
                    }
                    return File(package.GetAsByteArray(), "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", filename);
                }
            }
            catch (Exception err) { }
            return Json(new { }, JsonRequestBehavior.AllowGet);
        }

        #region OLD Skill Export
        //public ActionResult old_ExportSkillEmployee(string CostCode)
        //{
        //    try
        //    {
        //        string searchnow = System.Web.HttpContext.Current.Session["Searchvaluenow"].ToString();
        //        CostCode = (user.CostCode == "") ? CostCode : "";
        //        CostCode = (CostCode == "undefined") ? "" : CostCode;
        //        string templateFilename = "EmployeeSkillTemplate.xlsx";
        //        string dir = Path.GetTempPath();
        //        string datetimeToday = DateTime.Now.ToString("yyMMddhhmmss");
        //        string filename = string.Format("EmployeeSkillTemplate{0}_{1}.xlsx", datetimeToday, CostCode);
        //        FileInfo newFile = new FileInfo(Path.Combine(dir, filename));
        //        string apptemplatePath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, @"TemplateFiles\", templateFilename);
        //        FileInfo templateFile = new FileInfo(apptemplatePath);

        //        using (ExcelPackage package = new ExcelPackage(newFile, templateFile))  //-- With template.
        //        {

        //            List<GET_Employee_Details_Result> list = new List<GET_Employee_Details_Result>();
        //            list = db.GET_Employee_Details(user.CostCode, CostCode).ToList();
        //            list = list.Where(xx => xx.ModifiedStatus != null).ToList();
        //            list = list.Where(x => x.ModifiedStatus.ToLower() == "active").ToList();
        //            ExcelWorksheet ExportData = package.Workbook.Worksheets["AMSSheet"];
        //            int start = 2;
        //            if (!string.IsNullOrEmpty(searchnow))//filter
        //            {
        //                #region null remover
        //                list = list.Where(xx => xx.EmpNo != null).ToList();
        //                list = list.Where(xx => xx.First_Name != null).ToList();
        //                list = list.Where(xx => xx.Family_Name != null).ToList();
        //                #endregion
        //                list = list.Where(x => x.First_Name.ToLower().Contains(searchnow.ToLower())
        //                || x.Family_Name.ToLower().Contains(searchnow.ToLower())
        //                || x.EmpNo.Contains(searchnow)
        //                ).ToList<GET_Employee_Details_Result>();
        //                //list = list.Where(x => x.CostCode == CostCode).ToList();

        //            }
        //            //else
        //            //{
        //            //    list = (from c in list where c.CostCode == CostCode select c).ToList();
        //            //}
        //            for (int i = 0; i < list.Count; i++)
        //            {
        //                ExportData.Cells["A1"].Value = list[i].EmpNo;
        //                ExportData.Cells["B1"].Value = list[i].Family_Name + ", " + list[i].First_Name;
        //                start++;
        //            }
        //            return File(package.GetAsByteArray(), "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", filename);
        //        }
        //    }
        //    catch (Exception err) { }
        //    return Json(new { }, JsonRequestBehavior.AllowGet);
        //}
        #endregion

        public ActionResult ExportSkillEmployee(string CostCode)
        {
            try
            {
                string searchnow = System.Web.HttpContext.Current.Session["Searchvaluenow"].ToString();
                CostCode = (user.CostCode == null) ? CostCode : user.CostCode;
                //CostCode = (CostCode == "undefined") ? "" : CostCode;
                string templateFilename = "EmployeeSkillTemplate.xlsx";
                string dir = Path.GetTempPath();
                string datetimeToday = DateTime.Now.ToString("yyMMddhhmmss");
                string GroupSection = (user.CostCode != CostCode) ? CostCode : (from c in db.M_Cost_Center_List where c.Cost_Center == CostCode select c.GroupSection).FirstOrDefault();

                string filename = string.Format("EmployeesProcessTemplate{0}_{1}.xlsx", datetimeToday, GroupSection);
                FileInfo newFile = new FileInfo(Path.Combine(dir, filename));
                string apptemplatePath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, @"TemplateFiles\", templateFilename);
                FileInfo templateFile = new FileInfo(apptemplatePath);

                using (ExcelPackage package = new ExcelPackage(newFile, templateFile))  //-- With template.
                {

                    List<GET_Employee_Details_Skill_Result> list = new List<GET_Employee_Details_Skill_Result>();
                    CostCode = (user.CostCode == CostCode) ? "" : CostCode;
                    list = db.GET_Employee_Details_Skill(GroupSection).ToList();
                 
                    list = list.Where(x => x.ModifiedStatus.ToLower() == "active").ToList();
                    ExcelWorksheet ExportData = package.Workbook.Worksheets["AMSSheet"];
                    int start = 2;
                    if (!string.IsNullOrEmpty(searchnow))//filter
                    {
                        #region null remover
                        list = list.Where(xx => xx.EmpNo != null).ToList();
                        list = list.Where(xx => xx.First_Name != null).ToList();
                        list = list.Where(xx => xx.Family_Name != null).ToList();
                        #endregion
                        list = list.Where(x => x.First_Name.ToLower().Contains(searchnow.ToLower())
                        || x.Family_Name.ToLower().Contains(searchnow.ToLower())
                        || x.EmpNo.Contains(searchnow)
                        ).ToList<GET_Employee_Details_Skill_Result>();

                    }
                    //else
                    //{
                    //    list = (from c in list where c.CostCode == CostCode select c).ToList();
                    //}
                    for (int i = 0; i < list.Count; i++)
                    {
                        ExportData.Cells["A" + start].Value = i+1;
                        ExportData.Cells["B" + start].Value = list[i].EmpNo;
                        ExportData.Cells["C" + start].Value = list[i].Family_Name + ", " + list[i].First_Name;
                        ExportData.Cells["D" + start].Value = list[i].Line;
                        ExportData.Cells["E" + start].Value = list[i].Skill;
                        start++;
                    }
                    return File(package.GetAsByteArray(), "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", filename);
                }
            }
            catch (Exception err) { }
            return Json(new { }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult ExportNOSkillEmployee(string CostCode)
        {
            try
            {
                string searchnow = System.Web.HttpContext.Current.Session["Searchvaluenow"].ToString();
                CostCode = (user.CostCode == null) ? CostCode : user.CostCode;
                //CostCode = (CostCode == "undefined") ? "" : CostCode;
                string templateFilename = "EmployeeSkillTemplate.xlsx";
                string dir = Path.GetTempPath();
                string datetimeToday = DateTime.Now.ToString("yyMMddhhmmss");
                string GroupSection = (user.CostCode != CostCode) ? CostCode : (from c in db.M_Cost_Center_List where c.Cost_Center == CostCode select c.GroupSection).FirstOrDefault();

                string filename = string.Format("EmployeeNOSkillTemplate{0}_{1}.xlsx", datetimeToday, GroupSection);
                FileInfo newFile = new FileInfo(Path.Combine(dir, filename));
                string apptemplatePath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, @"TemplateFiles\", templateFilename);
                FileInfo templateFile = new FileInfo(apptemplatePath);

                using (ExcelPackage package = new ExcelPackage(newFile, templateFile))  //-- With template.
                {

                    List<GET_Employee_Details_Result> list = new List<GET_Employee_Details_Result>();
                    CostCode = (user.CostCode == CostCode) ? "" : CostCode;
                    list = db.GET_Employee_Details(GroupSection, 0, 100000, "", "", "").ToList();
                    list = list.Where(x => x.SkillCount == 0).ToList();
                    list = list.Where(x => x.ModifiedStatus.ToLower() == "active").ToList();
                    ExcelWorksheet ExportData = package.Workbook.Worksheets["AMSSheet"];
                    int start = 2;
                    if (!string.IsNullOrEmpty(searchnow))//filter
                    {
                        #region null remover
                        list = list.Where(xx => xx.EmpNo != null).ToList();
                        list = list.Where(xx => xx.First_Name != null).ToList();
                        list = list.Where(xx => xx.Family_Name != null).ToList();

                        #endregion
                        list = list.Where(x => x.First_Name.ToLower().Contains(searchnow.ToLower())
                        || x.Family_Name.ToLower().Contains(searchnow.ToLower())
                        || x.EmpNo.Contains(searchnow)
                        ).ToList<GET_Employee_Details_Result>();

                    }
                    //else
                    //{
                    //    list = (from c in list where c.CostCode == CostCode select c).ToList();
                    //}
                    for (int i = 0; i < list.Count; i++)
                    {
                        ExportData.Cells["A" + start].Value = i+1;
                        ExportData.Cells["B" + start].Value = list[i].EmpNo;
                        ExportData.Cells["C" + start].Value = list[i].Family_Name + ", " + list[i].First_Name;
                        
                        start++;
                    }
                    return File(package.GetAsByteArray(), "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", filename);
                }
            }
            catch (Exception err) { }
            return Json(new { }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult ExportSchedule(string CostCode)
        {
            try
            {
                string searchnow = System.Web.HttpContext.Current.Session["Searchvaluenow"].ToString();
                CostCode = (user.CostCode == null) ? CostCode : user.CostCode;
                //CostCode = (CostCode == "undefined") ? "" : CostCode;

                string templateFilename = "EmployeeSchedule.xlsx";
                string dir = Path.GetTempPath();
                string datetimeToday = DateTime.Now.ToString("yyMMddhhmmss");
                string GroupSection = (user.CostCode != CostCode)? CostCode : (from c in db.M_Cost_Center_List where c.Cost_Center == CostCode select c.GroupSection).FirstOrDefault();
                string filename = string.Format("EmployeeSchedule{0}_{1}.xlsx", datetimeToday, GroupSection);
                FileInfo newFile = new FileInfo(Path.Combine(dir, filename));
                string apptemplatePath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, @"TemplateFiles\", templateFilename);
                FileInfo templateFile = new FileInfo(apptemplatePath);

                using (ExcelPackage package = new ExcelPackage(newFile, templateFile))  //-- With template.
                {

                    List<GET_Employee_Details_Result> list = new List<GET_Employee_Details_Result>();
                    CostCode = (user.CostCode == CostCode) ? "" : CostCode;
                    list = db.GET_Employee_Details(GroupSection, 0, 100000, "", "", "").ToList();
                    list = list.Where(x => x.Status.ToLower() == "active").ToList();
                    ExcelWorksheet ExportData = package.Workbook.Worksheets["AMSSheet"];
                    int start = 2;
                    if (!string.IsNullOrEmpty(searchnow))//filter
                    {
                        #region null remover
                        list = list.Where(xx => xx.EmpNo != null).ToList();
                        list = list.Where(xx => xx.First_Name != null).ToList();
                        list = list.Where(xx => xx.Family_Name != null).ToList();
                        #endregion
                        list = list.Where(x => x.First_Name.ToLower().Contains(searchnow.ToLower())
                        || x.Family_Name.ToLower().Contains(searchnow.ToLower())
                        || x.EmpNo.Contains(searchnow)
                        ).ToList<GET_Employee_Details_Result>();
                        //list = list.Where(x => x.CostCode == CostCode).ToList();

                    }
                    //else
                    //{
                    //    list = (from c in list where c.CostCode == CostCode select c).ToList();
                    //}
                    for (int i = 0; i < list.Count; i++)
                    {
                        string o = list[i].ScheduleName;
                        M_Schedule sh = (from c in db.M_Schedule where c.Type == o select c).FirstOrDefault();
                        ExportData.Cells["A" + start].Value = i+1;
                        ExportData.Cells["B"+start].Value = list[i].EmpNo;
                        ExportData.Cells["C"+start].Value = list[i].Family_Name + ", " + list[i].First_Name;
                        if (sh != null)
                        {
                            ExportData.Cells["D" + start].Value = list[i].ScheduleName + " (" + sh.Timein + " - " + sh.TimeOut + ")";
                        }
                       
                        start++;
                    }


                    //GET ALL Schedule
                    ExcelWorksheet ExportData2 = package.Workbook.Worksheets["Instructions"];
                    List<M_Schedule> SchedList = (from c in db.M_Schedule
                                                  where c.IsDeleted != true
                                                  orderby c.Type ascending 
                                                  select c).ToList();
                    int d = 8;
                    for (int i = 0; i < SchedList.Count; i++)
                    {
                        ExportData2.Cells["A" + d].Value = SchedList[i].Type + " (" + SchedList[i].Timein + " - " + SchedList[i].TimeOut + ")";
                        ExportData2.Cells["D" + d].Value = SchedList[i].ID;
                        d++;
                    }

                    return File(package.GetAsByteArray(), "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", filename);
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
            return Json(new { }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult ExportStatus(string CostCode)
        {
            try
            {
                string searchnow = System.Web.HttpContext.Current.Session["Searchvaluenow"].ToString();
                CostCode = (user.CostCode == null) ? CostCode : user.CostCode;
                //CostCode = (CostCode == "undefined") ? "" : CostCode;

                string templateFilename = "EmployeeStatus.xlsx";
                string dir = Path.GetTempPath();
                string datetimeToday = DateTime.Now.ToString("yyMMddhhmmss");
                string GroupSection = (user.CostCode != CostCode) ? CostCode : (from c in db.M_Cost_Center_List where c.Cost_Center == CostCode select c.GroupSection).FirstOrDefault();

                string filename = string.Format("EmployeeStatus{0}_{1}.xlsx", datetimeToday, GroupSection);
                FileInfo newFile = new FileInfo(Path.Combine(dir, filename));
                string apptemplatePath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, @"TemplateFiles\", templateFilename);
                FileInfo templateFile = new FileInfo(apptemplatePath);

                using (ExcelPackage package = new ExcelPackage(newFile, templateFile))  //-- With template.
                {

                    List<GET_Employee_Details_Result> list = new List<GET_Employee_Details_Result>();
                    CostCode = (user.CostCode == CostCode) ? "" : CostCode;
                    list = db.GET_Employee_Details(GroupSection, 0, 100000, "", "", "").ToList();
                    //list = list.Where(x => x.ModifiedStatus.ToLower() == "active").ToList();
                    ExcelWorksheet ExportData = package.Workbook.Worksheets["AMSSheet"];
                    ExcelWorksheet ExportData2 = package.Workbook.Worksheets["Instructions"];

                    int start = 2;
                    if (!string.IsNullOrEmpty(searchnow))//filter
                    {
                        #region null remover
                        list = list.Where(xx => xx.EmpNo != null).ToList();
                        list = list.Where(xx => xx.First_Name != null).ToList();
                        list = list.Where(xx => xx.Family_Name != null).ToList();
                        #endregion
                        list = list.Where(x => x.First_Name.ToLower().Contains(searchnow.ToLower())
                        || x.Family_Name.ToLower().Contains(searchnow.ToLower())
                        || x.EmpNo.Contains(searchnow)
                        ).ToList<GET_Employee_Details_Result>();
                        //list = list.Where(x => x.CostCode == CostCode).ToList();

                    }
                    //else
                    //{
                    //    list = (from c in list where c.CostCode == CostCode select c).ToList();
                    //}
                    for (int i = 0; i < list.Count; i++)
                    {
                        ExportData.Cells["A" + start].Value = i+1;
                        ExportData.Cells["B"+start].Value = list[i].EmpNo;
                        ExportData.Cells["C"+start].Value = list[i].Family_Name + ", " + list[i].First_Name;
                        ExportData.Cells["D" + start].Value = list[i].Status;
                        ExportData.Cells["E" + start].Value = list[i].ModifiedStatus;
                        start++;
                    }

                    List<string> statuslist = (from c in db.M_Employee_Master_List
                                               where c.Status != "&nbsp;"
                                               && c.Status != ""
                                               && c.Status != null
                                               select c.Status).Distinct().ToList();
                    int d = 1;
                    for (int i = 0; i < statuslist.Count; i++)
                    {
                        ExportData2.Cells["Z" + d].Value = statuslist[i];
                       
                        d++;
                    }
                    return File(package.GetAsByteArray(), "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", filename);
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
            return Json(new { }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult ExportPosition(string CostCode)
        {
            try
            {
                string searchnow = System.Web.HttpContext.Current.Session["Searchvaluenow"].ToString();
                CostCode = (user.CostCode == null) ? CostCode : user.CostCode;
                //CostCode = (CostCode == "undefined") ? "" : CostCode;
                string GroupSection = (user.CostCode != CostCode) ? CostCode : (from c in db.M_Cost_Center_List where c.Cost_Center == CostCode select c.GroupSection).FirstOrDefault();

                string templateFilename = "EmployeePosition.xlsx";
                string dir = Path.GetTempPath();
                string datetimeToday = DateTime.Now.ToString("yyMMddhhmmss");
                string filename = string.Format("EmployeePosition{0}_{1}.xlsx", datetimeToday, GroupSection);
                FileInfo newFile = new FileInfo(Path.Combine(dir, filename));
                string apptemplatePath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, @"TemplateFiles\", templateFilename);
                FileInfo templateFile = new FileInfo(apptemplatePath);

                using (ExcelPackage package = new ExcelPackage(newFile, templateFile))  //-- With template.
                {

                    List<GET_Employee_Details_Result> list = new List<GET_Employee_Details_Result>();
                    list = db.GET_Employee_Details(GroupSection, 0, 100000, "", "", "").ToList();
                    list = list.Where(x => x.ModifiedStatus.ToLower() == "active").ToList();
                    ExcelWorksheet ExportData = package.Workbook.Worksheets["AMSSheet"];
                    ExcelWorksheet ExportData2 = package.Workbook.Worksheets["Instructions"];
                    int start = 2;
                    if (!string.IsNullOrEmpty(searchnow))//filter
                    {
                        #region null remover
                        list = list.Where(xx => xx.EmpNo != null).ToList();
                        list = list.Where(xx => xx.First_Name != null).ToList();
                        list = list.Where(xx => xx.Family_Name != null).ToList();
                        #endregion
                        list = list.Where(x => x.First_Name.ToLower().Contains(searchnow.ToLower())
                        || x.Family_Name.ToLower().Contains(searchnow.ToLower())
                        || x.EmpNo.Contains(searchnow)
                        ).ToList<GET_Employee_Details_Result>();
                        //list = list.Where(x => x.CostCode == CostCode).ToList();

                    }
                    //else
                    //{
                    //    list = (from c in list where c.CostCode == CostCode select c).ToList();
                    //}
                    for (int i = 0; i < list.Count; i++)
                    {
                        ExportData.Cells["A" + start].Value = i+1;
                        ExportData.Cells["B"+start].Value = list[i].EmpNo;
                        ExportData.Cells["C"+start].Value = list[i].Family_Name + ", " + list[i].First_Name;
                        ExportData.Cells["D" + start].Value = list[i].ModifiedPosition;
                        start++;
                    }
                    List<string> positionlist = (from c in db.M_Employee_Master_List
                                               where c.Position != "&nbsp;"
                                               && c.Position != ""
                                               && c.Position != null
                                               select c.Position).Distinct().ToList();
                    int d = 8;
                    List<string> positionlistORdered = positionlist.OrderBy(q => q).ToList();
                    for (int i = 0; i < positionlistORdered.Count; i++)
                    {
                        ExportData2.Cells["A" + d].Value = i+1;
                        ExportData2.Cells["B" + d].Value = positionlistORdered[i];

                        d++;
                    }
                    return File(package.GetAsByteArray(), "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", filename);
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
            return Json(new { }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult GetEmployeeStatus(string EmployeeNo)
        {
            //Server Side Parameter

            int start = Convert.ToInt32(Request["start"]);
            int length = Convert.ToInt32(Request["length"]);
            string searchValue = Request["search[value]"];
            string sortColumnName = Request["columns[" + Request["order[0][column]"] + "][name]"];
            string sortDirection = Request["order[0][dir]"];

            List<GET_Employee_ModifiedStatus_Result> list = db.GET_Employee_ModifiedStatus(EmployeeNo).ToList();

            if (!string.IsNullOrEmpty(searchValue))//filter
            {
                list = list.Where(x => x.Status.ToLower().Contains(searchValue.ToLower())).ToList<GET_Employee_ModifiedStatus_Result>();
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
            list = list.Skip(start).Take(length).ToList<GET_Employee_ModifiedStatus_Result>();
            return Json(new { data = list, draw = Request["draw"], recordsTotal = totalrows, recordsFiltered = totalrowsafterfiltering }, JsonRequestBehavior.AllowGet);
        }
        
        public ActionResult GetEmployeeScheduleList(string EmployeeNo)
        {
            //Server Side Parameter

            int start = Convert.ToInt32(Request["start"]);
            int length = Convert.ToInt32(Request["length"]);
            string searchValue = Request["search[value]"];
            string sortColumnName = Request["columns[" + Request["order[0][column]"] + "][name]"];
            string sortDirection = Request["order[0][dir]"];

            List<GET_Employee_ScheduleList_Result> list = db.GET_Employee_ScheduleList(EmployeeNo).ToList();

            if (!string.IsNullOrEmpty(searchValue))//filter
            {
                list = list.Where(x => x.ScheduleName.ToLower().Contains(searchValue.ToLower())).ToList<GET_Employee_ScheduleList_Result>();
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
            list = list.Skip(start).Take(length).ToList<GET_Employee_ScheduleList_Result>();
            return Json(new { data = list, draw = Request["draw"], recordsTotal = totalrows, recordsFiltered = totalrowsafterfiltering }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult GetEmployeeScheduleCSList(string EmployeeNo)
        {
            //Server Side Parameter

            int start = Convert.ToInt32(Request["start"]);
            int length = Convert.ToInt32(Request["length"]);
            string searchValue = Request["search[value]"];
            string sortColumnName = Request["columns[" + Request["order[0][column]"] + "][name]"];
            string sortDirection = Request["order[0][dir]"];

            List<GET_Employee_ScheduleListChangeShift_Result> list = db.GET_Employee_ScheduleListChangeShift(EmployeeNo).ToList();

            if (!string.IsNullOrEmpty(searchValue))//filter
            {
                list = list.Where(x => x.ScheduleName.ToLower().Contains(searchValue.ToLower())).ToList<GET_Employee_ScheduleListChangeShift_Result>();
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
            list = list.Skip(start).Take(length).ToList<GET_Employee_ScheduleListChangeShift_Result>();
            return Json(new { data = list, draw = Request["draw"], recordsTotal = totalrows, recordsFiltered = totalrowsafterfiltering }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult GetEmployeePosition(string EmployeeNo)
        {
            //Server Side Parameter

            int start = Convert.ToInt32(Request["start"]);
            int length = Convert.ToInt32(Request["length"]);
            string searchValue = Request["search[value]"];
            string sortColumnName = Request["columns[" + Request["order[0][column]"] + "][name]"];
            string sortDirection = Request["order[0][dir]"];

            List<GET_Employee_ModifiedPosition_Result> list = db.GET_Employee_ModifiedPosition(EmployeeNo).ToList();

            if (!string.IsNullOrEmpty(searchValue))//filter
            {
                list = list.Where(x => x.Position.ToLower().Contains(searchValue.ToLower())).ToList<GET_Employee_ModifiedPosition_Result>();
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
            list = list.Skip(start).Take(length).ToList<GET_Employee_ModifiedPosition_Result>();
            return Json(new { data = list, draw = Request["draw"], recordsTotal = totalrows, recordsFiltered = totalrowsafterfiltering }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult UpdateStatus(string EmpNo, string Status, string DateResigned)
        {
            try
            {
                M_Employee_Status EmpStatus = new M_Employee_Status();
                EmpStatus.EmployNo = EmpNo;
                EmpStatus.HRStatus = (from c in db.M_Employee_Master_List where c.EmpNo == EmpNo select c.Status).FirstOrDefault();
                EmpStatus.Status = Status;
                EmpStatus.Update_ID = user.UserName;
                EmpStatus.UpdateDate = DateTime.Now;
                EmpStatus.DateResigned = (DateResigned == "")?null:DateResigned;
                db.M_Employee_Status.Add(EmpStatus);
                db.SaveChanges();


                M_Employee_Master_List Employee = new M_Employee_Master_List();
                Employee = (from u in db.M_Employee_Master_List.ToList()
                            where u.EmpNo == EmpNo
                            select u).FirstOrDefault();
                Employee.Date_Resigned = (DateResigned == "") ? null : DateResigned;
                db.Entry(Employee).State = EntityState.Modified;
                db.SaveChanges();
            }
            catch(Exception err)
            {

            }

            return Json(new { }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult UpdatePosition(string EmpNo, string Position)
        {
            M_Employee_Position EmpPos = new M_Employee_Position();
            EmpPos.EmployNo = EmpNo;
            EmpPos.Position = Position;
            EmpPos.HRPosition = (from c in db.M_Employee_Master_List where c.EmpNo == EmpNo select c.Position).FirstOrDefault();
            EmpPos.Update_ID = user.UserName;
            EmpPos.UpdateDate = DateTime.Now;
            db.M_Employee_Position.Add(EmpPos);
            db.SaveChanges();
            return Json(new { }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult ActiveInactiveReport(string Status, string CostCode)
        {
            try
            {
                CostCode = (user.CostCode == null) ? CostCode : user.CostCode;
                string templateFilename = "ActiveInactiveReport.xlsx";
                string dir = Path.GetTempPath();
                string datetimeToday = DateTime.Now.ToString("yyMMddhhmmss");
                string GroupSection = (user.CostCode != CostCode) ? CostCode : (from c in db.M_Cost_Center_List where c.Cost_Center == CostCode select c.GroupSection).FirstOrDefault();

                string filename = string.Format("ActiveInactiveReport{0}_{1}.xlsx", datetimeToday, GroupSection);
                FileInfo newFile = new FileInfo(Path.Combine(dir, filename));
                string apptemplatePath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, @"TemplateFiles\", templateFilename);
                FileInfo templateFile = new FileInfo(apptemplatePath);


                using (ExcelPackage package = new ExcelPackage(newFile, templateFile))  //-- With template.
                {
                    ExcelWorksheet ExportData = package.Workbook.Worksheets["Employee List"];
                    List<GET_Employee_Details_Result> list = db.GET_Employee_Details(GroupSection, 0, 100000, "", "", "").ToList();
                    list = list.Where(x => x.ModifiedStatus != null).ToList();
                    if (Status == "Active")
                    {
                        list = list.Where(x => x.ModifiedStatus.ToUpper() == "ACTIVE").ToList();
                    }
                    else if(Status == "Inactive")
                    {
                        list = list.Where(x => x.ModifiedStatus.ToUpper() != "ACTIVE").ToList();
                    }
                    
                    int start = 2;
                    int rownumber = 1;
                    foreach (GET_Employee_Details_Result item in list)
                    {
                        ExportData.Cells["A" + start].Value = rownumber;
                        ExportData.Cells["B" + start].Value = item.REFID;
                        ExportData.Cells["C" + start].Value = item.ADID;
                        ExportData.Cells["D" + start].Value = item.EmpNo;
                        ExportData.Cells["E" + start].Value = item.Family_Name_Suffix;
                        ExportData.Cells["F" + start].Value = item.Family_Name;
                        ExportData.Cells["G" + start].Value = item.First_Name;
                        ExportData.Cells["H" + start].Value = item.Middle_Name;
                        ExportData.Cells["I" + start].Value = item.Date_Hired;
                        ExportData.Cells["J" + start].Value = item.Status;
                        ExportData.Cells["K" + start].Value = item.Emp_Category;
                        ExportData.Cells["L" + start].Value = item.Date_Regularized;
                        ExportData.Cells["M" + start].Value = item.Position;
                        ExportData.Cells["N" + start].Value = item.Email;
                        ExportData.Cells["O" + start].Value = item.Gender;
                        ExportData.Cells["P" + start].Value = item.RFID;
                        ExportData.Cells["Q" + start].Value = item.Section;
                        ExportData.Cells["R" + start].Value = item.Department;
                        ExportData.Cells["S" + start].Value = item.Company;
                        ExportData.Cells["T" + start].Value = item.CostCode;
                        ExportData.Cells["U" + start].Value = GroupSection;
                        ExportData.Cells["V" + start].Value = item.ModifiedStatus;
                        ExportData.Cells["W" + start].Value = item.ModifiedPosition;
                        ExportData.Cells["X" + start].Value = item.CostCenter_AMS;
                        ExportData.Cells["Y" + start].Value = item.CostCenter_IT;
                        ExportData.Cells["Z" + start].Value = item.CostCenter_EXPROD;
                        ExportData.Cells["AA" + start].Value = item.Date_Resigned;
                        start++;
                        rownumber++;
                    }



                    return File(package.GetAsByteArray(), "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", filename);
                }
            }
            catch (Exception err) { }
            return Json(new { }, JsonRequestBehavior.AllowGet);

        }

        public ActionResult DeleteEmp(string EmpNo)
        {
            bool result = true;
            try
            {
                db.M_SP_DeleteEmployee(EmpNo, user.UserName);
            }
            catch(Exception err)
            {
                result =false;
            }
            return Json(new { result = result }, JsonRequestBehavior.AllowGet);
        }
        
        public ActionResult ExportNOSchedule(string CostCode)
        {
            try
            {
                string searchnow = System.Web.HttpContext.Current.Session["Searchvaluenow"].ToString();
                CostCode = (user.CostCode == null) ? CostCode : user.CostCode;
                //CostCode = (CostCode == "undefined") ? "" : CostCode;

                string templateFilename = "EmployeeSchedule.xlsx";
                string dir = Path.GetTempPath();
                string datetimeToday = DateTime.Now.ToString("yyMMddhhmmss");
                string GroupSection = (user.CostCode != CostCode) ? CostCode : (from c in db.M_Cost_Center_List where c.Cost_Center == CostCode select c.GroupSection).FirstOrDefault();
                string filename = string.Format("EmployeeNOSchedule{0}_{1}.xlsx", datetimeToday, GroupSection);
                FileInfo newFile = new FileInfo(Path.Combine(dir, filename));
                string apptemplatePath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, @"TemplateFiles\", templateFilename);
                FileInfo templateFile = new FileInfo(apptemplatePath);

                using (ExcelPackage package = new ExcelPackage(newFile, templateFile))  //-- With template.
                {

                    List<GET_Employee_Details_Result> list = new List<GET_Employee_Details_Result>();
                    CostCode = (user.CostCode == CostCode) ? "" : CostCode;
                    list = db.GET_Employee_Details(GroupSection, 0, 100000, "", "", "").ToList();
                    list = list.Where(x => x.Schedule == null).ToList();
                    list = list.Where(x => x.ModifiedStatus.ToLower() == "active").ToList();
                    ExcelWorksheet ExportData = package.Workbook.Worksheets["AMSSheet"];
                    int start = 2;
                    if (!string.IsNullOrEmpty(searchnow))//filter
                    {
                        #region null remover
                        list = list.Where(xx => xx.EmpNo != null).ToList();
                        list = list.Where(xx => xx.First_Name != null).ToList();
                        list = list.Where(xx => xx.Family_Name != null).ToList();
                        #endregion
                        list = list.Where(x => x.First_Name.ToLower().Contains(searchnow.ToLower())
                        || x.Family_Name.ToLower().Contains(searchnow.ToLower())
                        || x.EmpNo.Contains(searchnow)
                        ).ToList<GET_Employee_Details_Result>();
                        //list = list.Where(x => x.CostCode == CostCode).ToList();

                    }
                    //else
                    //{
                    //    list = (from c in list where c.CostCode == CostCode select c).ToList();
                    //}
                    for (int i = 0; i < list.Count; i++)
                    {
                        ExportData.Cells["A" + start].Value = i+1;
                        ExportData.Cells["B" + start].Value = list[i].EmpNo;
                        ExportData.Cells["C" + start].Value = list[i].Family_Name + ", " + list[i].First_Name;
                        ExportData.Cells["D" + start].Value = list[i].ScheduleName;
                        start++;
                    }


                    //GET ALL Schedule
                    ExcelWorksheet ExportData2 = package.Workbook.Worksheets["Instructions"];
                    List<M_Schedule> SchedList = (from c in db.M_Schedule
                                                  where c.IsDeleted != true
                                                  orderby c.Type ascending
                                                  select c).ToList();
                    int d = 8;
                    for (int i = 0; i < SchedList.Count; i++)
                    {
                        ExportData2.Cells["A" + d].Value = SchedList[i].Type + "(" + SchedList[i].Timein + " - " + SchedList[i].TimeOut + ")";
                        ExportData2.Cells["D" + d].Value = SchedList[i].ID;
                        d++;
                    }

                    return File(package.GetAsByteArray(), "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", filename);
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
            return Json(new { }, JsonRequestBehavior.AllowGet);
        }


       
    }
}
