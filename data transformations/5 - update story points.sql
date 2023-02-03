-- SELECT E.story_points AS current_story_points, CL.To_String AS old_story_points
-- FROM Change_Log CL
-- LEFT JOIN Export E ON CL.Issue_ID = E.Issue_ID
-- LEFT JOIN Sprint_Issue SI on E.Sprint_Issue_ID = SI.ID
-- WHERE CL.Field = 'Story Points'
-- AND CL.Creation_Date = (
--     SELECT MAX(CL2.Creation_Date)
--     FROM Change_Log CL2
--     WHERE CL2.Creation_Date <= SI.To_Date
--     AND CL2.Field = 'Story Points'
--     AND CL.Issue_ID = CL2.Issue_ID
-- )
-- AND E.story_points <> To_String

Update Export E
LEFT JOIN Change_Log CL ON CL.Issue_ID = E.Issue_ID
LEFT JOIN Sprint_Issue SI on E.Sprint_Issue_ID = SI.ID
SET E.story_points = CAST(CL.To_String as double)
WHERE CL.Field = 'Story Points'
AND CL.Creation_Date = (
    SELECT MAX(CL2.Creation_Date)
    FROM Change_Log CL2
    WHERE CL2.Creation_Date <= SI.To_Date
    AND CL2.Field = 'Story Points'
    AND CL.Issue_ID = CL2.Issue_ID
)
AND E.story_points <> CAST(CL.To_String as double)