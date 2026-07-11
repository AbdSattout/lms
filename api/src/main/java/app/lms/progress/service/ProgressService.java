package app.lms.progress.service;

import app.lms.block.model.Block;
import app.lms.block.repository.BlockRepository;
import app.lms.block.service.BlockAccessService;
import app.lms.chapter.repository.ChapterRepository;
import app.lms.common.exception.ForbiddenException;
import app.lms.common.exception.NotFoundException;
import app.lms.courceEnrollment.model.CourseEnrollment;
import app.lms.courceEnrollment.service.CourseEnrollmentAccessService;
import app.lms.courceEnrollment.service.CourseEnrollmentService;
import app.lms.lesson.repository.LessonRepository;
import app.lms.progress.dto.SubmitBlockAnswerRequest;
import app.lms.progress.dto.SubmitBlockAnswerResponse;
import app.lms.progress.mapper.ProgressMapper;
import app.lms.progress.model.BlockProgress;
import app.lms.progress.repository.BlockProgressRepository;
import app.lms.question.model.Question;
import app.lms.quiz.repository.QuizRepository;
import app.lms.user.model.User;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class ProgressService {

    private final ProgressMapper progressMapper;
    private final BlockAccessService blockAccessService;
    private final BlockProgressRepository blockProgressRepository;
    private final BlockRepository blockRepository;
    private final LessonRepository lessonRepository;
    private final ChapterRepository chapterRepository;
    private final CourseEnrollmentService courseEnrollmentService;
    private final CourseEnrollmentAccessService courseEnrollmentAccessService;
    private final QuizRepository quizRepository;

    @Transactional
    public SubmitBlockAnswerResponse submitAnswer(
            Long blockId,
            SubmitBlockAnswerRequest request,
            User user
    ) {

        Block block =
                blockAccessService.getAccessibleBlock(
                        blockId,
                        user
                );

        validateCanSubmitBlock(
                block,
                user
        );

        Question question =
                block.getQuestion();

        boolean correct =
                question.getCorrectAnswerIndex()
                        .equals(
                                request.answerIndex()
                        );

        BlockProgress progress =
                getOrCreateProgress(
                        block,
                        user
                );

        if (Boolean.TRUE.equals(progress.getCompleted())) {
            return resolveNextStep(
                    block
            );
        }

        progress.setAttempts(
                progress.getAttempts() + 1
        );

        if (correct) {
            progress.setCompleted(
                    true
            );
        }

        blockProgressRepository.save(
                progress
        );

        if (!correct) {
            return progressMapper.incorrectAnswer();
        }

        SubmitBlockAnswerResponse nextStep =
                resolveNextStep(
                        block
                );

        courseEnrollmentService
                .updateProgressAfterCorrectAnswer(
                        block,
                        nextStep,
                        user
                );

        return nextStep;
    }

    private void validateCanSubmitBlock(
            Block block,
            User user
    ) {

        BlockProgress existingProgress =
                blockProgressRepository
                        .findByUserIdAndBlockId(
                                user.getId(),
                                block.getId()
                        )
                        .orElse(null);

        if (
                existingProgress != null &&
                        Boolean.TRUE.equals(
                                existingProgress.getCompleted()
                        )
        ) {
            return;
        }

        Long courseId =
                block.getLesson()
                        .getChapter()
                        .getCourse()
                        .getId();

        CourseEnrollment enrollment =
                courseEnrollmentAccessService
                        .getEnrollment(
                                courseId,
                                user
                        );

        Block lastAccessedBlock =
                enrollment.getLastAccessedBlock();

        if (lastAccessedBlock == null) {

            Block firstBlock =
                    getFirstBlockInCourse(
                            courseId
                    );

            if (!firstBlock.getId().equals(block.getId())) {
                throw new ForbiddenException(
                        "You cannot submit this block yet"
                );
            }

            return;
        }

        if (!lastAccessedBlock.getId().equals(block.getId())) {
            throw new ForbiddenException(
                    "You cannot submit this block yet"
            );
        }
    }

    private Block getFirstBlockInCourse(
            Long courseId
    ) {

        return chapterRepository
                .findFirstByCourseIdOrderByPositionAsc(
                        courseId
                )
                .flatMap(chapter ->
                        lessonRepository
                                .findFirstByChapterIdOrderByPositionAsc(
                                        chapter.getId()
                                )
                )
                .flatMap(lesson ->
                        blockRepository
                                .findFirstByLessonIdOrderByPositionAsc(
                                        lesson.getId()
                                )
                )
                .orElseThrow(() ->
                        new NotFoundException(
                                "Course has no blocks"
                        )
                );
    }

    private BlockProgress getOrCreateProgress(
            Block block,
            User user
    ) {

        return blockProgressRepository
                .findByUserIdAndBlockId(
                        user.getId(),
                        block.getId()
                )
                .orElseGet(() ->
                        BlockProgress.builder()
                                .user(user)
                                .block(block)
                                .attempts(0)
                                .completed(false)
                                .build()
                );
    }

    private SubmitBlockAnswerResponse resolveNextStep(
            Block currentBlock
    ) {

        return blockRepository
                .findFirstByLessonIdAndPositionGreaterThanOrderByPositionAsc(
                        currentBlock.getLesson().getId(),
                        currentBlock.getPosition()
                )
                .map(
                        progressMapper::toNextStepResponse
                )
                .orElseGet(() ->
                        resolveNextLesson(
                                currentBlock
                        )
                );
    }

    private SubmitBlockAnswerResponse resolveNextLesson(
            Block currentBlock
    ) {

        return lessonRepository
                .findFirstByChapterIdAndPositionGreaterThanOrderByPositionAsc(
                        currentBlock.getLesson()
                                .getChapter()
                                .getId(),
                        currentBlock.getLesson()
                                .getPosition()
                )
                .flatMap(nextLesson ->
                        blockRepository
                                .findFirstByLessonIdOrderByPositionAsc(
                                        nextLesson.getId()
                                )
                )
                .map(
                        progressMapper::toNextStepResponse
                )
                .orElseGet(() ->
                        resolveNextChapter(
                                currentBlock
                        )
                );
    }

    private SubmitBlockAnswerResponse resolveNextChapter(
            Block currentBlock
    ) {

        Long courseId =
                currentBlock.getLesson()
                        .getChapter()
                        .getCourse()
                        .getId();

        return chapterRepository
                .findFirstByCourseIdAndPositionGreaterThanOrderByPositionAsc(
                        courseId,
                        currentBlock.getLesson()
                                .getChapter()
                                .getPosition()
                )
                .flatMap(nextChapter ->
                        lessonRepository
                                .findFirstByChapterIdOrderByPositionAsc(
                                        nextChapter.getId()
                                )
                )
                .flatMap(nextLesson ->
                        blockRepository
                                .findFirstByLessonIdOrderByPositionAsc(
                                        nextLesson.getId()
                                )
                )
                .map(
                        progressMapper::toNextStepResponse
                )
                .orElseGet(() ->
                        resolveFinalQuizOrCompleteCourse(
                                courseId
                        )
                );
    }

    private SubmitBlockAnswerResponse resolveFinalQuizOrCompleteCourse(
            Long courseId
    ) {

        return quizRepository
                .findByCourseId(
                        courseId
                )
                .map(
                        progressMapper::toFinalQuizResponse
                )
                .orElseGet(
                        progressMapper::courseCompleted
                );
    }
}