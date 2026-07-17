package app.lms.practiceQuiz.dto;

import app.lms.common.quiz.interfaces.GradableQuizQuestion;

import java.util.List;

public class PracticeQuizGradingQuestion implements GradableQuizQuestion {

    private final Long questionId;
    private final String content;
    private final List<String> options;
    private final Integer correctAnswerIndex;
    private Integer selectedAnswerIndex;
    private Boolean correct;

    public PracticeQuizGradingQuestion(
            Long questionId,
            String content,
            List<String> options,
            Integer correctAnswerIndex
    ) {

        this.questionId = questionId;
        this.content = content;
        this.options = options;
        this.correctAnswerIndex = correctAnswerIndex;
    }

    @Override
    public Long gradingQuestionId() {
        return questionId;
    }

    public Long getQuestionId() {
        return questionId;
    }

    public String getContent() {
        return content;
    }

    @Override
    public List<String> getOptions() {
        return options;
    }

    @Override
    public Integer getCorrectAnswerIndex() {
        return correctAnswerIndex;
    }

    public Integer getSelectedAnswerIndex() {
        return selectedAnswerIndex;
    }

    @Override
    public void setSelectedAnswerIndex(
            Integer selectedAnswerIndex
    ) {
        this.selectedAnswerIndex = selectedAnswerIndex;
    }

    public Boolean getCorrect() {
        return correct;
    }

    @Override
    public void setCorrect(
            Boolean correct
    ) {
        this.correct = correct;
    }
}
