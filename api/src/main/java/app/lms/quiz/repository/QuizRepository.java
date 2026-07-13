package app.lms.quiz.repository;

import app.lms.quiz.model.Quiz;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface QuizRepository extends JpaRepository<Quiz, Long> {


    @Query("""
            select count(qz) > 0
            from Quiz qz
            join qz.questions q
            where q.id = :questionId
            """)
    boolean existsByQuestionId(
            Long questionId
    );
    Optional<Quiz> findByCourseId(
            Long courseId
    );


    boolean existsByCourseId(Long courseId);

    @Query("""
            select count(q)
            from Quiz quiz
            join quiz.questions q
            where quiz.course.id = :courseId
            """)
    long countQuestionsByCourseId(Long courseId);
}
