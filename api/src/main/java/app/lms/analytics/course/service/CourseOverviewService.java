package app.lms.analytics.course.service;

import app.lms.analytics.course.dto.CourseOverviewResponse;
import app.lms.block.repository.BlockRepository;
import app.lms.certificate.repository.CertificateRepository;
import app.lms.chapter.repository.ChapterRepository;
import app.lms.enrollment.enums.EnrollmentStatus;
import app.lms.enrollment.repository.CourseEnrollmentRepository;
import app.lms.lesson.repository.LessonRepository;
import app.lms.organization.service.OrganizationAccessService;
import app.lms.question.repository.QuestionRepository;
import app.lms.user.model.User;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class CourseOverviewService {

    private final OrganizationAccessService organizationAccessService;

    private final CourseEnrollmentRepository courseEnrollmentRepository;

    private final ChapterRepository chapterRepository;

    private final LessonRepository lessonRepository;

    private final BlockRepository blockRepository;

    private final QuestionRepository questionRepository;

    private final CertificateRepository certificateRepository;


    public CourseOverviewResponse getOverview(
            String slug,
            Long courseId,
            User user
    ) {

        organizationAccessService
                .getManageableOrganization(
                        slug,
                        user
                );


        return CourseOverviewResponse
                .builder()

                .enrollmentsCount(
                        courseEnrollmentRepository.countByCourseId(courseId)
                )

                .activeEnrollmentsCount(
                        courseEnrollmentRepository.countByCourseIdAndStatus(
                                courseId,
                                EnrollmentStatus.ACTIVE
                        )
                )

                .completedEnrollmentsCount(
                        courseEnrollmentRepository.countByCourseIdAndStatus(
                                courseId,
                                EnrollmentStatus.COMPLETED
                        )
                )

                .droppedEnrollmentsCount(
                        courseEnrollmentRepository.countByCourseIdAndStatus(
                                courseId,
                                EnrollmentStatus.DROPPED
                        )
                )

                .chaptersCount(
                        chapterRepository.countByCourseId(
                                courseId
                        )
                )

                .lessonsCount(
                        lessonRepository.countByCourseId(
                                courseId
                        )
                )

                .blocksCount(
                        blockRepository.countByCourseId(
                                courseId
                        )
                )

                .questionsCount(
                        questionRepository.countByCourseId(
                                courseId
                        )
                )

                .certificatesCount(
                        certificateRepository.countByCourseId(
                                courseId
                        )
                )

                .build();

    }

}
