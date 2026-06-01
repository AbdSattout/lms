package app.lms.courceEnrollment.service;

import app.lms.courceEnrollment.enums.EnrollmentStatus;
import app.lms.courceEnrollment.model.CourseEnrollment;
import app.lms.courceEnrollment.repository.CourseEnrollmentRepository;
import app.lms.course.model.Course;
import app.lms.organization.model.Block;
import app.lms.organization.model.Progress;
import app.lms.organization.repository.BlockRepository;
import app.lms.organization.repository.ProgressRepository;
import app.lms.user.model.User;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class ProgressService {

    private final ProgressRepository progressRepository;

    private final BlockRepository blockRepository;

    private final CourseEnrollmentRepository
            enrollmentRepository;

    @Transactional
    public void completeBlock(

            Long blockId,
            boolean correct,
            User user
    ) {

        Block block =
                blockRepository.findById(blockId)
                        .orElseThrow(() ->
                                new IllegalStateException(
                                        "Block not found"
                                )
                        );

        Progress progress =
                progressRepository
                        .findByUserIdAndBlockId(
                                user.getId(),
                                blockId
                        )
                        .orElse(
                                Progress.builder()
                                        .user(user)
                                        .block(block)
                                        .attempts(0)
                                        .completed(false)
                                        .correct(false)
                                        .build()
                        );

        if (!correct) {

            progress.setAttempts(
                    progress.getAttempts() + 1
            );

            progressRepository.save(progress);

            return;
        }

        progress.setCompleted(true);
        progress.setCorrect(true);
        progress.setCompletedAt(
                LocalDateTime.now()
        );

        progressRepository.save(progress);

        Course course =
                block.getLesson()
                        .getChapter()
                        .getCourse();

        CourseEnrollment enrollment =
                enrollmentRepository
                        .findByUserIdAndCourseId(
                                user.getId(),
                                course.getId()
                        )
                        .orElseThrow();

        int percentage =
                calculateProgress(
                        course.getId(),
                        user.getId()
                );

        enrollment.setProgressPercentage(
                percentage
        );

        if (percentage == 100) {

            enrollment.setStatus(
                    EnrollmentStatus.COMPLETED
            );

            enrollment.setCompletedAt(
                    LocalDateTime.now()
            );

        }
    }

    private int calculateProgress(
            Long courseId,
            Long userId
    ) {

        long totalBlocks =
                blockRepository.countByCourseId(
                        courseId
                );

        long completedBlocks =
                progressRepository
                        .countCompletedBlocksByCourse(
                                courseId,
                                userId
                        );

        if (totalBlocks == 0) {
            return 0;
        }

        return (int)
                ((completedBlocks * 100)
                        / totalBlocks);
    }
}
