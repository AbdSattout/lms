package app.lms.organization.mapper;

import app.lms.common.dto.BaseEntityResponse;
import app.lms.organization.dto.JoinRequestResponse;
import app.lms.organization.dto.OrganizationInviteResponse;
import app.lms.organization.dto.OrganizationMemberResponse;
import app.lms.organization.dto.OrganizationResponse;
import app.lms.organization.model.Organization;
import app.lms.organization.model.OrganizationInvite;
import app.lms.organization.model.OrganizationJoinRequest;
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
                .baseEntity(BaseEntityResponse.from(organization))
                .build();
    }
    public OrganizationInviteResponse toResponse(OrganizationInvite invite) {
        return OrganizationInviteResponse.builder()
                .id(invite.getId())
                .userId(invite.getUser() != null ? invite.getUser().getId() : null)
                .userName(invite.getUser() != null ? invite.getUser().getName() : "Public Link")
                .role(invite.getRole())
                .status(invite.getStatus())
                .invitedByName(invite.getInvitedBy().getName())
                .expiresAt(invite.getExpiresAt())
                .createdAt(invite.getCreatedAt())
                .maxUses(invite.getMaxUses())
                .usedCount(invite.getUsedCount())
                .baseEntity(BaseEntityResponse.from(invite))
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
    public JoinRequestResponse toJoinRequestResponse(OrganizationJoinRequest request) {
        return JoinRequestResponse.builder()
                .id(request.getId())
                .status(request.getStatus())
                .createdAt(request.getCreatedAt())
                .user(userMapper.toResponse(request.getUser()))
                .build();
    }
}
