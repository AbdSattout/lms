ALTER TABLE comments
    ADD COLUMN likes_count bigint NOT NULL DEFAULT 0;

CREATE TABLE likes (
                       id bigserial PRIMARY KEY,
                       target_type varchar(30) NOT NULL,
                       post_id bigint,
                       comment_id bigint,
                       user_id bigint NOT NULL,
                       reaction_type varchar(30) NOT NULL DEFAULT 'LIKE',
                       created_at timestamp(6),
                       UNIQUE (post_id, user_id),
                       UNIQUE (comment_id, user_id),
                       CONSTRAINT chk_likes_target CHECK (
                           (
                               target_type = 'POST'
                                   AND post_id IS NOT NULL
                                   AND comment_id IS NULL
                           )
                               OR
                           (
                               target_type = 'COMMENT'
                                   AND comment_id IS NOT NULL
                                   AND post_id IS NULL
                           )
                       )
);

INSERT INTO likes (
        target_type,
        post_id,
        user_id,
        reaction_type,
        created_at
)
SELECT
        'POST',
        post_id,
        user_id,
        reaction_type,
        created_at
FROM post_likes
ON CONFLICT DO NOTHING;

ALTER TABLE likes
    ADD CONSTRAINT fk_likes_post FOREIGN KEY (post_id) REFERENCES posts(id),
    ADD CONSTRAINT fk_likes_comment FOREIGN KEY (comment_id) REFERENCES comments(id),
    ADD CONSTRAINT fk_likes_user FOREIGN KEY (user_id) REFERENCES users(id);

CREATE INDEX idx_likes_user_post ON likes(user_id, post_id);
CREATE INDEX idx_likes_user_comment ON likes(user_id, comment_id);
CREATE INDEX idx_likes_post_reaction ON likes(post_id, reaction_type);
CREATE INDEX idx_likes_comment_reaction ON likes(comment_id, reaction_type);

DROP TABLE post_likes;
