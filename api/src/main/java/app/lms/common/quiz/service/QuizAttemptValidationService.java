package app.lms.common.quiz.service;

import app.lms.common.exception.ConflictException;
import app.lms.common.quiz.interfaces.CompletableQuizAttempt;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class QuizAttemptValidationService {

    public void validateNotSubmitted(
            CompletableQuizAttempt attempt
    ) {

        if (Boolean.TRUE.equals(attempt.getCompleted())) {
            throw new ConflictException(
                    "Quiz attempt already submitted"
            );
        }
    }

    public List<Long> validateUniqueQuestionIds(
            List<Long> questionIds
    ) {

        List<Long> uniqueQuestionIds =
                questionIds.stream()
                        .distinct()
                        .toList();

        if (uniqueQuestionIds.size() != questionIds.size()) {
            throw new ConflictException(
                    "Duplicate questions are not allowed"
            );
        }

        return uniqueQuestionIds;
    }
}
