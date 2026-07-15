package app.lms.block.service;

import app.lms.block.dto.*;
import app.lms.block.mapper.BlockMapper;
import app.lms.block.model.Block;
import app.lms.common.exception.ConflictException;
import app.lms.courceEnrollment.model.CourseEnrollment;
import app.lms.courceEnrollment.service.CourseEnrollmentAccessService;
import app.lms.placementTest.model.CoursePlacementTestAttempt;
import app.lms.placementTest.repository.CoursePlacementTestAttemptRepository;
import app.lms.progress.model.BlockProgress;
import app.lms.progress.repository.BlockProgressRepository;
import app.lms.user.model.User;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;



@Service
@RequiredArgsConstructor
public class BlockService {


    private final BlockMapper blockMapper;
    private final BlockAccessService blockAccessService;
    private final CourseEnrollmentAccessService courseEnrollmentAccessService;
    private final CoursePlacementTestAttemptRepository placementTestAttemptRepository;
    private final BlockProgressRepository blockProgressRepository;

    @Transactional
    public BlockPublicResponse getBlock(Long blockId, User user) {
        Block block = blockAccessService.getAccessibleBlock(blockId, user);
        validateCanOpenBlock(block, user);
        return blockMapper.toPublicResponse(block);
    }

    private void validateCanOpenBlock(
            Block block,
            User user
    ) {

        Long courseId =
                block.getLesson()
                        .getChapter()
                        .getCourse()
                        .getId();

        CourseEnrollment enrollment =
                courseEnrollmentAccessService.getEnrollment(
                        courseId,
                        user
                );

        if (enrollment.getCurrentBlock() == null) {
            validatePlacementChoiceMade(
                    courseId,
                    user
            );
            return;
        }

        if (
                enrollment.getCurrentBlock()
                        .getId()
                        .equals(
                                block.getId()
                        )
        ) {
            return;
        }

        BlockProgress progress =
                blockProgressRepository
                        .findByUserIdAndBlockId(
                                user.getId(),
                                block.getId()
                        )
                        .orElse(null);

        if (
                progress != null &&
                        Boolean.TRUE.equals(
                                progress.getCompleted()
                        )
        ) {
            return;
        }

        throw new ConflictException(
                "You cannot open this block yet"
        );
    }

    private void validatePlacementChoiceMade(
            Long courseId,
            User user
    ) {

        CoursePlacementTestAttempt attempt =
                placementTestAttemptRepository
                        .findByCourseIdAndUserId(
                                courseId,
                                user.getId()
                        )
                        .orElse(null);

        if (attempt == null) {
            throw new ConflictException(
                    "Choose placement test or skip it before opening course blocks"
            );
        }

        if (!Boolean.TRUE.equals(attempt.getCompleted())) {
            throw new ConflictException(
                    "Finish or skip the placement test before opening course blocks"
            );
        }
    }
}
