package app.lms.faq.repository;

import app.lms.faq.model.CourseFaq;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface CourseFaqRepository extends JpaRepository<CourseFaq, Long> {

    List<CourseFaq> findAllByCourseIdOrderByPositionAsc(Long courseId);

    boolean existsByCourseId(Long courseId);

    void deleteAllByCourseId(Long courseId);
}