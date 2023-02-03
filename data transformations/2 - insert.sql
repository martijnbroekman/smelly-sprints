-- Without the original joined sprints:

-- INSERT INTO Export (description_length, type, priority, estimated_days, story_points, num_comments, avg_comment_length, sprint_days_given, is_problematic, Issue_ID, Sprint_Issue_ID)
-- WITH comments_info AS (
--     SELECT Issue_ID, COUNT(*) AS comment_count, AVG(LENGTH(Comment_Text)) AS comment_length
--     FROM Comment
--     GROUP BY Issue_ID
-- )
-- SELECT
--     LENGTH(Description) AS description_length,
--     Type AS type,
--     Priority AS priority,
--     TO_DAYS(Creation_Date) - TO_DAYS(Estimation_Date) AS estimated_days,
--     Story_Point AS story_points,
--     IFNULL(comments_info.comment_count, 0) AS num_comments,
--     comments_info.comment_length AS avg_comment_length,
--     TO_DAYS(S.End_Date) - TO_DAYS(Issue.Creation_Date) AS sprint_days_given, 
--     IF (Issue.Resolution_Date <= S.End_Date, 0, 1) AS is_problematic,
--     Issue.ID AS Issue_ID,
--     SI.ID AS Sprint_Issue_ID
-- FROM Issue
-- INNER JOIN Sprint_Issue SI on Issue.ID = SI.Issue_ID
-- INNER JOIN Sprint S on SI.Sprint_ID = S.ID
--     AND (S.Start_Date >= SI.From_Date OR SI.From_Date IS NULL)
--     AND (S.End_Date <= SI.To_Date OR SI.To_Date IS NULL)
-- LEFT JOIN comments_info ON comments_info.Issue_ID = Issue.ID

-- Combination of original join and new join:

INSERT INTO Export (description_length, type, priority, estimated_days, story_points, num_comments, avg_comment_length, sprint_days_given, is_problematic, Issue_ID, Sprint_Issue_ID)
WITH comments_info AS (
    SELECT Issue_ID, COUNT(*) AS comment_count, AVG(LENGTH(Comment_Text)) AS comment_length
    FROM Comment
    GROUP BY Issue_ID
)
SELECT
    LENGTH(Description) AS description_length,
    Type AS type,
    Priority AS priority,
    TO_DAYS(Creation_Date) - TO_DAYS(Estimation_Date) AS estimated_days,
    Story_Point AS story_points,
    IFNULL(comments_info.comment_count, 0) AS num_comments,
    comments_info.comment_length AS avg_comment_length,
    TO_DAYS(S.End_Date) - TO_DAYS(Issue.Creation_Date) AS sprint_days_given,
    IF (Issue.Resolution_Date <= S.End_Date, 0, 1) AS is_problematic,
    Issue.ID AS Issue_ID,
    SI.ID AS Sprint_Issue_ID
FROM Issue
LEFT JOIN Sprint_Issue SI on Issue.ID = SI.Issue_ID
INNER JOIN Sprint S on
    (SI.Sprint_ID = S.ID
    AND (S.Start_Date >= SI.From_Date OR SI.From_Date IS NULL)
    AND (S.End_Date <= SI.To_Date OR SI.To_Date IS NULL))
    OR Issue.Sprint_ID = S.ID
LEFT JOIN comments_info ON comments_info.Issue_ID = Issue.ID