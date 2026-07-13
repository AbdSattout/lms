package app.lms.common.quiz.service;

import app.lms.common.exception.ConflictException;
import app.lms.common.quiz.interfaces.CompletableQuizAttempt;
import org.springframework.stereotype.Service;

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
}
