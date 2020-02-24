using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Brothers_WMS.Models
{
    public class ConfigMapper
    {
        public String id { get; set; }
        public int row { get; set; }
        public int col { get; set; }
        public int span { get; set; }
        public string remarks { get; set; }

        public ConfigMapper()
        {
        }

        public ConfigMapper(String id, int row, int col, int span, string remarks)
        {
            this.id = (id.Contains(".")) ? id.Replace('.', '_') : id;
            this.row = row;
            this.col = col;
            this.span = span;
            this.remarks = remarks;
        }
    }
}