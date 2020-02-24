using Brothers_WMS.Controllers;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace Brothers_WMS.Areas.Masters.Controllers
{
    [SessionExpire]
    public class LineController : Controller
    {
        // GET: Masters/Line
        public ActionResult Line()
        {
            return View();
        }
    }
}