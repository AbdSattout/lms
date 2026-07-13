package app.lms.question.repository;

import app.lms.question.enums.QuestionDifficulty;
import app.lms.question.model.Question;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface QuestionRepository extends JpaRepository<Question, Long> {

    List<Question> findAllByCourseIdOrderByIdDesc(
            Long courseId
    );
    List<Question> findAllByCourseIdAndDifficulty(
            Long courseId,
            QuestionDifficulty difficulty
    );
}
