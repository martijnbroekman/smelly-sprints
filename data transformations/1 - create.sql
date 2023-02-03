CREATE TABLE Export (
    ID INT auto_increment,
    description_length INT NULL,
    type VARCHAR(128) NULL,
    priority VARCHAR(128) NULL,
    estimated_days INT NULL,
    story_points DOUBLE NULL,
    num_comments INT NULL,
    avg_comment_length INT NULL,
    sprint_days_given INT NULL,
    is_problematic INT,
    Issue_ID INT,
    Sprint_Issue_ID INT,
    primary key(ID)
)