package app.lms.organization.repository;

import app.lms.organization.enums.QuestionDifficulty;
import app.lms.organization.model.Question;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface QuestionRepository
        extends JpaRepository<Question, Long> {

    List<Question>
    findAllByCourseId(Long courseId);

    List<Question>
    findAllByCourseIdAndDifficulty(
            Long courseId,
            QuestionDifficulty difficulty
    );
}
