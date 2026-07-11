package app.lms.ai.mobile.quiz.repository;

import app.lms.ai.mobile.quiz.model.RandomQuizAttempt;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface RandomQuizAttemptRepository extends JpaRepository<RandomQuizAttempt, Long> {

    Optional<RandomQuizAttempt> findByIdAndCourseIdAndUserId(
            Long id,
            Long courseId,
            Long userId
    );
}