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
    
    public partial class Department_Dashboard_ManpowerAttendanceRate_Result
    {
        public Nullable<int> Year { get; set; }
        public Nullable<int> Monthnum { get; set; }
        public Nullable<int> MonthDay { get; set; }
        public int CurrentMP { get; set; }
        public int Present { get; set; }
        public Nullable<int> Absent { get; set; }
        public int MLCount { get; set; }
        public Nullable<int> NWCount { get; set; }
        public Nullable<decimal> Percentage { get; set; }
    }
}
