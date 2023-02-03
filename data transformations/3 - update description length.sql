-- SELECT E.description_length AS current_description, LENGTH(CL.To_String) + 2 AS old_description
-- FROM Change_Log CL
-- LEFT JOIN Export E ON CL.Issue_ID = E.Issue_ID
-- LEFT JOIN Sprint_Issue SI on E.Sprint_Issue_ID = SI.ID
-- WHERE CL.Field = 'description'
-- AND CL.Creation_Date = (
--     SELECT MAX(CL2.Creation_Date)
--     FROM Change_Log CL2
--     WHERE CL2.Creation_Date <= SI.To_Date
--     AND CL2.Field = 'description'
--     AND CL.Issue_ID = CL2.Issue_ID
-- )
-- AND E.description_length <> LENGTH(CL.To_String) + 2

UPDATE Export E
LEFT JOIN Change_Log CL ON CL.Issue_ID = E.Issue_ID
LEFT JOIN Sprint_Issue SI on E.Sprint_Issue_ID = SI.ID
SET E.description_length = LENGTH(CL.To_String) + 2
WHERE CL.Field = 'description'
AND CL.Creation_Date = (
    SELECT MAX(CL2.Creation_Date)
    FROM Change_Log CL2
    WHERE CL2.Creation_Date <= SI.To_Date
    AND CL2.Field = 'description'
    AND CL.Issue_ID = CL2.Issue_ID
)
AND E.description_length <> LENGTH(CL.To_String) + 2