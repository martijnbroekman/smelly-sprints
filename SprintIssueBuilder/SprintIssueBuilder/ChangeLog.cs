using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SprintIssueBuilder
{
    public class ChangeLog
    {
        public int Issue_ID { get; set; }

        public string From_Value { get; set; }

        public string To_Value { get; set; }

        public DateTime Creation_Date { get; set; }
    }
}
