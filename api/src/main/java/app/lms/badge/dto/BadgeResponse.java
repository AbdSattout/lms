package app.lms.badge.dto;

import app.lms.common.dto.BaseEntityResponse;

public record BadgeResponse(
        Long id,
        String code,
        String title,
        String description,
        String iconUrl,
        Integer sortOrder,
        Boolean active,
        BaseEntityResponse baseEntity
) {
}
