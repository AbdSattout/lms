package app.lms.placementTest.service;

import app.lms.block.model.Block;
import app.lms.block.repository.BlockRepository;
import app.lms.common.dto.BaseEntityResponse;
import app.lms.common.exception.BadRequestException;
import app.lms.common.exception.ConflictException;
import app.lms.courceEnrollment.model.CourseEnrollment;
import app.lms.courceEnrollment.service.CourseEnrollmentAccessService;
import app.lms.placementTest.dto.PlacementTestQuestionResponse;
import app.lms.placementTest.dto.PlacementTestResponse;
import app.lms.placementTest.dto.SubmitPlacementTestRequest;
import app.lms.placementTest.dto.SubmitPlacementTestResponse;
import app.lms.placementTest.model.CoursePlacementTestAttempt;
import app.lms.placementTest.repository.CoursePlacementTestAttemptRepository;
import app.lms.progress.model.BlockProgress;
import app.lms.progress.repository.BlockProgressRepository;
import app.lms.question.model.Question;
import app.lms.quiz.repository.QuizRepository;
import app.lms.user.model.User;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class CoursePlacementTestService {

    private final CourseEnrollmentAccessService courseEnrollmentAccessService;
    private final CoursePlacementTestAttemptRepository placementTestAttemptRepository;
    private final BlockRepository blockRepository;
    private final BlockProgressRepository blockProgressRepository;
    private final QuizRepository quizRepository;

    @Transactional
    public PlacementTestResponse current(
            Long courseId,
            User user
    ) {

        CourseEnrollment enrollment =
                courseEnrollmentAccessService.getEnrollment(
                        courseId,
                        user
                );

        CoursePlacementTestAttempt attempt =
                placementTestAttemptRepository
                        .findByCourseIdAndUserId(
                                courseId,
                                user.getId()
                        )
                        .orElse(null);

        if (attempt != null && Boolean.TRUE.equals(attempt.getCompleted())) {
            return completedResponse(
                    attempt,
                    enrollment
            );
        }

        validateCourseNotStarted(
                courseId,
                user
        );

        List<Block> blocks =
                getOrderedCourseBlocks(
                        courseId
                );

        if (attempt == null) {
            attempt =
                    placementTestAttemptRepository.save(
                            CoursePlacementTestAttempt.builder()
                                    .user(user)
                                    .course(enrollment.getCourse())
                                    .currentBlock(blocks.getFirst())
                                    .completed(false)
                                    .correctAnswers(0)
                                    .totalAnswers(0)
                                    .build()
                    );
        }

        return new PlacementTestResponse(
                false,
                attempt.getCorrectAnswers(),
                attempt.getTotalAnswers(),
                toQuestionResponse(
                        resolveCurrentBlock(
                                attempt,
                                blocks
                        )
                ),
                null,
                null,
                null,
                enrollment.getProgressPercentage(),
                "Placement test question",
                BaseEntityResponse.from(attempt)
        );
    }

    @Transactional
    public SubmitPlacementTestResponse submit(
            Long courseId,
            SubmitPlacementTestRequest request,
            User user
    ) {

        CourseEnrollment enrollment =
                courseEnrollmentAccessService.getEnrollment(
                        courseId,
                        user
                );

        CoursePlacementTestAttempt attempt =
                placementTestAttemptRepository
                        .findByCourseIdAndUserId(
                                courseId,
                                user.getId()
                        )
                        .orElse(null);

        if (attempt != null && Boolean.TRUE.equals(attempt.getCompleted())) {
            throw new ConflictException(
                    "Placement test already completed"
            );
        }

        validateCourseNotStarted(
                courseId,
                user
        );

        List<Block> blocks =
                getOrderedCourseBlocks(
                        courseId
                );

        if (attempt == null) {
            attempt =
                    CoursePlacementTestAttempt.builder()
                            .user(user)
                            .course(enrollment.getCourse())
                            .currentBlock(blocks.getFirst())
                            .completed(false)
                            .correctAnswers(0)
                            .totalAnswers(0)
                            .build();
        }

        Block currentBlock =
                resolveCurrentBlock(
                        attempt,
                        blocks
                );

        Question question =
                currentBlock.getQuestion();

        validateAnswerIndex(
                request.answerIndex(),
                question
        );

        boolean correct =
                question.getCorrectAnswerIndex()
                        .equals(
                                request.answerIndex()
                        );

        attempt.setTotalAnswers(
                attempt.getTotalAnswers() + 1
        );

        if (correct) {
            attempt.setCorrectAnswers(
                    attempt.getCorrectAnswers() + 1
            );

            return handleCorrectAnswer(
                    attempt,
                    enrollment,
                    blocks,
                    currentBlock
            );
        }

        return handleWrongAnswer(
                attempt,
                enrollment,
                blocks,
                currentBlock
        );
    }

    @Transactional
    public PlacementTestResponse skip(
            Long courseId,
            User user
    ) {

        CourseEnrollment enrollment =
                courseEnrollmentAccessService.getEnrollment(
                        courseId,
                        user
                );

        if (enrollment.getCurrentBlock() != null) {
            throw new ConflictException(
                    "Course already started"
            );
        }

        List<Block> blocks =
                getOrderedCourseBlocks(
                        courseId
                );

        CoursePlacementTestAttempt attempt =
                placementTestAttemptRepository
                        .findByCourseIdAndUserId(
                                courseId,
                                user.getId()
                        )
                        .orElseGet(() ->
                                CoursePlacementTestAttempt.builder()
                                        .user(user)
                                        .course(enrollment.getCourse())
                                        .currentBlock(blocks.getFirst())
                                        .completed(false)
                                        .correctAnswers(0)
                                        .totalAnswers(0)
                                        .build()
                        );

        if (Boolean.TRUE.equals(attempt.getCompleted())) {
            throw new ConflictException(
                    "Placement test already completed"
            );
        }

        Block startBlock =
                attempt.getCurrentBlock() != null
                        ? resolveCurrentBlock(
                                attempt,
                                blocks
                        )
                        : blocks.getFirst();

        int startIndex =
                indexOfBlock(
                        blocks,
                        startBlock
                );

        completeBlocks(
                blocks.subList(
                        0,
                        Math.max(
                                0,
                                startIndex
                        )
                ),
                user
        );

        attempt.setCompleted(true);
        attempt.setCurrentBlock(null);
        attempt.setPlacedBlock(startBlock);
        placementTestAttemptRepository.save(attempt);

        enrollment.setCurrentLesson(
                startBlock.getLesson()
        );
        enrollment.setCurrentBlock(startBlock);
        enrollment.setProgressPercentage(
                calculateProgressPercentage(
                        Math.max(
                                0,
                                startIndex
                        ),
                        blocks.size()
                )
        );

        return new PlacementTestResponse(
                true,
                attempt.getCorrectAnswers(),
                attempt.getTotalAnswers(),
                null,
                startBlock.getId(),
                startBlock.getLesson().getId(),
                startBlock.getLesson().getChapter().getId(),
                enrollment.getProgressPercentage(),
                "Placement test skipped",
                BaseEntityResponse.from(attempt)
        );
    }

    private SubmitPlacementTestResponse handleCorrectAnswer(
            CoursePlacementTestAttempt attempt,
            CourseEnrollment enrollment,
            List<Block> blocks,
            Block currentBlock
    ) {

        int currentIndex =
                indexOfBlock(
                        blocks,
                        currentBlock
                );

        if (currentIndex < blocks.size() - 1) {
            Block nextBlock =
                    blocks.get(currentIndex + 1);

            attempt.setCurrentBlock(nextBlock);
            placementTestAttemptRepository.save(attempt);

            return new SubmitPlacementTestResponse(
                    true,
                    false,
                    attempt.getCorrectAnswers(),
                    attempt.getTotalAnswers(),
                    toQuestionResponse(nextBlock),
                    null,
                    null,
                    null,
                    enrollment.getProgressPercentage(),
                    "Correct answer",
                    BaseEntityResponse.from(attempt)
            );
        }

        attempt.setCompleted(true);
        attempt.setCurrentBlock(null);
        attempt.setPlacedBlock(null);
        placementTestAttemptRepository.save(attempt);

        completeBlocks(
                blocks,
                enrollment.getUser()
        );

        enrollment.setProgressPercentage(100);
        enrollment.setCurrentLesson(
                currentBlock.getLesson()
        );
        enrollment.setCurrentBlock(currentBlock);

        if (!quizRepository.existsByCourseId(enrollment.getCourse().getId())) {
            enrollment.setCompletedAt(
                    LocalDateTime.now()
            );
        }

        return new SubmitPlacementTestResponse(
                true,
                true,
                attempt.getCorrectAnswers(),
                attempt.getTotalAnswers(),
                null,
                null,
                null,
                null,
                100,
                quizRepository.existsByCourseId(enrollment.getCourse().getId())
                        ? "Placement test completed. Go to final quiz."
                        : "Placement test completed. Course content completed.",
                BaseEntityResponse.from(attempt)
        );
    }

    private SubmitPlacementTestResponse handleWrongAnswer(
            CoursePlacementTestAttempt attempt,
            CourseEnrollment enrollment,
            List<Block> blocks,
            Block currentBlock
    ) {

        int currentIndex =
                indexOfBlock(
                        blocks,
                        currentBlock
                );

        completeBlocks(
                blocks.subList(
                        0,
                        currentIndex
                ),
                enrollment.getUser()
        );

        attempt.setCompleted(true);
        attempt.setCurrentBlock(null);
        attempt.setPlacedBlock(currentBlock);
        placementTestAttemptRepository.save(attempt);

        enrollment.setCurrentLesson(
                currentBlock.getLesson()
        );
        enrollment.setCurrentBlock(currentBlock);
        enrollment.setProgressPercentage(
                calculateProgressPercentage(
                        currentIndex,
                        blocks.size()
                )
        );

        return new SubmitPlacementTestResponse(
                false,
                true,
                attempt.getCorrectAnswers(),
                attempt.getTotalAnswers(),
                null,
                currentBlock.getId(),
                currentBlock.getLesson().getId(),
                currentBlock.getLesson().getChapter().getId(),
                enrollment.getProgressPercentage(),
                "Placement test completed",
                BaseEntityResponse.from(attempt)
        );
    }

    private void completeBlocks(
            List<Block> blocks,
            User user
    ) {

        blocks.forEach(block -> {
            BlockProgress progress =
                    blockProgressRepository
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

            progress.setCompleted(true);
            blockProgressRepository.save(progress);
        });
    }

    private PlacementTestResponse completedResponse(
            CoursePlacementTestAttempt attempt,
            CourseEnrollment enrollment
    ) {

        Block placedBlock =
                attempt.getPlacedBlock();

        return new PlacementTestResponse(
                true,
                attempt.getCorrectAnswers(),
                attempt.getTotalAnswers(),
                null,
                placedBlock != null
                        ? placedBlock.getId()
                        : null,
                placedBlock != null
                        ? placedBlock.getLesson().getId()
                        : null,
                placedBlock != null
                        ? placedBlock.getLesson().getChapter().getId()
                        : null,
                enrollment.getProgressPercentage(),
                "Placement test already completed",
                BaseEntityResponse.from(attempt)
        );
    }

    private void validateCourseNotStarted(
            Long courseId,
            User user
    ) {

        CourseEnrollment enrollment =
                courseEnrollmentAccessService.getEnrollment(
                        courseId,
                        user
                );

        if (enrollment.getCurrentBlock() != null) {
            throw new ConflictException(
                    "Placement test is only available before starting the course"
            );
        }
    }

    private List<Block> getOrderedCourseBlocks(
            Long courseId
    ) {

        List<Block> blocks =
                blockRepository
                        .findAllByLessonChapterCourseIdOrderByLessonChapterPositionAscLessonPositionAscPositionAsc(
                                courseId
                        );

        if (blocks.isEmpty()) {
            throw new ConflictException(
                    "Course has no blocks"
            );
        }

        return blocks;
    }

    private Block resolveCurrentBlock(
            CoursePlacementTestAttempt attempt,
            List<Block> blocks
    ) {

        Block currentBlock =
                attempt.getCurrentBlock();

        if (currentBlock == null || indexOfBlock(blocks, currentBlock) < 0) {
            throw new ConflictException(
                    "Placement test question is no longer available"
            );
        }

        return currentBlock;
    }

    private int indexOfBlock(
            List<Block> blocks,
            Block target
    ) {

        if (target == null || target.getId() == null) {
            return -1;
        }

        for (int index = 0; index < blocks.size(); index++) {
            if (target.getId().equals(blocks.get(index).getId())) {
                return index;
            }
        }

        return -1;
    }

    private void validateAnswerIndex(
            Integer answerIndex,
            Question question
    ) {

        if (
                answerIndex == null ||
                        answerIndex < 0 ||
                        answerIndex >= question.getOptions().size()
        ) {
            throw new BadRequestException(
                    "Invalid answer index"
            );
        }
    }

    private Integer calculateProgressPercentage(
            int completedBlocks,
            int totalBlocks
    ) {

        if (totalBlocks <= 0) {
            return 0;
        }

        return (int) Math.round(
                completedBlocks * 100.0 / totalBlocks
        );
    }

    private PlacementTestQuestionResponse toQuestionResponse(
            Block block
    ) {

        Question question =
                block.getQuestion();

        return new PlacementTestQuestionResponse(
                block.getId(),
                block.getLesson().getId(),
                block.getLesson().getChapter().getId(),
                question.getId(),
                question.getContent(),
                question.getOptions(),
                BaseEntityResponse.from(question)
        );
    }
}
