package app.lms.badge.mapper;

import app.lms.badge.dto.BadgeResponse;
import app.lms.badge.model.Badge;
import app.lms.common.dto.BaseEntityResponse;
import org.springframework.stereotype.Component;

@Component
public class BadgeMapper {

    public BadgeResponse toResponse(
            Badge badge
    ) {

        return new BadgeResponse(
                badge.getId(),
                badge.getCode(),
                badge.getTitle(),
                badge.getDescription(),
                badge.getIconUrl(),
                badge.getSortOrder(),
                badge.getActive(),
                BaseEntityResponse.from(badge)
        );
    }
}
