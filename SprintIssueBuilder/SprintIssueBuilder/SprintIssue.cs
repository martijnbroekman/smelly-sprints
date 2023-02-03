using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SprintIssueBuilder
{
    public class SprintIssue
    {
        public int Sprint_Jira_ID { get; set; }

        public int Issue_ID { get; set; }

        public DateTime? From_Date { get; set; }

        public DateTime? To_Date { get; set; }
    }
}
