using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Brothers_WMS.Models
{
    public class EmployeeSkillModel
    {
        public long ID { get; set; }
        public long? SkillID { get; set; }
        public long? Line { get; set; }
        public string Skill { get; set; }
    }
}