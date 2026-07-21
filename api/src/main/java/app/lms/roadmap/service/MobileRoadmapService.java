package app.lms.roadmap.service;

import app.lms.common.exception.ConflictException;
import app.lms.common.exception.NotFoundException;
import app.lms.courceEnrollment.enums.EnrollmentStatus;
import app.lms.courceEnrollment.model.CourseEnrollment;
import app.lms.courceEnrollment.repository.CourseEnrollmentRepository;
import app.lms.course.enums.CourseStatus;
import app.lms.organization.model.Organization;
import app.lms.organization.repository.OrganizationMemberRepository;
import app.lms.organization.service.OrganizationAccessService;
import app.lms.roadmap.dto.RoadmapResponse;
import app.lms.roadmap.enums.RoadmapFollowStatus;
import app.lms.roadmap.mapper.RoadmapMapper;
import app.lms.roadmap.model.Roadmap;
import app.lms.roadmap.model.RoadmapFollower;
import app.lms.roadmap.repository.RoadmapFollowerRepository;
import app.lms.roadmap.repository.RoadmapRepository;
import app.lms.user.model.User;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class MobileRoadmapService {

    private final OrganizationAccessService organizationAccessService;
    private final RoadmapRepository roadmapRepository;
    private final RoadmapFollowerRepository roadmapFollowerRepository;
    private final CourseEnrollmentRepository courseEnrollmentRepository;
    private final OrganizationMemberRepository organizationMemberRepository;
    private final RoadmapMapper roadmapMapper;
    private final RoadmapFollowProgressService roadmapFollowProgressService;

    @Transactional
    public Page<RoadmapResponse> listAll(
            Pageable pageable,
            User user
    ) {

        return roadmapRepository
                .findAllByOrderByCreatedAtDesc(
                        pageable
                )
                .map(roadmap ->
                        roadmapResponseFor(
                                roadmap,
                                user
                        )
                );
    }

    @Transactional
    public Page<RoadmapResponse> list(
            String organizationSlug,
            Pageable pageable,
            User user
    ) {

        Organization organization =
                organizationAccessService
                        .getBySlug(
                                organizationSlug
                        );

        return roadmapRepository
                .findAllByOrganizationIdOrderByCreatedAtDesc(
                        organization.getId(),
                        pageable
                )
                .map(roadmap ->
                        roadmapResponseFor(
                                roadmap,
                                user
                        )
                );
    }

    @Transactional
    public RoadmapResponse getById(
            String organizationSlug,
            Long roadmapId,
            User user
    ) {

        Organization organization =
                organizationAccessService
                        .getBySlug(
                                organizationSlug
                        );

        Roadmap roadmap =
                getByIdAndOrganizationId(
                        roadmapId,
                        organization.getId()
                );

        return roadmapResponseFor(
                roadmap,
                user
        );
    }

    @Transactional
    public RoadmapResponse follow(
            String organizationSlug,
            Long roadmapId,
            User user
    ) {

        Organization organization =
                organizationAccessService
                        .getBySlug(
                                organizationSlug
                        );

        Roadmap roadmap =
                getByIdAndOrganizationId(
                        roadmapId,
                        organization.getId()
                );

        validateOrganizationMember(
                organization,
                user
        );

        if (
                roadmapFollowerRepository.existsByRoadmapIdAndUserId(
                        roadmap.getId(),
                        user.getId()
                )
        ) {
            throw new ConflictException(
                    "Already following roadmap"
            );
        }

        roadmapFollowerRepository.save(
                RoadmapFollower.builder()
                        .roadmap(roadmap)
                        .user(user)
                        .build()
        );

        roadmapFollowProgressService.refresh(
                roadmap,
                user
        );

        return roadmapResponseFor(
                roadmap,
                user
        );
    }

    @Transactional
    public void unfollow(
            String organizationSlug,
            Long roadmapId,
            User user
    ) {

        Organization organization =
                organizationAccessService
                        .getBySlug(
                                organizationSlug
                        );

        Roadmap roadmap =
                getByIdAndOrganizationId(
                        roadmapId,
                        organization.getId()
                );

        RoadmapFollower follower =
                roadmapFollowerRepository
                        .findByRoadmapIdAndUserId(
                                roadmap.getId(),
                                user.getId()
                        )
                        .orElseThrow(() ->
                                new NotFoundException(
                                        "Followed roadmap not found"
                                )
                        );

        roadmapFollowerRepository.delete(follower);
    }

    @Transactional
    public Page<RoadmapResponse> myRoadmaps(
            Pageable pageable,
            User user
    ) {

        return roadmapFollowerRepository
                .findAllByUserIdOrderByCreatedAtDesc(
                        user.getId(),
                        pageable
                )
                .map(follower ->
                        roadmapResponseFor(
                                follower.getRoadmap(),
                                user
                        )
                );
    }

    private RoadmapResponse roadmapResponseFor(
            Roadmap roadmap,
            User user
    ) {

        Map<Long, CourseEnrollment> enrollmentsByCourseId =
                enrollmentsByCourseId(
                        roadmap,
                        user
                );

        return roadmapMapper.toMobileResponse(
                roadmap,
                enrollmentsByCourseId,
                followStatus(
                        roadmap,
                        user
                )
        );
    }

    private RoadmapFollowStatus followStatus(
            Roadmap roadmap,
            User user
    ) {

        RoadmapFollower follower =
                roadmapFollowerRepository
                        .findByRoadmapIdAndUserId(
                                roadmap.getId(),
                                user.getId()
                        )
                        .orElse(null);

        if (follower == null) {
            return RoadmapFollowStatus.NOT_FOLLOWING;
        }

        if (follower.getStatus() == null) {
            follower.setStatus(
                    RoadmapFollowStatus.ACTIVE
            );
        }

        return follower.getStatus();
    }

    private List<Long> publishedCourseIds(
            Roadmap roadmap
    ) {

        return roadmap.getItems()
                .stream()
                .filter(item ->
                        item.getCourse().getStatus()
                                == CourseStatus.PUBLISHED
                )
                .map(item ->
                        item.getCourse().getId()
                )
                .toList();
    }

    private Roadmap getByIdAndOrganizationId(
            Long roadmapId,
            Long organizationId
    ) {

        return roadmapRepository
                .findByIdAndOrganizationId(
                        roadmapId,
                        organizationId
                )
                .orElseThrow(() ->
                        new NotFoundException(
                                "Roadmap not found"
                        )
                );
    }

    private Map<Long, CourseEnrollment> enrollmentsByCourseId(
            Roadmap roadmap,
            User user
    ) {

        List<Long> courseIds =
                publishedCourseIds(
                        roadmap
                );

        if (courseIds.isEmpty()) {
            return Map.of();
        }

        return courseEnrollmentRepository
                .findAllByUserIdAndStatusInAndCourseIdIn(
                        user
                                .getId(),
                        List.of(
                                EnrollmentStatus.ACTIVE,
                                EnrollmentStatus.COMPLETED
                        ),
                        courseIds
                )
                .stream()
                .collect(
                        Collectors.toMap(
                                enrollment ->
                                        enrollment.getCourse().getId(),
                                Function.identity()
                        )
                );
    }

    private void validateOrganizationMember(
            Organization organization,
            User user
    ) {

        if (
                !organizationMemberRepository.existsByOrganizationIdAndUserId(
                        organization.getId(),
                        user.getId()
                )
        ) {
            throw new NotFoundException(
                    "Organization membership not found"
            );
        }
    }
}
