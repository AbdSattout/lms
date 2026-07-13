package app.lms.question.repository;

import app.lms.question.enums.QuestionDifficulty;
import app.lms.question.model.Question;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface QuestionRepository extends JpaRepository<Question, Long> {

    List<Question> findAllByCourseIdOrderByIdDesc(
            Long courseId
    );

    @Query("""
            select q
            from Question q
            where q.course.id = :courseId
              and q.difficulty = :difficulty
              and not exists (
                  select b.id
                  from Block b
                  where b.question.id = q.id
              )
            """)
    List<Question> findBankQuestionsByCourseIdAndDifficulty(
            Long courseId,
            QuestionDifficulty difficulty
    );
}
