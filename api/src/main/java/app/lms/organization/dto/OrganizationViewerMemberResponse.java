package app.lms.organization.dto;

import app.lms.organization.enums.Role;
import lombok.Builder;

import java.time.LocalDateTime;

@Builder
public record OrganizationViewerMemberResponse(

        Long memberId,
        Role role,
        LocalDateTime joinedAt

) {}
