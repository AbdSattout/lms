package app.lms.media.dto;

import app.lms.common.dto.BaseEntityResponse;
import app.lms.media.enums.FileType;

public record OrganizationMediaResponse(
        Long id,
        String name,
        String url,
        FileType type,
        Long sizeBytes,
        Long organizationId,
        BaseEntityResponse baseEntity
) {
}
