package app.lms.quiz.repository;

import app.lms.quiz.model.FinalQuizAttempt;
import org.springframework.data.jpa.repository.JpaRepository;

public interface FinalQuizAttemptRepository extends JpaRepository<FinalQuizAttempt, Long> {

    boolean existsByCourseIdAndUserIdAndCompletedTrue(
            Long courseId,
            Long userId
    );
}