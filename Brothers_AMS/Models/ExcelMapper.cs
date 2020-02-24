using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Brothers_WMS.Models
{
    public class ExcelMapper
    {
        private string id;
        private List<String> data;

        public ExcelMapper()
        {
            data = new List<string>();
        }


        public void setId(String id)
        {
            this.id = id;
        }

        public void Convert()
        {
            if (this.id.Contains("."))
                this.id = this.id.Replace('.', '_');
        }

        public void ReverseConvert()
        {
            if (this.id.Contains("_"))
                this.id = this.id.Replace('_', '.');
        }

        public String getId()
        {
            return this.id;
        }

        public void setData(List<String> data)
        {
            this.data = data;
        }

        public List<String> getData()
        {
            return this.data;
        }
    }
}