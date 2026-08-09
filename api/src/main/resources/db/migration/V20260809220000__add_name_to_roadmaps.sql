ALTER TABLE roadmaps
    ADD COLUMN name varchar(255),
    ADD COLUMN description text;

UPDATE roadmaps
SET name = 'Untitled roadmap'
WHERE name IS NULL;

ALTER TABLE roadmaps
    ALTER COLUMN name SET NOT NULL;
