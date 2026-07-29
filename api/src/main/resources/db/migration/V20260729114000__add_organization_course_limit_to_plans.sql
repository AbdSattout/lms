ALTER TABLE plans
    ADD COLUMN organization_course_limit integer;

UPDATE plans
SET organization_course_limit = 3
WHERE code <> 'PREMIUM';

UPDATE plans
SET organization_course_limit = NULL
WHERE code = 'PREMIUM';
