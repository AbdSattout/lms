package app.lms.practiceQuiz.repository;

import app.lms.practiceQuiz.model.PracticeQuiz;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface PracticeQuizRepository extends JpaRepository<PracticeQuiz, Long> {

    List<PracticeQuiz> findAllByCourseIdOrderByCreatedAtDesc(Long courseId);

    Optional<PracticeQuiz> findByIdAndCourseId(Long id, Long courseId);
}