package app.lms.recommendation.service;

import app.lms.course.enums.CourseStatus;
import app.lms.organization.dto.OrganizationViewerResponse;
import app.lms.organization.service.OrganizationViewerService;
import app.lms.recommendation.dto.RecommendationScore;
import app.lms.recommendation.dto.RecommendedOrganizationResponse;
import app.lms.recommendation.mapper.RecommendationMapper;
import app.lms.recommendation.repository.OrganizationRecommendationCandidate;
import app.lms.recommendation.repository.OrganizationRecommendationRepository;
import app.lms.user.model.User;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class OrganizationRecommendationService {

    private final OrganizationRecommendationRepository organizationRecommendationRepository;
    private final RecommendationScoringService recommendationScoringService;
    private final RecommendationMapper recommendationMapper;
    private final RecommendationPageableFactory recommendationPageableFactory;
    private final OrganizationViewerService organizationViewerService;

    @Transactional(readOnly = true)
    public Page<RecommendedOrganizationResponse> recommend(
            Pageable pageable,
            User user
    ) {

        Instant recentCourseCutoff =
                recommendationScoringService.recentCutoff();

        Page<OrganizationRecommendationCandidate> candidates =
                organizationRecommendationRepository.findCandidates(
                        user.getId(),
                        CourseStatus.PUBLISHED,
                        recentCourseCutoff,
                        RecommendationScoringService.MANY_PUBLISHED_COURSES_THRESHOLD,
                        RecommendationScoringService.MANY_MEMBERS_THRESHOLD,
                        recommendationPageableFactory.forRanking(pageable)
                );

        Map<Long, OrganizationViewerResponse> organizationViewers =
                organizationViewerService.byOrganizationId(
                        candidates.getContent()
                                .stream()
                                .map(OrganizationRecommendationCandidate::organization)
                                .toList(),
                        user
                );

        return candidates.map(candidate ->
                toRecommendedOrganizationResponse(
                        candidate,
                        organizationViewers,
                        recentCourseCutoff
                )
        );
    }

    private RecommendedOrganizationResponse toRecommendedOrganizationResponse(
            OrganizationRecommendationCandidate candidate,
            Map<Long, OrganizationViewerResponse> organizationViewers,
            Instant recentCourseCutoff
    ) {

        RecommendationScore score =
                recommendationScoringService.scoreOrganization(
                        candidate,
                        recentCourseCutoff
                );

        return recommendationMapper.toOrganizationResponse(
                candidate,
                score,
                organizationViewers
        );
    }
}
