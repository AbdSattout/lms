package app.lms.course.dto;

import app.lms.common.dto.BaseEntityResponse;
import app.lms.enrollment.dto.CourseEnrollmentResponse;
import app.lms.course.enums.CourseStatus;
import app.lms.organization.dto.OrganizationSummaryResponse;
import app.lms.organization.organizationJoinRequest.enums.JoinRequestStatus;
import app.lms.organization.organizationJoinRequest.model.OrganizationJoinRequest;
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
        JoinRequestStatus joinRequest,
        BaseEntityResponse baseEntity

) {}
