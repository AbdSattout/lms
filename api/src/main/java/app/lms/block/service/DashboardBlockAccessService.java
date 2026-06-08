package app.lms.block.service;

import app.lms.block.model.Block;
import app.lms.block.repository.BlockRepository;
import app.lms.common.exception.NotFoundException;
import app.lms.course.service.CourseAccessService;
import app.lms.user.model.User;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class DashboardBlockAccessService {

    private final BlockRepository blockRepository;
    private final CourseAccessService courseAccessService;

    public Block getEditableBlock(
            Long blockId,
            User user
    ) {

        Block block =
                blockRepository
                        .findById(blockId)
                        .orElseThrow(
                                () -> new NotFoundException(
                                        "Block not found"
                                )
                        );

        Long courseId =
                block.getLesson()
                        .getChapter()
                        .getCourse()
                        .getId();

        courseAccessService
                .getEditableCourse(
                        courseId,
                        user
                );

        return block;
    }

    public Block getManageableBlock(
            Long blockId,
            User user
    ) {

        Block block =
                blockRepository.findById(blockId)
                        .orElseThrow(() ->
                                new NotFoundException("Block not found")
                        );

        Long courseId = block.getLesson()
                .getChapter()
                .getCourse()
                .getId();

        courseAccessService.getManageableCourse(courseId, user);

        return block;
    }

}
