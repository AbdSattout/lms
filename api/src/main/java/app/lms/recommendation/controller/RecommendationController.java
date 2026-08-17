package app.lms.recommendation.controller;

import app.lms.recommendation.dto.RecommendedCourseResponse;
import app.lms.recommendation.dto.RecommendedOrganizationResponse;
import app.lms.recommendation.service.CourseRecommendationService;
import app.lms.recommendation.service.OrganizationRecommendationService;
import app.lms.security.UserPrincipal;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/recommendations")
@RequiredArgsConstructor
public class RecommendationController {

    private final CourseRecommendationService courseRecommendationService;
    private final OrganizationRecommendationService organizationRecommendationService;

    @GetMapping("/courses")
    public ResponseEntity<Page<RecommendedCourseResponse>> recommendCourses(
            @PageableDefault(size = 10)
            Pageable pageable,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                courseRecommendationService.recommend(
                        pageable,
                        principal.user()
                )
        );
    }

    @GetMapping("/organizations")
    public ResponseEntity<Page<RecommendedOrganizationResponse>> recommendOrganizations(
            @PageableDefault(size = 10)
            Pageable pageable,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                organizationRecommendationService.recommend(
                        pageable,
                        principal.user()
                )
        );
    }
}
