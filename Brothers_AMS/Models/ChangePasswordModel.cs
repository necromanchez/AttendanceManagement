using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Brothers_WMS.Models
{
    public class ChangePasswordModel
    {
        public string currentpass { get; set; }
        public string newpassword { get; set; }
        public string confirmpassword { get; set; }
    }
}