package app.lms.ai.dashboard.text.service;

import app.lms.ai.dashboard.text.dto.AiTextRequest;
import app.lms.ai.dashboard.text.dto.AiTextResponse;
import app.lms.ai.common.exception.AiServiceException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Slf4j
public class DashboardAiTextService {

    private final ChatClient.Builder chatClientBuilder;
    private final DashboardAiTextPromptService dashboardAiTextPromptService;

    public AiTextResponse transform(AiTextRequest request) {
        try {
            ChatClient chatClient = chatClientBuilder.build();

            String result = chatClient
                    .prompt()
                    .system(dashboardAiTextPromptService.systemPrompt())
                    .user(dashboardAiTextPromptService.buildUserPrompt(request))
                    .call()
                    .content();

            if (result == null || result.isBlank()) {
                throw new AiServiceException(
                        "AI service returned an empty response",
                        HttpStatus.SERVICE_UNAVAILABLE,
                        null
                );
            }

            return new AiTextResponse(
                    request.action(),
                    request.tone(),
                    result
            );

        } catch (AiServiceException ex) {
            throw ex;

        } catch (Exception ex) {
            log.error("AI service failed", ex);

            throw new AiServiceException(
                    "AI service is currently unavailable",
                    HttpStatus.SERVICE_UNAVAILABLE,
                    ex
            );
        }
    }
}