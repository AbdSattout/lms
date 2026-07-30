package app.lms.tests.gamification.controller;

import app.lms.tests.gamification.dto.MonthlyAwardEmailTestRequest;
import app.lms.tests.gamification.dto.MonthlyAwardEmailTestResponse;
import app.lms.tests.gamification.service.MonthlyAwardEmailTestService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@ConditionalOnProperty(
        prefix = "app.tests",
        name = "enabled",
        havingValue = "true"
)
@RequestMapping("/tests/gamification/monthly-awards")
public class MonthlyAwardEmailTestController {

    private final MonthlyAwardEmailTestService monthlyAwardEmailTestService;

    @PostMapping("/email")
    public ResponseEntity<MonthlyAwardEmailTestResponse> send(
            @RequestBody @Valid
            MonthlyAwardEmailTestRequest request
    ) {

        return ResponseEntity.ok(
                monthlyAwardEmailTestService.send(request)
        );
    }
}
