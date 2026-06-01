package app.lms.organization.service;

import app.lms.common.exception.ForbiddenException;
import app.lms.organization.emums.Role;
import app.lms.organization.model.OrganizationMember;
import app.lms.organization.repository.OrganizationMemberRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class OrganizationMemberAccessService {

    private final OrganizationMemberRepository
            memberRepository;

    public OrganizationMember getMember(
            Long organizationId,
            Long userId
    ) {

        return memberRepository
                .findByOrganizationIdAndUserId(
                        organizationId,
                        userId
                )
                .orElseThrow(() ->
                        new ForbiddenException(
                                "Not a member"
                        )
                );
    }

    public OrganizationMember getManagerMember(
            Long organizationId,
            Long userId
    ) {

        OrganizationMember member =
                getMember(
                        organizationId,
                        userId
                );

        boolean allowed =
                member.getRole() == Role.OWNER
                        ||
                        member.getRole() == Role.ADMIN;

        if (!allowed) {
            throw new ForbiddenException(
                    "Access denied"
            );
        }

        return member;
    }
}