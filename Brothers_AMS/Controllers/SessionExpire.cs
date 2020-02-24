using Brothers_WMS.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace Brothers_WMS.Controllers
{
    public class SessionExpire : ActionFilterAttribute
    {
        // GET: SessionExpire
        public override void OnActionExecuting(ActionExecutingContext filterContext)
        {
            M_Users user = (M_Users)HttpContext.Current.Session["user"];
            string url = HttpContext.Current.Request.Url.AbsoluteUri;
            if (user == null)
            {
               
                System.Web.HttpContext.Current.Session["urlmail"] = url;
                filterContext.Result = new RedirectResult("/Login/Login");
                return;
            }
            if (!url.Contains("RNO") && !url.Contains("draw"))
            {
                System.Web.HttpContext.Current.Session["RNO"] = null;
            }
            System.Web.HttpContext.Current.Session["one"] = user.LastName;
            base.OnActionExecuting(filterContext);
        }

        public static class TypeHelper
        {
            public static object GetPropertyValue(object obj, string name)
            {
                return obj == null ? null : obj.GetType()
                .GetProperty(name)
                .GetValue(obj, null);
            }
        }
    }

}