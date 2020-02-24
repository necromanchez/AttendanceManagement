using Microsoft.AspNet.Identity;
using Microsoft.AspNet.Identity.EntityFramework;
using System;
using System.Security.Claims;
using System.Threading.Tasks;


namespace Brothers_WMS.Models
{
    // You can add profile data for the user by adding more properties to your ApplicationUser class, please visit http://go.microsoft.com/fwlink/?LinkID=317594 to learn more.
    public class ApplicationUser : IdentityUser
    {
        public string LastName { get; set; }
        public string FirstName { get; internal set; }
        public string MiddleName { get; set; }
        public string Email { get; set; }
        public string TelNo { get; set; }
        public bool isActive { get; set; }
        public string Section { get; set; }
        public bool firstTimeLogIn { get; set; }
        public string recentAccessDate { get; set; }
        public string CreateID { get; set; }
        public string CreateDate { get; set; }
        public string UpdateID { get; set; }
        public string UpdateDate { get; set; }
        public bool ResetPassword { get; set; }
        public bool locked { get; set; }
        public int LoginAttempts { get; set; }
        public bool DelFlag { get; set; }
        public string Photo { get; set; }

    }

    public class ApplicationDbContext : IdentityDbContext<ApplicationUser>
    {
        public ApplicationDbContext()
            : base("Brother_WMSDBEntities")
        {
        }
    }
}