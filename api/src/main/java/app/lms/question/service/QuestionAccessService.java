
package app.lms.question.service;

import app.lms.common.exception.NotFoundException;
import app.lms.course.service.CourseAccessService;
import app.lms.question.model.Question;
import app.lms.question.repository.QuestionRepository;
import app.lms.user.model.User;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class QuestionAccessService {

    private final QuestionRepository questionRepository;
    private final CourseAccessService courseAccessService;


    public Question getManageableQuestion(
            Long questionId,
            User user
    ) {

        Question question = getQuestionById(questionId);
        courseAccessService.getManageableCourse(
                question.getCourse().getId(),
                user
        );

        return question;
    }

    public Question getEditableQuestion(
            Long questionId,
            User user
    ) {

        Question question = getQuestionById(questionId);
        courseAccessService.getEditableCourse(
                question.getCourse().getId(),
                user
        );

        return question;
    }
    private Question getQuestionById(Long questionId){
        return questionRepository.findById(questionId)
                .orElseThrow(() ->
                        new NotFoundException(
                                "Question not found"
                        )
                );
    }
}
