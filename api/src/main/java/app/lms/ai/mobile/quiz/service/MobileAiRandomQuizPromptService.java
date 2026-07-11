package app.lms.ai.mobile.quiz.service;

import app.lms.question.model.Question;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class MobileAiRandomQuizPromptService {

    public String systemPrompt() {
        return """
                You are an educational quiz rewriting assistant for an LMS platform.

                Rewrite the provided questions into a new practice quiz.
                Rules:
                - Return exactly 10 questions.
                - Use only the provided source questions.
                - Each generated question must keep the same meaning as its source question.
                - Do not invent new topics.
                - Keep the same language as the source question.
                - Keep the same number of options as the source question.
                - The correct option must keep the same meaning as the original correct option.
                - Return only structured data.
                """;
    }

    public String buildPrompt(
            List<Question> questions
    ) {

        StringBuilder builder =
                new StringBuilder();

        builder.append("""
                Rewrite these 10 source questions into a new practice quiz.
                For each item, include the sourceQuestionId.
                
                Source questions:
                
                """);

        for (Question question : questions) {

            builder.append("Source question ID: ")
                    .append(question.getId())
                    .append("\n");

            builder.append("Question: ")
                    .append(question.getContent())
                    .append("\n");

            builder.append("Options:\n");

            for (int i = 0; i < question.getOptions().size(); i++) {
                builder.append(i)
                        .append(". ")
                        .append(question.getOptions().get(i))
                        .append("\n");
            }

            builder.append("Correct answer index: ")
                    .append(question.getCorrectAnswerIndex())
                    .append("\n\n");
        }

        return builder.toString();
    }
}