using Brothers_WMS.Controllers;
using Brothers_WMS.Models;
using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Globalization;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using static Brothers_WMS.Controllers.SessionExpire;

namespace Brothers_WMS.Areas.Masters.Controllers
{
    [SessionExpire]
    public class ScheduleController : Controller
    {
        // GET: Masters/Schedule
        Brothers_AMSDBEntities db = new Brothers_AMSDBEntities();
        M_Users user = (M_Users)System.Web.HttpContext.Current.Session["user"];
        public ActionResult Schedule()
        {
            return View();
        }

        public ActionResult GetScheduleList()
        {
            //Server Side Parameter
            int start = Convert.ToInt32(Request["start"]);
            int length = Convert.ToInt32(Request["length"]);
            string searchValue = Request["search[value]"];
            string sortColumnName = Request["columns[" + Request["order[0][column]"] + "][name]"];
            string sortDirection = Request["order[0][dir]"];

            List<GET_ScheduleList_Result> list = new List<GET_ScheduleList_Result>();
            list = (from c in db.GET_ScheduleList()
                    where c.IsDeleted == false
                    select c).ToList();

            if (!string.IsNullOrEmpty(searchValue))//filter
            {
                list = list.Where(x => x.Type.ToLower().Contains(searchValue.ToLower())
                || x.Type.ToLower().Contains(searchValue.ToLower())).ToList<GET_ScheduleList_Result>();
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
            list = list.Skip(start).Take(length).ToList<GET_ScheduleList_Result>();
            return Json(new { data = list, draw = Request["draw"], recordsTotal = totalrows, recordsFiltered = totalrowsafterfiltering }, JsonRequestBehavior.AllowGet);
        }
        public ActionResult CreateSchedule(M_Schedule data)
        {
            try
            {
                string startTime = data.Timein.ToString();
                string endTime = data.TimeOut.ToString();

                DateTime start = DateTime.Parse(startTime);
                DateTime end = DateTime.Parse(endTime);
              
                TimeSpan duration = end.Subtract(start);

                //if (duration.TotalHours != 0)
                if (duration.TotalHours > 0) //change to military time
                {
                    data.CreateID = user.UserName;
                    data.CreateDate = DateTime.Now;
                    data.UpdateID = user.UserName;
                    data.UpdateDate = DateTime.Now;

                    M_Schedule checker = (from c in db.M_Schedule
                                          where c.Type == data.Type
                                          && c.Timein == data.Timein
                                          && c.TimeOut == data.TimeOut
                                          && c.Status == data.Status
                                          && c.IsDeleted == false
                                          select c).FirstOrDefault();
                    if (checker == null)
                    {
                        db.M_Schedule.Add(data);
                        db.SaveChanges();
                        return Json(new { msg = "Success" }, JsonRequestBehavior.AllowGet);
                    }
                    else
                    {
                        return Json(new { msg = "Failed" }, JsonRequestBehavior.AllowGet);

                    }
                }
                else
                {
                    return Json(new { msg = "zero" }, JsonRequestBehavior.AllowGet);
                }
            }
            catch (Exception err)
            {
                Error_Logs error = new Error_Logs();
                error.PageModule = "Master - Schedule";
                error.ErrorLog = err.Message;
                error.DateLog = DateTime.Now;
                error.Username = user.UserName;
                db.Error_Logs.Add(error);
                db.SaveChanges();
                return Json(new { msg = err.Message }, JsonRequestBehavior.AllowGet);
            }
        }
        public ActionResult DeleteSchedule(int ID)
        {
            M_Schedule schedule = new M_Schedule();
            schedule = (from u in db.M_Schedule.ToList()
                        where u.ID == ID
                        select u).FirstOrDefault();
            schedule.IsDeleted = true;
            schedule.UpdateDate = DateTime.Now;
            schedule.UpdateID = user.UserName;
            db.Entry(schedule).State = EntityState.Modified;
            db.SaveChanges();
            return Json(new { msg = "Success" }, JsonRequestBehavior.AllowGet);
        }
        public ActionResult EditSchedule(M_Schedule data)
        {
            try
            {
                M_Schedule schedule = new M_Schedule();
                schedule = (from u in db.M_Schedule.ToList()
                            where u.ID == data.ID
                            select u).FirstOrDefault();
                schedule.Type = data.Type;
                schedule.Timein = data.Timein;
                schedule.TimeOut = data.TimeOut;
                schedule.Status = data.Status;

                schedule.UpdateID = user.UserName;
                schedule.UpdateDate = DateTime.Now;

                M_Schedule checker = (from c in db.M_Schedule
                                      where c.Type == data.Type
                                      && c.Timein == data.Timein
                                      && c.TimeOut == data.TimeOut
                                      && c.Status == data.Status
                                      && c.IsDeleted == false
                                      select c).FirstOrDefault();
                if (checker == null)
                {
                    db.Entry(schedule).State = EntityState.Modified;
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
                error.PageModule = "Master - Schedule";
                error.ErrorLog = err.Message;
                error.DateLog = DateTime.Now;
                error.Username = user.UserName;
                db.Error_Logs.Add(error);
                db.SaveChanges();
            }

            return Json(new { msg = "Success" }, JsonRequestBehavior.AllowGet);
        }


        //BREAKS

        public ActionResult GetBreaks(int ID)
        {
            //Server Side Parameter
            int start = Convert.ToInt32(Request["start"]);
            int length = Convert.ToInt32(Request["length"]);
            string searchValue = Request["search[value]"];
            string sortColumnName = Request["columns[" + Request["order[0][column]"] + "][name]"];
            string sortDirection = Request["order[0][dir]"];

            List<M_ScheduleBreaks> list = new List<M_ScheduleBreaks>();
            list = (from c in db.M_ScheduleBreaks where c.ScheduleID == ID
                    select c).ToList();

            if (!string.IsNullOrEmpty(searchValue))//filter
            {
                list = list.Where(x => x.BreakIn.ToLower().Contains(searchValue.ToLower())
                || x.BreakOut.ToLower().Contains(searchValue.ToLower())).ToList<M_ScheduleBreaks>();
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
            list = list.Skip(start).Take(length).ToList<M_ScheduleBreaks>();
            return Json(new { data = list, draw = Request["draw"], recordsTotal = totalrows, recordsFiltered = totalrowsafterfiltering }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult EditBreaks(M_ScheduleBreaks data)
        {
            try
            {
                M_ScheduleBreaks schedule = new M_ScheduleBreaks();
                schedule = (from u in db.M_ScheduleBreaks.ToList()
                            where u.ID == data.ID
                            select u).FirstOrDefault();
                schedule.BreakIn = data.BreakIn;
                schedule.BreakOut = data.BreakOut;
                TimeSpan BreakIn = DateTime.Parse(data.BreakIn).TimeOfDay;
                TimeSpan BreakOut = DateTime.Parse(data.BreakOut).TimeOfDay;
                TimeSpan ts = BreakIn - BreakOut;

                schedule.BreakTime = ts.TotalMinutes.ToString();
                schedule.UpdateID = user.UserName;
                schedule.UpdateDate = DateTime.Now;

                M_ScheduleBreaks checker = (from c in db.M_ScheduleBreaks
                                            where c.BreakIn == data.BreakIn
                                            && c.BreakOut == data.BreakOut
                                            && c.ScheduleID == data.ScheduleID
                                      select c).FirstOrDefault();
                if (checker == null)
                {
                    db.Entry(schedule).State = EntityState.Modified;
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
                error.PageModule = "Master - Schedule";
                error.ErrorLog = err.Message;
                error.DateLog = DateTime.Now;
                error.Username = user.UserName;
                db.Error_Logs.Add(error);
                db.SaveChanges();
            }

            return Json(new { msg = "Success" }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult AddBreaks(M_ScheduleBreaks data)
        {
            try
            {
                string startTime = data.BreakOut.ToString();
                string endTime = data.BreakIn.ToString();

                DateTime start = DateTime.Parse(startTime);
                DateTime end = DateTime.Parse(endTime);
                if (start > end)
                {
                    end = end.AddDays(1);
                }

                TimeSpan duration = end.Subtract(start);

                if (duration.TotalMinutes > 0)
                {

                    data.BreakTime = duration.TotalMinutes.ToString();
                    data.CreateID = user.UserName;
                    data.CreateDate = DateTime.Now;
                    data.UpdateID = user.UserName;
                    data.UpdateDate = DateTime.Now;

                    M_ScheduleBreaks checker = (from c in db.M_ScheduleBreaks
                                                where c.BreakTime == data.BreakTime
                                                && c.BreakIn == data.BreakIn
                                                && c.BreakOut == data.BreakOut
                                                && c.ScheduleID == data.ScheduleID
                                                select c).FirstOrDefault();
                    if (checker == null)
                    {
                        db.M_ScheduleBreaks.Add(data);
                        db.SaveChanges();
                        return Json(new { msg = "Success", ID = data.ScheduleID }, JsonRequestBehavior.AllowGet);
                    }
                    else
                    {
                        return Json(new { msg = "Failed", ID = data.ScheduleID }, JsonRequestBehavior.AllowGet);

                    }
                }
                else
                {
                    return Json(new { msg = "zero", ID = data.ScheduleID }, JsonRequestBehavior.AllowGet);

                }
            }
            catch (Exception err)
            {
                Error_Logs error = new Error_Logs();
                error.PageModule = "Master - Schedule";
                error.ErrorLog = err.Message;
                error.DateLog = DateTime.Now;
                error.Username = user.UserName;
                db.Error_Logs.Add(error);
                db.SaveChanges();
                return Json(new { msg = err.Message }, JsonRequestBehavior.AllowGet);
            }
        }

        public ActionResult DeleteScheduleBreak(int ID)
        {
            M_ScheduleBreaks schedule = new M_ScheduleBreaks();
            schedule = (from u in db.M_ScheduleBreaks.ToList()
                        where u.ID == ID
                        select u).FirstOrDefault();
            db.M_ScheduleBreaks.Remove(schedule);
            db.SaveChanges();
            return Json(new { msg = "Success" }, JsonRequestBehavior.AllowGet);
        }
    }
}