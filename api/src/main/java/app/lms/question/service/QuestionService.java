package app.lms.question.service;


import app.lms.common.exception.BadRequestException;
import app.lms.course.model.Course;
import app.lms.course.service.CourseAccessService;
import app.lms.question.dto.CreateQuestionRequest;
import app.lms.question.dto.QuestionResponse;
import app.lms.question.dto.UpdateQuestionRequest;
import app.lms.question.mapper.QuestionMapper;
import app.lms.question.model.Question;
import app.lms.question.repository.QuestionRepository;
import app.lms.user.model.User;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class QuestionService {

    private final QuestionRepository questionRepository;
    private final QuestionMapper questionMapper;
    private final CourseAccessService courseAccessService;
    private final QuestionAccessService questionAccessService;

    @Transactional
    public QuestionResponse create(
            Long courseId,
            CreateQuestionRequest request,
            User user
    ) {

        Course course =
                courseAccessService.getManageableCourse(
                        courseId,
                        user
                );

        validateQuestion(
                request.options(),
                request.correctAnswerIndex()
        );

        Question question =
                questionMapper.toEntity(
                        request,
                        course
                );

        questionRepository.save(
                question
        );

        return questionMapper.toResponse(
                question
        );
    }

    @Transactional
    public List<QuestionResponse> getQuestionsByCourseId(
            Long courseId,
            User user
    ) {

        return questionAccessService
                .getManageableQuestionsByCourseId(
                        courseId,
                        user
                )
                .stream()
                .map(
                        questionMapper::toResponse
                )
                .toList();
    }


    @Transactional
    public QuestionResponse update(
            Long questionId,
            UpdateQuestionRequest request,
            User user
    ) {

        Question question =
                questionAccessService.getManageableQuestion(
                        questionId,
                        user
                );

        String content =
                request.content() != null
                        ? request.content().trim()
                        : question.getContent();

        List<String> options =
                request.options() != null
                        ? request.options()
                        : question.getOptions();

        Integer correctAnswerIndex =
                request.correctAnswerIndex() != null
                        ? request.correctAnswerIndex()
                        : question.getCorrectAnswerIndex();

        if (content == null || content.isBlank()) {
            throw new BadRequestException(
                    "Question content cannot be empty"
            );
        }

        validateQuestion(
                options,
                correctAnswerIndex
        );

        question.setContent(
                content
        );

        question.setOptions(
                options
        );

        question.setCorrectAnswerIndex(
                correctAnswerIndex
        );

        return questionMapper.toResponse(
                question
        );
    }

    @Transactional
    public void delete(
            Long questionId,
            User user
    ) {

        Question question =
                questionAccessService
                        .getManageableQuestion(
                                questionId,
                                user
                        );

        questionAccessService.validateQuestionNotUsed(
                questionId
        );

        questionRepository.delete(
                question
        );
    }

    private void validateQuestion(
            List<String> options,
            Integer correctAnswerIndex
    ) {

        if (options == null || options.size() < 2) {
            throw new BadRequestException(
                    "Question must have at least two options"
            );
        }

        boolean hasEmptyOption =
                options.stream()
                        .anyMatch(option ->
                                option == null || option.isBlank()
                        );

        if (hasEmptyOption) {
            throw new BadRequestException(
                    "Question options cannot be empty"
            );
        }

        if (correctAnswerIndex == null
                || correctAnswerIndex < 0
                || correctAnswerIndex >= options.size()) {
            throw new BadRequestException(
                    "Invalid correct answer index"
            );
        }
    }

}
