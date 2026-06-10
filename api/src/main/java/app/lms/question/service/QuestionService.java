package app.lms.question.service;


import app.lms.block.service.BlockAccessService;
import app.lms.common.exception.BadRequestException;
import app.lms.common.exception.NotFoundException;
import app.lms.question.dto.QuestionResponse;
import app.lms.question.dto.UpdateQuestionRequest;
import app.lms.question.mapper.QuestionMapper;
import app.lms.question.model.Question;
import app.lms.question.repository.QuestionRepository;
import app.lms.user.model.User;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class QuestionService {

    private final QuestionRepository questionRepository;
    private final QuestionMapper questionMapper;
    private final BlockAccessService blockAccessService;

    @Transactional
    public QuestionResponse update(
            Long questionId,
            UpdateQuestionRequest request,
            User user
    ) {

        Question question =
                questionRepository.findById(questionId)
                        .orElseThrow(() ->
                                new NotFoundException(
                                        "Question not found"
                                )
                        );

        blockAccessService.getEditableBlock(
                question.getBlock().getId(),
                user
        );

        if (request.content() != null) {
            question.setContent(
                    request.content().trim()
            );
        }

        if (request.options() != null) {
            question.setOptions(
                    request.options()
            );
        }

        if (request.correctAnswerIndex() != null) {

            int optionsSize =
                    request.options() != null
                            ? request.options().size()
                            : question.getOptions().size();

            if (request.correctAnswerIndex() >= optionsSize) {
                throw new BadRequestException(
                        "Invalid correct answer index"
                );
            }

            question.setCorrectAnswerIndex(
                    request.correctAnswerIndex()
            );
        }

        return questionMapper.toResponse(
                question
        );
    }
}
