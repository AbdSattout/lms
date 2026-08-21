package app.lms.faq.service;

import app.lms.course.model.Course;
import app.lms.faq.dto.CourseFaqResponse;
import app.lms.faq.mapper.CourseFaqMapper;
import app.lms.faq.repository.CourseFaqRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.concurrent.ConcurrentHashMap;

@Service
@RequiredArgsConstructor
@Slf4j
public class CourseFaqProvider {

    private final CourseFaqRepository courseFaqRepository;
    private final CourseFaqMapper courseFaqMapper;
    private final CourseFaqAiGenerator courseFaqAiGenerator;

    private final ConcurrentHashMap<Long, Object> courseLocks =
            new ConcurrentHashMap<>();

    public List<CourseFaqResponse> getOrGenerate(
            Course course
    ) {

        List<CourseFaqResponse> stored =
                storedFaqs(course.getId());

        if (!stored.isEmpty()) {
            return stored;
        }

        Object lock =
                courseLocks.computeIfAbsent(
                        course.getId(),
                        key -> new Object()
                );

        synchronized (lock) {

            stored = storedFaqs(course.getId());

            if (!stored.isEmpty()) {
                return stored;
            }

            try {
                return courseFaqAiGenerator.generateFor(course);

            } catch (Exception ex) {
                log.error(
                        "Lazy FAQ generation failed for course {}",
                        course.getId(),
                        ex
                );

                return null;
            }
        }
    }

    private List<CourseFaqResponse> storedFaqs(
            Long courseId
    ) {

        return courseFaqRepository
                .findAllByCourseIdOrderByPositionAsc(courseId)
                .stream()
                .map(courseFaqMapper::toResponse)
                .toList();
    }
}
