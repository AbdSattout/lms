package app.lms.practiceQuiz.repository;

import app.lms.practiceQuiz.model.PracticeQuizAttempt;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PracticeQuizAttemptRepository extends JpaRepository<PracticeQuizAttempt, Long> {
}