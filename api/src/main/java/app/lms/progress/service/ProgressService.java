package app.lms.progress.service;

import app.lms.block.model.Block;
import app.lms.block.repository.BlockRepository;
import app.lms.block.service.BlockAccessService;
import app.lms.chapter.repository.ChapterRepository;
import app.lms.courceEnrollment.service.CourseEnrollmentService;
import app.lms.lesson.repository.LessonRepository;
import app.lms.progress.dto.SubmitBlockAnswerRequest;
import app.lms.progress.dto.SubmitBlockAnswerResponse;
import app.lms.progress.mapper.ProgressMapper;
import app.lms.progress.model.BlockProgress;
import app.lms.progress.repository.BlockProgressRepository;
import app.lms.question.model.Question;
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
            progress.setCompleted(true);
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

        return chapterRepository
                .findFirstByCourseIdAndPositionGreaterThanOrderByPositionAsc(
                        currentBlock.getLesson()
                                .getChapter()
                                .getCourse()
                                .getId(),
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
                .orElseGet(
                        progressMapper::courseCompleted
                );
    }
}