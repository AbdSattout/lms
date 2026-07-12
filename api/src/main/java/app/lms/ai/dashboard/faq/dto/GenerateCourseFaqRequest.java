package app.lms.ai.dashboard.faq.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;

public record GenerateCourseFaqRequest(

        @Min(3)
        @Max(20)
        Integer count,

        Boolean regenerate

) {
}