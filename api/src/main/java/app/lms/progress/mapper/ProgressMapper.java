package app.lms.progress.mapper;

import app.lms.block.model.Block;
import app.lms.gamification.dto.GamificationAwardResponse;
import app.lms.progress.dto.SubmitBlockAnswerResponse;
import app.lms.progress.enums.NextStepType;
import app.lms.quiz.model.Quiz;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
public class ProgressMapper {

    public SubmitBlockAnswerResponse incorrectAnswer() {
        return new SubmitBlockAnswerResponse(
                NextStepType.INCORRECT,
                null,
                null,
                null,
                null,
                "Incorrect answer",
                List.of()
        );
    }

    public SubmitBlockAnswerResponse toNextStepResponse(
            Block block
    ) {
        return new SubmitBlockAnswerResponse(
                NextStepType.BLOCK,
                block.getId(),
                block.getLesson().getId(),
                block.getLesson().getChapter().getId(),
                null,
                "Correct answer",
                List.of()
        );
    }

    public SubmitBlockAnswerResponse toFinalQuizResponse(
            Quiz quiz
    ) {
        return new SubmitBlockAnswerResponse(
                NextStepType.QUIZ,
                null,
                null,
                null,
                quiz.getId(),
                "Course lessons completed. Go to final quiz.",
                List.of()
        );
    }

    public SubmitBlockAnswerResponse courseCompleted() {
        return new SubmitBlockAnswerResponse(
                NextStepType.COURSE_COMPLETED,
                null,
                null,
                null,
                null,
                "Course completed",
                List.of()
        );
    }

    public SubmitBlockAnswerResponse withRewards(
            SubmitBlockAnswerResponse response,
            List<GamificationAwardResponse> rewards
    ) {

        return new SubmitBlockAnswerResponse(
                response.nextType(),
                response.nextBlockId(),
                response.nextLessonId(),
                response.nextChapterId(),
                response.quizId(),
                response.message(),
                rewards
        );
    }
}
