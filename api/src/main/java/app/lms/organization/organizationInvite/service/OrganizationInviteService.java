package app.lms.organization.organizationInvite.service;

import app.lms.common.exception.BadRequestException;
import app.lms.common.exception.ForbiddenException;
import app.lms.common.exception.NotFoundException;
import app.lms.organization.enums.Role;
import app.lms.organization.model.Organization;
import app.lms.organization.model.OrganizationMember;
import app.lms.organization.organizationInvite.dto.CreateInviteRequest;
import app.lms.organization.organizationInvite.dto.CreatePublicInviteRequest;
import app.lms.organization.organizationInvite.dto.OrganizationInviteOverviewResponse;
import app.lms.organization.organizationInvite.dto.OrganizationInviteResponse;
import app.lms.organization.organizationInvite.dto.UpdateInviteCapacityRequest;
import app.lms.organization.organizationInvite.enums.InviteStatus;
import app.lms.organization.organizationInvite.mapper.OrganizationInviteMapper;
import app.lms.organization.organizationInvite.model.OrganizationInvite;
import app.lms.organization.organizationInvite.repository.OrganizationInviteRepository;
import app.lms.organization.repository.OrganizationMemberRepository;
import app.lms.organization.service.OrganizationAccessService;
import app.lms.user.model.User;
import app.lms.user.repository.UserRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class OrganizationInviteService {

    private final OrganizationAccessService organizationAccessService;
    private final OrganizationInviteRepository organizationInviteRepository;
    private final UserRepository userRepository;
    private final OrganizationMemberRepository memberRepository;
    private final OrganizationInviteMapper organizationInviteMapper;
    private final OrganizationInviteOverviewService organizationInviteOverviewService;
    private final OrganizationInviteEmailService organizationInviteEmailService;

    public OrganizationInviteResponse invite(
            String slug,
            CreateInviteRequest request,
            User currentUser
    ) {

        Organization organization =
                organizationAccessService.getManageableOrganization(
                        slug,
                        currentUser
                );

        if (organizationInviteRepository.existsByOrganizationIdAndUserIdAndStatus(
                organization.getId(),
                request.getUserId(),
                InviteStatus.PENDING
        )) {

            throw new BadRequestException(
                    "User already invited"
            );
        }
        User targetUser = userRepository.findById(request.getUserId())
                .orElseThrow(() -> new NotFoundException("User not found"));

        if (targetUser.getId().equals(currentUser.getId())) {
            throw new BadRequestException(
                    "You cannot invite yourself"
            );
        }

        validateUserCanBeInvited(
                organization,
                targetUser
        );

        validateInviteRole(
                request.getRole()
        );

        OrganizationInvite invite =
                OrganizationInvite.builder()
                        .organization(organization)
                        .user(targetUser)
                        .role(request.getRole() != null ? request.getRole() : Role.STUDENT)
                        .status(InviteStatus.PENDING)
                        .token(UUID.randomUUID().toString())
                        .expiresAt(LocalDateTime.now().plusDays(7))
                        .invitedBy(currentUser)
                        .build();

        OrganizationInvite savedInvite = organizationInviteRepository.save(invite);
        organizationInviteEmailService.sendPrivateInvite(savedInvite);

        return organizationInviteMapper.toResponse(savedInvite);

    }
    @Transactional
    public OrganizationInviteResponse resendInvite(
            String slug,
            Long inviteId,
            User currentUser
    ) {
        Organization organization =
                organizationAccessService.getManageableOrganization(slug, currentUser);

        OrganizationInvite invite = organizationInviteRepository.findById(inviteId)
                .orElseThrow(() -> new NotFoundException("Invite not found"));

        if (!invite.getOrganization().getId().equals(organization.getId())) {
            throw new BadRequestException("Invalid invite");
        }

        if (invite.getStatus() == InviteStatus.ACCEPTED) {
            throw new BadRequestException("User has already accepted the invitation");
        }

        if (invite.getUser() != null) {
            validateUserCanBeInvited(
                    organization,
                    invite.getUser()
            );
        }

        invite.setToken(UUID.randomUUID().toString());
        invite.setExpiresAt(LocalDateTime.now().plusDays(7));
        invite.setStatus(InviteStatus.PENDING);
        invite.setInvitedBy(currentUser);

        OrganizationInvite updatedInvite = organizationInviteRepository.save(invite);
        organizationInviteEmailService.sendPrivateInvite(updatedInvite);

        return organizationInviteMapper.toResponse(updatedInvite);

    }

    public List<OrganizationInviteResponse> getPendingInvites(
            String slug,
            User currentUser
    ) {
        Organization organization =
                organizationAccessService.getManageableOrganization(slug, currentUser);

        return organizationInviteRepository.findAllByOrganizationIdAndStatus(
                        organization.getId(),
                        InviteStatus.PENDING
                ).stream()
                .map(organizationInviteMapper::toResponse)
                .toList();
    }

    @Transactional
    public OrganizationInviteResponse createPublicInvite(
            String slug,
            CreatePublicInviteRequest request,
            User currentUser
    ) {
        Organization organization =
                organizationAccessService.getManageableOrganization(slug, currentUser);

        validatePublicInviteRole(
                request.getRole()
        );

        validateMaxUses(
                request.getMaxUses()
        );

        OrganizationInvite invite = OrganizationInvite.builder()
                .organization(organization)
                .user(null)
                .role(request.getRole() != null ? request.getRole() : Role.STUDENT)
                .status(InviteStatus.PENDING)
                .token(UUID.randomUUID().toString())
                .expiresAt(LocalDateTime.now().plusDays(30))
                .maxUses(request.getMaxUses())
                .usedCount(0)
                .invitedBy(currentUser)
                .build();

        OrganizationInvite savedInvite = organizationInviteRepository.save(invite);
        return organizationInviteMapper.toResponse(savedInvite);
    }
    @Transactional
    public OrganizationInviteResponse updatePublicInviteCapacity(
            String slug,
            Long inviteId,
            UpdateInviteCapacityRequest request,
            User currentUser
    ) {
        Organization organization =
                organizationAccessService.getManageableOrganization(slug, currentUser);

        OrganizationInvite invite = organizationInviteRepository.findById(inviteId)
                .orElseThrow(() -> new NotFoundException("Invite not found"));

        if (!invite.getOrganization().getId().equals(organization.getId())) {
            throw new BadRequestException("Invalid invite");
        }

        if (invite.getUser() != null) {
            throw new BadRequestException("Cannot change capacity for a personal invite");
        }

        validateMaxUses(
                request.getMaxUses()
        );

        if (request.getMaxUses() != null && request.getMaxUses() < invite.getUsedCount()) {
            throw new BadRequestException("Max uses cannot be less than the current used count (" + invite.getUsedCount() + ")");
        }

        invite.setMaxUses(request.getMaxUses());

        if (invite.getStatus() == InviteStatus.EXPIRED &&
                (request.getMaxUses() == null || invite.getUsedCount() < request.getMaxUses())) {
            invite.setStatus(InviteStatus.PENDING);
        }

        OrganizationInvite updatedInvite = organizationInviteRepository.save(invite);
        return organizationInviteMapper.toResponse(updatedInvite);
    }
    @Transactional
    public void acceptInvite(String token, User currentUser) {
        OrganizationInvite invite = findInvite(token);

        organizationAccessService.validateUserNotBannedFromOrg(
                invite.getOrganization(),
                currentUser
        );

        if (invite.getStatus() == InviteStatus.ACCEPTED) {
            throw new BadRequestException("Invite already processed");
        }

        if (invite.getStatus() != InviteStatus.PENDING) {
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
        } else {
            validatePublicInviteRole(
                    invite.getRole()
            );

            if (invite.getMaxUses() != null && invite.getUsedCount() >= invite.getMaxUses()) {
                invite.setStatus(InviteStatus.EXPIRED);
                throw new BadRequestException("This invite link has reached its maximum capacity");
            }
        }

        boolean alreadyMember = memberRepository.existsByOrganizationIdAndUserId(
                invite.getOrganization().getId(),
                currentUser.getId()
        );

        if (alreadyMember) {
            throw new BadRequestException(
                    "User is already a member"
            );
        }

        validateInviteRole(
                invite.getRole()
        );

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

        if (invite.getUser() == null) {
            throw new BadRequestException(
                    "Public invite cannot be declined"
            );
        }

        validateInviteOwner(invite, currentUser);

        if (invite.getStatus() != InviteStatus.PENDING) {
            throw new BadRequestException(
                    "Invite is no longer valid"
            );
        }

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

        Organization organization =
                organizationAccessService
                        .getManageableOrganization(
                                slug,
                                currentUser
                        );

        OrganizationInvite invite =
                organizationInviteRepository
                        .findById(inviteId)
                        .orElseThrow(() ->
                                new NotFoundException(
                                        "Invite not found"
                                ));

        if (!invite.getOrganization().getId().equals(organization.getId())) {
            throw new BadRequestException(
                    "Invalid invite"
            );
        }

        if (invite.getStatus() != InviteStatus.PENDING) {
            throw new BadRequestException(
                    "Only pending invites can be cancelled"
            );
        }

        invite.setStatus(
                InviteStatus.CANCELLED
        );
    }
    private OrganizationInvite findInvite(String token) {
        OrganizationInvite invite =
                organizationInviteRepository.findByToken(token)
                .orElseThrow(() -> new NotFoundException("Invite not found"));

        organizationAccessService.validateNotBanned(
                invite.getOrganization()
        );

        return invite;
    }

    private void validateInviteOwner(OrganizationInvite invite, User currentUser) {
        if (!invite.getUser().getId().equals(currentUser.getId())) {
            throw new ForbiddenException("This invite belongs to another user");
        }
    }
    public List<OrganizationInviteResponse> getMyInvites(User user, Role role) {
        List<OrganizationInvite> invites =
                organizationInviteRepository.findAllVisibleToUserByUserIdAndRoleAndStatus(
                        user.getId(),
                        role,
                        InviteStatus.PENDING
                );

        Map<Long, OrganizationInviteOverviewResponse> overviews =
                organizationInviteOverviewService
                        .buildByOrganizationId(invites);

        return invites
                .stream()
                .map(invite ->
                        organizationInviteMapper.toResponse(
                                invite,
                                overviews.get(
                                        invite.getOrganization().getId()
                                )
                        )
                )
                .toList();
    }

    private void validateUserCanBeInvited(
            Organization organization,
            User targetUser
    ) {

        if (memberRepository.existsByOrganizationIdAndUserId(
                organization.getId(),
                targetUser.getId()
        )) {
            throw new BadRequestException(
                    "User is already a member"
            );
        }

        organizationAccessService.validateUserNotBannedFromOrg(
                organization,
                targetUser
        );
    }

    private void validateInviteRole(
            Role role
    ) {

        if (role == Role.OWNER) {
            throw new BadRequestException(
                    "you can not use Role OWNER in invite"
            );
        }
    }

    private void validatePublicInviteRole(
            Role role
    ) {

        if (role != null && role != Role.STUDENT) {
            throw new BadRequestException(
                    "Public invites can only be for students"
            );
        }
    }

    private void validateMaxUses(
            Integer maxUses
    ) {

        if (maxUses != null && maxUses <= 0) {
            throw new BadRequestException(
                    "Max uses must be greater than 0"
            );
        }
    }
}


