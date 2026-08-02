package app.lms.organization.organizationInvite.mapper;

import app.lms.common.dto.BaseEntityResponse;
import app.lms.organization.model.Organization;
import app.lms.organization.organizationInvite.dto.OrganizationInviteOverviewResponse;
import app.lms.organization.organizationInvite.dto.OrganizationInviteOrganizationResponse;
import app.lms.organization.organizationInvite.dto.OrganizationInviteResponse;
import app.lms.organization.organizationInvite.model.OrganizationInvite;
import app.lms.user.mapper.UserMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class OrganizationInviteMapper {

    private final UserMapper userMapper;

    public OrganizationInviteResponse toResponse(OrganizationInvite invite) {

        return toResponse(invite, null);
    }

    public OrganizationInviteResponse toResponse(
            OrganizationInvite invite,
            OrganizationInviteOverviewResponse overview
    ) {
        return OrganizationInviteResponse.builder()
                .id(invite.getId())
                .userId(invite.getUser() != null ? invite.getUser().getId() : null)
                .userName(invite.getUser() != null ? invite.getUser().getName() : "Public Link")
                .role(invite.getRole())
                .status(invite.getStatus())
                .token(invite.getUser() == null ? invite.getToken() : null)
                .organization(
                        toOrganizationResponse(
                                invite.getOrganization()
                        )
                )
                .overview(overview)
                .invitedByName(invite.getInvitedBy().getName())
                .expiresAt(invite.getExpiresAt())
                .maxUses(invite.getMaxUses())
                .usedCount(invite.getUsedCount())
                .baseEntity(BaseEntityResponse.from(invite))
                .build();

    }

    private OrganizationInviteOrganizationResponse toOrganizationResponse(
            Organization organization
    ) {

        return OrganizationInviteOrganizationResponse
                .builder()
                .id(organization.getId())
                .name(organization.getName())
                .slug(organization.getSlug())
                .description(organization.getDescription())
                .imageUrl(organization.getImageUrl())
                .visibility(organization.getVisibility())
                .owner(userMapper.toResponse(organization.getOwner()))
                .build();
    }
}
