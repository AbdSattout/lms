package app.lms.organization.repository;

import app.lms.organization.model.Chapter;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ChapterRepository
        extends JpaRepository<Chapter, Long> {

    List<Chapter>
    findAllByCourseIdOrderByPositionAsc(
            Long courseId
    );
}
