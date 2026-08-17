package app.lms.recommendation.service;

import app.lms.course.dto.CourseLearningSummary;
import app.lms.course.enums.CourseStatus;
import app.lms.course.service.CourseLearningSummaryService;
import app.lms.enrollment.enums.EnrollmentStatus;
import app.lms.organization.dto.OrganizationViewerResponse;
import app.lms.organization.service.OrganizationViewerService;
import app.lms.recommendation.dto.RecommendationScore;
import app.lms.recommendation.dto.RecommendedCourseResponse;
import app.lms.recommendation.mapper.RecommendationMapper;
import app.lms.recommendation.repository.CourseRecommendationCandidate;
import app.lms.recommendation.repository.CourseRecommendationRepository;
import app.lms.user.model.User;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class CourseRecommendationService {

    private final CourseRecommendationRepository courseRecommendationRepository;
    private final RecommendationScoringService recommendationScoringService;
    private final RecommendationMapper recommendationMapper;
    private final RecommendationPageableFactory recommendationPageableFactory;
    private final CourseLearningSummaryService courseLearningSummaryService;
    private final OrganizationViewerService organizationViewerService;

    @Transactional(readOnly = true)
    public Page<RecommendedCourseResponse> recommend(
            Pageable pageable,
            User user
    ) {

        Instant recentCourseCutoff =
                recommendationScoringService.recentCutoff();

        Page<CourseRecommendationCandidate> candidates =
                courseRecommendationRepository.findCandidates(
                        user.getId(),
                        CourseStatus.PUBLISHED,
                        List.of(
                                EnrollmentStatus.ACTIVE,
                                EnrollmentStatus.COMPLETED
                        ),
                        recentCourseCutoff,
                        recommendationPageableFactory.forRanking(pageable)
                );

        Map<Long, OrganizationViewerResponse> organizationViewers =
                organizationViewerService.byOrganizationId(
                        candidates.getContent()
                                .stream()
                                .map(candidate ->
                                        candidate.course()
                                                .getOrganization()
                                )
                                .toList(),
                        user
                );

        return candidates.map(candidate ->
                toRecommendedCourseResponse(
                        candidate,
                        organizationViewers,
                        recentCourseCutoff
                )
        );
    }

    private RecommendedCourseResponse toRecommendedCourseResponse(
            CourseRecommendationCandidate candidate,
            Map<Long, OrganizationViewerResponse> organizationViewers,
            Instant recentCourseCutoff
    ) {

        RecommendationScore score =
                recommendationScoringService.scoreCourse(
                        candidate,
                        recentCourseCutoff
                );

        CourseLearningSummary learningSummary =
                courseLearningSummaryService.summarize(
                        candidate.course()
                                .getId()
                );

        return recommendationMapper.toCourseResponse(
                candidate,
                score,
                organizationViewers,
                learningSummary
        );
    }
}
