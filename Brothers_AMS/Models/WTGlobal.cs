using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;

namespace Brothers_WMS.Models
{
    public class WTGlobal
    {
        public decimal DayShiftCountnow { get; set; }
        public decimal NightshiftCountnow { get; set; }
        public decimal Dayshift { get; set; }
        public decimal NightShift { get; set; }
        public decimal DayShiftper { get; set; }
        public decimal NightShiftper { get; set; }
        public decimal MLCountDay { get; set; }
        public decimal MLCountNight { get; set; }
        public decimal NWCountDay { get; set; }
        public decimal NWCountNight { get; set; }
    }
    
}