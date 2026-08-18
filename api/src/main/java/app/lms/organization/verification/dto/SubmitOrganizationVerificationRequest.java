package app.lms.organization.verification.dto;

import jakarta.validation.constraints.Size;

public record SubmitOrganizationVerificationRequest(
        @Size(max = 2000)
        String note
) {
}
