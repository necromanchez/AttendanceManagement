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

namespace Brothers_WMS.Controllers
{
    

    public class TimeInandOutController : Controller
    {
        // GET: TimeIn
        Brothers_AMSDBEntities db = new Brothers_AMSDBEntities();

        public ActionResult TimeInandOut()
        {
            return View();
        }

        private string dec2Hex(long val)
        {
            return Convert.ToString(val,16);
        }
        private double hex2Dec(string strHex)
        {
            return Convert.ToInt16(strHex, 16);
        }


        public ActionResult GetEmployeeDetails(double RFID)
        {
            try
            {

                string SourceValue = dec2Hex(Convert.ToInt64(RFID));
                string Hexvalue = SourceValue.Substring(SourceValue.Length - 4);
                string Prefix = SourceValue.Remove(SourceValue.Length - 4).ToUpper();
                string THERFID = hex2Dec(Hexvalue).ToString();

                
                #region GET Employee Details
                M_Employee_Master_List employee = new M_Employee_Master_List();
                string rawrfid = RFID.ToString();
                employee = (from c in db.M_Employee_Master_List where c.RFID == rawrfid select c).FirstOrDefault();
                string RFIDtoEmployeeno = "";
               
                
                if (employee == null)
                {
                    employee = (from c in db.M_Employee_Master_List where c.RFID == THERFID select c).FirstOrDefault();
                    RFIDtoEmployeeno = employee.EmpNo;
                }
                else
                {
                    string r = RFID.ToString();
                    RFIDtoEmployeeno = (from c in db.M_Employee_Master_List where c.RFID == r select c.EmpNo).FirstOrDefault();
                }
                
                string CostCode = (from c in db.M_Employee_CostCenter where c.EmployNo == RFIDtoEmployeeno orderby c.ID descending select c.CostCenter_AMS).FirstOrDefault();
                #endregion

                #region CHECK for Forms
                //string EmployeeNo = employee.EmpNo;
                //List<AF_OTfiling> forms = (from c in db.AF_OTfiling
                //                           where c.EmployeeNo == EmployeeNo
                //                           && c.EmployeeAccept == null
                //                           select c).ToList();
                #endregion
                return Json(new { employee = employee, CostCode = CostCode }, JsonRequestBehavior.AllowGet);
            }
            catch(Exception err)
            {
                Error_Logs error = new Error_Logs();
                error.PageModule = "Time In";
                error.ErrorLog = err.Message;
                error.DateLog = DateTime.Now;
                error.Username = RFID.ToString();
                db.Error_Logs.Add(error);
                db.SaveChanges();
                return Json(new { employee = "", Section = "" }, JsonRequestBehavior.AllowGet);

            }


        }

