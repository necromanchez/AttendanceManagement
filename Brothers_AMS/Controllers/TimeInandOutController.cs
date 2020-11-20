using Brothers_WMS.Models;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Entity;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Sockets;
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

        public ActionResult GetServerDate()
        {
            DateTime? thed = db.TT_GETTIME().FirstOrDefault();//DateTime.Now;
            return Json(new { thed = thed }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult GetComIP()
        {
            var host = Dns.GetHostEntry(Dns.GetHostName());
            List<string> comip = (from ip in host.AddressList where ip.AddressFamily == AddressFamily.InterNetwork select ip.ToString()).ToList();
            return Json(new { comip = comip }, JsonRequestBehavior.AllowGet);
        }

        private string dec2Hex(long val)
        {
            return Convert.ToString(val,16);
        }
        private double hex2Dec(string strHex)
        {
            return Convert.ToInt64(strHex, 16);
        }
        
        public ActionResult GetEmployeeDetails(double RFID)
        {
            try
            {

                string SourceValue = dec2Hex(Convert.ToInt64(RFID));
                string Hexvalue = SourceValue.Substring(SourceValue.Length - 4).ToUpper();
                string Prefix = SourceValue.Remove(SourceValue.Length - 4).ToUpper();
                string THERFID = hex2Dec(Hexvalue).ToString();
                string Empnumber = "";
                bool HRInactive = false;
                #region GET Employee Details
                M_Employee_Master_List employee = new M_Employee_Master_List();
                string rawrfid = Convert.ToInt64(RFID).ToString();
                //string CurStatus = (from c in db.M_Employee_Status where c.EmployNo ==)
                DateTime? NOW = db.TT_GETTIME().FirstOrDefault();


                employee = (from c in db.M_Employee_Master_List where c.RFID == rawrfid && (from x in db.M_Employee_Status where x.EmployNo == c.EmpNo orderby x.ID descending select x.Status).FirstOrDefault().ToLower().ToString() == "active" select c).FirstOrDefault();

                if (employee == null)
                {
                    employee = (from c in db.M_Employee_Master_List where c.RFID == rawrfid select c).FirstOrDefault();
                    HRInactive = (employee != null) ? true : false;
                }
                string RFIDtoEmployeeno = "";
              
                if (employee == null)
                {
                    employee = (from c in db.M_Employee_Master_List where c.RFID == THERFID select c).FirstOrDefault();
                    Empnumber = employee.EmpNo;
                    employee.Status = ((from c in db.M_Employee_Status where c.EmployNo == Empnumber orderby c.ID descending select c.Status).FirstOrDefault() == null)?employee.Status : (from c in db.M_Employee_Status where c.EmployNo == Empnumber orderby c.ID descending select c.Status).FirstOrDefault();
                    employee.Position = ((from c in db.M_Employee_Position where c.EmployNo == Empnumber orderby c.ID descending select c.Position).FirstOrDefault() == null)?employee.Position : (from c in db.M_Employee_Position where c.EmployNo == Empnumber orderby c.ID descending select c.Position).FirstOrDefault();
                    RFIDtoEmployeeno = employee.EmpNo;
                }
                else
                {
                    Empnumber = employee.EmpNo;
                    employee.Status = ((from c in db.M_Employee_Status where c.EmployNo == Empnumber orderby c.ID descending select c.Status).FirstOrDefault() == null) ? employee.Status : (from c in db.M_Employee_Status where c.EmployNo == Empnumber orderby c.ID descending select c.Status).FirstOrDefault();
                    employee.Position = ((from c in db.M_Employee_Position where c.EmployNo == Empnumber orderby c.ID descending select c.Position).FirstOrDefault() == null) ? employee.Position : (from c in db.M_Employee_Position where c.EmployNo == Empnumber orderby c.ID descending select c.Position).FirstOrDefault();

                    string r = RFID.ToString();
                    RFIDtoEmployeeno = (from c in db.M_Employee_Master_List where c.RFID == r && c.Status.ToLower() == "active" select c.EmpNo).FirstOrDefault();
                }
                string CostCode = (from c in db.M_Employee_CostCenter where c.EmployNo == RFIDtoEmployeeno  orderby c.ID descending select c.CostCenter_AMS).FirstOrDefault();
                CostCode = (CostCode == null) ? employee.CostCode : CostCode;
                #endregion

                #region CHECK for Forms
                //string EmployeeNo = employee.EmpNo;
                //List<AF_OTfiling> forms = (from c in db.AF_OTfiling
                //                           where c.EmployeeNo == EmployeeNo
                //                           && c.EmployeeAccept == null
                //                           select c).ToList();
                #endregion


                #region Record Tap
                T_TimeTap Tapemployee = new T_TimeTap();
                Tapemployee.Employee_RFID = (employee == null) ? RFID.ToString() : employee.RFID;
                Tapemployee.Tap = db.TT_GETTIME().FirstOrDefault();
                Tapemployee.Taptype = "Initial";
                Tapemployee.Type = "No Process Initial Tap";
                Tapemployee.EmpNo = employee.EmpNo;
                db.T_TimeTap.Add(Tapemployee);
                db.SaveChanges();
                #endregion
                DateTime? servertimechecker = db.TT_GETTIME().FirstOrDefault();

                employee.Section = (from c in db.M_Cost_Center_List where c.Cost_Center == CostCode select c.GroupSection).FirstOrDefault();

                AF_ChangeSchedulefiling checkCS = (from c in db.AF_ChangeSchedulefiling where c.EmployeeNo == employee.EmpNo && c.Status == c.StatusMax && (c.DateFrom <= servertimechecker && c.DateTo >= servertimechecker) orderby c.ID descending select c).FirstOrDefault();
                long? CurrentSchedule = 0;
                if (checkCS != null)
                {
                    CurrentSchedule = checkCS.Schedule;
                }
                else
                {
                    CurrentSchedule = (from c in db.M_Employee_Master_List_Schedule where c.EmployeeNo == Empnumber where c.EffectivityDate <= NOW && c.ScheduleID != null orderby c.UpdateDate descending select c.ScheduleID).FirstOrDefault();
                }
                
                string ScheduleName = (from c in db.M_Schedule where c.ID == CurrentSchedule where c.IsDeleted != true select c.Type + " (" + c.Timein + "-" + c.TimeOut + ")").FirstOrDefault();


                return Json(new { employee = employee
                                , CostCode = CostCode
                                , HRInactive= HRInactive
                                , ScheduleName =ScheduleName}, JsonRequestBehavior.AllowGet);
            }
            catch(Exception err)
            {
                Error_Logs error = new Error_Logs();
                error.PageModule = "Tap In and Out";
                error.ErrorLog = "Error in Tap In/Out";
                error.DateLog = db.TT_GETTIME().FirstOrDefault();//DateTime.Now;
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
                List<GET_TT_ProcessAvailable_Result> Skilllist = db.GET_TT_ProcessAvailable(Convert.ToInt64(LineID), removezero.ToString()).OrderBy(x => x.Skill).ToList();
                List<GET_TT_ProcessAvailable_Uncertified_Result> UnSkilllist = db.GET_TT_ProcessAvailable_Uncertified(Convert.ToInt64(LineID), removezero.ToString()).OrderBy(x => x.Skill).ToList();

                if (Skilllist.Count == 0 && UnSkilllist.Count == 0)
                {
                    Skilllist = db.GET_TT_ProcessAvailable(Convert.ToInt64(LineID), THERFID).OrderBy(x => x.Skill).ToList();
                    UnSkilllist = db.GET_TT_ProcessAvailable_Uncertified(Convert.ToInt64(LineID), THERFID).OrderBy(x => x.Skill).ToList();
                }
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
            string TheResult = "";
            try { 
                    T_TimeInOut checklastIN = (from c in db.T_TimeInOut where c.Employee_RFID == Employee.RFID
                                               //where c.TimeOut == null
                                               orderby c.ID descending select c).FirstOrDefault();
                    string Empno = Employee.EmpNo;
                    string tapprocess = (from c in db.M_Skills where c.ID == ProcessID select c.Skill).FirstOrDefault();
                    DateTime? NOW = db.TT_GETTIME().FirstOrDefault();
                    long? CurrentSchedule = (from c in db.M_Employee_Master_List_Schedule where c.EmployeeNo == Empno where c.EffectivityDate <= NOW && c.ScheduleID != null orderby c.UpdateDate descending select c.ScheduleID).FirstOrDefault();
                    DateTime? servertimechecker = db.TT_GETTIME().FirstOrDefault();
                    AF_ChangeSchedulefiling checkCS = (from c in db.AF_ChangeSchedulefiling where c.EmployeeNo == Empno && c.Status == c.StatusMax  && (c.DateFrom <= servertimechecker && c.DateTo >= servertimechecker) orderby c.ID descending select c).FirstOrDefault(); 
                    
                   
                    string ScheduleName = (from c in db.M_Schedule where c.ID == CurrentSchedule select c.Type).FirstOrDefault();
                    string Schedule;

                    if(ScheduleName == null)
                    {
                        Schedule = "Day";
                    }
                    else if(ScheduleName.ToUpper().Contains("DAY")){
                        Schedule = "Day";
                    }
                    else
                    {
                        Schedule = "Night";
                    }
          
                    switch (Schedule)
                    {
                        case "Day":
                            switch (Mode)
                            {
                                case "IN":
                                    if (checklastIN == null) //First Time Time
                                    {
                                        T_TimeInOut timein = new T_TimeInOut();
                                        timein.Employee_RFID = Employee.RFID;
                                        timein.LineID = LineID;
                                        timein.ProcessID = ProcessID;
                                        timein.ScheduleID = CurrentSchedule;
                                        timein.EmpNo = Empno;
                                        timein.TimeIn = db.TT_GETTIME().FirstOrDefault();
                                        timein.TimeOut = null;

                                        if (checkCS != null)
                                        {
                                            timein.ScheduleID = checkCS.Schedule;
                                            timein.CSRef_No = checkCS.CS_RefNo;
                                            timein.CS_ScheduleID = checkCS.Schedule;
                                        }

                                        db.T_TimeInOut.Add(timein);
                                        db.SaveChanges();


                                        #region Record Tap
                                        T_TimeTap Tapemployee = new T_TimeTap();
                                        Tapemployee.Employee_RFID = Employee.RFID;
                                        Tapemployee.Tap = db.TT_GETTIME().FirstOrDefault();
                                        Tapemployee.Taptype = "IN";
                                        Tapemployee.Type = "With Process " + tapprocess;
                                        Tapemployee.EmpNo = Empno;
                                        db.T_TimeTap.Add(Tapemployee);
                                        db.SaveChanges();
                                        #endregion
                                    }
                                    else if (checklastIN.ProcessID != ProcessID && checklastIN.TimeOut == null)
                                    {

                                        if (checkCS != null)
                                        {
                                            checklastIN.CSRef_No = checkCS.CS_RefNo;
                                            checklastIN.CS_ScheduleID = checkCS.Schedule;
                                            checklastIN.ScheduleID = checkCS.Schedule;
                                        }
                                        checklastIN.TimeOut = db.TT_GETTIME().FirstOrDefault();
                                        db.Entry(checklastIN).State = EntityState.Modified;     //Out in Line A and in to Line B
                                        db.SaveChanges();

                                        T_TimeInOut timein = new T_TimeInOut();
                                        timein.Employee_RFID = Employee.RFID;
                                        timein.LineID = LineID;
                                        timein.ProcessID = ProcessID;
                                        timein.ScheduleID = CurrentSchedule;
                                        timein.TimeIn = db.TT_GETTIME().FirstOrDefault();
                                        timein.TimeOut = null;
                                        timein.EmpNo = Empno;
                                        if (checkCS != null)
                                        {
                                            timein.CSRef_No = checkCS.CS_RefNo;
                                            timein.CS_ScheduleID = checkCS.Schedule;
                                        }
                                        db.T_TimeInOut.Add(timein);
                                        db.SaveChanges();

                                        #region Record Tap
                                        T_TimeTap Tapemployee = new T_TimeTap();
                                        Tapemployee.Employee_RFID = Employee.RFID;
                                        Tapemployee.Tap = db.TT_GETTIME().FirstOrDefault();
                                        Tapemployee.Taptype = "IN";
                                        Tapemployee.Type = "With Process " + tapprocess;
                                        Tapemployee.EmpNo = Empno;
                                        db.T_TimeTap.Add(Tapemployee);
                                        db.SaveChanges();
                                        #endregion
                                    }
                                    else if (checklastIN.ProcessID == ProcessID && checklastIN.TimeOut != null)
                                    {
                                        T_TimeInOut timein = new T_TimeInOut();
                                        timein.Employee_RFID = Employee.RFID;
                                        timein.LineID = LineID;
                                        timein.ProcessID = ProcessID;
                                        timein.ScheduleID = CurrentSchedule;
                                        timein.TimeIn = db.TT_GETTIME().FirstOrDefault();
                                        timein.TimeOut = null;
                                        timein.EmpNo = Empno;
                                        if (checkCS != null)
                                        {
                                            timein.CSRef_No = checkCS.CS_RefNo;
                                            timein.CS_ScheduleID = checkCS.Schedule;
                                            timein.ScheduleID = checkCS.Schedule;
                                        }

                                        db.T_TimeInOut.Add(timein);
                                        db.SaveChanges();

                                        #region Record Tap
                                        T_TimeTap Tapemployee = new T_TimeTap();
                                        Tapemployee.Employee_RFID = Employee.RFID;
                                        Tapemployee.Tap = db.TT_GETTIME().FirstOrDefault();
                                        Tapemployee.Taptype = "IN";
                                        Tapemployee.Type = "With Process " + tapprocess;
                                        Tapemployee.EmpNo = Empno;
                                        db.T_TimeTap.Add(Tapemployee);
                                        db.SaveChanges();
                                        #endregion
                                    }
                                    else if (checklastIN.ProcessID == ProcessID && checklastIN.TimeOut == Convert.ToDateTime("1/1/1900 12:00:00 AM"))
                                    {
                                        T_TimeInOut timein = new T_TimeInOut();
                                        timein.Employee_RFID = Employee.RFID;
                                        timein.LineID = LineID;
                                        timein.ProcessID = ProcessID;
                                        timein.ScheduleID = CurrentSchedule;
                                        timein.TimeIn = db.TT_GETTIME().FirstOrDefault();
                                        timein.TimeOut = null;
                                        timein.EmpNo = Empno;

                                        if (checkCS != null)
                                        {
                                            timein.CSRef_No = checkCS.CS_RefNo;
                                            timein.CS_ScheduleID = checkCS.Schedule;
                                            timein.ScheduleID = checkCS.Schedule;
                                    }

                                        db.T_TimeInOut.Add(timein);
                                        db.SaveChanges();

                                        #region Record Tap
                                        T_TimeTap Tapemployee = new T_TimeTap();
                                        Tapemployee.Employee_RFID = Employee.RFID;
                                        Tapemployee.Tap = db.TT_GETTIME().FirstOrDefault();
                                        Tapemployee.Taptype = "IN";
                                        Tapemployee.Type = "With Process " + tapprocess;
                                        Tapemployee.EmpNo = Empno;
                                        db.T_TimeTap.Add(Tapemployee);
                                        db.SaveChanges();
                                        #endregion
                                    }
                                    else if (checklastIN.ProcessID != ProcessID)
                                    {
                                        T_TimeInOut timein = new T_TimeInOut();
                                        timein.Employee_RFID = Employee.RFID;
                                        timein.LineID = LineID;
                                        timein.ProcessID = ProcessID;
                                        timein.ScheduleID = CurrentSchedule;
                                        timein.TimeIn = db.TT_GETTIME().FirstOrDefault();
                                        timein.TimeOut = null;
                                        timein.EmpNo = Empno;
                                        if (checkCS != null)
                                        {
                                            timein.CSRef_No = checkCS.CS_RefNo;
                                            timein.CS_ScheduleID = checkCS.Schedule;
                                            timein.ScheduleID = checkCS.Schedule;
                                        }

                                        db.T_TimeInOut.Add(timein);
                                        db.SaveChanges();
                                        #region Record Tap
                                        T_TimeTap Tapemployee = new T_TimeTap();
                                        Tapemployee.Employee_RFID = Employee.RFID;
                                        Tapemployee.Tap = db.TT_GETTIME().FirstOrDefault();
                                        Tapemployee.Taptype = "IN";
                                        Tapemployee.Type = "With Process " + tapprocess;
                                        Tapemployee.EmpNo = Empno;
                                        db.T_TimeTap.Add(Tapemployee);
                                        db.SaveChanges();
                                        #endregion
                                    }
                                    else
                                    {
                                        #region Record Tap
                                        T_TimeTap Tapemployee = new T_TimeTap();
                                        Tapemployee.Employee_RFID = Employee.RFID;
                                        Tapemployee.Tap = db.TT_GETTIME().FirstOrDefault();
                                        Tapemployee.Taptype = "IN";
                                        Tapemployee.Type = "Same Process";
                                        Tapemployee.EmpNo = Empno;
                                        db.T_TimeTap.Add(Tapemployee);
                                        db.SaveChanges();
                                        #endregion
                                        TheResult = "SameProcess";
                                        }
                                    break;

                                case "OUT":
                                    if (checklastIN == null) //First Time Time
                                    {
                                        T_TimeInOut timein = new T_TimeInOut();
                                        timein.Employee_RFID = Employee.RFID;
                                        timein.LineID = LineID;
                                        timein.ProcessID = ProcessID;
                                        timein.ScheduleID = CurrentSchedule;
                                        
                                        timein.TimeIn = null;
                                        timein.TimeOut = db.TT_GETTIME().FirstOrDefault();
                                        timein.EmpNo = Empno;
                                        if (checkCS != null)
                                        {
                                            timein.CSRef_No = checkCS.CS_RefNo;
                                            timein.CS_ScheduleID = checkCS.Schedule;
                                            timein.ScheduleID = checkCS.Schedule;
                                        }


                                        db.T_TimeInOut.Add(timein);
                                        db.SaveChanges();
                                        #region Record Tap
                                        T_TimeTap Tapemployee = new T_TimeTap();
                                        Tapemployee.Employee_RFID = Employee.RFID;
                                        Tapemployee.Tap = db.TT_GETTIME().FirstOrDefault();
                                        Tapemployee.Taptype = "OUT";
                                        Tapemployee.Type = "No Process";
                                        Tapemployee.EmpNo = Empno;
                                        db.T_TimeTap.Add(Tapemployee);
                                        db.SaveChanges();
                                        #endregion
                                    }
                                    else if (checklastIN.TimeOut == null)
                                    {
                                        if (checkCS != null)
                                        {
                                            checklastIN.CSRef_No = checkCS.CS_RefNo;
                                            checklastIN.CS_ScheduleID = checkCS.Schedule;
                                            checklastIN.ScheduleID = checkCS.Schedule;
                                        }
                                        checklastIN.TimeOut = db.TT_GETTIME().FirstOrDefault();
                                        db.Entry(checklastIN).State = EntityState.Modified;
                                        db.SaveChanges();

                                        #region Record Tap
                                        T_TimeTap Tapemployee = new T_TimeTap();
                                        Tapemployee.Employee_RFID = Employee.RFID;
                                        Tapemployee.Tap = db.TT_GETTIME().FirstOrDefault();
                                        Tapemployee.Taptype = "OUT";
                                        tapprocess = (from c in db.M_Skills where c.ID == checklastIN.ProcessID select c.Skill).FirstOrDefault();

                                        Tapemployee.Type = "With Process " + tapprocess;
                                        Tapemployee.EmpNo = Empno;
                                        db.T_TimeTap.Add(Tapemployee);
                                        db.SaveChanges();
                                        #endregion
                                    }
                                    else if ((checklastIN.TimeOut.Value.ToShortDateString() != servertimechecker.Value.ToShortDateString()))
                                    {
                                        T_TimeInOut timein = new T_TimeInOut();
                                        timein.Employee_RFID = Employee.RFID;
                                        timein.LineID = LineID;
                                        timein.ProcessID = ProcessID;
                                        timein.ScheduleID = CurrentSchedule;

                                        timein.TimeIn = null;
                                        timein.TimeOut = db.TT_GETTIME().FirstOrDefault();
                                        timein.EmpNo = Empno;
                                        if (checkCS != null)
                                        {
                                            timein.CSRef_No = checkCS.CS_RefNo;
                                            timein.CS_ScheduleID = checkCS.Schedule;
                                            timein.ScheduleID = checkCS.Schedule;
                                        }

                                        db.T_TimeInOut.Add(timein);
                                        db.SaveChanges();
                                        #region Record Tap
                                        T_TimeTap Tapemployee = new T_TimeTap();
                                        Tapemployee.Employee_RFID = Employee.RFID;
                                        Tapemployee.Tap = db.TT_GETTIME().FirstOrDefault();
                                        Tapemployee.Taptype = "OUT";
                                        Tapemployee.Type = "No Process";
                                        Tapemployee.EmpNo = Empno;
                                        db.T_TimeTap.Add(Tapemployee);
                                        db.SaveChanges();
                                        #endregion
                                    }
                                    else
                                    {
                                        if (checkCS != null)
                                        {
                                            checklastIN.CSRef_No = checkCS.CS_RefNo;
                                            checklastIN.CS_ScheduleID = checkCS.Schedule;
                                            checklastIN.ScheduleID = checkCS.Schedule;
                                        }
                                        checklastIN.TimeOut = db.TT_GETTIME().FirstOrDefault();
                                        db.Entry(checklastIN).State = EntityState.Modified;
                                        db.SaveChanges();
                                        #region Record Tap
                                        T_TimeTap Tapemployee = new T_TimeTap();
                                        Tapemployee.Employee_RFID = Employee.RFID;
                                        Tapemployee.Tap = db.TT_GETTIME().FirstOrDefault();
                                        Tapemployee.Taptype = "OUT";
                                        tapprocess = (from c in db.M_Skills where c.ID == checklastIN.ProcessID select c.Skill).FirstOrDefault();
                                        Tapemployee.EmpNo = Empno;
                                        Tapemployee.Type = "With Process " + tapprocess;
                                        db.T_TimeTap.Add(Tapemployee);
                                        db.SaveChanges();
                                        #endregion
                                    }

                                break;
                            }
                            break;



                        case "Night":
                            switch (Mode)
                            {
                                case "IN":
                                    if (checklastIN == null) //First Time Time
                                    {
                                        T_TimeInOut timein = new T_TimeInOut();
                                        timein.Employee_RFID = Employee.RFID;
                                        timein.LineID = LineID;
                                        timein.ProcessID = ProcessID;
                                        timein.ScheduleID = CurrentSchedule;

                                        timein.TimeIn = db.TT_GETTIME().FirstOrDefault();
                                        timein.TimeOut = null;
                                        timein.EmpNo = Empno;
                                        if (checkCS != null)
                                        {
                                            timein.CSRef_No = checkCS.CS_RefNo;
                                            timein.CS_ScheduleID = checkCS.Schedule;
                                            timein.ScheduleID = checkCS.Schedule;
                                        }

                                        db.T_TimeInOut.Add(timein);
                                        db.SaveChanges();


                                        #region Record Tap
                                        T_TimeTap Tapemployee = new T_TimeTap();
                                        Tapemployee.Employee_RFID = Employee.RFID;
                                        Tapemployee.Tap = db.TT_GETTIME().FirstOrDefault();
                                        Tapemployee.Taptype = "IN";
                                        Tapemployee.Type = "With Process " + tapprocess;
                                        Tapemployee.EmpNo = Empno;
                                        db.T_TimeTap.Add(Tapemployee);
                                        db.SaveChanges();
                                        #endregion
                                    }
                                    else if (checklastIN.ProcessID != ProcessID && checklastIN.TimeOut == null)
                                    {

                                        if (checkCS != null)
                                        {
                                            checklastIN.CSRef_No = checkCS.CS_RefNo;
                                            checklastIN.CS_ScheduleID = checkCS.Schedule;
                                            checklastIN.ScheduleID = checkCS.Schedule;
                                        }

                                        checklastIN.TimeOut = db.TT_GETTIME().FirstOrDefault();
                                        db.Entry(checklastIN).State = EntityState.Modified;     //Out in Line A and in to Line B
                                        db.SaveChanges();

                                        T_TimeInOut timein = new T_TimeInOut();
                                        timein.Employee_RFID = Employee.RFID;
                                        timein.LineID = LineID;
                                        timein.ProcessID = ProcessID;
                                        timein.ScheduleID = CurrentSchedule;
                                        timein.TimeIn = db.TT_GETTIME().FirstOrDefault();
                                        timein.TimeOut = null;
                                        timein.EmpNo = Empno;
                                        if (checkCS != null)
                                        {
                                            timein.CSRef_No = checkCS.CS_RefNo;
                                            timein.CS_ScheduleID = checkCS.Schedule;
                                            timein.ScheduleID = checkCS.Schedule;
                                        }
                                        db.T_TimeInOut.Add(timein);
                                        db.SaveChanges();

                                        #region Record Tap
                                        T_TimeTap Tapemployee = new T_TimeTap();
                                        Tapemployee.Employee_RFID = Employee.RFID;
                                        Tapemployee.Tap = db.TT_GETTIME().FirstOrDefault();
                                        Tapemployee.Taptype = "IN";
                                        Tapemployee.Type = "With Process " + tapprocess;
                                        Tapemployee.EmpNo = Empno;
                                        db.T_TimeTap.Add(Tapemployee);
                                        db.SaveChanges();
                                        #endregion
                                    }
                                    else if (checklastIN.ProcessID == ProcessID && checklastIN.TimeOut != null)
                                    {
                                        T_TimeInOut timein = new T_TimeInOut();
                                        timein.Employee_RFID = Employee.RFID;
                                        timein.LineID = LineID;
                                        timein.ProcessID = ProcessID;
                                        timein.ScheduleID = CurrentSchedule;
                                        timein.TimeIn = db.TT_GETTIME().FirstOrDefault();
                                        timein.TimeOut = null;
                                        timein.EmpNo = Empno;

                                        if (checkCS != null)
                                        {
                                            timein.CSRef_No = checkCS.CS_RefNo;
                                            timein.CS_ScheduleID = checkCS.Schedule;
                                            timein.ScheduleID = checkCS.Schedule;
                                        }

                                        db.T_TimeInOut.Add(timein);
                                        db.SaveChanges();

                                        #region Record Tap
                                        T_TimeTap Tapemployee = new T_TimeTap();
                                        Tapemployee.Employee_RFID = Employee.RFID;
                                        Tapemployee.Tap = db.TT_GETTIME().FirstOrDefault();
                                        Tapemployee.Taptype = "IN";
                                        Tapemployee.Type = "With Process " + tapprocess;
                                        Tapemployee.EmpNo = Empno;
                                        db.T_TimeTap.Add(Tapemployee);
                                        db.SaveChanges();
                                        #endregion
                                    }
                                    else if (checklastIN.ProcessID == ProcessID && checklastIN.TimeOut == Convert.ToDateTime("1/1/1900 12:00:00 PM"))
                                    {
                                        T_TimeInOut timein = new T_TimeInOut();
                                        timein.Employee_RFID = Employee.RFID;
                                        timein.LineID = LineID;
                                        timein.ProcessID = ProcessID;
                                        timein.ScheduleID = CurrentSchedule;
                                        timein.TimeIn = db.TT_GETTIME().FirstOrDefault();
                                        timein.TimeOut = null;
                                        timein.EmpNo = Empno;
                                        if (checkCS != null)
                                        {
                                            timein.CSRef_No = checkCS.CS_RefNo;
                                            timein.CS_ScheduleID = checkCS.Schedule;
                                            timein.ScheduleID = checkCS.Schedule;
                                        }

                                        db.T_TimeInOut.Add(timein);
                                        db.SaveChanges();

                                        #region Record Tap
                                        T_TimeTap Tapemployee = new T_TimeTap();
                                        Tapemployee.Employee_RFID = Employee.RFID;
                                        Tapemployee.Tap = db.TT_GETTIME().FirstOrDefault();
                                        Tapemployee.Taptype = "IN";
                                        Tapemployee.Type = "With Process " + tapprocess;
                                        Tapemployee.EmpNo = Empno;
                                        db.T_TimeTap.Add(Tapemployee);
                                        db.SaveChanges();
                                        #endregion
                                    }
                                    else if (checklastIN.ProcessID != ProcessID)
                                    {
                                        T_TimeInOut timein = new T_TimeInOut();
                                        timein.Employee_RFID = Employee.RFID;
                                        timein.LineID = LineID;
                                        timein.ProcessID = ProcessID;
                                        timein.ScheduleID = CurrentSchedule;
                                        timein.TimeIn = db.TT_GETTIME().FirstOrDefault();
                                        timein.TimeOut = null;
                                        timein.EmpNo = Empno;
                                        if (checkCS != null)
                                        {
                                            timein.CSRef_No = checkCS.CS_RefNo;
                                            timein.CS_ScheduleID = checkCS.Schedule;
                                            timein.ScheduleID = checkCS.Schedule;
                                        }

                                        db.T_TimeInOut.Add(timein);
                                        db.SaveChanges();
                                        #region Record Tap
                                        T_TimeTap Tapemployee = new T_TimeTap();
                                        Tapemployee.Employee_RFID = Employee.RFID;
                                        Tapemployee.Tap = db.TT_GETTIME().FirstOrDefault();
                                        Tapemployee.Taptype = "IN";
                                        Tapemployee.Type = "With Process " + tapprocess;
                                        Tapemployee.EmpNo = Empno;
                                        db.T_TimeTap.Add(Tapemployee);
                                        db.SaveChanges();
                                        #endregion
                                    }
                                    else
                                    {
                                        #region Record Tap
                                        T_TimeTap Tapemployee = new T_TimeTap();
                                        Tapemployee.Employee_RFID = Employee.RFID;
                                        Tapemployee.Tap = db.TT_GETTIME().FirstOrDefault();
                                        Tapemployee.Taptype = "IN";
                                        Tapemployee.Type = "Same Process";
                                        Tapemployee.EmpNo = Empno;
                                        db.T_TimeTap.Add(Tapemployee);
                                        db.SaveChanges();
                                        #endregion
                                        TheResult = "SameProcess";
                                    }
                                    break;

                                case "OUT":
                                    if (checklastIN == null) //First Time Time
                                    {
                                        T_TimeInOut timein = new T_TimeInOut();
                                        timein.Employee_RFID = Employee.RFID;
                                        timein.LineID = LineID;
                                        timein.ProcessID = ProcessID;
                                        timein.ScheduleID = CurrentSchedule;

                                        timein.TimeIn = null;
                                        timein.TimeOut = db.TT_GETTIME().FirstOrDefault();
                                        timein.EmpNo = Empno;
                                        if (checkCS != null)
                                        {
                                            timein.CSRef_No = checkCS.CS_RefNo;
                                            timein.CS_ScheduleID = checkCS.Schedule;
                                            timein.ScheduleID = checkCS.Schedule;
                                        }


                                        db.T_TimeInOut.Add(timein);
                                        db.SaveChanges();
                                        #region Record Tap
                                        T_TimeTap Tapemployee = new T_TimeTap();
                                        Tapemployee.Employee_RFID = Employee.RFID;
                                        Tapemployee.Tap = db.TT_GETTIME().FirstOrDefault();
                                        Tapemployee.Taptype = "OUT";
                                        Tapemployee.Type = "No Process";
                                        Tapemployee.EmpNo = Empno;
                                        db.T_TimeTap.Add(Tapemployee);
                                        db.SaveChanges();
                                        #endregion
                                    }
                                    else if (checklastIN.TimeOut == null)
                                    {
                                        if (checkCS != null)
                                        {
                                            checklastIN.CSRef_No = checkCS.CS_RefNo;
                                            checklastIN.CS_ScheduleID = checkCS.Schedule;
                                            checklastIN.ScheduleID = checkCS.Schedule;
                                        }
                                        checklastIN.TimeOut = db.TT_GETTIME().FirstOrDefault();
                                        db.Entry(checklastIN).State = EntityState.Modified;
                                        db.SaveChanges();
                                        #region Record Tap
                                        T_TimeTap Tapemployee = new T_TimeTap();
                                        Tapemployee.Employee_RFID = Employee.RFID;
                                        Tapemployee.Tap = db.TT_GETTIME().FirstOrDefault();
                                        Tapemployee.Taptype = "OUT";
                                        tapprocess = (from c in db.M_Skills where c.ID == checklastIN.ProcessID select c.Skill).FirstOrDefault();
                                        Tapemployee.EmpNo = Empno;
                                        Tapemployee.Type = "With Process " + tapprocess;
                                        db.T_TimeTap.Add(Tapemployee);
                                        db.SaveChanges();
                                        #endregion
                                    }
                                    else if ((checklastIN.TimeOut.Value.ToShortDateString() != servertimechecker.Value.ToShortDateString()))
                                    {
                                        T_TimeInOut timein = new T_TimeInOut();
                                        timein.Employee_RFID = Employee.RFID;
                                        timein.LineID = LineID;
                                        timein.ProcessID = ProcessID;
                                        timein.ScheduleID = CurrentSchedule;

                                        timein.TimeIn = null;
                                        timein.TimeOut = db.TT_GETTIME().FirstOrDefault();
                                        timein.EmpNo = Empno;
                                        if (checkCS != null)
                                        {
                                            timein.CSRef_No = checkCS.CS_RefNo;
                                            timein.CS_ScheduleID = checkCS.Schedule;
                                            timein.ScheduleID = checkCS.Schedule;
                                        }

                                        db.T_TimeInOut.Add(timein);
                                        db.SaveChanges();
                                        #region Record Tap
                                        T_TimeTap Tapemployee = new T_TimeTap();
                                        Tapemployee.Employee_RFID = Employee.RFID;
                                        Tapemployee.Tap = db.TT_GETTIME().FirstOrDefault();
                                        Tapemployee.Taptype = "OUT";
                                        Tapemployee.Type = "No Process";
                                        Tapemployee.EmpNo = Empno;
                                        db.T_TimeTap.Add(Tapemployee);
                                        db.SaveChanges();
                                        #endregion
                                    }
                                    else
                                    {
                                        if (checkCS != null)
                                        {
                                            checklastIN.CSRef_No = checkCS.CS_RefNo;
                                            checklastIN.CS_ScheduleID = checkCS.Schedule;
                                            checklastIN.ScheduleID = checkCS.Schedule;
                                        }
                                        checklastIN.TimeOut = db.TT_GETTIME().FirstOrDefault();
                                        db.Entry(checklastIN).State = EntityState.Modified;
                                        db.SaveChanges();
                                        #region Record Tap
                                        T_TimeTap Tapemployee = new T_TimeTap();
                                        Tapemployee.Employee_RFID = Employee.RFID;
                                        Tapemployee.Tap = db.TT_GETTIME().FirstOrDefault();
                                        Tapemployee.Taptype = "OUT";
                                        tapprocess = (from c in db.M_Skills where c.ID == checklastIN.ProcessID select c.Skill).FirstOrDefault();
                                        Tapemployee.EmpNo = Empno;
                                        Tapemployee.Type = "With Process " + tapprocess;
                                        db.T_TimeTap.Add(Tapemployee);
                                        db.SaveChanges();
                                        #endregion
                                    }

                                    break;
                            }
                        break;
                    }

            }
            catch(Exception err)
            {
                Error_Logs error = new Error_Logs();
                error.PageModule = "Tap In and Out";
                error.ErrorLog = "Error in Tap In/Out";
                error.DateLog = db.TT_GETTIME().FirstOrDefault();//DateTime.Now;
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
            RFID = Convert.ToInt64(RFID).ToString();
            List<GET_Employee_TimeIns_Result> list = db.GET_Employee_TimeIns(RFID).ToList();
            if(list.Count == 0)
            {
                long removezero = Convert.ToInt64(THERFID);
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

        
        public ActionResult GetPendingTK(string RFID)
        {
            string SourceValue = dec2Hex(Convert.ToInt64(RFID));
            string Hexvalue = SourceValue.Substring(SourceValue.Length - 4);
            string Prefix = SourceValue.Remove(SourceValue.Length - 4).ToUpper();
            string THERFID = hex2Dec(Hexvalue).ToString();
            string Empnumber = "";
            
            //Server Side Parameter
            int start = Convert.ToInt32(Request["start"]);
            int length = Convert.ToInt32(Request["length"]);
            string searchValue = Request["search[value]"];
            string sortColumnName = Request["columns[" + Request["order[0][column]"] + "][name]"];
            string sortDirection = Request["order[0][dir]"];

            M_Employee_Master_List employee = new M_Employee_Master_List();
            List<TT_GETPendingTimeKeepings_Result> list = new List<TT_GETPendingTimeKeepings_Result>();
            string rawrfid = RFID.ToString();
            employee = (from c in db.M_Employee_Master_List where c.RFID == rawrfid select c).FirstOrDefault();
          
            if (employee == null)
            {
                list = db.TT_GETPendingTimeKeepings(THERFID).ToList();
            }
            else
            {
                list = db.TT_GETPendingTimeKeepings(rawrfid).ToList();
            }
            if (!string.IsNullOrEmpty(searchValue))//filter
            {
                list = list.Where(x => x.Type.ToLower().Contains(searchValue.ToLower())).ToList<TT_GETPendingTimeKeepings_Result>();
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
            list = list.Skip(start).Take(length).ToList<TT_GETPendingTimeKeepings_Result>();
            return Json(new { data = list, draw = Request["draw"], recordsTotal = totalrows, recordsFiltered = totalrowsafterfiltering }, JsonRequestBehavior.AllowGet);
            
        }

        public ActionResult SaveOTResult(long ID, string Type, string msg)
        {
            switch (Type) {

                case "CS":
                    AF_ChangeSchedulefiling file = (from c in db.AF_ChangeSchedulefiling where c.ID == ID select c).FirstOrDefault();
                    file.EmployeeAccept = DateTime.Now;
                    file.ReasonforDecline = msg;
                    db.Entry(file).State = EntityState.Modified;
                    db.SaveChanges();
                    break;
                case "DTR":
                    AF_DTRfiling files = (from c in db.AF_DTRfiling where c.ID == ID select c).FirstOrDefault();
                    files.EmployeeAccept = DateTime.Now;
                    files.ReasonforDecline = msg;
                    db.Entry(files).State = EntityState.Modified;
                    db.SaveChanges();
                    break;
                case "OT":
                    AF_OTfiling file2 = (from c in db.AF_OTfiling where c.ID == ID select c).FirstOrDefault();
                    file2.EmployeeAccept = DateTime.Now;
                    file2.ReasonforDecline = msg;
                    db.Entry(file2).State = EntityState.Modified;
                    db.SaveChanges();
                    break;

            }


            return Json(new { }, JsonRequestBehavior.AllowGet);

        }
    
    }
}