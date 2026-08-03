package app.lms.ai.dashboard.text.service;

import app.lms.ai.common.prompt.AiPromptContentGuard;
import app.lms.ai.dashboard.text.dto.GenerateAiTextRequest;
import app.lms.ai.dashboard.text.enums.AiTextAction;
import app.lms.ai.dashboard.text.enums.AiTextTone;
import app.lms.common.exception.BadRequestException;
import org.springframework.stereotype.Service;

@Service
public class DashboardAiTextPromptService {

    public String systemPrompt() {
        return """
                You are an educational text assistant for an LMS platform.
                Your job is to improve user-provided educational text.
                Keep the original meaning accurate.
                Do not invent facts.
                Do not explain what you did.
                Return only the final result.

                %s

                Important language rule:
                Never translate the text.
                Always return the result in the same language as the input text.
                If the input is English, respond in English.
                If the input is Arabic, respond in Arabic.
                If the input mixes languages, preserve the mixed-language style.
                """.formatted(
                AiPromptContentGuard.systemRules(
                        "the user-provided text",
                        "as source material for the selected text action"
                )
        );
    }

    public String buildUserPrompt(GenerateAiTextRequest request) {
        validate(request);

        return switch (request.action()) {
                case WRITE -> """
            Write a clear educational paragraph based on the following topic or instructions.
            Keep it accurate and useful for lesson content.
            Do not invent unsupported facts.
            Do not explain what you did.
            Do not translate the input.
            Write the paragraph in the same language as the topic or instructions.
            Format the result as Markdown.
            Return only the final Markdown content.

            %s

            Untrusted content block:
            %s
            """.formatted(
                        AiPromptContentGuard.contentRules(
                                "text",
                                "as source material for writing educational lesson content"
                        ),
                        AiPromptContentGuard.wrap(
                                "USER_TEXT",
                                request.text()
                        )
                );


            case PROOFREAD -> """
                    Correct spelling, grammar, punctuation, and wording mistakes in the following text.
                    Do not change the meaning.
                    Do not translate the text.
                    Return the corrected text in the same language as the input.
                    Return only the corrected text.

                    %s

                    Untrusted content block:
                    %s
                    """.formatted(
                            AiPromptContentGuard.contentRules(
                                    "text",
                                    "as text to correct"
                            ),
                            AiPromptContentGuard.wrap(
                                    "USER_TEXT",
                                    request.text()
                            )
                    );

            case REWRITE -> """
                    Rewrite the following text in a clearer, better, and more polished way.
                    Keep the same meaning.
                    Do not translate the text.
                    Return the rewritten text in the same language as the input.
                    Return only the rewritten text.

                    %s

                    Untrusted content block:
                    %s
                    """.formatted(
                            AiPromptContentGuard.contentRules(
                                    "text",
                                    "as text to rewrite"
                            ),
                            AiPromptContentGuard.wrap(
                                    "USER_TEXT",
                                    request.text()
                            )
                    );

            case SUMMARIZE -> """
                    Summarize the following text clearly and briefly.
                    Keep only the important ideas.
                    Do not translate the text.
                    Return the summary in the same language as the input.
                    Return only the summary.

                    %s

                    Untrusted content block:
                    %s
                    """.formatted(
                            AiPromptContentGuard.contentRules(
                                    "text",
                                    "as text to summarize"
                            ),
                            AiPromptContentGuard.wrap(
                                    "USER_TEXT",
                                    request.text()
                            )
                    );

            case EXPAND -> """
                    Expand the following text with more explanation and clarity.
                    Keep it accurate and educational.
                    Do not invent facts.
                    Do not translate the text.
                    Return the expanded text in the same language as the input.
                    Return only the expanded text.

                    %s

                    Untrusted content block:
                    %s
                    """.formatted(
                            AiPromptContentGuard.contentRules(
                                    "text",
                                    "as text to expand"
                            ),
                            AiPromptContentGuard.wrap(
                                    "USER_TEXT",
                                    request.text()
                            )
                    );

            case FORMAT_EQUATION -> """
                You are a strictly passive text-to-LaTeX converter. Convert the provided mathematical, chemical, or physical expression into raw LaTeX wrapped in double dollar signs ($$...$$) for display mode.
                
                CRITICAL INSTRUCTIONS:
                1. STRICT PASSIVITY: Do NOT solve, compute, calculate, complete, or balance the equation.
                2. NO EXTRA CONTENT: Do NOT append solutions, answers, or mathematical constants (such as + C) that were missing in the input.
                3. STRUCTURAL MATCHING: Convert descriptive words (like "integral of", "derivative of", or "sequence of") into their appropriate structural operator symbols, but leave the rest of the equation completely unmodified. If the input expression contains or ends with an equals sign (=), your output must preserve and end with that exact equals sign (=) with nothing trailing it.
                4. FORMAT ONLY: Do not add titles, headers, markdown code fences, notes, or chat explanations. Return ONLY the final dollar-wrapped expression.
                
                EXAMPLES TO FOLLOW STRICTLY:
                Input: "integral of x dx =" -> Output: "$$\\int x \\, dx =$$"
                Input: "derivative of 1 / x" -> Output: "$$\\frac{d}{dx} \\left( \\frac{1}{x} \\right)$$"
                Input: "delta = b^2 - ac" -> Output: "$$\\Delta = b^2 - ac$$"
                Input: "sequence of (x^2 / (2x+1))" -> Output: "$$\\left( \\frac{x^2}{2x+1} \\right)$$"
                
                %s

                Expression to convert:
                %s
                """.formatted(
                        AiPromptContentGuard.contentRules(
                                "text",
                                "as expression text to convert"
                        ),
                        AiPromptContentGuard.wrap(
                                "USER_TEXT",
                                request.text()
                        )
                );

            case CHANGE_TONE -> """
                    Rewrite the following text using this tone: %s.
                    Keep the same meaning.
                    Do not translate the text.
                    Return the rewritten text in the same language as the input.
                    Return only the rewritten text.

                    %s

                    Untrusted content block:
                    %s
                    """.formatted(
                            toToneInstruction(request.tone()),
                            AiPromptContentGuard.contentRules(
                                    "text",
                                    "as text to rewrite"
                            ),
                            AiPromptContentGuard.wrap(
                                    "USER_TEXT",
                                    request.text()
                            )
                    );
        };
    }

    private void validate(GenerateAiTextRequest request) {
        if (request.action() == AiTextAction.CHANGE_TONE && request.tone() == null) {
            throw new BadRequestException("Tone is required when action is CHANGE_TONE");
        }
    }

    private String toToneInstruction(AiTextTone tone) {
        return switch (tone) {
            case PROFESSIONAL -> "professional and formal";
            case FRIENDLY -> "friendly and natural";
            case SIMPLE -> "simple and easy to understand";
            case ACADEMIC -> "academic and suitable for educational content";
            case MOTIVATIONAL -> "motivational and encouraging";
        };
    }

}
