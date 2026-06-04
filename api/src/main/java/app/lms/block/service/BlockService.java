package app.lms.block.service;

import app.lms.block.dto.BlockResponse;
import app.lms.block.dto.CreateBlockRequest;
import app.lms.block.dto.ReorderBlocksRequest;
import app.lms.block.dto.UpdateBlockRequest;
import app.lms.block.mapper.BlockMapper;
import app.lms.block.model.Block;
import app.lms.block.repository.BlockRepository;
import app.lms.common.exception.ConflictException;
import app.lms.common.exception.NotFoundException;
import app.lms.lesson.model.Lesson;
import app.lms.lesson.service.LessonAccessService;
import app.lms.user.model.User;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class BlockService {

    private final BlockRepository blockRepository;
    private final BlockMapper blockMapper;
    private final BlockAccessService blockAccessService;
    private final LessonAccessService lessonAccessService;

    @Transactional
    public BlockResponse create(
            Long lessonId,
            CreateBlockRequest request,
            User user
    ) {

        Lesson lesson =
                lessonAccessService
                        .getEditableLesson(
                                lessonId,
                                user
                        );

        Integer position =
                blockRepository
                        .findMaxPositionByLessonId(
                                lessonId
                        )
                        .orElse(0) + 1;

        Block block =
                Block.builder()
                        .title(request.title())
                        .type(request.type())
                        .content(request.content())
                        .position(position)
                        .isPublished(false)
                        .lesson(lesson)
                        .build();

        blockRepository.save(
                block
        );

        return blockMapper.toResponse(
                block
        );
    }

    @Transactional
    public BlockResponse update(
            Long blockId,
            UpdateBlockRequest request,
            User user
    ) {

        Block block =
                blockAccessService
                        .getEditableBlock(
                                blockId,
                                user
                        );

        if (request.title() != null) {
            block.setTitle(
                    request.title()
            );
        }

        if (request.content() != null) {
            block.setContent(
                    request.content()
            );
        }

        if (request.isPublished() != null) {
            block.setIsPublished(
                    request.isPublished()
            );
        }

        return blockMapper.toResponse(
                block
        );
    }

    @Transactional
    public void delete(
            Long blockId,
            User user
    ) {

        Block block =
                blockAccessService
                        .getEditableBlock(
                                blockId,
                                user
                        );

        Long lessonId =
                block.getLesson().getId();

        blockRepository.delete(
                block
        );

        normalizePositions(
                lessonId
        );
    }

    @Transactional
    public void reorder(
            Long lessonId,
            ReorderBlocksRequest request,
            User user
    ) {

        Lesson lesson =
                lessonAccessService
                        .getEditableLesson(
                                lessonId,
                                user
                        );

        List<Block> blocks =
                blockRepository
                        .findAllByLessonId(
                                lesson.getId()
                        );

        if (
                request.blockIds().size()
                        != blocks.size()
                        ||
                        request.blockIds()
                                .stream()
                                .distinct()
                                .count()
                                != blocks.size()
        ) {

            throw new ConflictException(
                    "Invalid block list"
            );
        }

        Map<Long, Block> blockMap =
                blocks.stream()
                        .collect(
                                Collectors.toMap(
                                        Block::getId,
                                        Function.identity()
                                )
                        );

        int position = 1;

        for (Long blockId : request.blockIds()) {

            Block block =
                    blockMap.get(
                            blockId
                    );

            if (block == null) {
                throw new NotFoundException(
                        "Block not found"
                );
            }

            block.setPosition(
                    position++
            );
        }
    }

    private void normalizePositions(
            Long lessonId
    ) {

        List<Block> blocks =
                blockRepository
                        .findAllByLessonIdOrderByPositionAsc(
                                lessonId
                        );

        int position = 1;

        for (Block block : blocks) {

            block.setPosition(
                    position++
            );
        }
    }
}
