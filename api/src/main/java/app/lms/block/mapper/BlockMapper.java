package app.lms.block.mapper;

import app.lms.block.dto.BlockResponse;
import app.lms.block.model.Block;
import org.springframework.stereotype.Component;

@Component
public class BlockMapper {

    public BlockResponse toResponse(
            Block block
    ) {

        return new BlockResponse(
                block.getId(),
                block.getTitle(),
                block.getType(),
                block.getContent(),
                block.getPosition(),
                block.getIsPublished()
        );
    }
}
