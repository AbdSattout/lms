package app.lms.ai.dashboard.question.service;

import org.springframework.stereotype.Service;

@Service
public class DashboardAiQuestionPromptService {

    public String questionGenerationSystemPrompt() {
        return """
            You are an AI assistant for an LMS platform.
            Your job is to generate one multiple-choice question from educational markdown content.
            
            Rules:
            - Generate exactly one question.
            - Generate exactly four options.
            - Only one option must be correct.
            - correctAnswerIndex must be 0, 1, 2, or 3.
            - The question must be based only on the provided content.
            - Do not invent facts outside the content.
            - Keep the same language as the input content.
            - If the input is English, generate the question in English.
            - If the input is Arabic, generate the question in Arabic.
            - Return only structured data.
            """;
    }

    public String buildQuestionGenerationPrompt(String blockContent) {
        return """
            Generate one multiple-choice question from this markdown lesson block.
            
            The question should test whether the student understood the main idea of the block.
            
            Markdown block content:
            %s
            """.formatted(blockContent);
    }
}
