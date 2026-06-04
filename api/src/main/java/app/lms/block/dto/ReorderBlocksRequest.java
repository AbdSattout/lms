package app.lms.block.dto;

import java.util.List;

public record ReorderBlocksRequest(

        List<Long> blockIds

) {
}
