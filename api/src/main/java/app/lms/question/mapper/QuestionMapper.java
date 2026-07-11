package app.lms.question.mapper;

import app.lms.question.dto.QuestionPublicResponse;
import app.lms.question.dto.QuestionResponse;
import app.lms.question.model.Question;
import org.springframework.stereotype.Component;

@Component
public class QuestionMapper {

    public QuestionResponse toResponse(
            Question question
    ) {
        return new QuestionResponse(
                question.getId(),
                question.getCourse().getId(),
                question.getContent(),
                question.getOptions(),
                question.getCorrectAnswerIndex()
        );
    }

    public QuestionPublicResponse toPublicResponse(
            Question question
    ) {

        return new QuestionPublicResponse(
                question.getId(),
                question.getContent(),
                question.getOptions()
        );
    }
}