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
import app.lms.question.model.Question;
import app.lms.question.service.QuestionAccessService;
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
public class DashboardBlockService {

    private final BlockRepository blockRepository;
    private final LessonAccessService lessonAccessService;
    private final BlockMapper blockMapper;
    private final BlockAccessService blockAccessService;
    private final QuestionAccessService questionAccessService;

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

        Question question =
                questionAccessService
                        .getEditableQuestion(
                                request.questionId(),
                                user
                        );

        validateQuestionBelongsToSameCourse(
                lesson,
                question
        );

        Integer position =
                blockRepository
                        .findMaxPositionByLessonId(
                                lessonId
                        )
                        .orElse(0) + 1;

        Block block =
                Block.builder()
                        .title(request.title().trim())
                        .content(request.content())
                        .position(position)
                        .lesson(lesson)
                        .question(question)
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
                    request.title().trim()
            );
        }

        if (request.content() != null) {
            block.setContent(
                    request.content()
            );
        }

        if (request.questionId() != null) {

            Question question =
                    questionAccessService
                            .getManageableQuestion(
                                    request.questionId(),
                                    user
                            );

            validateQuestionBelongsToSameCourse(
                    block.getLesson(),
                    question
            );

            block.setQuestion(
                    question
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

    @Transactional
    public BlockResponse getBlock(
            Long blockId,
            User user
    ) {

        Block block =
                blockAccessService
                        .getManageableBlock(
                                blockId,
                                user
                        );

        return blockMapper.toResponse(
                block
        );
    }

    private void validateQuestionBelongsToSameCourse(
            Lesson lesson,
            Question question
    ) {

        Long lessonCourseId =
                lesson.getChapter()
                        .getCourse()
                        .getId();

        Long questionCourseId =
                question.getCourse()
                        .getId();

        if (!lessonCourseId.equals(questionCourseId)) {
            throw new BadRequestException(
                    "Question must belong to the same course as the lesson"
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