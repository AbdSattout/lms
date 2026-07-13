package app.lms.randomquiz.service;

import app.lms.common.exception.NotFoundException;
import app.lms.randomquiz.model.BankRandomQuizAttempt;
import app.lms.randomquiz.repository.BankRandomQuizAttemptRepository;
import app.lms.user.model.User;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class BankRandomQuizAccessService {

    private final BankRandomQuizAttemptRepository bankRandomQuizAttemptRepository;

    public BankRandomQuizAttempt getAttempt(
            Long courseId,
            Long attemptId,
            User user
    ) {

        return bankRandomQuizAttemptRepository
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
