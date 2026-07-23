package app.lms.ai.dashboard.question.service;

import app.lms.ai.dashboard.question.dto.GenerateQuestionFromBlockContentRequest;
import app.lms.ai.dashboard.question.dto.GeneratedQuestionResponse;
import app.lms.ai.common.exception.AiServiceException;
import app.lms.plan.annotation.ConsumesPlanUsage;
import app.lms.plan.enums.PlanUsageType;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class DashboardAiQuestionService {

    private final ChatClient.Builder chatClientBuilder;
    private final DashboardAiQuestionPromptService dashboardAiQuestionPromptService;

    @ConsumesPlanUsage(PlanUsageType.AI_TOOL)
    public GeneratedQuestionResponse generateFromBlock(
            GenerateQuestionFromBlockContentRequest request
    ) {
        try {
            ChatClient chatClient = chatClientBuilder.build();

            GeneratedQuestionResponse response = chatClient
                    .prompt()
                    .system(dashboardAiQuestionPromptService.questionGenerationSystemPrompt())
                    .user(dashboardAiQuestionPromptService.buildQuestionGenerationPrompt(request.blockContent()))
                    .call()
                    .entity(GeneratedQuestionResponse.class);

            validateGeneratedQuestion(response);

            return response;

        } catch (AiServiceException ex) {
            throw ex;

        } catch (Exception ex) {
            log.error("AI question generation failed", ex);

            throw new AiServiceException(
                    "AI question generation is currently unavailable",
                    HttpStatus.SERVICE_UNAVAILABLE,
                    ex
            );
        }
    }

    private void validateGeneratedQuestion(
            GeneratedQuestionResponse response
    ) {
        if (response == null) {
            throw new AiServiceException(
                    "AI returned an empty question",
                    HttpStatus.SERVICE_UNAVAILABLE,
                    null
            );
        }

        if (response.content() == null || response.content().isBlank()) {
            throw new AiServiceException(
                    "AI returned an invalid question content",
                    HttpStatus.SERVICE_UNAVAILABLE,
                    null
            );
        }

        List<String> options = response.options();

        if (options == null || options.size() != 4) {
            throw new AiServiceException(
                    "AI returned invalid question options",
                    HttpStatus.SERVICE_UNAVAILABLE,
                    null
            );
        }

        for (String option : options) {
            if (option == null || option.isBlank()) {
                throw new AiServiceException(
                        "AI returned an empty question option",
                        HttpStatus.SERVICE_UNAVAILABLE,
                        null
                );
            }
        }

        Integer correctAnswerIndex = response.correctAnswerIndex();

        if (correctAnswerIndex == null
                || correctAnswerIndex < 0
                || correctAnswerIndex >= options.size()) {
            throw new AiServiceException(
                    "AI returned invalid correct answer index",
                    HttpStatus.SERVICE_UNAVAILABLE,
                    null
            );
        }
    }
}
