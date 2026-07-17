
package app.lms.question.service;

import app.lms.common.exception.ConflictException;
import app.lms.common.exception.NotFoundException;
import app.lms.block.repository.BlockRepository;
import app.lms.course.service.CourseAccessService;
import app.lms.practiceExam.repository.PracticeExamRepository;
import app.lms.practiceQuiz.repository.PracticeQuizRepository;
import app.lms.question.model.Question;
import app.lms.question.repository.QuestionRepository;
import app.lms.quiz.repository.QuizRepository;
import app.lms.user.model.User;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class QuestionAccessService {

    private final QuestionRepository questionRepository;
    private final CourseAccessService courseAccessService;
    private final BlockRepository blockRepository;
    private final QuizRepository quizRepository;
    private final PracticeQuizRepository practiceQuizRepository;
    private final PracticeExamRepository practiceExamRepository;


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

    public List<Question> getManageableQuestionsByCourseId(
            Long courseId,
            User user
    ) {

        courseAccessService.getManageableCourse(
                courseId,
                user
        );

        return questionRepository
                .findAllByCourseIdOrderByIdDesc(
                        courseId
                );
    }

    public void validateQuestionNotUsed(
            Long questionId
    ) {

        if (blockRepository.existsByQuestionId(questionId)) {
            throw new ConflictException(
                    "Question is used by one or more blocks. Remove it from those blocks before deleting it."
            );
        }

        if (quizRepository.existsByQuestionId(questionId)) {
            throw new ConflictException(
                    "Question is used by the final quiz. Remove it from the final quiz before deleting it."
            );
        }

        if (practiceQuizRepository.existsByQuestionId(questionId)) {
            throw new ConflictException(
                    "Question is used by one or more practice quizzes. Remove it from those quizzes before deleting it."
            );
        }

        if (practiceExamRepository.existsByQuestionId(questionId)) {
            throw new ConflictException(
                    "Question is used by one or more practice exams. Remove it from those exams before deleting it."
            );
        }
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
