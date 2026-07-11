package app.lms.ai.dashboard.faq.service;

import app.lms.ai.common.exception.AiServiceException;
import app.lms.ai.dashboard.faq.dto.GenerateCourseFaqRequest;
import app.lms.ai.dashboard.faq.dto.GeneratedCourseFaqResponse;
import app.lms.ai.dashboard.faq.dto.GeneratedFaqItem;
import app.lms.chapter.model.Chapter;
import app.lms.course.model.Course;
import app.lms.course.service.CourseAccessService;
import app.lms.faq.dto.CourseFaqResponse;
import app.lms.faq.model.CourseFaq;
import app.lms.faq.repository.CourseFaqRepository;
import app.lms.lesson.model.Lesson;
import app.lms.user.model.User;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

import java.util.Comparator;
import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class DashboardAiFaqService {

    private final ChatClient.Builder chatClientBuilder;
    private final DashboardAiFaqPromptService promptService;
    private final CourseAccessService courseAccessService;
    private final CourseFaqRepository courseFaqRepository;
    private final DashboardAiFaqAccessService  dashboardAiFaqAccessService;
    @Transactional
    public List<CourseFaqResponse> generate(
            Long courseId,
            GenerateCourseFaqRequest request,
            User user
    ) {

        Course course =
                courseAccessService.getEditableCourse(
                        courseId,
                        user
                );

        boolean regenerate =
                request.regenerate() != null
                        && request.regenerate();

        if (!regenerate && courseFaqRepository.existsByCourseId(courseId)) {
            return dashboardAiFaqAccessService.getFaqs(courseId, user);
        }

        Integer count =
                request.count() != null
                        ? request.count()
                        : 8;

        String outline =
                buildCourseOutline(course);

        try {
            ChatClient chatClient =
                    chatClientBuilder.build();

            GeneratedCourseFaqResponse response =
                    chatClient
                            .prompt()
                            .system(promptService.systemPrompt())
                            .user(promptService.buildPrompt(outline, count))
                            .call()
                            .entity(GeneratedCourseFaqResponse.class);

            validateResponse(response);

            courseFaqRepository.deleteAllByCourseId(
                    courseId
            );

            int position = 1;

            for (GeneratedFaqItem item : response.faqs()) {

                CourseFaq faq =
                        CourseFaq.builder()
                                .course(course)
                                .question(item.question().trim())
                                .answer(item.answer().trim())
                                .position(position++)
                                .build();

                courseFaqRepository.save(
                        faq
                );
            }

            return dashboardAiFaqAccessService.getFaqs(courseId, user);

        } catch (AiServiceException ex) {
            throw ex;

        } catch (Exception ex) {
            log.error("AI FAQ generation failed", ex);

            throw new AiServiceException(
                    "AI FAQ generation is currently unavailable",
                    HttpStatus.SERVICE_UNAVAILABLE,
                    ex
            );
        }
    }



    private String buildCourseOutline(
            Course course
    ) {

        StringBuilder builder =
                new StringBuilder();

        builder.append("Course: ")
                .append(course.getTitle())
                .append("\n\n");

        course.getChapters()
                .stream()
                .sorted(
                        Comparator.comparing(
                                Chapter::getPosition
                        )
                )
                .forEach(chapter -> {

                    builder.append("Chapter: ")
                            .append(chapter.getTitle())
                            .append("\n");

                    chapter.getLessons()
                            .stream()
                            .sorted(
                                    Comparator.comparing(
                                            Lesson::getPosition
                                    )
                            )
                            .forEach(lesson ->
                                    builder.append("- Lesson: ")
                                            .append(lesson.getTitle())
                                            .append("\n")
                            );

                    builder.append("\n");
                });

        return builder.toString();
    }

    private void validateResponse(
            GeneratedCourseFaqResponse response
    ) {

        if (
                response == null ||
                        response.faqs() == null ||
                        response.faqs().isEmpty()
        ) {
            throw new AiServiceException(
                    "AI returned empty FAQ list",
                    HttpStatus.SERVICE_UNAVAILABLE,
                    null
            );
        }

        for (GeneratedFaqItem item : response.faqs()) {

            if (
                    item.question() == null ||
                            item.question().isBlank() ||
                            item.answer() == null ||
                            item.answer().isBlank()
            ) {
                throw new AiServiceException(
                        "AI returned invalid FAQ item",
                        HttpStatus.SERVICE_UNAVAILABLE,
                        null
                );
            }
        }
    }

    public List<CourseFaqResponse> getFaqs(Long courseId, User user) {
        return dashboardAiFaqAccessService.getFaqs(courseId, user);
    }
}