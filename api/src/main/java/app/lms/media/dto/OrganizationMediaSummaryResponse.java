package app.lms.media.dto;

public record OrganizationMediaSummaryResponse(
        Long organizationId,
        Long totalFiles,
        Long totalSizeBytes
) {
}
