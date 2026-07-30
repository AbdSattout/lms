ALTER TABLE post_likes
    ADD COLUMN reaction_type varchar(30) NOT NULL DEFAULT 'LIKE';
