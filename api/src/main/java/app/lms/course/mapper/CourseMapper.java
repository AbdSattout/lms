package app.lms.course.mapper;

import app.lms.block.model.Block;
import app.lms.chapter.model.Chapter;
import app.lms.common.dto.BaseEntityResponse;
import app.lms.courceEnrollment.dto.CourseEnrollmentResponse;
import app.lms.courceEnrollment.dto.CourseProgressResponse;
import app.lms.courceEnrollment.model.CourseEnrollment;
import app.lms.course.dto.CourseBlockMapResponse;
import app.lms.course.dto.CourseChapterMapResponse;
import app.lms.course.dto.CourseDetailsResponse;
import app.lms.course.dto.CourseLessonMapResponse;
import app.lms.course.dto.CourseResponse;
import app.lms.course.enums.CourseNodeStatus;
import app.lms.course.model.Course;
import app.lms.lesson.model.Lesson;
import app.lms.organization.mapper.OrganizationMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.Comparator;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

@Component
@RequiredArgsConstructor
public class CourseMapper {

    private final OrganizationMapper organizationMapper;

    public CourseResponse toResponse(
            Course course
    ) {

        return toResponse(
                course,
                null
        );
    }

    public CourseResponse toResponse(
            Course course,
            CourseEnrollment enrollment
    ) {

        return CourseResponse.builder()
                .id(course.getId())
                .title(course.getTitle())
                .description(course.getDescription())
                .coverUrl(course.getCoverUrl())
                .organization(
                        organizationMapper.toSummaryResponse(
                                course.getOrganization()
                        )
                )
                .slug(course.getSlug())
                .status(course.getStatus())
                .enrollment(
                        enrollment != null
                                ? toEnrollmentResponse(enrollment)
                                : null
                )
                .baseEntity(BaseEntityResponse.from(course))
                .build();
    }

    private CourseEnrollmentResponse toEnrollmentResponse(
            CourseEnrollment enrollment
    ) {

        return CourseEnrollmentResponse.builder()
                .id(enrollment.getId())
                .courseId(enrollment.getCourse().getId())
                .courseTitle(enrollment.getCourse().getTitle())
                .enrolledAt(enrollment.getEnrolledAt())
                .status(enrollment.getStatus())
                .placementTestCompleted(
                        placementTestCompletedFor(enrollment)
                )
                .progressPercentage(enrollment.getProgressPercentage())
                .currentChapterId(
                        currentChapterIdFor(enrollment)
                )
                .currentLessonId(
                        enrollment.getCurrentLesson() != null
                                ? enrollment.getCurrentLesson()
                                        .getId()
                                : null
                )
                .currentBlockId(
                        enrollment.getCurrentBlock() != null
                                ? enrollment.getCurrentBlock()
                                        .getId()
                                : null
                )
                .completedAt(enrollment.getCompletedAt())
                .build();
    }

    private Boolean placementTestCompletedFor(
            CourseEnrollment enrollment
    ) {

        return currentChapterIdFor(enrollment) != null
                || enrollment.getCurrentLesson() != null
                || enrollment.getCurrentBlock() != null;
    }

    private Long currentChapterIdFor(
            CourseEnrollment enrollment
    ) {

        if (
                enrollment.getCurrentLesson() != null
                        && enrollment.getCurrentLesson()
                                .getChapter() != null
        ) {
            return enrollment.getCurrentLesson()
                    .getChapter()
                    .getId();
        }

        if (
                enrollment.getCurrentBlock() != null
                        && enrollment.getCurrentBlock()
                                .getLesson() != null
                        && enrollment.getCurrentBlock()
                                .getLesson()
                                .getChapter() != null
        ) {
            return enrollment.getCurrentBlock()
                    .getLesson()
                    .getChapter()
                    .getId();
        }

        return null;
    }

