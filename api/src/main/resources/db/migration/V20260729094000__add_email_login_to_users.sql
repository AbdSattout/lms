ALTER TABLE users
    ADD COLUMN email varchar(255);

CREATE UNIQUE INDEX users_email_lower_key
    ON users (lower(email))
    WHERE email IS NOT NULL;
