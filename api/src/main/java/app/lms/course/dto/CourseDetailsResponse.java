package app.lms.course.dto;

import app.lms.common.dto.BaseEntityResponse;
import app.lms.courceEnrollment.dto.CourseProgressResponse;
import lombok.*;

import java.util.List;

@Builder
    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    public class CourseDetailsResponse {

        private Long id;

        private String title;

        private String slug;

        private String description;

        private String coverUrl;

        private String organizationName;
        private List<CourseChapterMapResponse> chapters;
        private CourseProgressResponse progress;
        private BaseEntityResponse baseEntity;

    }
