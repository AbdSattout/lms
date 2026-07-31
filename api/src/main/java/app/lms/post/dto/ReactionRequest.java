package app.lms.post.dto;

import app.lms.post.enums.ReactionType;
import jakarta.validation.constraints.NotNull;

public record ReactionRequest(

        @NotNull
        ReactionType reactionType

) {}
