package app.lms.organization.dto;

import app.lms.organization.enums.Role;
import app.lms.organization.organizationInvite.enums.InviteStatus;
import app.lms.organization.organizationJoinRequest.enums.JoinRequestStatus;
import lombok.Builder;

@Builder
public record OrganizationViewerResponse(

        boolean joined,
        Role role,
        JoinRequestStatus joinRequestStatus,
        Long inviteId,
        InviteStatus inviteStatus,
        OrganizationViewerMemberResponse member

) {}
