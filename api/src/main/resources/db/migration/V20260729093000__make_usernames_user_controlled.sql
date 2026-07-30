UPDATE users
SET username = NULL;

CREATE UNIQUE INDEX users_username_lower_key
    ON users (lower(username))
    WHERE username IS NOT NULL;
