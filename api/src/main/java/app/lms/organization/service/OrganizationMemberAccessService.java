package app.lms.organization.service;

import app.lms.common.exception.BadRequestException;
import app.lms.common.exception.ForbiddenException;
import app.lms.common.exception.NotFoundException;
import app.lms.organization.enums.InviteStatus;
import app.lms.organization.enums.Role;
import app.lms.organization.model.Organization;
import app.lms.organization.model.OrganizationInvite;
import app.lms.organization.model.OrganizationMember;
import app.lms.organization.repository.OrganizationInviteRepository;
import app.lms.organization.repository.OrganizationMemberRepository;
import app.lms.user.model.User;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class OrganizationMemberAccessService {

    private final OrganizationMemberRepository
            memberRepository;
    private final OrganizationInviteRepository
            organizationInviteRepository;


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

    @Transactional
    public void acceptInvite(String token, User currentUser) {
        OrganizationInvite invite = findInvite(token);

        if (invite.getStatus() == InviteStatus.CANCELLED || invite.getStatus() == InviteStatus.DECLINED) {
            throw new BadRequestException("Invite is no longer valid");
        }

        if (invite.getExpiresAt().isBefore(LocalDateTime.now())) {
            invite.setStatus(InviteStatus.EXPIRED);
            throw new BadRequestException("Invite expired");
        }

        if (invite.getUser() != null) {
            if (!invite.getUser().getId().equals(currentUser.getId())) {
                throw new ForbiddenException("This invite belongs to another user");
            }

            if (invite.getStatus() == InviteStatus.ACCEPTED) {
                throw new BadRequestException("Invite already processed");
            }
        } else {
            if (invite.getMaxUses() != null && invite.getUsedCount() >= invite.getMaxUses()) {
                invite.setStatus(InviteStatus.EXPIRED);
                throw new BadRequestException("This invite link has reached its maximum capacity");
            }
        }

        boolean alreadyMember = memberRepository.existsByOrganizationIdAndUserId(
                invite.getOrganization().getId(),
                currentUser.getId()
        );

        if (!alreadyMember) {
            OrganizationMember member = OrganizationMember.builder()
                    .organization(invite.getOrganization())
                    .user(currentUser)
                    .role(invite.getRole())
                    .build();

            memberRepository.save(member);

            if (invite.getUser() == null) {
                invite.setUsedCount(invite.getUsedCount() + 1);

                if (invite.getMaxUses() != null && invite.getUsedCount() >= invite.getMaxUses()) {
                    invite.setStatus(InviteStatus.EXPIRED);
                }
            }
        }

        if (invite.getUser() != null) {
            invite.setStatus(InviteStatus.ACCEPTED);
            invite.setAcceptedAt(LocalDateTime.now());
        }
    }

    @Transactional
    public void decline(
            String token,
            User currentUser
    ) {

        OrganizationInvite invite =
                findInvite(token);

        validateInviteOwner(invite, currentUser);

        invite.setStatus(
                InviteStatus.DECLINED
        );
    }
    @Transactional
    public void cancelInvite(
            String slug,
            Long inviteId,
            User currentUser
    ) {


        OrganizationInvite invite =
                organizationInviteRepository
                        .findById(inviteId)
                        .orElseThrow(() ->
                                new NotFoundException(
                                        "Invite not found"
                                ));

        validateManager(
                invite.getOrganization().getId(),
                currentUser.getId()
        );

        invite.setStatus(
                InviteStatus.CANCELLED
        );
    }
    private OrganizationInvite findInvite(String token) {
        return organizationInviteRepository.findByToken(token)
                .orElseThrow(() -> new NotFoundException("Invite not found"));
    }

    private void validateInviteOwner(OrganizationInvite invite, User currentUser) {
        if (!invite.getUser().getId().equals(currentUser.getId())) {
            throw new ForbiddenException("This invite belongs to another user");
        }
    }
}