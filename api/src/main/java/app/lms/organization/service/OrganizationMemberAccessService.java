package app.lms.organization.service;

import app.lms.common.exception.BadRequestException;
import app.lms.common.exception.ForbiddenException;
import app.lms.common.exception.NotFoundException;
import app.lms.organization.OrganizationBan.repository.OrganizationBanRepository;
import app.lms.organization.organizationInvite.dto.OrganizationInviteResponse;
import app.lms.organization.organizationInvite.enums.InviteStatus;
import app.lms.organization.enums.Role;
import app.lms.organization.mapper.OrganizationMapper;
import app.lms.organization.organizationInvite.model.OrganizationInvite;
import app.lms.organization.model.OrganizationMember;
import app.lms.organization.organizationInvite.repository.OrganizationInviteRepository;
import app.lms.organization.repository.OrganizationMemberRepository;
import app.lms.user.model.User;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class OrganizationMemberAccessService {

    private final OrganizationMemberRepository
            memberRepository;
    private final OrganizationInviteRepository
            organizationInviteRepository;
    private final OrganizationMapper organizationMapper;
    private final OrganizationBanRepository organizationBanRepository;


    public OrganizationMember getMember(
            Long organizationId,
            Long userId
    ) {

        if (
                organizationBanRepository.existsByOrganizationIdAndUserId(
                        organizationId,
                        userId
                )
        ) {
            throw new ForbiddenException(
                    "You are banned from this organization."
            );
        }

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

    public boolean isManager(
            Long organizationId,
            Long userId
    ) {
        try {
            validateManager(
                    organizationId,
                    userId
            );
            return true;
        } catch (ForbiddenException e) {
            return false;
        }
    }
    private OrganizationMember getManagerMember(
            Long organizationId,
            Long userId
    ) {

        return getMember(
                organizationId,
                userId
        );
    }
    public void validateManager(
            Long organizationId,
            Long userId
    ) {

        OrganizationMember member =
                getManagerMember(
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
    }

    public void validateCanRemoveMember(
            OrganizationMember actor,
            OrganizationMember target
    ) {

        if (actor.getRole() != Role.OWNER) {
            throw new ForbiddenException(
                    "Only organization owners can remove admins"
            );
        }

        if (target.getRole() != Role.ADMIN) {
            throw new ForbiddenException(
                    "Only organization admins can be removed"
            );
        }
    }

    public void validateCanBanUser(
            OrganizationMember actor,
            OrganizationMember target
    ) {

        if (target == null) {
            validateCanBanNonMember(actor);
            return;
        }

        if (actor.getRole() == Role.OWNER) {

            if (target.getRole() == Role.OWNER) {
                throw new ForbiddenException(
                        "Owner cannot be banned"
                );
            }

            return;
        }

        if (actor.getRole() == Role.ADMIN) {

            if (target.getRole() != Role.STUDENT) {
                throw new ForbiddenException(
                        "Admins can only ban students"
                );
            }

            return;
        }

        throw new ForbiddenException(
                "Access denied"
        );
    }

    private void validateCanBanNonMember(
            OrganizationMember actor
    ) {

        if (
                actor.getRole() == Role.OWNER ||
                        actor.getRole() == Role.ADMIN
        ) {
            return;
        }

        throw new ForbiddenException(
                "Access denied"
        );
    }


}
