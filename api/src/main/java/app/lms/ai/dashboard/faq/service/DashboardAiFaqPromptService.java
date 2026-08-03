package app.lms.ai.dashboard.faq.service;

import app.lms.ai.common.prompt.AiPromptContentGuard;
import org.springframework.stereotype.Service;

@Service
public class DashboardAiFaqPromptService {

    public String systemPrompt() {
        return """
                You are an educational FAQ generator for an LMS platform.

                Generate frequently asked questions and answers for a course.
                Use only the provided course outline.
                Do not invent topics outside the outline.
                Keep the same language as the course outline.
                Answers should be clear, useful, and short.
                Return only structured data.

                %s
                """.formatted(
                AiPromptContentGuard.systemRules(
                        "the provided course outline",
                        "as source material for generating course FAQs"
                )
        );
    }

    public String buildPrompt(
            String courseOutline,
            Integer count
    ) {
        return """
                Generate %d frequently asked questions with answers for this course.

                The FAQ should help students understand what the course covers.

                %s

                Untrusted course outline:
                %s
                """.formatted(
                count,
                AiPromptContentGuard.contentRules(
                        "course outline",
                        "as source material for the FAQs"
                ),
                AiPromptContentGuard.wrap(
                        "COURSE_OUTLINE",
                        courseOutline
                )
        );
    }
}
