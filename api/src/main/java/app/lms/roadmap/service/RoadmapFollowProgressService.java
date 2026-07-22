package app.lms.roadmap.service;

import app.lms.course.enums.CourseStatus;
import app.lms.enrollment.enums.EnrollmentStatus;
import app.lms.roadmap.enums.RoadmapFollowStatus;
import app.lms.roadmap.model.Roadmap;
import app.lms.roadmap.model.RoadmapFollower;
import app.lms.roadmap.repository.RoadmapFollowerRepository;
import app.lms.roadmap.repository.RoadmapRepository;
import app.lms.user.model.User;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class RoadmapFollowProgressService {

    private final RoadmapRepository roadmapRepository;
    private final RoadmapFollowerRepository roadmapFollowerRepository;

    @Transactional
    public void refreshForCourse(
            Long courseId,
            User user
    ) {

        roadmapRepository
                .findAllByCourseId(courseId)
                .forEach(roadmap ->
                        refresh(
                                roadmap,
                                user
                        )
                );
    }

    @Transactional
    public void refresh(
            Roadmap roadmap,
            User user
    ) {

        RoadmapFollower follower =
                roadmapFollowerRepository
                        .findByRoadmapIdAndUserId(
                                roadmap.getId(),
                                user.getId()
                        )
                        .orElse(null);

        if (follower == null) {
            return;
        }

        RoadmapFollowStatus status =
                completed(
                        roadmap.getId(),
                        user.getId()
                )
                        ? RoadmapFollowStatus.COMPLETED
                        : RoadmapFollowStatus.ACTIVE;

        if (follower.getStatus() != status) {
            follower.setStatus(status);
        }
    }

    private boolean completed(
            Long roadmapId,
            Long userId
    ) {

        long publishedCourses =
                roadmapRepository.countCoursesByStatus(
                        roadmapId,
                        CourseStatus.PUBLISHED
                );

        if (publishedCourses == 0) {
            return false;
        }

        return roadmapRepository
                .countIncompleteCoursesForUser(
                        roadmapId,
                        userId,
                        CourseStatus.PUBLISHED,
                        EnrollmentStatus.COMPLETED
                )
                == 0;
    }
}
