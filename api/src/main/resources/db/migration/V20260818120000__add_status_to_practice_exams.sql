ALTER TABLE practice_exams
    ADD COLUMN status varchar(255);

UPDATE practice_exams
SET status = 'PUBLISHED'
WHERE status IS NULL;

ALTER TABLE practice_exams
    ALTER COLUMN status SET DEFAULT 'DRAFT',
    ALTER COLUMN status SET NOT NULL;

ALTER TABLE practice_exams
    ADD CONSTRAINT chk_practice_exams_status
        CHECK (status IN ('DRAFT', 'PUBLISHED'));
