using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Brothers_WMS.Models
{
    public class ApproverModel
    {
        public long ID { get; set; }
        public string Company { get; set; }
        public string EmployeeNo { get; set; }
        public long SectionID { get; set; }
        public string Section { get; set; }
        public bool Status { get; set; }
    }
}