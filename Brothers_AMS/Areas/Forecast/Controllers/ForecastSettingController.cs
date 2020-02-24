using Brothers_WMS.Controllers;
using Brothers_WMS.Models;
using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using static Brothers_WMS.Controllers.SessionExpire;

namespace Brothers_WMS.Areas.Forecast.Controllers
{
    [SessionExpire]
    public class ForecastSettingController : Controller
    {
        // GET: Forecast/ForecastSetting
        Brothers_AMSDBEntities db = new Brothers_AMSDBEntities();
        M_Users user = (M_Users)System.Web.HttpContext.Current.Session["user"];
        public ActionResult ForecastSetting()
        {
            return View();
        }

        #region For Year Forcast
        public ActionResult GetForecastYearList()
        {
            //Server Side Parameter
            int start = Convert.ToInt32(Request["start"]);
            int length = Convert.ToInt32(Request["length"]);
            string searchValue = Request["search[value]"];
            string sortColumnName = Request["columns[" + Request["order[0][column]"] + "][name]"];
            string sortDirection = Request["order[0][dir]"];

            List<FC_ForecastYears> list = new List<FC_ForecastYears>();
            list = (from c in db.FC_ForecastYears
                    select c).ToList();

            if (!string.IsNullOrEmpty(searchValue))//filter
            {
                list = list.Where(x => x.Year.ToLower().Contains(searchValue.ToLower())).ToList<FC_ForecastYears>();
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
            list = list.Skip(start).Take(length).ToList<FC_ForecastYears>();
            return Json(new { data = list, draw = Request["draw"], recordsTotal = totalrows, recordsFiltered = totalrowsafterfiltering }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult SaveYear(string Year)
        {
            FC_ForecastYears forecast = new FC_ForecastYears();
            forecast.Year = Year;
            forecast.CreateDate = DateTime.Now;
            forecast.CreateID = user.UserName;
            forecast.UpdateDate = DateTime.Now;
            forecast.UpdateID = user.UserName;
            db.FC_ForecastYears.Add(forecast);
            db.SaveChanges();
            return Json(new { }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult Updateforecast(FC_ForecastYears data)
        {
            FC_ForecastYears forecast = (from c in db.FC_ForecastYears where c.Year == data.Year select c).FirstOrDefault();
            forecast.Apr = data.Apr;
            forecast.May = data.May;
            forecast.Jun = data.Jun;
            forecast.Jul = data.Jul;
            forecast.Aug = data.Aug;
            forecast.Sep = data.Sep;
            forecast.Oct = data.Oct;
            forecast.Nov = data.Nov;
            forecast.Dec = data.Dec;
            forecast.Jan = data.Jan;
            forecast.Feb = data.Feb;
            forecast.Mar = data.Mar;
            forecast.UpdateDate = DateTime.Now;
            forecast.UpdateID = user.UserName;
            db.Entry(forecast).State = EntityState.Modified;
            db.SaveChanges();

            return Json(new { }, JsonRequestBehavior.AllowGet);
        }

        #endregion


        #region For Position Forecast
        public ActionResult GetForecastPositionList()
        {
            //Server Side Parameter
            int start = Convert.ToInt32(Request["start"]);
            int length = Convert.ToInt32(Request["length"]);
            string searchValue = Request["search[value]"];
            string sortColumnName = Request["columns[" + Request["order[0][column]"] + "][name]"];
            string sortDirection = Request["order[0][dir]"];

            List<FC_EmployeeForecast> list = new List<FC_EmployeeForecast>();
            list = (from c in db.FC_EmployeeForecast
                    where c.IsDeleted != true
                    select c).ToList();

            if (!string.IsNullOrEmpty(searchValue))//filter
            {
                list = list.Where(x => x.Position.ToLower().Contains(searchValue.ToLower())).ToList<FC_EmployeeForecast>();
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
            list = list.Skip(start).Take(length).ToList<FC_EmployeeForecast>();
            return Json(new { data = list, draw = Request["draw"], recordsTotal = totalrows, recordsFiltered = totalrowsafterfiltering }, JsonRequestBehavior.AllowGet);
        }


        public ActionResult CreateForecastPos(FC_EmployeeForecast data)
        {
            try
            {
                data.CreateID = user.UserName;
                data.CreateDate = DateTime.Now;
                data.UpdateID = user.UserName;
                data.UpdateDate = DateTime.Now;

                FC_EmployeeForecast checker = (from c in db.FC_EmployeeForecast
                                            where c.Position == data.Position
                                            && c.ClassJ == data.ClassJ
                                            && c.ClassE == data.ClassE
                                            && c.IsDeleted == false
                                    select c).FirstOrDefault();
                if (checker == null)
                {
                    db.FC_EmployeeForecast.Add(data);
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
                error.PageModule = "Master - Agency";
                error.ErrorLog = err.Message;
                error.DateLog = DateTime.Now;
                error.Username = user.UserName;
                db.Error_Logs.Add(error);
                db.SaveChanges();
                return Json(new { msg = err.Message }, JsonRequestBehavior.AllowGet);
            }
        }
        public ActionResult EditForecastPos(FC_EmployeeForecast data)
        {
            try
            {
                FC_EmployeeForecast agency = new FC_EmployeeForecast();
                agency = (from u in db.FC_EmployeeForecast.ToList()
                          where u.ID == data.ID
                          select u).FirstOrDefault();
                agency.Position = data.Position;
                agency.ClassE = data.ClassE;
                agency.ClassJ = data.ClassJ;
                agency.Unit = data.Unit;

                agency.UpdateID = user.UserName;
                agency.UpdateDate = DateTime.Now;

                FC_EmployeeForecast checker = (from c in db.FC_EmployeeForecast
                                               where c.Position == data.Position
                                               && c.ClassJ == data.ClassJ
                                               && c.ClassE == data.ClassE
                                               && c.Unit == data.Unit
                                               && c.IsDeleted == false
                                               select c).FirstOrDefault();
                if (checker == null)
                {
                    db.Entry(agency).State = EntityState.Modified;
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
                error.PageModule = "Master - Agency";
                error.ErrorLog = err.Message;
                error.DateLog = DateTime.Now;
                error.Username = user.UserName;
                db.Error_Logs.Add(error);
                db.SaveChanges();
            }

            return Json(new { msg = "Success" }, JsonRequestBehavior.AllowGet);
        }
        public ActionResult DeleteForecast(long ID)
        {
            FC_EmployeeForecast users = new FC_EmployeeForecast();
            users = (from u in db.FC_EmployeeForecast.ToList()
                     where u.ID == ID
                     select u).FirstOrDefault();
            users.IsDeleted = true;
            users.UpdateDate = DateTime.Now;
            users.UpdateID = user.UserName;
            db.Entry(users).State = EntityState.Modified;
            db.SaveChanges();
            return Json(new { msg = "Success" }, JsonRequestBehavior.AllowGet);
        }
        #endregion
    }
}