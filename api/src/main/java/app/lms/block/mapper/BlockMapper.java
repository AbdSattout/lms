package app.lms.block.mapper;

import app.lms.block.dto.BlockPublicResponse;
import app.lms.block.dto.BlockResponse;
import app.lms.block.model.Block;
import app.lms.question.mapper.QuestionMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class BlockMapper {

    private final QuestionMapper questionMapper;

    public BlockResponse toResponse(
            Block block
    ) {

        return new BlockResponse(
                block.getId(),
                block.getTitle(),
                block.getType(),
                block.getContent(),
                block.getPosition(),
                block.getQuestion() == null
                        ? null
                        : questionMapper.toResponse(
                        block.getQuestion()
                )
        );
    }

    public BlockPublicResponse toPublicResponse(Block block) {

        return new BlockPublicResponse(
                block.getId(),
                block.getTitle(),
                block.getType(),
                block.getContent(),
                block.getPosition(),
                block.getQuestion() == null
                        ? null
                        : questionMapper.toPublicResponse(block.getQuestion())
        );
    }

}
