package app.lms.recommendation.mapper;

import app.lms.course.dto.CourseLearningSummary;
import app.lms.course.mapper.CourseMapper;
import app.lms.course.model.Course;
import app.lms.organization.dto.OrganizationViewerResponse;
import app.lms.organization.mapper.OrganizationMapper;
import app.lms.organization.model.Organization;
import app.lms.recommendation.dto.RecommendationScore;
import app.lms.recommendation.dto.RecommendedCourseResponse;
import app.lms.recommendation.dto.RecommendedOrganizationResponse;
import app.lms.recommendation.repository.CourseRecommendationCandidate;
import app.lms.recommendation.repository.OrganizationRecommendationCandidate;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.Map;

@Component
@RequiredArgsConstructor
public class RecommendationMapper {

    private final CourseMapper courseMapper;
    private final OrganizationMapper organizationMapper;

    public RecommendedCourseResponse toCourseResponse(
            CourseRecommendationCandidate candidate,
            RecommendationScore score,
            Map<Long, OrganizationViewerResponse> organizationViewers,
            CourseLearningSummary learningSummary
    ) {

        Course course =
                candidate.course();

        return new RecommendedCourseResponse(
                courseMapper.toResponse(
                        course,
                        null,
                        viewerFor(
                                course.getOrganization(),
                                organizationViewers
                        ),
                        learningSummary
                ),
                score.score(),
                score.reason()
        );
    }

    public RecommendedOrganizationResponse toOrganizationResponse(
            OrganizationRecommendationCandidate candidate,
            RecommendationScore score,
            Map<Long, OrganizationViewerResponse> organizationViewers
    ) {

        Organization organization =
                candidate.organization();

        return new RecommendedOrganizationResponse(
                organizationMapper.ToResponse(
                        organization,
                        viewerFor(
                                organization,
                                organizationViewers
                        ),
                        candidate.publishedCourseCount()
                ),
                score.score(),
                score.reason()
        );
    }

    private OrganizationViewerResponse viewerFor(
            Organization organization,
            Map<Long, OrganizationViewerResponse> organizationViewers
    ) {

        return organizationViewers.get(
                organization.getId()
        );
    }
}
