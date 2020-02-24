using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace Brothers_WMS.Areas.Summary.Controllers
{
    public class ForecastController : Controller
    {
        // GET: Summary/Forecast
        public ActionResult Forecast()
        {
            return View();
        }
    }
}