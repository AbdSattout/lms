package app.lms.common.quiz.service;

import app.lms.common.exception.BadRequestException;
import app.lms.question.model.Question;
import app.lms.question.service.QuestionAccessService;
import app.lms.user.model.User;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class QuizQuestionSelectionService {

    private final QuestionAccessService questionAccessService;
    private final QuizAttemptValidationService quizAttemptValidationService;

    public List<Question> getManageableCourseQuestions(
            List<Long> questionIds,
            Long courseId,
            User user,
            String quizType
    ) {

        return quizAttemptValidationService
                .validateUniqueQuestionIds(
                        questionIds
                )
                .stream()
                .map(questionId ->
                        questionAccessService
                                .getManageableQuestion(
                                        questionId,
                                        user
                                )
                )
                .peek(question ->
                        validateQuestionBelongsToCourse(
                                question,
                                courseId,
                                quizType
                        )
                )
                .toList();
    }

    private void validateQuestionBelongsToCourse(
            Question question,
            Long courseId,
            String quizType
    ) {

        if (!question.getCourse().getId().equals(courseId)) {
            throw new BadRequestException(
                    "Question must belong to the same course as the " + quizType
            );
        }
    }
}
