package app.lms.practiceExam.repository;

import app.lms.practiceExam.model.PracticeExam;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Optional;

public interface PracticeExamRepository extends JpaRepository<PracticeExam, Long> {

    List<PracticeExam> findAllByCourseIdOrderByCreatedAtDesc(Long courseId);

    Optional<PracticeExam> findByIdAndCourseId(Long id, Long courseId);

    @Query("""
            select count(pe) > 0
            from PracticeExam pe
            join pe.questions q
            where q.id = :questionId
            """)
    boolean existsByQuestionId(Long questionId);
}
