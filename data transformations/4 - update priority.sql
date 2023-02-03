-- SELECT E.priority AS current_priority, CL.To_String AS old_priority
-- FROM Change_Log CL
-- LEFT JOIN Export E ON CL.Issue_ID = E.Issue_ID
-- LEFT JOIN Sprint_Issue SI on E.Sprint_Issue_ID = SI.ID
-- WHERE CL.Field = 'priority'
-- AND CL.Creation_Date = (
--     SELECT MAX(CL2.Creation_Date)
--     FROM Change_Log CL2
--     WHERE CL2.Creation_Date <= SI.To_Date
--     AND CL2.Field = 'priority'
--     AND CL.Issue_ID = CL2.Issue_ID
-- )
-- AND E.priority <> To_String

Update Export E
LEFT JOIN Change_Log CL ON CL.Issue_ID = E.Issue_ID
LEFT JOIN Sprint_Issue SI on E.Sprint_Issue_ID = SI.ID
SET E.priority = CL.To_String
WHERE CL.Field = 'priority'
AND CL.Creation_Date = (
    SELECT MAX(CL2.Creation_Date)
    FROM Change_Log CL2
    WHERE CL2.Creation_Date <= SI.To_Date
    AND CL2.Field = 'priority'
    AND CL.Issue_ID = CL2.Issue_ID
)
AND E.priority <> To_String