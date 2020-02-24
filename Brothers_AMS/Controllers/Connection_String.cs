using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Web;

namespace Brothers_WMS.Controllers
{
    public class Connection_String
    {
        public static string AMSDB
        {
            get
            {
                return ConfigurationManager.ConnectionStrings["Brothers_AMSDB"].ConnectionString;
            }
        }
    }
}