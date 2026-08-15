package app.lms.admin.dto;

import app.lms.common.dto.BaseEntityResponse;
import app.lms.user.dto.UserResponse;

import java.time.LocalDateTime;

public record BannedUserResponse(
        Long id,
        UserResponse user,
        AdminResponse bannedBy,
        String reason,
        LocalDateTime expiresAt,
        BaseEntityResponse baseEntity
) {
}
