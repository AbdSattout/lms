ALTER TABLE posts
    DROP COLUMN IF EXISTS likes_count;

ALTER TABLE comments
    DROP COLUMN IF EXISTS likes_count;
