package app.lms.media.dto;

import app.lms.media.enums.FileType;
import app.lms.common.dto.BaseEntityResponse;

public record PostMediaResponse(

        Long id,

        String name,

        String url,

        FileType type,

        Long organizationId,

        Long organizationMediaId,

        Long sizeBytes,

        BaseEntityResponse baseEntity
) {
}
