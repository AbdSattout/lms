package app.lms.common.dto;

import app.lms.common.model.BaseEntity;

import java.time.Instant;

public record BaseEntityResponse(
        Instant createdAt,
        Instant updatedAt
) {

    public static BaseEntityResponse from(
            BaseEntity entity
    ) {

        if (entity == null) {
            return null;
        }

        return new BaseEntityResponse(
                entity.getCreatedAt(),
                entity.getUpdatedAt()
        );
    }
}
