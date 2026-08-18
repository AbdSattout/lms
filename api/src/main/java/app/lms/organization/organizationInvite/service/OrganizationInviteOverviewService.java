package app.lms.organization.organizationInvite.service;

import app.lms.course.enums.CourseStatus;
import app.lms.course.repository.CourseRepository;
import app.lms.organization.enums.Role;
import app.lms.organization.organizationInvite.dto.OrganizationInviteOverviewResponse;
import app.lms.organization.organizationInvite.model.OrganizationInvite;
import app.lms.organization.repository.OrganizationMemberRepository;
import app.lms.organization.repository.projection.OrganizationCountProjection;
import app.lms.post.repository.PostRepository;
import app.lms.roadmap.repository.RoadmapRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class OrganizationInviteOverviewService {

    private final OrganizationMemberRepository memberRepository;
    private final CourseRepository courseRepository;
    private final PostRepository postRepository;
    private final RoadmapRepository roadmapRepository;

    public Map<Long, OrganizationInviteOverviewResponse> buildByOrganizationId(
            List<OrganizationInvite> invites
    ) {

        Set<Long> organizationIds =
                invites
                        .stream()
                        .map(invite -> invite.getOrganization().getId())
                        .collect(Collectors.toSet());

        if (organizationIds.isEmpty()) {
            return Map.of();
        }

        Map<Long, Long> membersCounts =
                toCountMap(
                        memberRepository.countActiveByOrganizationIds(
                                organizationIds
                        )
                );

        Map<Long, Long> adminsCounts =
                toCountMap(
                        memberRepository.countActiveByOrganizationIdsAndRole(
                                organizationIds,
                                Role.ADMIN
                        )
                );

        Map<Long, Long> studentsCounts =
                toCountMap(
                        memberRepository.countActiveByOrganizationIdsAndRole(
                                organizationIds,
                                Role.STUDENT
                        )
                );

        Map<Long, Long> coursesCounts =
                toCountMap(
                        courseRepository.countByOrganizationIds(
                                organizationIds
                        )
                );

        Map<Long, Long> publishedCoursesCounts =
                toCountMap(
                        courseRepository.countByOrganizationIdsAndStatus(
                                organizationIds,
                                CourseStatus.PUBLISHED
                        )
                );

        Map<Long, Long> draftCoursesCounts =
                toCountMap(
                        courseRepository.countByOrganizationIdsAndStatus(
                                organizationIds,
                                CourseStatus.DRAFT
                        )
                );

        Map<Long, Long> postsCounts =
                toCountMap(
                        postRepository.countByOrganizationIds(
                                organizationIds
                        )
                );

        Map<Long, Long> roadmapsCounts =
                toCountMap(
                        roadmapRepository.countByOrganizationIds(
                                organizationIds
                        )
                );

        return organizationIds
                .stream()
                .collect(
                        Collectors.toMap(
                                organizationId -> organizationId,
                                organizationId ->
                                        OrganizationInviteOverviewResponse
                                                .builder()
                                                .membersCount(
                                                        count(
                                                                membersCounts,
                                                                organizationId
                                                        )
                                                )
                                                .adminsCount(
                                                        count(
                                                                adminsCounts,
                                                                organizationId
                                                        )
                                                )
                                                .studentsCount(
                                                        count(
                                                                studentsCounts,
                                                                organizationId
                                                        )
                                                )
                                                .coursesCount(
                                                        count(
                                                                coursesCounts,
                                                                organizationId
                                                        )
                                                )
                                                .publishedCoursesCount(
                                                        count(
                                                                publishedCoursesCounts,
                                                                organizationId
                                                        )
                                                )
                                                .draftCoursesCount(
                                                        count(
                                                                draftCoursesCounts,
                                                                organizationId
                                                        )
                                                )
                                                .postsCount(
                                                        count(
                                                                postsCounts,
                                                                organizationId
                                                        )
                                                )
                                                .roadmapsCount(
                                                        count(
                                                                roadmapsCounts,
                                                                organizationId
                                                        )
                                                )
                                                .build()
                        )
                );
    }

    private Map<Long, Long> toCountMap(
            List<OrganizationCountProjection> counts
    ) {

        return counts
                .stream()
                .collect(
                        Collectors.toMap(
                                OrganizationCountProjection::getOrganizationId,
                                OrganizationCountProjection::getTotal
                        )
                );
    }

    private long count(
            Map<Long, Long> counts,
            Long organizationId
    ) {

        return counts.getOrDefault(
                organizationId,
                0L
        );
    }
}
