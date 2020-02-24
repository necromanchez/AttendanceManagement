using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Brothers_WMS.Models
{
    public class LineProcessTeamModel
    {
        public long ID { get; set; }
        public long? SectionID { get; set; }
        public string Section { get; set; }
        public string Line { get; set; }
        public bool? Status { get; set; }
    }
}