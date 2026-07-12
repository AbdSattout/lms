package app.lms.ai.dashboard.text.controller;

import app.lms.ai.dashboard.text.dto.GenerateAiTextRequest;
import app.lms.ai.dashboard.text.dto.GeneratedAiTextResponse;
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
    public ResponseEntity<GeneratedAiTextResponse> transformText(
            @RequestBody @Valid GenerateAiTextRequest request
    ) {
        return ResponseEntity.ok(
                dashboardAiTextService.transform(request)
        );
    }
}