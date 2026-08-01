package app.lms.organization.service;

import app.lms.common.exception.ConflictException;
import app.lms.enrollment.enums.EnrollmentStatus;
import app.lms.enrollment.repository.CourseEnrollmentRepository;
import app.lms.organization.dto.OrganizationResponse;
import app.lms.organization.enums.Role;
import app.lms.organization.mapper.OrganizationMapper;
import app.lms.organization.model.Organization;
import app.lms.organization.model.OrganizationMember;
import app.lms.organization.repository.OrganizationMemberRepository;
import app.lms.organization.repository.OrganizationRepository;
import app.lms.user.model.User;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.function.Function;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class OrganizationService {


    private final OrganizationRepository organizationRepository;
    private final OrganizationMapper organizationMapper;
    private final OrganizationAccessService organizationAccessService;
    private final OrganizationMemberRepository memberRepository;
    private final OrganizationMemberAccessService organizationMemberAccessService;
    private final CourseEnrollmentRepository courseEnrollmentRepository;

    @Value("${app.search.organization-similarity-threshold:0.2}")
    private double organizationSearchSimilarityThreshold;


    public OrganizationResponse getBySlug(
            String slug,
            User user
    ) {

        Organization organization =
                organizationAccessService.getBySlug(slug);

        organizationAccessService.validateUserNotBannedFromOrg(
                organization,
                user
        );

        Optional<OrganizationMember> member =
                memberRepository.findByOrganizationIdAndUserId(
                        organization.getId(),
                        user.getId()
                );

        return organizationMapper.ToResponse(
                organization,
                member.orElse(null)
        );
    }

    public Page<OrganizationResponse> getAll(
            String q,
            User user,
            Pageable pageable
    ) {

        Page<Organization> organizations =
                StringUtils.hasText(q)
                        ? organizationRepository.searchVisibleToUser(
                                q.trim(),
                                organizationSearchSimilarityThreshold,
                                user.getId(),
                                pageable
                        )
                        : organizationRepository.findAllVisibleToUser(
                                user.getId(),
                                pageable
                        );

        Map<Long, OrganizationMember> membersByOrganizationId =
                membersByOrganizationId(user);

        return organizations.map(organization ->
                        organizationMapper.ToResponse(
                                organization,
                                membersByOrganizationId.get(
                                        organization.getId()
                                )
                        )
                );
    }

    public List<OrganizationResponse> getMyOrganizations(
            User user
    ) {

        return memberRepository
                .findAllByUserIdAndOrganizationNotBanned(
                        user.getId()
                )
                .stream()
                .map(member ->
                        organizationMapper.ToResponse(
                                member.getOrganization(),
                                member
                        )
                )
                .toList();
    }

    private Map<Long, OrganizationMember> membersByOrganizationId(
            User user
    ) {

        return memberRepository
                .findAllByUserIdAndOrganizationNotBanned(
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

    @Transactional
    public void leaveOrganization(
            String organizationSlug,
            User user
    ) {

        Organization organization =
                organizationAccessService.getBySlug(
                        organizationSlug
                );

        OrganizationMember member =
                organizationMemberAccessService.getMember(
                        organization.getId(),
                        user.getId()
                );

        if (member.getRole() == Role.OWNER) {
            throw new ConflictException(
                    "Organization owner cannot leave the organization."
            );
        }

        boolean hasActiveEnrollments =
                courseEnrollmentRepository
                        .existsByUserIdAndCourseOrganizationIdAndStatus(
                                user.getId(),
                                organization.getId(),
                                EnrollmentStatus.ACTIVE
                        );

        if (hasActiveEnrollments) {
            throw new ConflictException(
                    "You must unenroll from all active courses before leaving the organization."
            );
        }

        memberRepository.delete(member);
    }

}
