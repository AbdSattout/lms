package app.lms.course.dto;

import app.lms.common.dto.BaseEntityResponse;
import app.lms.courceEnrollment.dto.CourseEnrollmentResponse;
import app.lms.course.enums.CourseStatus;
import app.lms.organization.dto.OrganizationSummaryResponse;
import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Builder;

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
        CourseEnrollmentResponse enrollment,
        BaseEntityResponse baseEntity

) {}
