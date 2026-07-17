package app.lms.organization.organizationInvite.mapper;

import app.lms.common.dto.BaseEntityResponse;
import app.lms.organization.organizationInvite.dto.OrganizationInviteResponse;
import app.lms.organization.organizationInvite.model.OrganizationInvite;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class OrganizationInviteMapper {
    public OrganizationInviteResponse toResponse(OrganizationInvite invite) {
        return OrganizationInviteResponse.builder()
                .id(invite.getId())
                .userId(invite.getUser() != null ? invite.getUser().getId() : null)
                .userName(invite.getUser() != null ? invite.getUser().getName() : "Public Link")
                .role(invite.getRole())
                .status(invite.getStatus())
                .token(invite.getToken())
                .invitedByName(invite.getInvitedBy().getName())
                .expiresAt(invite.getExpiresAt())
                .maxUses(invite.getMaxUses())
                .usedCount(invite.getUsedCount())
                .baseEntity(BaseEntityResponse.from(invite))
                .build();

    }
}
