using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Brothers_WMS.Models
{
        using System;
        using System.Collections.Generic;

        public partial class AspNetUser
        {
            public AspNetUser()
            {
                this.AspNetUserClaims = new HashSet<AspNetUserClaim>();
              
            }

            public string Id { get; set; }
            public string UserName { get; set; }
            public string PasswordHash { get; set; }
            public string SecurityStamp { get; set; }
            public string Section { get; set; }
            public string Discriminator { get; set; }
            public string LastName { get; set; }
            public string FirstName { get; set; }
            public string MiddleName { get; set; }
            public string Email { get; set; }
            public string TelNo { get; set; }
            public Nullable<bool> isActive { get; set; }
            public Nullable<bool> firstTimeLogIn { get; set; }
            public string recentAccessDate { get; set; }
            public string CreateID { get; set; }
            public string CreateDate { get; set; }
            public string UpdateID { get; set; }
            public string UpdateDate { get; set; }
            public Nullable<bool> ResetPassword { get; set; }
            public Nullable<bool> locked { get; set; }
            public Nullable<int> LoginAttempts { get; set; }
            public Nullable<bool> DelFlag { get; set; }
            public string Photo { get; set; }

            public virtual ICollection<AspNetUserClaim> AspNetUserClaims { get; set; }
        
        }
    
}