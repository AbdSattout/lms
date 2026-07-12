package app.lms.ai.dashboard.faq.dto;

import java.util.List;

public record GeneratedCourseFaqResponse(
        List<GeneratedFaqItem> faqs
) {
}