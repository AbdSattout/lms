package app.lms.security;

import org.springframework.util.StringUtils;

public enum AuthPrincipalType {
    USER,
    ADMIN;

    public static AuthPrincipalType from(
            String value
    ) {

        if (!StringUtils.hasText(value)) {
            return USER;
        }

        return AuthPrincipalType.valueOf(
                value.trim()
                        .toUpperCase()
        );
    }
}
