ALTER TABLE users
    ALTER COLUMN picture TYPE text;

ALTER TABLE plans
    ALTER COLUMN description TYPE text;

ALTER TABLE organizations
    ALTER COLUMN description TYPE text,
    ALTER COLUMN image_url TYPE text;

ALTER TABLE courses
    ALTER COLUMN description TYPE text,
    ALTER COLUMN cover_url TYPE text;

ALTER TABLE question_options
    ALTER COLUMN option_value TYPE text;

ALTER TABLE final_quiz_attempt_answer_options
    ALTER COLUMN option_value TYPE text;

ALTER TABLE practice_exam_attempt_answer_options
    ALTER COLUMN option_value TYPE text;

ALTER TABLE random_quiz_attempt_question_options
    ALTER COLUMN option_value TYPE text;

ALTER TABLE bank_random_quiz_attempt_question_options
    ALTER COLUMN option_value TYPE text;
