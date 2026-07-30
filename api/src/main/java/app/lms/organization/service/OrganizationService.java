package app.lms.organization.service;

import app.lms.course.dto.CourseResponse;
import app.lms.course.enums.CourseStatus;
import app.lms.course.mapper.CourseMapper;
import app.lms.course.model.Course;
import app.lms.course.repository.CourseRepository;
import app.lms.enrollment.enums.EnrollmentStatus;
import app.lms.enrollment.model.CourseEnrollment;
import app.lms.enrollment.repository.CourseEnrollmentRepository;
import app.lms.organization.dto.OrganizationDetailsResponse;
import app.lms.organization.dto.OrganizationResponse;
import app.lms.organization.mapper.OrganizationMapper;
import app.lms.organization.model.Organization;
import app.lms.organization.model.OrganizationMember;
import app.lms.organization.repository.OrganizationMemberRepository;
import app.lms.organization.repository.OrganizationRepository;
import app.lms.post.dto.PostResponse;
import app.lms.post.mapper.PostMapper;
import app.lms.post.model.Post;
import app.lms.post.repository.PostRepository;
import app.lms.user.model.User;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import java.util.ArrayList;
import java.util.Comparator;
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
    private final CourseRepository courseRepository;
    private final CourseMapper courseMapper;
    private final CourseEnrollmentRepository enrollmentRepository;
    private final PostRepository postRepository;
    private final PostMapper postMapper;

    @Value("${app.search.organization-similarity-threshold:0.2}")
    private double organizationSearchSimilarityThreshold;


    public OrganizationDetailsResponse getBySlug(
            String slug,
            User user
    ) {

        Organization organization =
                organizationAccessService.getBySlug(slug);

        Optional<OrganizationMember> member =
                memberRepository.findByOrganizationIdAndUserId(
                        organization.getId(),
                        user.getId()
                );

        List<Course> courses =
                courseRepository.findAllByOrganizationIdAndStatus(
                        organization.getId(),
                        CourseStatus.PUBLISHED
                );

        Map<Long, CourseEnrollment> enrollmentsByCourseId =
                enrollmentsByCourseId(
                        courses,
                        user
                );

        return OrganizationDetailsResponse.builder()
                .organization(
                        organizationMapper.ToResponse(
                                organization,
                                member.orElse(null)
                        )
                )
                .courses(
                        courseResponses(
                                courses,
                                enrollmentsByCourseId
                        )
                )
                .posts(
                        postResponses(
                                organization,
                                member.isPresent(),
                                enrollmentsByCourseId
                        )
                )
                .build();
    }

    public List<OrganizationResponse> getAll(
            String q,
            User user
    ) {

        List<Organization> organizations =
                StringUtils.hasText(q)
                        ? organizationRepository.search(
                                q.trim(),
                                organizationSearchSimilarityThreshold
                        )
                        : organizationRepository.findAll();

        Map<Long, OrganizationMember> membersByOrganizationId =
                membersByOrganizationId(user);

        return organizations
                .stream()
                .map(organization ->
                        organizationMapper.ToResponse(
                                organization,
                                membersByOrganizationId.get(
                                        organization.getId()
                                )
                        )
                )
                .toList();
    }

    public List<OrganizationResponse> getMyOrganizations(
            User user
    ) {

        return memberRepository
                .findAllByUserId(user.getId())
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
                .findAllByUserId(user.getId())
                .stream()
                .collect(
                        Collectors.toMap(
                                member -> member.getOrganization()
                                        .getId(),
                                Function.identity()
                        )
                );
    }

    private Map<Long, CourseEnrollment> enrollmentsByCourseId(
            List<Course> courses,
            User user
    ) {

        List<Long> courseIds =
                courses.stream()
                        .map(Course::getId)
                        .toList();

        if (courseIds.isEmpty()) {
            return Map.of();
        }

        return enrollmentRepository
                .findAllByUserIdAndStatusInAndCourseIdIn(
                        user.getId(),
                        List.of(
                                EnrollmentStatus.ACTIVE,
                                EnrollmentStatus.COMPLETED
                        ),
                        courseIds
                )
                .stream()
                .collect(
                        Collectors.toMap(
                                enrollment -> enrollment.getCourse()
                                        .getId(),
                                Function.identity()
                        )
                );
    }

    private List<CourseResponse> courseResponses(
            List<Course> courses,
            Map<Long, CourseEnrollment> enrollmentsByCourseId
    ) {

        return courses.stream()
                .map(course ->
                        courseMapper.toResponse(
                                course,
                                enrollmentsByCourseId.get(
                                        course.getId()
                                )
                        )
                )
                .toList();
    }

    private List<PostResponse> postResponses(
            Organization organization,
            boolean joined,
            Map<Long, CourseEnrollment> enrollmentsByCourseId
    ) {

        List<Post> posts =
                new ArrayList<>(
                        postRepository
                                .findAllByOrganizationIdAndCourseIsNullOrderByCreatedAtDesc(
                                        organization.getId()
                                )
                );

        if (joined && !enrollmentsByCourseId.isEmpty()) {
            posts.addAll(
                    postRepository
                            .findAllByOrganizationIdAndCourseIdInOrderByCreatedAtDesc(
                                    organization.getId(),
                                    enrollmentsByCourseId.keySet()
                                            .stream()
                                            .toList()
                            )
            );
        }

        posts.sort(
                Comparator.comparing(
                        Post::getCreatedAt,
                        Comparator.nullsFirst(
                                Comparator.naturalOrder()
                        )
                ).reversed()
        );

        return posts.stream()
                .map(postMapper::toResponse)
                .toList();
    }

}
