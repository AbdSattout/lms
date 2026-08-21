package app.lms.ai.dashboard.faq.service;


import app.lms.course.service.CourseAccessService;
import app.lms.faq.dto.CourseFaqResponse;
import app.lms.faq.mapper.CourseFaqMapper;
import app.lms.faq.repository.CourseFaqRepository;
import app.lms.user.model.User;
import jakarta.transaction.Transactional;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class DashboardAiFaqAccessService {

    CourseAccessService courseAccessService;
    CourseFaqRepository courseFaqRepository;
    CourseFaqMapper courseFaqMapper;
    @Transactional
    public List<CourseFaqResponse> getFaqs(
            Long courseId,
            User user
    ) {

        courseAccessService.getManageableCourse(
                courseId,
                user
        );

        return getStoredFaqs(
                courseId
        );
    }

    public boolean hasFaqs(Long courseId) {
        return courseFaqRepository.existsByCourseId(courseId);
    }

    private List<CourseFaqResponse> getStoredFaqs(
            Long courseId
    ) {

        return courseFaqRepository
                .findAllByCourseIdOrderByPositionAsc(
                        courseId
                )
                .stream()
                .map(
                        courseFaqMapper::toResponse
                )
                .toList();
    }
}
