package app.lms.practiceExam.repository;

import app.lms.practiceExam.model.PracticeExamAttempt;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface PracticeExamAttemptRepository extends JpaRepository<PracticeExamAttempt, Long> {

    List<PracticeExamAttempt> findAllByPracticeExamId(Long practiceExamId);
}
