package app.lms.common.dto;

import app.lms.common.model.BaseEntity;

import java.time.LocalDateTime;

public record BaseEntityResponse(
        LocalDateTime createdAt,
        LocalDateTime updatedAt
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
