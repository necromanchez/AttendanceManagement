//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated from a template.
//
//     Manual changes to this file may cause unexpected behavior in your application.
//     Manual changes to this file will be overwritten if the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace Brothers_WMS.Models
{
    using System;
    
    public partial class Dashboard_AbsentRate_Yearly_Result
    {
        public Nullable<int> YEAR { get; set; }
        public Nullable<int> TotalDayAbsent { get; set; }
        public Nullable<int> CurrentMPTotalDay { get; set; }
        public Nullable<int> TotalNightAbsent { get; set; }
        public Nullable<int> CurrentMPTotalNight { get; set; }
        public Nullable<int> TotalNoSchedAbsent { get; set; }
        public Nullable<int> CurrentMPTotalNoSched { get; set; }
        public Nullable<int> TotalAbsent { get; set; }
        public Nullable<int> TotalMP { get; set; }
        public Nullable<decimal> DayPercent { get; set; }
        public Nullable<decimal> NightPercent { get; set; }
        public Nullable<decimal> NoSchedPercent { get; set; }
        public Nullable<decimal> TotalAbsentPercent { get; set; }
    }
}
