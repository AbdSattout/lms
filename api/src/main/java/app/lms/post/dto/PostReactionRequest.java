package app.lms.post.dto;

import app.lms.post.enums.PostReactionType;
import jakarta.validation.constraints.NotNull;

public record PostReactionRequest(

        @NotNull
        PostReactionType reactionType

) {}
