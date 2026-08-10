ALTER TABLE roadmaps
    ADD COLUMN status varchar(255);

UPDATE roadmaps
SET status = 'DRAFT'
WHERE status IS NULL;

ALTER TABLE roadmaps
    ALTER COLUMN status SET NOT NULL,
    ALTER COLUMN status SET DEFAULT 'DRAFT';
