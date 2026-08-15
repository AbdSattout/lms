package app.lms.admin.mapper;

import app.lms.admin.dto.BannedOrganizationResponse;
import app.lms.admin.dto.BannedUserResponse;
import app.lms.common.dto.BaseEntityResponse;
import app.lms.organization.OrganizationBan.model.OrganizationModeration;
import app.lms.organization.mapper.OrganizationMapper;
import app.lms.user.mapper.UserMapper;
import app.lms.user.moderation.model.UserModeration;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class AdminModerationMapper {

    private final UserMapper userMapper;
    private final AdminMapper adminMapper;
    private final OrganizationMapper organizationMapper;

    public BannedUserResponse toBannedUserResponse(
            UserModeration moderation
    ) {

        return new BannedUserResponse(
                moderation.getId(),
                userMapper.toResponse(
                        moderation.getUser()
                ),
                adminMapper.toResponse(
                        moderation.getBannedBy()
                ),
                moderation.getReason(),
                moderation.getExpiresAt(),
                BaseEntityResponse.from(moderation)
        );
    }

    public BannedOrganizationResponse toBannedOrganizationResponse(
            OrganizationModeration moderation
    ) {

        return new BannedOrganizationResponse(
                moderation.getId(),
                organizationMapper.toSummaryResponse(
                        moderation.getOrganization()
                ),
                adminMapper.toResponse(
                        moderation.getBannedBy()
                ),
                moderation.getReason(),
                moderation.getExpiresAt(),
                BaseEntityResponse.from(moderation)
        );
    }
}
