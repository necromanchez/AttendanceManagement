using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Brothers_WMS.Models.AFModel
{
    public class AF_DTRModel
    {
        public long ID { get; set; }
        public string DTR_RefNo { get; set; }
        public string EmployeeNo { get; set; }
        public bool Approved { get; set; }
    }
}