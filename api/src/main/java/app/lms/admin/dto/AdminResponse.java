package app.lms.admin.dto;

import app.lms.admin.enums.AdminRole;

public record AdminResponse(
        Long id,
        String name,
        String email,
        AdminRole role,
        Boolean enabled
) {
}
