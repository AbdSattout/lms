package app.lms.organization.dto;

import app.lms.admin.dto.AdminResponse;
import app.lms.common.dto.BaseEntityResponse;
import app.lms.user.dto.UserResponse;

import java.time.LocalDateTime;

public record OrganizationBannedUserResponse(
        Long id,
        UserResponse user,
        UserResponse bannedByOrgAdmin,
        AdminResponse bannedByAppAdmin,
        String reason,
        LocalDateTime expiresAt,
        BaseEntityResponse baseEntity
) {
}
