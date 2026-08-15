package app.lms.admin.dto;

import app.lms.common.dto.BaseEntityResponse;
import app.lms.organization.dto.OrganizationSummaryResponse;

import java.time.LocalDateTime;

public record BannedOrganizationResponse(
        Long id,
        OrganizationSummaryResponse organization,
        AdminResponse bannedBy,
        String reason,
        LocalDateTime expiresAt,
        BaseEntityResponse baseEntity
) {
}
