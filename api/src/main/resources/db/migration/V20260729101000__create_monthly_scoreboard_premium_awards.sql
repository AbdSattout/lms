CREATE TABLE monthly_scoreboard_premium_awards (
    id bigserial PRIMARY KEY,
    period_from date NOT NULL,
    period_to date NOT NULL,
    award_rank integer NOT NULL,
    xp bigint NOT NULL,
    premium_started_at timestamp(6) NOT NULL,
    premium_expires_at timestamp(6) NOT NULL,
    email varchar(255),
    email_sent_at timestamp(6),
    user_id bigint NOT NULL,
    created_at timestamp(6),
    updated_at timestamp(6),
    CONSTRAINT uk_monthly_scoreboard_awards_period_rank
        UNIQUE (period_from, period_to, award_rank),
    CONSTRAINT uk_monthly_scoreboard_awards_period_user
        UNIQUE (period_from, period_to, user_id)
);

ALTER TABLE monthly_scoreboard_premium_awards
    ADD CONSTRAINT fk_monthly_scoreboard_awards_user
        FOREIGN KEY (user_id) REFERENCES users(id);

CREATE INDEX idx_monthly_scoreboard_awards_user
    ON monthly_scoreboard_premium_awards(user_id);
