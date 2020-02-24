using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Brothers_WMS.Models
{
    public class AF_OTModel
    {
        public long ID { get; set; }
        public string OT_RefNo { get; set; }
        public string EmployeeNo { get; set; }
        public bool Approved { get; set; }
    }
}