package app.lms.organization.mapper;

import app.lms.common.dto.BaseEntityResponse;
import app.lms.organization.dto.OrganizationMemberResponse;
import app.lms.organization.dto.OrganizationResponse;
import app.lms.organization.dto.OrganizationSummaryResponse;
import app.lms.organization.dto.OrganizationViewerMemberResponse;
import app.lms.organization.dto.OrganizationViewerResponse;
import app.lms.organization.model.Organization;
import app.lms.organization.organizationInvite.enums.InviteStatus;
import app.lms.organization.organizationInvite.model.OrganizationInvite;
import app.lms.organization.organizationJoinRequest.enums.JoinRequestStatus;
import app.lms.organization.organizationJoinRequest.model.OrganizationJoinRequest;
import app.lms.organization.model.OrganizationMember;
import app.lms.organization.repository.OrganizationMemberRepository;
import app.lms.user.mapper.UserMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class OrganizationMapper {

    private final UserMapper userMapper;
    private final OrganizationMemberRepository memberRepository;

    public OrganizationResponse ToResponse(
            Organization organization
    ) {

        return toResponse(
                organization,
                null
        );
    }

    public OrganizationResponse ToResponse(
            Organization organization,
            OrganizationMember member,
            OrganizationJoinRequest request
    ) {

        return ToResponse(
                organization,
                member,
                request,
                null
        );
    }

    public OrganizationResponse ToResponse(
            Organization organization,
            OrganizationMember member,
            OrganizationJoinRequest request,
            OrganizationInvite invite
    ) {

        return toResponse(
                organization,
                toViewerResponse(
                        member,
                        request,
                        invite
                )
        );
    }

    private OrganizationResponse toResponse(
            Organization organization,
            OrganizationViewerResponse viewer
    ) {

        return OrganizationResponse.builder()
                .id(organization.getId())
                .name(organization.getName())
                .slug(organization.getSlug())
                .description(organization.getDescription())
                .image(organization.getImageUrl())
                .visibility(organization.getVisibility())
                .ownerName(
                        organization.getOwner().getName()
                )
                .membersCount(memberRepository.countByOrganizationId(
                        organization.getId()
                ))
                .viewer(viewer)
                .baseEntity(BaseEntityResponse.from(organization))
                .build();
    }

    public OrganizationViewerResponse toViewerResponse(
            OrganizationMember member,
            OrganizationJoinRequest request,
            OrganizationInvite invite
    ) {

        return OrganizationViewerResponse.builder()
                .joined(member != null)
                .role(
                        member != null
                                ? member.getRole()
                                : null
                )
                .joinRequestStatus(joinRequestStatusFor(member, request))
                .inviteStatus(inviteStatusFor(invite))
                .member(viewerMemberResponseFor(member))
                .build();
    }

    private JoinRequestStatus joinRequestStatusFor(
            OrganizationMember member,
            OrganizationJoinRequest request
    ) {

        if (member != null) {
            return JoinRequestStatus.ACCEPTED;
        }

        return request != null
                ? request.getStatus()
                : null;
    }

    private InviteStatus inviteStatusFor(
            OrganizationInvite invite
    ) {

        return invite != null
                ? invite.getStatus()
                : null;
    }

    private OrganizationViewerMemberResponse viewerMemberResponseFor(
            OrganizationMember member
    ) {

        if (member == null) {
            return null;
        }

        return OrganizationViewerMemberResponse.builder()
                .memberId(member.getId())
                .role(member.getRole())
                .joinedAt(member.getJoinedAt())
                .build();
    }

    public OrganizationSummaryResponse toSummaryResponse(
            Organization organization
    ) {

        return OrganizationSummaryResponse.builder()
                .id(organization.getId())
                .name(organization.getName())
                .slug(organization.getSlug())
                .description(organization.getDescription())
                .image(organization.getImageUrl())
                .visibility(organization.getVisibility())
                .build();
    }

    public OrganizationMemberResponse toMemberResponse(
            OrganizationMember member
    ) {

        return OrganizationMemberResponse
                .builder()
                .memberId(member.getId())
                .user(userMapper.toResponse(member.getUser()))
                .role(member.getRole())
                .build();
    }
}
