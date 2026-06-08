package app.lms.block.service;

import app.lms.block.dto.BlockResponse;
import app.lms.block.dto.CreateBlockRequest;
import app.lms.block.dto.ReorderBlocksRequest;
import app.lms.block.dto.UpdateBlockRequest;
import app.lms.block.mapper.BlockMapper;
import app.lms.block.model.Block;
import app.lms.block.repository.BlockRepository;
import app.lms.common.exception.BadRequestException;
import app.lms.common.exception.ConflictException;
import app.lms.common.exception.NotFoundException;
import app.lms.lesson.model.Lesson;
import app.lms.lesson.service.LessonAccessService;
import app.lms.question.dto.CreateQuestionRequest;
import app.lms.question.model.Question;
import app.lms.user.model.User;
import jakarta.transaction.Transactional;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

@Service
public class DashboardBlockService {

    BlockRepository blockRepository;
    LessonAccessService lessonAccessService;
    BlockMapper blockMapper;
    BlockAccessService blockAccessService;
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

        Question question =
                buildQuestion(request);

        Block block =
                buildBlock(
                        request,
                        lesson,
                        position,
                        question
                );


        question.setBlock(block);
        block.setQuestion(question);




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
                    request.title().trim()
            );
        }

        if (request.content() != null) {
            block.setContent(
                    request.content()
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

    private Question buildQuestion(
            CreateBlockRequest request
    ) {

        CreateQuestionRequest questionRequest =
                request.question();

        if (questionRequest == null) {
            throw new BadRequestException(
                    "Question is required"
            );
        }

        if (
                questionRequest.correctAnswerIndex()
                        >= questionRequest.options().size()
        ) {
            throw new BadRequestException(
                    "Invalid correct answer index"
            );
        }

        return Question.builder()
                .content(
                        questionRequest.content().trim()
                )
                .options(
                        questionRequest.options()
                )
                .correctAnswerIndex(
                        questionRequest.correctAnswerIndex()
                )
                .build();
    }

    private Block buildBlock(
            CreateBlockRequest request,
            Lesson lesson,
            Integer position,
            Question question
    ) {


        return Block.builder()
                .title(request.title().trim())
                .content(request.content())
                .position(position)
                .lesson(lesson)
                .question(question)
                .build();
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

    public BlockResponse getBlock(Long blockId, User user) {

        Block block =  blockAccessService.getManageableBlock(blockId, user);

          return  blockMapper.toResponse(block);

    }
}
