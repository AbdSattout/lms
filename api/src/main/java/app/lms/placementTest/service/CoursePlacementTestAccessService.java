package app.lms.placementTest.service;

import app.lms.common.exception.ConflictException;
import app.lms.placementTest.model.CoursePlacementTestAttempt;
import app.lms.placementTest.repository.CoursePlacementTestAttemptRepository;
import app.lms.user.model.User;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class CoursePlacementTestAccessService {

    private final CoursePlacementTestAttemptRepository placementTestAttemptRepository;

    public void validateCompletedOrSkipped(
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
                    "Go to placement test before opening this course"
            );
        }

        if (!Boolean.TRUE.equals(attempt.getCompleted())) {
            throw new ConflictException(
                    "Finish or skip the placement test before opening this course"
            );
        }
    }
}
