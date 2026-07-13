package app.lms.ai.mobile.quiz.service;

import app.lms.ai.mobile.quiz.model.RandomQuizAttempt;
import app.lms.ai.mobile.quiz.repository.RandomQuizAttemptRepository;
import app.lms.common.exception.NotFoundException;
import app.lms.user.model.User;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class MobileAiRandomQuizAccessService {

    private final RandomQuizAttemptRepository randomQuizAttemptRepository;

    public RandomQuizAttempt getAttempt(
            Long courseId,
            Long attemptId,
            User user
    ) {

        return randomQuizAttemptRepository
                .findByIdAndCourseIdAndUserId(
                        attemptId,
                        courseId,
                        user.getId()
                )
                .orElseThrow(() ->
                        new NotFoundException(
                                "Random quiz attempt not found"
                        )
                );
    }
}
