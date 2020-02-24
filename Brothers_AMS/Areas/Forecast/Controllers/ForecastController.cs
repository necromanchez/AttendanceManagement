using Brothers_WMS.Controllers;
using Brothers_WMS.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace Brothers_WMS.Areas.Forecast.Controllers
{
    [SessionExpire]
    public class ForecastController : Controller
    {
        // GET: Forecast/Forecast
        Brothers_AMSDBEntities db = new Brothers_AMSDBEntities();
        M_Users user = (M_Users)System.Web.HttpContext.Current.Session["user"];
        public ActionResult Forecast()
        {
            return View();
        }
    }
}