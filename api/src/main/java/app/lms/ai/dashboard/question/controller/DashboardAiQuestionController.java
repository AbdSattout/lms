package app.lms.ai.dashboard.question.controller;

import app.lms.ai.dashboard.question.dto.GenerateQuestionFromBlockContentRequest;
import app.lms.ai.dashboard.question.dto.GeneratedQuestionResponse;
import app.lms.ai.dashboard.question.service.DashboardAiQuestionService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/dashboard/ai/questions")
@RequiredArgsConstructor
public class DashboardAiQuestionController {

    private final DashboardAiQuestionService dashboardAiQuestionService;

    @PostMapping("/from-block-content")
    public ResponseEntity<GeneratedQuestionResponse> generateFromBlockContent(
            @RequestBody @Valid GenerateQuestionFromBlockContentRequest request
    ) {
        return ResponseEntity.ok(
                dashboardAiQuestionService.generateFromBlock(request)
        );
    }
}