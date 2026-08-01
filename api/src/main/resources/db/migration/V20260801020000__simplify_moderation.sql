DROP TABLE IF EXISTS course_bans CASCADE;
DROP TABLE IF EXISTS course_moderation CASCADE;

CREATE TABLE IF NOT EXISTS user_moderation (
    id bigserial PRIMARY KEY,

    user_id bigint NOT NULL,
    banned_by_id bigint NOT NULL,

    reason text,

    created_at timestamp(6),
    updated_at timestamp(6),

    CONSTRAINT uk_user_moderation_user
        UNIQUE (user_id),

    CONSTRAINT fk_user_moderation_user
        FOREIGN KEY (user_id)
            REFERENCES users(id)
            ON DELETE CASCADE,

    CONSTRAINT fk_user_moderation_admin
        FOREIGN KEY (banned_by_id)
            REFERENCES admins(id)
            ON DELETE RESTRICT
);

CREATE INDEX IF NOT EXISTS idx_user_moderation_user
    ON user_moderation(user_id);

CREATE INDEX IF NOT EXISTS idx_user_moderation_admin
    ON user_moderation(banned_by_id);
