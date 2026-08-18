package app.lms.organization.verification.dto;

import app.lms.admin.dto.AdminResponse;
import app.lms.common.dto.BaseEntityResponse;
import app.lms.organization.dto.OrganizationResponse;
import app.lms.organization.verification.enums.OrganizationVerificationStatus;
import app.lms.user.dto.UserResponse;

import java.time.LocalDateTime;

public record OrganizationVerificationResponse(
        Long id,
        OrganizationResponse organization,
        UserResponse requestedBy,
        String note,
        String proofUrl,
        OrganizationVerificationStatus status,
        AdminResponse reviewedBy,
        String adminNote,
        LocalDateTime reviewedAt,
        BaseEntityResponse baseEntity
) {
}
