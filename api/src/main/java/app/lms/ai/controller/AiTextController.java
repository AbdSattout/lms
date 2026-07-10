package app.lms.ai.controller;

import app.lms.ai.dto.AiTextRequest;
import app.lms.ai.dto.AiTextResponse;
import app.lms.ai.service.AiTextService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/ai")
@RequiredArgsConstructor
public class AiTextController {

    private final AiTextService aiTextService;

    @PostMapping("/text")
    public ResponseEntity<AiTextResponse> transformText(
            @RequestBody @Valid AiTextRequest request
    ) {
        return ResponseEntity.ok(aiTextService.transform(request));
    }
}