using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Brothers_WMS.Models
{
    public class MPFilterModel
    {
        public DateTime DateFrom { get; set; }
        public DateTime DateTo { get; set; }
        public string Section { get; set; }
        public long Shift { get; set; }
        public long Line { get; set; }
        public long Process { get; set; }
    }
}

