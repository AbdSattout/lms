package app.lms.analytics.organization.service;

import app.lms.course.enums.CourseStatus;
import app.lms.course.repository.CourseRepository;
import app.lms.analytics.organization.dto.OrganizationOverviewResponse;
import app.lms.media.dto.StorageResponse;
import app.lms.media.repository.OrganizationMediaRepository;
import app.lms.organization.enums.Role;
import app.lms.organization.model.Organization;
import app.lms.organization.repository.OrganizationMemberRepository;
import app.lms.organization.service.OrganizationAccessService;
import app.lms.plan.model.Plan;
import app.lms.plan.service.UserPlanService;
import app.lms.post.repository.PostRepository;
import app.lms.roadmap.repository.RoadmapRepository;
import app.lms.user.mapper.UserMapper;
import app.lms.user.model.User;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class OrganizationOverviewService {

    private final OrganizationAccessService organizationAccessService;

    private final OrganizationMemberRepository organizationMemberRepository;

    private final CourseRepository courseRepository;

    private final PostRepository postRepository;

    private final UserMapper userMapper;

    private final UserPlanService userPlanService;

    private final OrganizationMediaRepository organizationMediaRepository;

    private final RoadmapRepository roadmapRepository;

    public OrganizationOverviewResponse getOverview(

            String slug,
            User user
    ) {

        Organization organization =
                organizationAccessService
                        .getManageableOrganization(
                                slug,
                                user
                        );


        return OrganizationOverviewResponse
                .builder()

                .owner(
                        userMapper.toResponse(
                                organization.getOwner()
                        )
                )

                .membersCount(
                        organizationMemberRepository
                                .countByOrganizationId(
                                        organization.getId()
                                )
                )

                .adminsCount(
                        organizationMemberRepository
                                .countByOrganizationIdAndRole(
                                        organization.getId(),
                                        Role.ADMIN
                                )
                )

                .studentsCount(
                        organizationMemberRepository
                                .countByOrganizationIdAndRole(
                                        organization.getId(),
                                        Role.STUDENT
                                )
                )

                .coursesCount(
                        courseRepository
                                .countByOrganizationId(
                                        organization.getId()
                                )
                )

                .publishedCoursesCount(
                        courseRepository
                                .countByOrganizationIdAndStatus(
                                        organization.getId(),
                                        CourseStatus.PUBLISHED
                                )
                )

                .draftCoursesCount(
                        courseRepository
                                .countByOrganizationIdAndStatus(
                                        organization.getId(),
                                        CourseStatus.DRAFT
                                )
                )

                .postsCount(
                        postRepository
                                .countByOrganizationId(
                                        organization.getId()
                                )
                )

                .roadmapsCount(
                        roadmapRepository.countByOrganizationId(
                                organization.getId()
                        )
                )

                .storage(buildStorageResponse(organization))


                .build();

    }

    private StorageResponse buildStorageResponse(
            Organization organization
    ) {

        Plan plan =
                userPlanService
                        .getOrCreateCurrentPlan(
                                organization.getOwner()
                        );

        long used =
                organizationMediaRepository
                        .sumSizeBytesByOrganizationId(
                                organization.getId()
                        );

        Long limit =
                plan.getOrganizationStorageLimitBytes();

        if (limit == null ) {
            return StorageResponse.builder()
                    .usedBytes(used)
                    .unlimited(true)
                    .build();
        }

        long available = Math.max(0, limit - used);

        double percentage =
                limit == 0
                        ? 0
                        : (used * 100.0) / limit;

        return StorageResponse.builder()
                .usedBytes(used)
                .availableBytes(available)
                .totalBytes(limit)
                .usagePercentage(percentage)
                .unlimited(false)
                .build();
    }

}
