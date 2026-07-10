package app.lms.ai.dashboard.text.controller;

import app.lms.ai.dashboard.text.dto.AiTextRequest;
import app.lms.ai.dashboard.text.dto.AiTextResponse;
import app.lms.ai.dashboard.text.service.DashboardAiTextService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/dashboard/ai/text")
@RequiredArgsConstructor
public class DashboardAiTextController {

    private final DashboardAiTextService dashboardAiTextService;

    @PostMapping
    public ResponseEntity<AiTextResponse> transformText(
            @RequestBody @Valid AiTextRequest request
    ) {
        return ResponseEntity.ok(
                dashboardAiTextService.transform(request)
        );
    }
}