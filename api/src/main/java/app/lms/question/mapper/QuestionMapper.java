package app.lms.question.mapper;

import app.lms.course.model.Course;
import app.lms.question.dto.CreateQuestionRequest;
import app.lms.question.dto.QuestionPublicResponse;
import app.lms.question.dto.QuestionResponse;
import app.lms.question.enums.QuestionDifficulty;
import app.lms.question.model.Question;
import org.springframework.stereotype.Component;

@Component
public class QuestionMapper {

    public Question toEntity(
            CreateQuestionRequest request,
            Course course
    ) {

        return Question.builder()
                .course(course)
                .content(request.content().trim())
                .options(request.options())
                .correctAnswerIndex(request.correctAnswerIndex())
                .difficulty(
                        request.difficulty() != null
                                ? request.difficulty()
                                : QuestionDifficulty.MEDIUM
                )
                .build();
    }

    public QuestionResponse toResponse(Question question) {
        return new QuestionResponse(
                question.getId(),
                question.getContent(),
                question.getOptions(),
                question.getCorrectAnswerIndex(),
                question.getDifficulty(),
                question.getCourse().getId()
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
