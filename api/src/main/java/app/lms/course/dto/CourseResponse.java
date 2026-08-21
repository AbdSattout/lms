package app.lms.course.dto;

import app.lms.common.dto.BaseEntityResponse;
import app.lms.enrollment.dto.CourseEnrollmentResponse;
import app.lms.course.enums.CourseStatus;
import app.lms.faq.dto.CourseFaqResponse;
import app.lms.organization.dto.OrganizationSummaryResponse;
import app.lms.organization.organizationJoinRequest.enums.JoinRequestStatus;
import app.lms.question.enums.QuestionDifficulty;
import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Builder;

import java.util.List;

@Builder
public record CourseResponse(

        Long id,
        String title,
        String slug,
        String description,
        String coverUrl,
        OrganizationSummaryResponse organization,
        CourseStatus status,
        @JsonInclude(JsonInclude.Include.NON_NULL)
        QuestionDifficulty level,
        @JsonInclude(JsonInclude.Include.NON_NULL)
        Integer completionXp,
        @JsonInclude(JsonInclude.Include.NON_NULL)
        Long chaptersCount,
        @JsonInclude(JsonInclude.Include.NON_NULL)
        CourseEnrollmentResponse enrollment,
        @JsonInclude(JsonInclude.Include.NON_NULL)
        JoinRequestStatus joinRequest,
        @JsonInclude(JsonInclude.Include.NON_NULL)
        List<CourseFaqResponse> faqs,
        BaseEntityResponse baseEntity

) {}
