package app.lms.practiceExam.repository;

import app.lms.practiceExam.model.PracticeExamAttempt;
import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;

import java.util.List;
import java.util.Optional;

public interface PracticeExamAttemptRepository extends JpaRepository<PracticeExamAttempt, Long> {

    List<PracticeExamAttempt> findAllByPracticeExamId(Long practiceExamId);

    List<PracticeExamAttempt> findAllByCourseIdAndUserIdAndCompletedFalse(
            Long courseId,
            Long userId
    );

    Optional<PracticeExamAttempt> findFirstByPracticeExamIdAndCourseIdAndUserIdAndCompletedFalseOrderByStartedAtDesc(
            Long practiceExamId,
            Long courseId,
            Long userId
    );

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    Optional<PracticeExamAttempt> findLockedByIdAndPracticeExamIdAndCourseIdAndUserId(
            Long id,
            Long practiceExamId,
            Long courseId,
            Long userId
    );

    boolean existsByPracticeExamIdAndUserIdAndIdLessThan(
            Long practiceExamId,
            Long userId,
            Long id
    );
}
