package app.lms.course.mapper;

import app.lms.block.model.Block;
import app.lms.chapter.model.Chapter;
import app.lms.common.dto.BaseEntityResponse;
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
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.Comparator;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@Component
@RequiredArgsConstructor
public class CourseMapper {

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
                .status(course.getStatus())
                .baseEntity(BaseEntityResponse.from(course))
                .build();
    }
    public CourseDetailsResponse toDetailsResponse(
            Course course,
            CourseEnrollment enrollment,
            List<Long> completedBlockIds
    ) {

        Set<Long> completedBlockIdSet =
                completedBlockIds.stream()
                        .collect(
                                Collectors.toSet()
                        );

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
                currentBlockId != null &&
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
