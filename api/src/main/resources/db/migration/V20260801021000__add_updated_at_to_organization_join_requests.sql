ALTER TABLE organization_join_requests
    ADD COLUMN updated_at timestamp(6);

UPDATE organization_join_requests
SET updated_at = created_at
WHERE updated_at IS NULL;
