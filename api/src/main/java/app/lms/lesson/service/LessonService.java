    package app.lms.lesson.service;

    import app.lms.chapter.model.Chapter;
    import app.lms.chapter.repository.ChapterRepository;
    import app.lms.chapter.service.ChapterAccessService;
    import app.lms.common.exception.BadRequestException;
    import app.lms.common.exception.ConflictException;
    import app.lms.common.exception.NotFoundException;
    import app.lms.lesson.dto.*;
    import app.lms.lesson.mapper.LessonMapper;
    import app.lms.lesson.model.Lesson;
    import app.lms.lesson.repository.LessonRepository;
    import app.lms.user.model.User;
    import jakarta.transaction.Transactional;
    import lombok.RequiredArgsConstructor;
    import org.springframework.stereotype.Service;

    import java.util.Comparator;
    import java.util.List;
    import java.util.Map;
    import java.util.function.Function;
    import java.util.stream.Collectors;

    @Service
    @RequiredArgsConstructor
    public class LessonService {

        private final ChapterRepository chapterRepository;
        private final LessonRepository lessonRepository;
        private final LessonMapper lessonMapper;
        private final LessonAccessService lessonAccessService;
        private final ChapterAccessService chapterAccessService;


        @Transactional
        public LessonDetailsResponse getById(
                Long lessonId,
                User user
        ) {

            Lesson lesson =
                    lessonAccessService
                            .getEditableLesson(
                                    lessonId,
                                    user
                            );

            return lessonMapper.toDetailsResponse(lesson);
        }

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



            if (request.chapterId() != null) {
                moveLessonToChapter(
                        lesson,
                        request.chapterId()
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
        @Transactional
        public List<LessonResponse> getLessonsByChapterId(
                Long chapterId,
                User user
        ) {

            Chapter chapter =
                    chapterAccessService
                            .getManageableChapter(
                                    chapterId,
                                    user
                            );

            return chapter.getLessons()
                    .stream()
                    .sorted(
                            Comparator.comparing(
                                    Lesson::getPosition
                            )
                    )
                    .map(
                            lessonMapper::toResponse
                    )
                    .toList();
        }
        private void moveLessonToChapter(
                Lesson lesson,
                Long newChapterId
        ) {

            Chapter currentChapter =
                    lesson.getChapter();

            if (currentChapter.getId().equals(newChapterId)) {
                return;
            }

            Chapter newChapter =
                    chapterRepository.findById(newChapterId)
                            .orElseThrow(() ->
                                    new NotFoundException(
                                            "Chapter not found"
                                    )
                            );

            Long currentCourseId =
                    currentChapter
                            .getCourse()
                            .getId();

            Long newCourseId =
                    newChapter
                            .getCourse()
                            .getId();

            if (!currentCourseId.equals(newCourseId)) {
                throw new BadRequestException(
                        "Lesson can only be moved to a chapter in the same course"
                );
            }

            lesson.setChapter(
                    newChapter
            );
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
