package app.lms.chapter.service;

import app.lms.chapter.dto.ChapterResponse;
import app.lms.chapter.dto.CreateChapterRequest;
import app.lms.chapter.dto.ReorderChaptersRequest;
import app.lms.chapter.dto.UpdateChapterRequest;
import app.lms.chapter.mapper.ChapterMapper;
import app.lms.chapter.model.Chapter;
import app.lms.chapter.repository.ChapterRepository;
import app.lms.common.exception.ConflictException;
import app.lms.common.exception.NotFoundException;
import app.lms.course.model.Course;
import app.lms.course.service.CourseAccessService;
import app.lms.user.model.User;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ChapterService {

    private final CourseAccessService courseAccessService;
    private final ChapterRepository chapterRepository;
    private final ChapterMapper chapterMapper;
    private final ChapterAccessService chapterAccessService;
    @Transactional
    public ChapterResponse create(
            Long courseId,
            CreateChapterRequest request,
            User user
    ) {

        Course course =
                courseAccessService
                        .getEditableCourse(
                                courseId,
                                user
                        );

        Integer position =
                chapterRepository
                        .findMaxPositionByCourseId(
                                courseId
                        )
                        .orElse(0) + 1;

        Chapter chapter =
                buildChapter(
                        request.title(),
                        position,
                        course
                );
        if (chapter.getLessons() == null) {
            chapter.setLessons(new ArrayList<>());
        }
        chapterRepository.save(chapter);

        return chapterMapper.toResponse(
                chapter
        );
    }


    @Transactional
    public ChapterResponse update(
            Long chapterId,
            UpdateChapterRequest request,
            User user
    ) {

        Chapter chapter =
                chapterAccessService.getEditableChapter(
                        chapterId,
                        user
                );

        if (request.title() != null) {
            chapter.setTitle(request.title());
        }

        return chapterMapper.toResponse(chapter);
    }

    @Transactional
    public void delete(
            Long chapterId,
            User user
    ) {

        Chapter chapter =
                chapterAccessService
                        .getEditableChapter(
                                chapterId,
                                user
                        );

        Long courseId =
                chapter.getCourse().getId();

        chapterRepository.delete(
                chapter
        );

        normalizePositions(
                courseId
        );
    }

    private void normalizePositions(
            Long courseId
    ) {

        List<Chapter> chapters =
                chapterRepository
                        .findAllByCourseIdOrderByPositionAsc(
                                courseId
                        );

        int position = 1;

        for (Chapter chapter : chapters) {
            chapter.setPosition(position++);
        }
    }
    private Chapter buildChapter(
            String title,
            Integer position,
            Course course
    ) {

        return Chapter.builder()
                .title(title)
                .position(position)
                .course(course)
                .build();
    }

    @Transactional
    public void reorder(
            Long courseId,
            ReorderChaptersRequest request,
            User user
    ) {

        Course course =
                courseAccessService
                        .getEditableCourse(
                                courseId,
                                user
                        );

        List<Chapter> chapters =
                chapterRepository.findAllByCourseId(
                        course.getId()
                );

        if (
                request.chapterIds().size()
                        != chapters.size()
                        ||
                        request.chapterIds()
                                .stream()
                                .distinct()
                                .count()
                                != chapters.size()
        )
        {
            throw new ConflictException(
                    "Invalid chapter list"
            );
        }

        Map<Long, Chapter> chapterMap =
                chapters.stream()
                        .collect(
                                Collectors.toMap(
                                        Chapter::getId,
                                        Function.identity()
                                )
                        );

        int position = 1;

        for (Long chapterId : request.chapterIds()) {

            Chapter chapter =
                    chapterMap.get(chapterId);

            if (chapter == null) {
                throw new NotFoundException(
                        "Chapter not found"
                );
            }

            chapter.setPosition(position++);
        }
    }
}
