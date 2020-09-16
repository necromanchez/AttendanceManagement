using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Brothers_WMS.Models
{
    public class M_LineTeamModel
    {
        public long ID { get; set; }
        public string Section { get; set; }
        public string Line { get; set; }
        public Nullable<bool> Status { get; set; }
        public bool IsDeleted { get; set; }
        public string CreateID { get; set; }
        public System.DateTime CreateDate { get; set; }
        public string UpdateID { get; set; }
        public System.DateTime UpdateDate { get; set; }
    }
}