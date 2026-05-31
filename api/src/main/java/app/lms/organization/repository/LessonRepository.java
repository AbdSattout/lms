package app.lms.organization.repository;

import app.lms.organization.model.Lesson;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface LessonRepository
        extends JpaRepository<Lesson, Long> {

    List<Lesson>
    findAllByChapterIdOrderByPositionAsc(
            Long chapterId
    );
}
