package app.lms.organization.dto;

import app.lms.course.dto.CourseResponse;
import app.lms.post.dto.PostResponse;
import lombok.Builder;

import java.util.List;

@Builder
public record OrganizationDetailsResponse(

        OrganizationResponse organization,
        List<CourseResponse> courses,
        List<PostResponse> posts

) {}
