package app.lms.organization.service;

import app.lms.common.exception.ConflictException;
import app.lms.course.repository.CourseRepository;
import app.lms.enrollment.enums.EnrollmentStatus;
import app.lms.enrollment.repository.CourseEnrollmentRepository;
import app.lms.organization.dto.OrganizationResponse;
import app.lms.organization.dto.OrganizationViewerResponse;
import app.lms.organization.enums.Role;
import app.lms.organization.mapper.OrganizationMapper;
import app.lms.organization.model.Organization;
import app.lms.organization.model.OrganizationMember;
import app.lms.organization.repository.OrganizationMemberRepository;
import app.lms.organization.repository.OrganizationRepository;
import app.lms.organization.repository.projection.OrganizationCountProjection;
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

@Service
@RequiredArgsConstructor
public class OrganizationService {


    private final OrganizationRepository organizationRepository;
    private final OrganizationMapper organizationMapper;
    private final OrganizationAccessService organizationAccessService;
    private final OrganizationMemberRepository memberRepository;
    private final OrganizationMemberAccessService organizationMemberAccessService;
    private final CourseEnrollmentRepository courseEnrollmentRepository;
    private final OrganizationViewerService organizationViewerService;
    private final CourseRepository courseRepository;

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

        OrganizationViewerResponse viewer =
                organizationViewerService.forOrganization(
                        organization,
                        user
                );

        return organizationMapper.ToResponse(
                organization,
                viewer,
                courseRepository.countByOrganizationId(
                        organization.getId()
                )
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

        Map<Long, OrganizationViewerResponse> viewersByOrganizationId =
                organizationViewerService.byOrganizationId(
                        organizations.getContent(),
                        user
                );

        Map<Long, Long> coursesCountsByOrganizationId =
                coursesCountsByOrganizationId(
                        organizations.getContent()
                );

        return organizations.map(organization ->
                        organizationMapper.ToResponse(
                                organization,
                                viewersByOrganizationId.get(
                                        organization.getId()
                                ),
                                coursesCountsByOrganizationId.getOrDefault(
                                        organization.getId(),
                                        0L
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
                                member,
                                null
                        )
                )
                .toList();
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

    private Map<Long, Long> coursesCountsByOrganizationId(
            List<Organization> organizations
    ) {

        List<Long> organizationIds =
                organizations.stream()
                        .map(Organization::getId)
                        .toList();

        if (organizationIds.isEmpty()) {
            return Map.of();
        }

        return courseRepository
                .countByOrganizationIds(
                        organizationIds
                )
                .stream()
                .collect(
                        java.util.stream.Collectors.toMap(
                                OrganizationCountProjection::getOrganizationId,
                                OrganizationCountProjection::getTotal
                        )
                );
    }

}
