package app.lms.progress.service;

import app.lms.block.model.Block;
import app.lms.block.repository.BlockRepository;
import app.lms.block.service.BlockAccessService;
import app.lms.chapter.repository.ChapterRepository;
import app.lms.common.exception.ForbiddenException;
import app.lms.common.exception.NotFoundException;
import app.lms.enrollment.model.CourseEnrollment;
import app.lms.enrollment.service.CourseEnrollmentAccessService;
import app.lms.enrollment.service.CourseEnrollmentService;
import app.lms.gamification.dto.GamificationAwardResponse;
import app.lms.gamification.enums.XPEventType;
import app.lms.gamification.service.GamificationService;
import app.lms.gamification.service.LearningXpPolicy;
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

import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class ProgressService {

    private static final double BLOCK_ATTEMPT_PENALTY_RATE = 0.20;
    private static final double MIN_BLOCK_XP_MULTIPLIER = 0.30;

    private final ProgressMapper progressMapper;
    private final BlockAccessService blockAccessService;
    private final BlockProgressRepository blockProgressRepository;
    private final BlockRepository blockRepository;
    private final LessonRepository lessonRepository;
    private final ChapterRepository chapterRepository;
    private final CourseEnrollmentService courseEnrollmentService;
    private final CourseEnrollmentAccessService courseEnrollmentAccessService;
    private final QuizRepository quizRepository;
    private final GamificationService gamificationService;

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
            if (!correct) {
                return progressMapper.incorrectAnswer();
            }

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

        List<GamificationAwardResponse> rewards =
                awardLearningXp(
                        block,
                        user,
                        progress
                );

        return progressMapper.withRewards(
                nextStep,
                rewards
        );
    }

    private List<GamificationAwardResponse> awardLearningXp(
            Block block,
            User user,
            BlockProgress progress
    ) {

        List<GamificationAwardResponse> rewards =
                new ArrayList<>();

        addAwardedReward(
                rewards,
                gamificationService.awardXp(
                        user,
                        XPEventType.BLOCK_COMPLETE,
                        block.getId(),
                        blockCompleteXpFor(
                                block.getQuestion(),
                                progress
                        )
                )
        );

        if (isLessonCompleted(block, user)) {
            addAwardedReward(
                    rewards,
                    gamificationService.awardXp(
                            user,
                            XPEventType.LESSON_COMPLETE,
                            block.getLesson().getId(),
                            LearningXpPolicy.LESSON_COMPLETE_XP
                    )
            );
        }

        if (isChapterCompleted(block, user)) {
            addAwardedReward(
                    rewards,
                    gamificationService.awardXp(
                            user,
                            XPEventType.CHAPTER_COMPLETE,
                            block.getLesson()
                                    .getChapter()
                                    .getId(),
                            LearningXpPolicy.CHAPTER_COMPLETE_XP
                    )
            );
        }

        return rewards;
    }

    private int blockCompleteXpFor(
            Question question,
            BlockProgress progress
    ) {

        int baseXp =
                LearningXpPolicy.maxBlockCompleteXpFor(
                        question.getDifficulty()
                );

        return applyAttemptPenalty(
                baseXp,
                progress
        );
    }

    private int applyAttemptPenalty(
            int baseXp,
            BlockProgress progress
    ) {

        int attempts =
                progress.getAttempts() != null &&
                        progress.getAttempts() > 0
                        ? progress.getAttempts()
                        : 1;

        int extraAttempts =
                attempts - 1;

        double multiplier =
                Math.max(
                        MIN_BLOCK_XP_MULTIPLIER,
                        1.0 - extraAttempts * BLOCK_ATTEMPT_PENALTY_RATE
                );

        return Math.max(
                1,
                (int) Math.round(baseXp * multiplier)
        );
    }

    private void addAwardedReward(
            List<GamificationAwardResponse> rewards,
            GamificationAwardResponse reward
    ) {

        if (reward.awarded()) {
            rewards.add(reward);
        }
    }

    private boolean isLessonCompleted(
            Block block,
            User user
    ) {

        Long lessonId =
                block.getLesson().getId();

        long totalBlocks =
                blockRepository.countByLessonId(
                        lessonId
                );

        long completedBlocks =
                blockProgressRepository
                        .countByUserIdAndBlockLessonIdAndCompletedTrue(
                                user.getId(),
                                lessonId
                        );

        return totalBlocks > 0 && completedBlocks >= totalBlocks;
    }

    private boolean isChapterCompleted(
            Block block,
            User user
    ) {

        Long chapterId =
                block.getLesson()
                        .getChapter()
                        .getId();

        long totalBlocks =
                blockRepository.countByLessonChapterId(
                        chapterId
                );

        long completedBlocks =
                blockProgressRepository
                        .countByUserIdAndBlockLessonChapterIdAndCompletedTrue(
                                user.getId(),
                                chapterId
                        );

        return totalBlocks > 0 && completedBlocks >= totalBlocks;
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

        Block currentBlock =
                enrollment.getCurrentBlock();

        if (currentBlock == null) {

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

        if (!currentBlock.getId().equals(block.getId())) {
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
