package app.lms.ai.dashboard.faq.service;

import app.lms.ai.dashboard.faq.dto.GenerateCourseFaqRequest;
import app.lms.course.model.Course;
import app.lms.course.service.CourseAccessService;
import app.lms.faq.dto.CourseFaqResponse;
import app.lms.faq.service.CourseFaqAiGenerator;
import app.lms.plan.annotation.ConsumesPlanUsage;
import app.lms.plan.enums.PlanUsageType;
import app.lms.user.model.User;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class DashboardAiFaqService {

    private final CourseAccessService courseAccessService;
    private final CourseFaqAiGenerator courseFaqAiGenerator;
    private final DashboardAiFaqAccessService  dashboardAiFaqAccessService;

    @ConsumesPlanUsage(PlanUsageType.AI_TOOL)
    public List<CourseFaqResponse> generate(
            Long courseId,
            GenerateCourseFaqRequest request,
            User user
    ) {

        Course course =
                courseAccessService.getEditableCourse(
                        courseId,
                        user
                );

        boolean regenerate =
                request.regenerate() != null
                        && request.regenerate();

        if (!regenerate && dashboardAiFaqAccessService.hasFaqs(courseId)) {
            return dashboardAiFaqAccessService.getFaqs(courseId, user);
        }

        return courseFaqAiGenerator.generateFor(
                course,
                request.count()
        );
    }

    public List<CourseFaqResponse> getFaqs(Long courseId, User user) {
        return dashboardAiFaqAccessService.getFaqs(courseId, user);
    }
}
