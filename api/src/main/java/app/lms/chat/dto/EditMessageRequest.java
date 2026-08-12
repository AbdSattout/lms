package app.lms.chat.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record EditMessageRequest(

        @NotBlank
        @Size(max = 5000)
        String content

) {}
