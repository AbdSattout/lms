package app.lms.quiz.service;

import app.lms.common.exception.NotFoundException;
import app.lms.course.service.CourseAccessService;
import app.lms.quiz.model.Quiz;
import app.lms.quiz.repository.QuizRepository;
import app.lms.user.model.User;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class QuizAccessService {


    QuizRepository quizRepository;
    CourseAccessService courseAccessService;
    public Quiz getManageableQuiz(
            Long quizId,
            User user
    ) {

        Quiz quiz =
                quizRepository.findById(quizId)
                        .orElseThrow(() ->
                                new NotFoundException(
                                        "Quiz not found"
                                )
                        );

        courseAccessService.getManageableCourse(
                quiz.getCourse().getId(),
                user
        );

        return quiz;
    }
}
