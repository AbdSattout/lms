package app.lms.randomquiz.repository;

import app.lms.randomquiz.model.BankRandomQuizAttempt;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface BankRandomQuizAttemptRepository extends JpaRepository<BankRandomQuizAttempt, Long> {

    Optional<BankRandomQuizAttempt> findByIdAndCourseIdAndUserId(
            Long id,
            Long courseId,
            Long userId
    );
}