        public ActionResult GetProcesses(string LineID, string RFID)
        {
            if (LineID != "")
            {
                string SourceValue = dec2Hex(Convert.ToInt64(RFID));
                string Hexvalue = SourceValue.Substring(SourceValue.Length - 4);
                string Prefix = SourceValue.Remove(SourceValue.Length - 4).ToUpper();
                string THERFID = hex2Dec(Hexvalue).ToString();

                long removezero = Convert.ToInt64(RFID);
                List<GET_TT_ProcessAvailable_Result> Skilllist = db.GET_TT_ProcessAvailable(Convert.ToInt64(LineID), THERFID).OrderBy(x => x.Skill).ToList();
                List<GET_TT_ProcessAvailable_Uncertified_Result> UnSkilllist = db.GET_TT_ProcessAvailable_Uncertified(Convert.ToInt64(LineID), THERFID).OrderBy(x => x.Skill).ToList();

                if (Skilllist.Count == 0 && UnSkilllist.Count == 0)
                {
                    Skilllist = db.GET_TT_ProcessAvailable(Convert.ToInt64(LineID), removezero.ToString()).OrderBy(x => x.Skill).ToList();
                    UnSkilllist = db.GET_TT_ProcessAvailable_Uncertified(Convert.ToInt64(LineID), removezero.ToString()).OrderBy(x => x.Skill).ToList();
                }

                //List<GET_TT_ProcessNotAvailable_Result> UnSkilllist = db.GET_TT_ProcessNotAvailable(LineID).ToList();
                return Json(new { Skilllist = Skilllist, UnSkilllist = UnSkilllist }, JsonRequestBehavior.AllowGet);
            }
            else
            {
                return Json(new { Skilllist = "", UnSkilllist = "" }, JsonRequestBehavior.AllowGet);
            }
            //return Json(new { Skilllist = Skilllist }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult ConfirmOut(string RFID, long LineID)
        {
            bool timeoutnow = false;
            T_TimeInOut checklastIN = (from c in db.T_TimeInOut where c.Employee_RFID == RFID orderby c.TimeIn descending select c).FirstOrDefault();
            
            if (checklastIN.TimeIn == DateTime.Now.Date && checklastIN.LineID == LineID)
            {
                timeoutnow = true;
            }
            return Json(new { timeoutnow = timeoutnow }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult SaveTimein(M_Employee_Master_List Employee, long LineID, long ProcessID, string Mode)
        {
            //DateTime startDateTime = DateTime.Today.AddDays(-1).AddTicks(-1); ; //Today at 00:00:00
            //DateTime endDateTime = DateTime.Today.AddDays(1).AddTicks(-1); //Today at 23:59:59
            T_TimeInOut checklastIN = (from c in db.T_TimeInOut where c.Employee_RFID == Employee.RFID
                                       //where c.TimeOut == null
                                       orderby c.ID descending select c).FirstOrDefault();
            string Empno = Employee.EmpNo;
            string TheResult = "";
            long? CurrentSchedule = (from c in db.M_Employee_Master_List_Schedule where c.EmployeeNo == Empno orderby c.ID descending select c.ScheduleID_CSTemp).FirstOrDefault();
            if(CurrentSchedule == null)
            {
                CurrentSchedule = (from c in db.M_Employee_Master_List_Schedule where c.EmployeeNo == Empno orderby c.ID descending select c.ScheduleID).FirstOrDefault();
            }

            try
            {
               
                    if (Mode == "IN")
                    {
                        if (checklastIN == null) //Check if last In was yesterday
                        {

                            T_TimeInOut timein = new T_TimeInOut();
                            timein.Employee_RFID = Employee.RFID;
                            timein.LineID = LineID;
                            timein.ProcessID = ProcessID;
                            timein.ScheduleID = CurrentSchedule;
                        //DateTime s = DateTime.Now;
                        //TimeSpan ts = new TimeSpan(18, 30, 0);
                        //s = s.Date + ts;
                        timein.TimeIn = DateTime.Now;
                            timein.TimeOut = null;

                            db.T_TimeInOut.Add(timein);
                            db.SaveChanges();
                        }
                        else if (checklastIN.LineID != LineID && checklastIN.ProcessID != ProcessID)
                        {
                            if (checklastIN.TimeIn != null)
                            {
                                checklastIN.TimeOut = DateTime.Now;
                                db.Entry(checklastIN).State = EntityState.Modified;     //Out in Line A and in to Line B
                                db.SaveChanges();
                            }

                            T_TimeInOut timein = new T_TimeInOut();
                            timein.Employee_RFID = Employee.RFID;
                            timein.LineID = LineID;
                            timein.ProcessID = ProcessID;
                            timein.ScheduleID = CurrentSchedule;
                            timein.TimeIn = DateTime.Now;
                            timein.TimeOut = null;

                            db.T_TimeInOut.Add(timein);
                            db.SaveChanges();
                        }
                        else if (checklastIN.ProcessID != ProcessID)
                        {
                            if (checklastIN.TimeOut != Convert.ToDateTime("1/1/1900 12:00:00 AM") && checklastIN.TimeOut != Convert.ToDateTime("1/1/1900 12:00:00 PM"))
                            {
                                checklastIN.TimeOut = DateTime.Now;
                                db.Entry(checklastIN).State = EntityState.Modified;     //Out in Process A and in to Process B
                                db.SaveChanges();
                            }

                            T_TimeInOut timein = new T_TimeInOut();

                            timein.Employee_RFID = Employee.RFID;
                            timein.LineID = LineID;
                            timein.ProcessID = ProcessID;
                            timein.ScheduleID = CurrentSchedule;
                            timein.TimeIn = DateTime.Now;
                            timein.TimeOut = null;

                            db.T_TimeInOut.Add(timein);
                            db.SaveChanges();
                        }
                        else
                        {
                        string processID = checklastIN.ProcessID.ToString();
                        List<string> result = db.TT_TimeInAccept(processID, checklastIN.Employee_RFID).ToList();


                        if (result[0].Contains("ACCEPT"))
                        {
                            T_TimeInOut timein = new T_TimeInOut();
                            timein.Employee_RFID = Employee.RFID;
                            timein.LineID = LineID;
                            timein.ProcessID = ProcessID;
                            timein.ScheduleID = CurrentSchedule;
                            timein.TimeIn = DateTime.Now;
                            timein.TimeOut = null;

                            db.T_TimeInOut.Add(timein);
                            db.SaveChanges();
                        }
                        else
                        {
                            TheResult = "SameProcess";
                        }
                        }


                    }
                    else
                    {
                        if (checklastIN != null)
                        {
                            if (checklastIN.TimeOut == null)
                            {
                            //DateTime s = DateTime.Now;
                            //TimeSpan ts = new TimeSpan(19, 00, 0);
                            //s = s.Date + ts;
                            //checklastIN.TimeOut = s;
                            checklastIN.TimeOut = DateTime.Now;
                            db.Entry(checklastIN).State = EntityState.Modified;     //Time Out
                                db.SaveChanges();
                            }
                        else
                        {
                            if (checklastIN.TimeOut != Convert.ToDateTime("1/1/1900 12:00:00 AM") && checklastIN.TimeOut != Convert.ToDateTime("1/1/1900 12:00:00 PM"))
                            {
                                checklastIN.TimeOut = DateTime.Now;
                                db.Entry(checklastIN).State = EntityState.Modified;     //Time Out
                                db.SaveChanges();
                            }
                            else
                            {
                                T_TimeInOut timein = new T_TimeInOut();
                                timein.Employee_RFID = Employee.RFID;
                                timein.LineID = LineID;
                                timein.ProcessID = ProcessID;
                                timein.ScheduleID = CurrentSchedule;
                                timein.TimeIn = null;
                                timein.TimeOut = DateTime.Now;

                                db.T_TimeInOut.Add(timein);
                                db.SaveChanges();
                            }
                        }
                      
                        }
                        else
                        {
                        T_TimeInOut timein = new T_TimeInOut();
                        timein.Employee_RFID = Employee.RFID;
                        timein.LineID = LineID;
                        timein.ProcessID = ProcessID;
                        timein.ScheduleID = CurrentSchedule;
                        timein.TimeIn = null;
                        timein.TimeOut = DateTime.Now;

                        db.T_TimeInOut.Add(timein);
                        db.SaveChanges();
                    }
                }
              
            }
            catch(Exception err)
            {
                Error_Logs error = new Error_Logs();
                error.PageModule = "Login";
                error.ErrorLog = err.Message;
                error.DateLog = DateTime.Now;
                error.Username = Employee.EmpNo;
                db.Error_Logs.Add(error);
                db.SaveChanges();
            }

            LineViewController line = new LineViewController();
           

            return Json(new { TheResult = TheResult }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult GetAttendanceDetailsList(string RFID)
        {
            string SourceValue = dec2Hex(Convert.ToInt64(RFID));
            string Hexvalue = SourceValue.Substring(SourceValue.Length - 4);
            string Prefix = SourceValue.Remove(SourceValue.Length - 4).ToUpper();
            string THERFID = hex2Dec(Hexvalue).ToString();
            //Server Side Parameter
            int start = Convert.ToInt32(Request["start"]);
            int length = Convert.ToInt32(Request["length"]);
            string searchValue = Request["search[value]"];
            string sortColumnName = Request["columns[" + Request["order[0][column]"] + "][name]"];
            string sortDirection = Request["order[0][dir]"];

            List<GET_Employee_TimeIns_Result> list = db.GET_Employee_TimeIns(THERFID).ToList();
            if(list.Count == 0)
            {
                long removezero = Convert.ToInt64(RFID);
                list = db.GET_Employee_TimeIns(removezero.ToString()).ToList();
            }


            if (!string.IsNullOrEmpty(searchValue))//filter
            {
                list = list.Where(x => x.Skill.ToLower().Contains(searchValue.ToLower())).ToList<GET_Employee_TimeIns_Result>();
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
            list = list.Skip(start).Take(length).ToList<GET_Employee_TimeIns_Result>();
            return Json(new { data = list, draw = Request["draw"], recordsTotal = totalrows, recordsFiltered = totalrowsafterfiltering }, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        public ActionResult UploadEmployeePhoto(string Employee)
        {
                #region Save to Server
                bool isSuccess = false;
                string serverMessage = string.Empty;
                var fileOne = Request.Files[0] as HttpPostedFileBase;
                string uploadPath = Server.MapPath(@"~/PictureResources/EmployeePhoto/");
                string newFileOne = Path.Combine(uploadPath, fileOne.FileName);
                //fileOne.SaveAs(newFileOne);
                //fileOne.SaveAs(HttpContext.Server.MapPath("~/PictureResources/EmployeePhoto/") + Path.GetFileName(fileOne.FileName));
                fileOne.SaveAs(HttpContext.Server.MapPath("~/PictureResources/EmployeePhoto/") + Path.GetFileName(Regex.Replace(fileOne.FileName, @"\s+", "")));

            #endregion
            string SourceValue = dec2Hex(Convert.ToInt64(Employee));
            string Hexvalue = SourceValue.Substring(SourceValue.Length - 4);
            string Prefix = SourceValue.Remove(SourceValue.Length - 4).ToUpper();
            string THERFID = hex2Dec(Hexvalue).ToString();
            #region ImageSet
            M_Employee_Master_List pack = (from c in db.M_Employee_Master_List where c.RFID == THERFID select c).FirstOrDefault();
            string[]data = fileOne.FileName.Split('\\');
            //pack.EmployeePhoto = data[data.Length-1];//fileOne.FileName;
            pack.EmployeePhoto = Regex.Replace(data[data.Length - 1], @"\s+", "");//fileOne.FileName;

            db.Entry(pack).State = EntityState.Modified;
            db.SaveChanges();

            #endregion
            

            return Json(new { wew = "" }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult UploadEmployeePhoto2(string Employee)
        {
            #region Save to Server
            bool isSuccess = false;
            string serverMessage = string.Empty;
            var fileOne = Request.Files[0] as HttpPostedFileBase;
            string uploadPath = Server.MapPath(@"~/PictureResources/EmployeePhoto/");
            string newFileOne = Path.Combine(uploadPath, fileOne.FileName);
            //fileOne.SaveAs(newFileOne);
            //fileOne.SaveAs(HttpContext.Server.MapPath("~/PictureResources/EmployeePhoto/") + Path.GetFileName(fileOne.FileName));
            fileOne.SaveAs(HttpContext.Server.MapPath("~/PictureResources/EmployeePhoto/") + Path.GetFileName(Regex.Replace(fileOne.FileName, @"\s+", "")));

           
            M_Employee_Master_List pack = (from c in db.M_Employee_Master_List where c.EmpNo == Employee select c).FirstOrDefault();
            string[] data = fileOne.FileName.Split('\\');
            //pack.EmployeePhoto = data[data.Length-1];//fileOne.FileName;
            pack.EmployeePhoto = Regex.Replace(data[data.Length - 1], @"\s+", "");//fileOne.FileName;

            db.Entry(pack).State = EntityState.Modified;
            db.SaveChanges();

            #endregion


            return Json(new { wew = "" }, JsonRequestBehavior.AllowGet);
        }

    }
}