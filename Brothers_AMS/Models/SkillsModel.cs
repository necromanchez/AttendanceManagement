using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Brothers_WMS.Models
{
    public class SkillsModel
    {
        public long ID { get; set; }
        public long? LineID { get; set; }
        public string Line { get; set; }
        public string Skill { get; set; }
        public string Type { get; set; }
        public int? Count { get; set; }
        public bool? Status { get; set; } 
        public string Logo { get; set; }
    }
}