    public CourseDetailsResponse toDetailsResponse(
            Course course,
            CourseEnrollment enrollment,
            List<Long> completedBlockIds
    ) {

        Set<Long> completedBlockIdSet =
                new HashSet<>(completedBlockIds);

        Block currentBlock =
                currentBlockFor(
                        enrollment,
                        completedBlockIdSet
                );

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
                        chaptersFor(
                                enrollment,
                                course,
                                completedBlockIdSet,
                                currentBlock != null
                                        ? currentBlock.getId()
                                        : null
                        )
                )
                .progress(
                        new CourseProgressResponse(
                                currentChapterIdFor(enrollment),
                                currentBlock != null
                                        ? currentBlock.getLesson().getId()
                                        : null,
                                currentBlock != null
                                        ? currentBlock.getId()
                                        : null,
                                enrollment.getProgressPercentage(),
                                enrollment.getCompletedAt() != null,
                                enrollment.getCompletedAt()
                        )
                )
                .baseEntity(BaseEntityResponse.from(course))
                .build();
    }

    private List<CourseChapterMapResponse> chaptersFor(
            CourseEnrollment enrollment,
            Course course,
            Set<Long> completedBlockIds,
            Long currentBlockId
    ) {

        if (enrollment.getCurrentBlock() == null) {
            return List.of();
        }

        return course.getChapters()
                .stream()
                .sorted(
                        Comparator.comparing(
                                Chapter::getPosition
                        )
                )
                .map(chapter ->
                        toChapterMapResponse(
                                chapter,
                                completedBlockIds,
                                currentBlockId
                        )
                )
                .toList();
    }

    private CourseChapterMapResponse toChapterMapResponse(
            Chapter chapter,
            Set<Long> completedBlockIds,
            Long currentBlockId
    ) {

        List<CourseLessonMapResponse> lessons =
                chapter.getLessons()
                        .stream()
                        .sorted(
                                Comparator.comparing(
                                        Lesson::getPosition
                                )
                        )
                        .map(lesson ->
                                toLessonMapResponse(
                                        lesson,
                                        completedBlockIds,
                                        currentBlockId
                                )
                        )
                        .toList();

        return new CourseChapterMapResponse(
                chapter.getId(),
                chapter.getTitle(),
                chapter.getPosition(),
                aggregateStatus(
                        lessons.stream()
                                .map(CourseLessonMapResponse::status)
                                .toList()
                ),
                lessons,
                BaseEntityResponse.from(chapter)
        );
    }

    private CourseLessonMapResponse toLessonMapResponse(
            Lesson lesson,
            Set<Long> completedBlockIds,
            Long currentBlockId
    ) {

        List<CourseBlockMapResponse> blocks =
                lesson.getBlocks()
                        .stream()
                        .sorted(
                                Comparator.comparing(
                                        Block::getPosition
                                )
                        )
                        .map(block ->
                                toBlockMapResponse(
                                        block,
                                        completedBlockIds,
                                        currentBlockId
                                )
                        )
                        .toList();

        return new CourseLessonMapResponse(
                lesson.getId(),
                lesson.getTitle(),
                lesson.getPosition(),
                aggregateStatus(
                        blocks.stream()
                                .map(CourseBlockMapResponse::status)
                                .toList()
                ),
                blocks,
                BaseEntityResponse.from(lesson)
        );
    }

    private CourseBlockMapResponse toBlockMapResponse(
            Block block,
            Set<Long> completedBlockIds,
            Long currentBlockId
    ) {

        return new CourseBlockMapResponse(
                block.getId(),
                block.getTitle(),
                block.getPosition(),
                statusForBlock(
                        block,
                        completedBlockIds,
                        currentBlockId
                ),
                BaseEntityResponse.from(block)
        );
    }

    private CourseNodeStatus statusForBlock(
            Block block,
            Set<Long> completedBlockIds,
            Long currentBlockId
    ) {

        if (completedBlockIds.contains(block.getId())) {
            return CourseNodeStatus.COMPLETED;
        }

        if (
                block.getId().equals(currentBlockId)
        ) {
            return CourseNodeStatus.CURRENT;
        }

        return CourseNodeStatus.LOCKED;
    }

    private Block currentBlockFor(
            CourseEnrollment enrollment,
            Set<Long> completedBlockIds
    ) {

        Block currentBlock =
                enrollment.getCurrentBlock();

        if (currentBlock == null) {
            return null;
        }

        if (completedBlockIds.contains(currentBlock.getId())) {
            return null;
        }

        return currentBlock;
    }

    private CourseNodeStatus aggregateStatus(
            List<CourseNodeStatus> statuses
    ) {

        if (statuses.isEmpty()) {
            return CourseNodeStatus.LOCKED;
        }

        if (statuses.stream().allMatch(CourseNodeStatus.COMPLETED::equals)) {
            return CourseNodeStatus.COMPLETED;
        }

        if (statuses.contains(CourseNodeStatus.CURRENT)) {
            return CourseNodeStatus.CURRENT;
        }

        if (statuses.contains(CourseNodeStatus.COMPLETED)) {
            return CourseNodeStatus.CURRENT;
        }

        return CourseNodeStatus.LOCKED;
    }
}
