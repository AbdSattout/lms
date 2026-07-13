package app.lms.common.quiz.interfaces;

import java.util.List;

public interface GradableQuizQuestion {

    Long gradingQuestionId();

    List<String> getOptions();

    Integer getCorrectAnswerIndex();

    void setSelectedAnswerIndex(Integer selectedAnswerIndex);

    void setCorrect(Boolean correct);
}