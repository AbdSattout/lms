ALTER TABLE users
    ALTER COLUMN telegram_id DROP NOT NULL;

ALTER TABLE users
    ADD COLUMN google_id varchar(255);

ALTER TABLE users
    ADD CONSTRAINT users_google_id_key UNIQUE (google_id);
