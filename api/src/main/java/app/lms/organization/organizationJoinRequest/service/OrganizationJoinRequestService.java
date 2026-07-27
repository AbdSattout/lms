package app.lms.organization.organizationJoinRequest.service;

import app.lms.common.exception.ConflictException;
import app.lms.common.exception.NotFoundException;
import app.lms.organization.organizationJoinRequest.dto.JoinRequestResponse;
import app.lms.organization.organizationJoinRequest.enums.JoinRequestStatus;
import app.lms.organization.enums.Role;
import app.lms.organization.enums.Visibility;
import app.lms.organization.model.Organization;
import app.lms.organization.organizationJoinRequest.mapper.OrganizationJoinRequestMapper;
import app.lms.organization.organizationJoinRequest.model.OrganizationJoinRequest;
import app.lms.organization.model.OrganizationMember;
import app.lms.organization.organizationJoinRequest.repository.OrganizationJoinRequestRepository;
import app.lms.organization.repository.OrganizationMemberRepository;
import app.lms.organization.repository.OrganizationRepository;
import app.lms.organization.service.OrganizationAccessService;
import app.lms.user.model.User;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class OrganizationJoinRequestService {

    private final OrganizationJoinRequestRepository joinRequestRepository;
    private final OrganizationMemberRepository memberRepository;
    private final OrganizationAccessService organizationAccessService;
    private final OrganizationRepository organizationRepository;
    private final OrganizationJoinRequestMapper organizationJoinRequestMapper;

    @Transactional
    public JoinRequestResponse createRequest(String slug, User user) {
        Organization organization = organizationRepository.findBySlug(slug)
                .orElseThrow(() -> new NotFoundException("Organization not found"));

        if (organization.getVisibility() == Visibility.PUBLIC) {
            throw new ConflictException("Organization is public. You can enroll directly.");
        }

        boolean isMember = memberRepository.existsByOrganizationIdAndUserId(organization.getId(), user.getId());
        if (isMember) {
            throw new ConflictException("You are already a member of this organization.");
        }

        boolean hasPendingRequest = joinRequestRepository.existsByOrganizationIdAndUserIdAndStatus(
                organization.getId(), user.getId(), JoinRequestStatus.PENDING
        );
        if (hasPendingRequest) {
            throw new ConflictException("Join request already sent");
        }

        OrganizationJoinRequest request = OrganizationJoinRequest.builder()
                .organization(organization)
                .user(user)
                .status(JoinRequestStatus.PENDING)
                .build();

        OrganizationJoinRequest savedRequest = joinRequestRepository.save(request);

        return organizationJoinRequestMapper.toJoinRequestResponse(savedRequest);    }


    public List<JoinRequestResponse> getPendingRequests(String slug, User user) {
        Organization organization = organizationAccessService.getManageableOrganization(slug, user);

        return joinRequestRepository.findAllByOrganizationIdAndStatusOrderByCreatedAtDesc(
                        organization.getId(), JoinRequestStatus.PENDING
                ).stream()
                .map(organizationJoinRequestMapper::toJoinRequestResponse)
                .toList();
    }


    @Transactional
    public void acceptRequest(String slug, Long requestId, User currentUser) {
        organizationAccessService.getManageableOrganization(slug, currentUser);

        OrganizationJoinRequest request = joinRequestRepository.findById(requestId)
                .orElseThrow(() -> new NotFoundException("Join request not found"));

        if (request.getStatus() != JoinRequestStatus.PENDING) {
            throw new ConflictException("Request is not pending.");
        }

        request.setStatus(JoinRequestStatus.ACCEPTED);
        request.setReviewedAt(LocalDateTime.now());
        request.setReviewedBy(currentUser);

        OrganizationMember newMember = OrganizationMember.builder()
                .organization(request.getOrganization())
                .user(request.getUser())
                .role(Role.STUDENT)
                .build();

        memberRepository.save(newMember);
        joinRequestRepository.save(request);
    }

    @Transactional
    public void rejectRequest(String slug, Long requestId, User currentUser) {
        organizationAccessService.getManageableOrganization(slug, currentUser);

        OrganizationJoinRequest request = joinRequestRepository.findById(requestId)
                .orElseThrow(() -> new NotFoundException("Join request not found"));

        if (request.getStatus() != JoinRequestStatus.PENDING) {
            throw new ConflictException("Request is not pending.");
        }

        request.setStatus(JoinRequestStatus.REJECTED);
        request.setReviewedAt(LocalDateTime.now());
        request.setReviewedBy(currentUser);

        joinRequestRepository.save(request);
    }


    @Transactional
    public void cancelRequest(String slug, User user) {
        Organization organization = organizationRepository.findBySlug(slug)
                .orElseThrow(() -> new NotFoundException("Organization not found"));

        OrganizationJoinRequest request = joinRequestRepository
                .findByOrganizationIdAndUserIdAndStatus(organization.getId(), user.getId(), JoinRequestStatus.PENDING)
                .orElseThrow(() -> new NotFoundException("No pending join request found to cancel."));

        request.setStatus(JoinRequestStatus.CANCELLED);
        joinRequestRepository.save(request);
    }


}
