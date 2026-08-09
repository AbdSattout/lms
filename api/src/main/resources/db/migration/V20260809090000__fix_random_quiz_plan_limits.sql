UPDATE plans
SET random_quiz_per_course_limit = 1
WHERE code = 'FREE';

UPDATE plans
SET random_quiz_per_course_limit = NULL
WHERE code = 'PREMIUM';
