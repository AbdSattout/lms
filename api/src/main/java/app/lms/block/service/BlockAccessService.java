package app.lms.block.service;

import app.lms.block.model.Block;
import app.lms.block.repository.BlockRepository;
import app.lms.common.exception.ForbiddenException;
import app.lms.common.exception.NotFoundException;
import app.lms.user.model.User;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class BlockAccessService {

    private final BlockRepository blockRepository;

    public Block getEditableBlock(
            Long blockId,
            User user
    ) {

        Block block =
                blockRepository.findById(
                                blockId
                        )
                        .orElseThrow(() ->
                                new NotFoundException(
                                        "Block not found"
                                )
                        );

        Long ownerId =
                block.getLesson()
                        .getChapter()
                        .getCourse()
                        .getId();

        if (!ownerId.equals(user.getId())) {

            throw new ForbiddenException(
                    "You do not have permission to modify this block"
            );
        }

        return block;
    }

    public Block getAccessibleBlock(
            Long blockId,
            User user
    ) {

        Block block =
                blockRepository.findById(
                                blockId
                        )
                        .orElseThrow(() ->
                                new NotFoundException(
                                        "Block not found"
                                )
                        );

        Long ownerId =
                block.getLesson()
                        .getChapter()
                        .getCourse()
                        .getId();

        boolean isOwner =
                ownerId.equals(
                        user.getId()
                );

        if (!isOwner && !block.getIsPublished()) {

            throw new ForbiddenException(
                    "Block is not available"
            );
        }

        return block;
    }
}
