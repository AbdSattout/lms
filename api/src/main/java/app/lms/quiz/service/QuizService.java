package app.lms.quiz.service;

import app.lms.block.service.BlockAccessService;
import app.lms.common.exception.NotFoundException;
import app.lms.question.dto.CreateQuestionRequest;
import app.lms.question.dto.QuestionResponse;
import app.lms.question.mapper.QuestionMapper;
import app.lms.question.model.Question;
import app.lms.question.repository.QuestionRepository;
import app.lms.quiz.dto.QuizResponse;
import app.lms.quiz.mapper.QuizMapper;
import app.lms.quiz.model.Quiz;
import app.lms.quiz.repository.QuizRepository;
import app.lms.user.model.User;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class QuizService {

    private final QuizRepository quizRepository;
    private final QuestionRepository questionRepository;
    private final QuizMapper quizMapper;
    private final QuestionMapper questionMapper;
    private final BlockAccessService blockAccessService;


    public QuizResponse getQuizById(Long quizId) {
        Quiz quiz = quizRepository.findById(quizId)
                .orElseThrow(() -> new NotFoundException("Quiz not found"));
        return quizMapper.toResponse(quiz);
    }

    @Transactional
    public QuestionResponse addQuestionToQuiz(Long quizId, Long questionId, User user) {
        Quiz quiz = quizRepository.findById(quizId)
                .orElseThrow(() -> new NotFoundException("Quiz not found"));

        Question question = questionRepository.findById(questionId)
                .orElseThrow(() -> new NotFoundException("Question not found"));

        blockAccessService.getEditableBlock(
                question.getBlock().getId(),
                user
        );

        question.setQuiz(quiz);

        Question savedQuestion = questionRepository.save(question);
        return questionMapper.toResponse(savedQuestion);
    }
    @Transactional
    public void deleteQuestionFromQuiz(Long quizId, Long questionId, User user) {
        quizRepository.findById(quizId)
                .orElseThrow(() -> new NotFoundException("Quiz not found"));

        Question question = questionRepository.findById(questionId)
                .orElseThrow(() -> new NotFoundException("Question not found"));

        blockAccessService.getEditableBlock(
                question.getBlock().getId(),
                user
        );

        question.setQuiz(null);

        questionRepository.save(question);
    }
}
