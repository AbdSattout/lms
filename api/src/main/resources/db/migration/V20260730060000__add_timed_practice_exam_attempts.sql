ALTER TABLE practice_exam_attempts
    ADD COLUMN completed boolean NOT NULL DEFAULT true,
    ADD COLUMN started_at timestamp(6),
    ADD COLUMN expires_at timestamp(6),
    ADD COLUMN submitted_at timestamp(6);

UPDATE practice_exam_attempts
SET started_at = COALESCE(created_at, CURRENT_TIMESTAMP),
    submitted_at = COALESCE(created_at, CURRENT_TIMESTAMP)
WHERE started_at IS NULL;

ALTER TABLE practice_exam_attempts
    ALTER COLUMN started_at SET NOT NULL;

ALTER TABLE practice_exam_attempt_answers
    ALTER COLUMN selected_answer_index DROP NOT NULL,
    ALTER COLUMN correct DROP NOT NULL;
