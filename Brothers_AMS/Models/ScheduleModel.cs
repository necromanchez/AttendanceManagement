using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Brothers_WMS.Models
{
    public class ScheduleModel
    {
        public long ID { get; set; }
        public string ScheduleCode { get; set; }
        public string Type { get; set; }
        public string TimeIn { get; set; }
        public string TimeOut { get; set; }
        public bool Status { get; set; }
    }
}