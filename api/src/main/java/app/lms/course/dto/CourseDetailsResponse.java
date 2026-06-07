package app.lms.course.dto;

import app.lms.chapter.dto.ChapterResponse;
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
        private List<ChapterResponse> chapters;

    }

