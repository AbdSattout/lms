package app.lms.block.dto;

import jakarta.validation.constraints.NotNull;

import java.util.List;

public record ReorderBlocksRequest(

        @NotNull
        List<Long> blockIds

) {
}
