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
    
    public partial class GET_AF_DTRExport_Result
    {
        public long ID { get; set; }
        public string DTR_RefNo { get; set; }
        public string BIPH_Agency { get; set; }
        public int FileType { get; set; }
        public string Section { get; set; }
        public string EmployeeNo { get; set; }
        public string OvertimeType { get; set; }
        public System.DateTime DateFrom { get; set; }
        public System.DateTime DateTo { get; set; }
        public string Timein { get; set; }
        public string TimeOut { get; set; }
        public string OTin { get; set; }
        public string OTout { get; set; }
        public string Reason { get; set; }
        public int Status { get; set; }
        public int StatusMax { get; set; }
        public string CreateID { get; set; }
        public System.DateTime CreateDate { get; set; }
        public string UpdateID { get; set; }
        public System.DateTime UpdateDate { get; set; }
        public string Concerns { get; set; }
        public Nullable<System.DateTime> EmployeeAccept { get; set; }
        public string ReasonforDecline { get; set; }
        public string First_Name { get; set; }
        public string Family_Name { get; set; }
    }
}
