package app.lms.course.mapper;

import app.lms.chapter.mapper.ChapterMapper;
import app.lms.chapter.model.Chapter;
import app.lms.courceEnrollment.dto.CourseProgressResponse;
import app.lms.courceEnrollment.model.CourseEnrollment;
import app.lms.course.dto.CourseDetailsResponse;
import app.lms.course.dto.CourseResponse;
import app.lms.course.model.Course;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.Comparator;

@Component
@RequiredArgsConstructor
public class CourseMapper {

    private final ChapterMapper chapterMapper;
    public CourseResponse toResponse(
            Course course
    ) {

        return CourseResponse.builder()
                .id(course.getId())
                .title(course.getTitle())
                .description(course.getDescription())
                .coverUrl(course.getCoverUrl())
                .organizationName(
                        course.getOrganization().getName()
                )
                .slug(course.getSlug())
                .build();
    }
    public CourseDetailsResponse toDetailsResponse(
            Course course,
            CourseEnrollment enrollment
    ) {

        return CourseDetailsResponse.builder()
                .id(course.getId())
                .title(course.getTitle())
                .slug(course.getSlug())
                .description(course.getDescription())
                .coverUrl(course.getCoverUrl())
                .organizationName(
                        course.getOrganization().getName()
                )
                .chapters(
                        course.getChapters()
                                .stream()
                                .sorted(
                                        Comparator.comparing(
                                                Chapter::getPosition
                                        )
                                )
                                .map(
                                        chapterMapper::toResponse
                                )
                                .toList()
                )
                .progress(
                        new CourseProgressResponse(
                                enrollment.getLastAccessedLesson() != null
                                        ? enrollment.getLastAccessedLesson().getId()
                                        : null,
                                enrollment.getLastAccessedBlock() != null
                                        ? enrollment.getLastAccessedBlock().getId()
                                        : null,
                                enrollment.getProgressPercentage(),
                                enrollment.getCompletedAt() != null,
                                enrollment.getCompletedAt()
                        )
                )
                .build();
    }
}
