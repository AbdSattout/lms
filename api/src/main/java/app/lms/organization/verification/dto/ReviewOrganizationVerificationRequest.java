package app.lms.organization.verification.dto;

import app.lms.organization.verification.enums.OrganizationVerificationStatus;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record ReviewOrganizationVerificationRequest(
        @NotNull
        OrganizationVerificationStatus status,

        @Size(max = 2000)
        String adminNote
) {
}
