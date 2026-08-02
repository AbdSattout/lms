package app.lms.organization.service;

import app.lms.organization.dto.OrganizationViewerResponse;
import app.lms.organization.mapper.OrganizationMapper;
import app.lms.organization.model.Organization;
import app.lms.organization.model.OrganizationMember;
import app.lms.organization.organizationInvite.enums.InviteStatus;
import app.lms.organization.organizationInvite.model.OrganizationInvite;
import app.lms.organization.organizationInvite.repository.OrganizationInviteRepository;
import app.lms.organization.organizationJoinRequest.enums.JoinRequestStatus;
import app.lms.organization.organizationJoinRequest.model.OrganizationJoinRequest;
import app.lms.organization.organizationJoinRequest.repository.OrganizationJoinRequestRepository;
import app.lms.organization.repository.OrganizationMemberRepository;
import app.lms.user.model.User;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.Collection;
import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class OrganizationViewerService {

    private final OrganizationMemberRepository memberRepository;
    private final OrganizationJoinRequestRepository organizationJoinRequestRepository;
    private final OrganizationInviteRepository organizationInviteRepository;
    private final OrganizationMapper organizationMapper;

    public OrganizationViewerResponse forOrganization(
            Organization organization,
            User user
    ) {

        return byOrganizationId(
                List.of(organization),
                user
        ).get(
                organization.getId()
        );
    }

    public Map<Long, OrganizationViewerResponse> byOrganizationId(
            Collection<Organization> organizations,
            User user
    ) {

        List<Long> organizationIds =
                organizationIds(organizations);

        if (organizationIds.isEmpty()) {
            return Map.of();
        }

        Map<Long, OrganizationMember> membersByOrganizationId =
                membersByOrganizationId(
                        organizationIds,
                        user
                );

        Map<Long, OrganizationJoinRequest> requestsByOrganizationId =
                latestRelevantJoinRequestsByOrganizationId(
                        organizationIds,
                        user,
                        membersByOrganizationId
                );

        Map<Long, OrganizationInvite> invitesByOrganizationId =
                latestRelevantInvitesByOrganizationId(
                        organizationIds,
                        user,
                        membersByOrganizationId
                );

        return organizationIds
                .stream()
                .collect(
                        Collectors.toMap(
                                Function.identity(),
                                organizationId ->
                                        organizationMapper.toViewerResponse(
                                                membersByOrganizationId.get(organizationId),
                                                requestsByOrganizationId.get(organizationId),
                                                invitesByOrganizationId.get(organizationId)
                                        )
                        )
                );
    }

    private Map<Long, OrganizationMember> membersByOrganizationId(
            Collection<Long> organizationIds,
            User user
    ) {

        return memberRepository
                .findAllByOrganizationIdsAndUserId(
                        organizationIds,
                        user.getId()
                )
                .stream()
                .collect(
                        Collectors.toMap(
                                member -> member.getOrganization()
                                        .getId(),
                                Function.identity()
                        )
                );
    }

    private Map<Long, OrganizationJoinRequest> latestRelevantJoinRequestsByOrganizationId(
            Collection<Long> organizationIds,
            User user,
            Map<Long, OrganizationMember> membersByOrganizationId
    ) {

        return organizationJoinRequestRepository
                .findAllByOrganizationIdsAndUserIdOrderByLatest(
                        organizationIds,
                        user.getId()
                )
                .stream()
                .filter(request ->
                        !membersByOrganizationId.containsKey(
                                request.getOrganization().getId()
                        )
                )
                .filter(request ->
                        request.getStatus() != JoinRequestStatus.ACCEPTED
                )
                .collect(
                        Collectors.toMap(
                                request -> request.getOrganization().getId(),
                                Function.identity(),
                                (first, ignored) -> first
                        )
                );
    }

    private Map<Long, OrganizationInvite> latestRelevantInvitesByOrganizationId(
            Collection<Long> organizationIds,
            User user,
            Map<Long, OrganizationMember> membersByOrganizationId
    ) {

        return organizationInviteRepository
                .findAllByOrganizationIdsAndUserIdOrderByLatest(
                        organizationIds,
                        user.getId()
                )
                .stream()
                .filter(invite ->
                        isRelevantInvite(
                                invite,
                                membersByOrganizationId.get(
                                        invite.getOrganization().getId()
                                )
                        )
                )
                .collect(
                        Collectors.toMap(
                                invite -> invite.getOrganization().getId(),
                                Function.identity(),
                                (first, ignored) -> first
                        )
                );
    }

    private boolean isRelevantInvite(
            OrganizationInvite invite,
            OrganizationMember member
    ) {

        return member != null
                ? invite.getStatus() == InviteStatus.ACCEPTED
                : invite.getStatus() != InviteStatus.ACCEPTED;
    }

    private List<Long> organizationIds(
            Collection<Organization> organizations
    ) {

        return organizations
                .stream()
                .map(Organization::getId)
                .distinct()
                .toList();
    }
}
