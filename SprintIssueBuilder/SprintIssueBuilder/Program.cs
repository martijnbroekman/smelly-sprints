using Dapper;
using MySql.Data.MySqlClient;
using System.Data;
using System.Data.SqlClient;
using Z.BulkOperations;

namespace SprintIssueBuilder
{
    public class Program
    {
        public static void Main(string[] args)
        {
            var sprintIssues = new List<SprintIssue>();

            using (var connection = new MySqlConnection("Server=localhost;port=3306;uid=root;pwd=password;database=tawos;"))
            {
                var logs = connection.Query<ChangeLog>("SELECT * FROM Change_Log WHERE Field = 'Sprint'");
                var groupedLogs = logs.GroupBy(log => log.Issue_ID);

                foreach (var grouping in groupedLogs)
                {
                    var issueId = grouping.Key;
                    var issueLogs = grouping.OrderBy(log => log.Creation_Date).ToList();
                    
                    if (issueLogs.Count == 1)
                    {
                        sprintIssues.AddRange(CreateFromSingle(issueLogs[0]));
                    }
                    else
                    {
                        sprintIssues.AddRange(CreateFromMultiple(issueId, issueLogs));
                    }
                }

                //Console.WriteLine(sprintIssues.Count());
                //Console.WriteLine(sprintIssues.Where(x => x.To_Date != null && x.From_Date != null).Select(x => (x.To_Date - x.From_Date).Value.Days).Max());
                //Console.WriteLine(sprintIssues.Where(x => (x.To_Date != null && x.From_Date != null) && x.To_Date == x.From_Date).Count());
            }

            using (var connection = new MySqlConnection("Server=localhost;port=3306;uid=root;pwd=password;database=tawos;"))
            {
                connection.Open();

                var bulk = new BulkOperation(connection);
                bulk.ColumnMappings.Add(nameof(SprintIssue.Issue_ID), nameof(SprintIssue.Issue_ID));
                bulk.ColumnMappings.Add(nameof(SprintIssue.Sprint_Jira_ID), nameof(SprintIssue.Sprint_Jira_ID));
                bulk.ColumnMappings.Add(nameof(SprintIssue.From_Date), nameof(SprintIssue.From_Date));
                bulk.ColumnMappings.Add(nameof(SprintIssue.To_Date), nameof(SprintIssue.To_Date));
                bulk.DestinationTableName = "Jira_Sprint_Issue";
                bulk.BulkInsert(ToDataTable(sprintIssues));
            }
        }


        public static DataTable ToDataTable(List<SprintIssue> sprintIssues)
        {
            var dataTable = new DataTable();

            dataTable.Columns.Add(new DataColumn(nameof(SprintIssue.Issue_ID), typeof(int)));
            dataTable.Columns.Add(new DataColumn(nameof(SprintIssue.Sprint_Jira_ID), typeof(int)));
            dataTable.Columns.Add(new DataColumn(nameof(SprintIssue.From_Date), typeof(DateTime)));
            dataTable.Columns.Add(new DataColumn(nameof(SprintIssue.To_Date), typeof(DateTime)));

            foreach (var sprintIssue in sprintIssues)
            {
                var row = dataTable.NewRow();
                row[nameof(SprintIssue.Issue_ID)] = sprintIssue.Issue_ID;
                row[nameof(SprintIssue.Sprint_Jira_ID)] = sprintIssue.Sprint_Jira_ID;
                row[nameof(SprintIssue.From_Date)] = sprintIssue.From_Date ?? (object)DBNull.Value;
                row[nameof(SprintIssue.To_Date)] = sprintIssue.To_Date ?? (object)DBNull.Value;

                dataTable.Rows.Add(row);
            }

            return dataTable;
        }

        public static IEnumerable<SprintIssue> CreateFromSingle(ChangeLog issueLog)
        {
            var fromSprints = issueLog.From_Value?.Split(", ", StringSplitOptions.RemoveEmptyEntries) ?? new string[0];
            var toSprints = issueLog.To_Value?.Split(", ", StringSplitOptions.RemoveEmptyEntries) ?? new string[0];
            var unionSprints = new HashSet<string>(fromSprints.Union(toSprints));

            foreach (var fromSprint in fromSprints)
            {
                if (unionSprints.Contains(fromSprint))
                {
                    yield return new SprintIssue
                    {
                        Issue_ID = issueLog.Issue_ID,
                        Sprint_Jira_ID = int.Parse(fromSprint)
                    };
                }
                else
                {
                    yield return new SprintIssue
                    {
                        Issue_ID = issueLog.Issue_ID,
                        Sprint_Jira_ID = int.Parse(fromSprint),
                        To_Date = issueLog.Creation_Date
                    };
                }
            }

            foreach (var toSprint in toSprints)
            {
                if (unionSprints.Contains(toSprint))
                {
                    continue;
                }

                yield return new SprintIssue
                {
                    Issue_ID = issueLog.Issue_ID,
                    Sprint_Jira_ID = int.Parse(toSprint),
                    From_Date = issueLog.Creation_Date,
                };
            }
        }

        public static IEnumerable<SprintIssue> CreateFromMultiple(int issueId, List<ChangeLog> issueLogs)
        {
            var sprintIssueMap = new Dictionary<int, SprintIssue>();

            foreach (var issueLog in issueLogs)
            {
                var fromSprints = issueLog.From_Value?.Split(", ", StringSplitOptions.RemoveEmptyEntries) ?? new string[0];
                var toSprints = issueLog.To_Value?.Split(", ", StringSplitOptions.RemoveEmptyEntries) ?? new string[0];
                var removedSprints = fromSprints.Except(toSprints);

                foreach (var fromSprint in fromSprints)
                {
                    var sprintId = int.Parse(fromSprint);

                    if (!sprintIssueMap.ContainsKey(sprintId))
                    {
                        sprintIssueMap.Add(sprintId, new SprintIssue
                        {
                            Issue_ID = issueId,
                            Sprint_Jira_ID = sprintId,
                            // Set the end date in case its not in the to sprints
                            To_Date = issueLog.Creation_Date,
                        });
                    }
                }

                foreach (var toSprint in toSprints)
                {
                    var sprintId = int.Parse(toSprint);

                    if (sprintIssueMap.TryGetValue(sprintId, out var sprintIssue))
                    {
                        sprintIssue.To_Date = null;
                    }
                    else
                    {
                        sprintIssueMap.Add(sprintId, new SprintIssue
                        {
                            Issue_ID = issueId,
                            Sprint_Jira_ID = sprintId,
                            From_Date = issueLog.Creation_Date,
                        });
                    }
                }

                foreach (var removedSprint in removedSprints)
                {
                    var sprintId = int.Parse(removedSprint);

                    sprintIssueMap[sprintId].To_Date = issueLog.Creation_Date;
                }
            }

            return sprintIssueMap.Values;
        }
    }
}