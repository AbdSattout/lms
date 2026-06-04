    package app.lms.lesson.service;

    import app.lms.chapter.model.Chapter;
    import app.lms.chapter.service.ChapterAccessService;
    import app.lms.common.exception.ConflictException;
    import app.lms.common.exception.NotFoundException;
    import app.lms.lesson.dto.CreateLessonRequest;
    import app.lms.lesson.dto.LessonResponse;
    import app.lms.lesson.dto.ReorderLessonsRequest;
    import app.lms.lesson.dto.UpdateLessonRequest;
    import app.lms.lesson.mapper.LessonMapper;
    import app.lms.lesson.model.Lesson;
    import app.lms.lesson.repository.LessonRepository;
    import app.lms.user.model.User;
    import jakarta.transaction.Transactional;
    import lombok.RequiredArgsConstructor;
    import org.springframework.stereotype.Service;

    import java.util.List;
    import java.util.Map;
    import java.util.function.Function;
    import java.util.stream.Collectors;

    @Service
    @RequiredArgsConstructor
    public class LessonService {

        private final LessonRepository lessonRepository;
        private final LessonMapper lessonMapper;
        private final LessonAccessService lessonAccessService;
        private final ChapterAccessService chapterAccessService;

        @Transactional
        public LessonResponse create(
                Long chapterId,
                CreateLessonRequest request,
                User user
        ) {

            Chapter chapter =
                    chapterAccessService
                            .getEditableChapter(
                                    chapterId,
                                    user
                            );

            Integer position =
                    lessonRepository
                            .findMaxPositionByChapterId(
                                    chapterId
                            )
                            .orElse(0) + 1;

            Lesson lesson =
                    buildLesson(
                            request.title(),
                            position,
                            chapter
                    );

            lessonRepository.save(
                    lesson
            );

            return lessonMapper.toResponse(
                    lesson
            );
        }

        @Transactional
        public LessonResponse update(
                Long lessonId,
                UpdateLessonRequest request,
                User user
        ) {

            Lesson lesson =
                    lessonAccessService
                            .getEditableLesson(
                                    lessonId,
                                    user
                            );

            if (request.title() != null) {
                lesson.setTitle(
                        request.title()
                );
            }




            return lessonMapper.toResponse(
                    lesson
            );
        }

        @Transactional
        public void delete(
                Long lessonId,
                User user
        ) {

            Lesson lesson =
                    lessonAccessService
                            .getEditableLesson(
                                    lessonId,
                                    user
                            );

            Long chapterId =
                    lesson.getChapter().getId();

            lessonRepository.delete(
                    lesson
            );

            normalizePositions(
                    chapterId
            );
        }

        @Transactional
        public void reorder(
                Long chapterId,
                ReorderLessonsRequest request,
                User user
        ) {

            Chapter chapter =
                    chapterAccessService
                            .getEditableChapter(
                                    chapterId,
                                    user
                            );

            List<Lesson> lessons =
                    lessonRepository
                            .findAllByChapterId(
                                    chapter.getId()
                            );

            if (
                    request.lessonIds().size()
                            != lessons.size()
                            ||
                            request.lessonIds()
                                    .stream()
                                    .distinct()
                                    .count()
                                    != lessons.size()
            ) {

                throw new ConflictException(
                        "Invalid lesson list"
                );
            }

            Map<Long, Lesson> lessonMap =
                    lessons.stream()
                            .collect(
                                    Collectors.toMap(
                                            Lesson::getId,
                                            Function.identity()
                                    )
                            );

            int position = 1;

            for (Long lessonId : request.lessonIds()) {

                Lesson lesson =
                        lessonMap.get(
                                lessonId
                        );

                if (lesson == null) {
                    throw new NotFoundException(
                            "Lesson not found"
                    );
                }

                lesson.setPosition(
                        position++
                );
            }
        }
        private Lesson buildLesson(
                String title,
                Integer position,
                Chapter chapter
        ) {

            return Lesson.builder()
                    .title(title)
                    .position(position)
                    .chapter(chapter)
                    .build();
        }

        private void normalizePositions(
                Long chapterId
        ) {

            List<Lesson> lessons =
                    lessonRepository
                            .findAllByChapterIdOrderByPositionAsc(
                                    chapterId
                            );

            int position = 1;

            for (Lesson lesson : lessons) {
                lesson.setPosition(
                        position++
                );
            }
        }
    }
