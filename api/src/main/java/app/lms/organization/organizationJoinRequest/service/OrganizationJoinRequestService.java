package app.lms.organization.organizationJoinRequest.service;

import app.lms.common.exception.ConflictException;
import app.lms.common.exception.NotFoundException;
import app.lms.organization.organizationJoinRequest.dto.JoinRequestResponse;
import app.lms.organization.organizationJoinRequest.enums.JoinRequestStatus;
import app.lms.organization.enums.Role;
import app.lms.organization.enums.Visibility;
import app.lms.organization.model.Organization;
import app.lms.organization.organizationInvite.enums.InviteStatus;
import app.lms.organization.organizationInvite.repository.OrganizationInviteRepository;
import app.lms.organization.organizationJoinRequest.mapper.OrganizationJoinRequestMapper;
import app.lms.organization.organizationJoinRequest.model.OrganizationJoinRequest;
import app.lms.organization.model.OrganizationMember;
import app.lms.organization.organizationJoinRequest.repository.OrganizationJoinRequestRepository;
import app.lms.organization.repository.OrganizationMemberRepository;
import app.lms.organization.service.OrganizationAccessService;
import app.lms.user.model.User;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class OrganizationJoinRequestService {

    private final OrganizationJoinRequestRepository joinRequestRepository;
    private final OrganizationMemberRepository memberRepository;
    private final OrganizationAccessService organizationAccessService;
    private final OrganizationJoinRequestMapper organizationJoinRequestMapper;
    private final OrganizationInviteRepository organizationInviteRepository;

    @Transactional
    public void join(String slug, User user) {

        Organization organization =
                organizationAccessService.getBySlug(
                        slug
                );

        organizationAccessService.validateUserNotBannedFromOrg(
                organization,
                user
        );

        validateNotMember(
                organization,
                user
        );
        validateNoPendingInvite(
                organization,
                user
        );

        OrganizationJoinRequest pendingRequest =
                pendingRequestFor(
                        organization,
                        user
                );

        if (organization.getVisibility() == Visibility.PUBLIC) {

            memberRepository.save(
                    OrganizationMember.builder()
                            .organization(organization)
                            .user(user)
                            .role(Role.STUDENT)
                            .build()
            );

            if (pendingRequest != null) {
                pendingRequest.setStatus(JoinRequestStatus.ACCEPTED);
                pendingRequest.setReviewedAt(LocalDateTime.now());
                pendingRequest.setReviewedBy(user);
                joinRequestRepository.save(pendingRequest);
            }

            return;
        }

        if (pendingRequest != null) {
            throw new ConflictException(
                    "Join request already sent."
            );
        }

        OrganizationJoinRequest request = OrganizationJoinRequest.builder()
                .organization(organization)
                .user(user)
                .status(JoinRequestStatus.PENDING)
                .build();

        joinRequestRepository.save(request);

    }


    public List<JoinRequestResponse> getPendingRequests(String slug, User user) {
        Organization organization =
                organizationAccessService.getManageableOrganization(
                        slug,
                        user
                );

        return joinRequestRepository
                .findAllByOrganizationIdAndStatusOrderByCreatedAtDesc(
                        organization.getId(),
                        JoinRequestStatus.PENDING
                )
                .stream()
                .map(organizationJoinRequestMapper::toJoinRequestResponse)
                .toList();
    }


    @Transactional
    public void acceptRequest(String slug, Long requestId, User currentUser) {
        Organization organization =
                organizationAccessService.getManageableOrganization(
                        slug,
                        currentUser
                );

        OrganizationJoinRequest request =
                joinRequestRepository
                        .findById(requestId)
                        .orElseThrow(() ->
                                new NotFoundException(
                                        "Join request not found"
                                )
                        );

        validateRequestOrganization(
                request,
                organization
        );

        if (request.getStatus() != JoinRequestStatus.PENDING) {
            throw new ConflictException(
                    "Request is not pending."
            );
        }

        organizationAccessService.validateUserNotBannedFromOrg(
                organization,
                request.getUser()
        );

        validateNotMember(
                organization,
                request.getUser()
        );

        request.setStatus(JoinRequestStatus.ACCEPTED);
        request.setReviewedAt(LocalDateTime.now());
        request.setReviewedBy(currentUser);

        OrganizationMember newMember = OrganizationMember.builder()
                .organization(organization)
                .user(request.getUser())
                .role(Role.STUDENT)
                .build();

        memberRepository.save(newMember);
        joinRequestRepository.save(request);
    }

    @Transactional
    public void rejectRequest(String slug, Long requestId, User currentUser) {
        Organization organization =
                organizationAccessService.getManageableOrganization(
                        slug,
                        currentUser
                );

        OrganizationJoinRequest request =
                joinRequestRepository
                        .findById(requestId)
                        .orElseThrow(() ->
                                new NotFoundException(
                                        "Join request not found"
                                )
                        );

        validateRequestOrganization(
                request,
                organization
        );

        if (request.getStatus() != JoinRequestStatus.PENDING) {
            throw new ConflictException(
                    "Request is not pending."
            );
        }

        request.setStatus(JoinRequestStatus.REJECTED);
        request.setReviewedAt(LocalDateTime.now());
        request.setReviewedBy(currentUser);

        joinRequestRepository.save(request);
    }


    @Transactional
    public void cancelRequest(String slug, User user) {
        Organization organization =
                organizationAccessService.getBySlug(
                        slug
                );

        organizationAccessService.validateUserNotBannedFromOrg(
                organization,
                user
        );

        OrganizationJoinRequest request =
                joinRequestRepository
                        .findByOrganizationIdAndUserIdAndStatus(
                                organization.getId(),
                                user.getId(),
                                JoinRequestStatus.PENDING
                        )
                        .orElseThrow(() ->
                                new NotFoundException(
                                        "No pending join request found to cancel."
                                )
                        );

        request.setStatus(JoinRequestStatus.CANCELLED);
        joinRequestRepository.save(request);
    }

    public Page<JoinRequestResponse> getMyRequests(
            User user,
            JoinRequestStatus status,
            Pageable pageable
    ) {
        return joinRequestRepository
                .findAllVisibleToUserByUserIdAndStatus(
                        user.getId(),
                        status,
                        pageable
                )
                .map(organizationJoinRequestMapper::toJoinRequestResponse);
    }

    private void validateNotMember(
            Organization organization,
            User user
    ) {

        if (
                memberRepository.existsByOrganizationIdAndUserId(
                        organization.getId(),
                        user.getId()
                )
        ) {

            throw new ConflictException(
                    "You are already a member of this organization."
            );

        }

    }

    private void validateNoPendingInvite(
            Organization organization,
            User user
    ) {

        if (
                organizationInviteRepository
                        .existsByOrganizationIdAndUserIdAndStatus(
                                organization.getId(),
                                user.getId(),
                                InviteStatus.PENDING
                        )
        ) {
            throw new ConflictException(
                    "You already have an invitation for this organization."
            );
        }
    }

    private OrganizationJoinRequest pendingRequestFor(
            Organization organization,
            User user
    ) {

        return joinRequestRepository
                .findByOrganizationIdAndUserIdAndStatus(
                        organization.getId(),
                        user.getId(),
                        JoinRequestStatus.PENDING
                )
                .orElse(null);

    }

    private void validateRequestOrganization(
            OrganizationJoinRequest request,
            Organization organization
    ) {

        if (
                !request.getOrganization()
                        .getId()
                        .equals(organization.getId())
        ) {

            throw new NotFoundException(
                    "Join request not found"
            );

        }

    }


}
