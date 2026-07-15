package app.lms.practiceExam.repository;

import app.lms.practiceExam.model.PracticeExam;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface PracticeExamRepository extends JpaRepository<PracticeExam, Long> {

    List<PracticeExam> findAllByCourseIdOrderByCreatedAtDesc(Long courseId);

    Optional<PracticeExam> findByIdAndCourseId(Long id, Long courseId);
}
