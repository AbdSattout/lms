ALTER TABLE practice_exams
    ADD COLUMN time_limit_minutes integer;

ALTER TABLE practice_exams
    ADD CONSTRAINT chk_practice_exams_time_limit_minutes_positive
        CHECK (time_limit_minutes IS NULL OR time_limit_minutes > 0);
