package app.lms.admin.dto;

import jakarta.validation.constraints.Size;

public record BanRequest(

        @Size(max = 500)
        String reason

) {
}
