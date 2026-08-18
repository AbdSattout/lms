package app.lms.organization.mapper;

import app.lms.admin.mapper.AdminMapper;
import app.lms.common.dto.BaseEntityResponse;
import app.lms.course.repository.CourseRepository;
import app.lms.organization.OrganizationBan.model.OrganizationBan;
import app.lms.organization.dto.OrganizationBannedUserResponse;
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
    private final AdminMapper adminMapper;
    private final OrganizationMemberRepository memberRepository;
    private final CourseRepository courseRepository;

    public OrganizationResponse ToResponse(
            Organization organization
    ) {

        return toResponse(
                organization,
                null,
                null
        );
    }

    public OrganizationResponse ToResponse(
            Organization organization,
            OrganizationViewerResponse viewer
    ) {

        return toResponse(
                organization,
                viewer,
                null
        );
    }

    public OrganizationResponse ToResponse(
            Organization organization,
            OrganizationViewerResponse viewer,
            Long coursesCount
    ) {

        return toResponse(
                organization,
                viewer,
                coursesCount
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
                ),
                null
        );
    }

    private OrganizationResponse toResponse(
            Organization organization,
            OrganizationViewerResponse viewer,
            Long coursesCount
    ) {

        return OrganizationResponse.builder()
                .id(organization.getId())
                .name(organization.getName())
                .slug(organization.getSlug())
                .description(organization.getDescription())
                .image(organization.getImageUrl())
                .visibility(organization.getVisibility())
                .verified(
                        Boolean.TRUE.equals(
                                organization.getVerified()
                        )
                )
                .ownerName(
                        organization.getOwner().getName()
                )
                .membersCount(memberRepository.countActiveByOrganizationId(
                        organization.getId()
                ))
                .coursesCount(
                        coursesCount != null
                                ? coursesCount
                                : courseRepository.countByOrganizationId(
                                        organization.getId()
                                )
                )
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
                .inviteId(
                        invite != null
                                ? invite.getId()
                                : null
                )
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

        return toSummaryResponse(
                organization,
                null
        );
    }

    public OrganizationSummaryResponse toSummaryResponse(
            Organization organization,
            OrganizationViewerResponse viewer
    ) {

        return OrganizationSummaryResponse.builder()
                .id(organization.getId())
                .name(organization.getName())
                .slug(organization.getSlug())
                .description(organization.getDescription())
                .image(organization.getImageUrl())
                .visibility(organization.getVisibility())
                .verified(
                        Boolean.TRUE.equals(
                                organization.getVerified()
                        )
                )
                .viewer(viewer)
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

    public OrganizationBannedUserResponse toBannedUserResponse(
            OrganizationBan ban
    ) {

        return new OrganizationBannedUserResponse(
                ban.getId(),
                userMapper.toResponse(
                        ban.getUser()
                ),
                ban.getBannedByOrgAdmins() != null
                        ? userMapper.toResponse(
                                ban.getBannedByOrgAdmins()
                        )
                        : null,
                ban.getBannedByAppAdmins() != null
                        ? adminMapper.toResponse(
                                ban.getBannedByAppAdmins()
                        )
                        : null,
                ban.getReason(),
                ban.getExpiresAt(),
                BaseEntityResponse.from(ban)
        );
    }
}
