CREATE TABLE admins (
    id bigserial PRIMARY KEY,
    name varchar(255) NOT NULL,
    email varchar(255) NOT NULL,
    password_hash varchar(255) NOT NULL,
    role varchar(255) NOT NULL,
    enabled boolean NOT NULL DEFAULT true,
    last_login_at timestamp(6),
    created_at timestamp(6),
    updated_at timestamp(6)
);

CREATE UNIQUE INDEX uk_admins_email_lower
    ON admins (lower(email));
