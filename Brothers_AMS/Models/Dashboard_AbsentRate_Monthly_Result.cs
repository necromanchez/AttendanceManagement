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
    
    public partial class Dashboard_AbsentRate_Monthly_Result
    {
        public Nullable<int> Year { get; set; }
        public Nullable<int> Monthnum { get; set; }
        public Nullable<int> TotalDayAbsent { get; set; }
        public Nullable<decimal> AbsentPercentDay { get; set; }
        public Nullable<int> TotalNightAbsent { get; set; }
        public Nullable<decimal> AbsentPercentNight { get; set; }
        public Nullable<int> TotalNoSchedAbsent { get; set; }
        public Nullable<decimal> AbsentPercentNoSched { get; set; }
        public Nullable<decimal> TotalAbsentPercent { get; set; }
    }
}
