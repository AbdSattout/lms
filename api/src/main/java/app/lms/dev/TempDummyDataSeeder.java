package app.lms.dev;

import app.lms.LmsApplication;
import app.lms.block.model.Block;
import app.lms.block.repository.BlockRepository;
import app.lms.chapter.model.Chapter;
import app.lms.chapter.repository.ChapterRepository;
import app.lms.courceEnrollment.enums.EnrollmentStatus;
import app.lms.courceEnrollment.model.CourseEnrollment;
import app.lms.courceEnrollment.repository.CourseEnrollmentRepository;
import app.lms.course.enums.CourseStatus;
import app.lms.course.model.Course;
import app.lms.course.repository.CourseRepository;
import app.lms.gamification.service.GamificationService;
import app.lms.lesson.model.Lesson;
import app.lms.lesson.repository.LessonRepository;
import app.lms.organization.enums.Role;
import app.lms.organization.enums.Visibility;
import app.lms.organization.model.Organization;
import app.lms.organization.model.OrganizationMember;
import app.lms.organization.repository.OrganizationMemberRepository;
import app.lms.organization.repository.OrganizationRepository;
import app.lms.practiceExam.model.PracticeExam;
import app.lms.practiceExam.repository.PracticeExamRepository;
import app.lms.practiceQuiz.model.PracticeQuiz;
import app.lms.practiceQuiz.repository.PracticeQuizRepository;
import app.lms.question.enums.QuestionDifficulty;
import app.lms.question.model.Question;
import app.lms.question.repository.QuestionRepository;
import app.lms.quiz.model.Quiz;
import app.lms.quiz.repository.QuizRepository;
import app.lms.user.model.User;
import app.lms.user.repository.UserRepository;
import org.springframework.boot.WebApplicationType;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;

/**
 * Temporary dev seeder. Run manually; it is not a normal application startup bean.
 */
@Component
public class TempDummyDataSeeder {

    private static final Long STUDENT_USER_ID = 900000L;
    private static final Long OWNER_USER_ID = 900001L;
    private static final String ORGANIZATION_SLUG = "dummy-gamification-org";
    private static final String COURSE_SLUG = "dummy-gamification-course";

    private final UserRepository userRepository;
    private final OrganizationRepository organizationRepository;
    private final OrganizationMemberRepository organizationMemberRepository;
    private final CourseRepository courseRepository;
    private final ChapterRepository chapterRepository;
    private final LessonRepository lessonRepository;
    private final QuestionRepository questionRepository;
    private final BlockRepository blockRepository;
    private final QuizRepository quizRepository;
    private final PracticeQuizRepository practiceQuizRepository;
    private final PracticeExamRepository practiceExamRepository;
    private final CourseEnrollmentRepository enrollmentRepository;
    private final GamificationService gamificationService;
    private final JdbcTemplate jdbcTemplate;

    public TempDummyDataSeeder(
            UserRepository userRepository,
            OrganizationRepository organizationRepository,
            OrganizationMemberRepository organizationMemberRepository,
            CourseRepository courseRepository,
            ChapterRepository chapterRepository,
            LessonRepository lessonRepository,
            QuestionRepository questionRepository,
            BlockRepository blockRepository,
            QuizRepository quizRepository,
            PracticeQuizRepository practiceQuizRepository,
            PracticeExamRepository practiceExamRepository,
            CourseEnrollmentRepository enrollmentRepository,
            GamificationService gamificationService,
            JdbcTemplate jdbcTemplate
    ) {
        this.userRepository = userRepository;
        this.organizationRepository = organizationRepository;
        this.organizationMemberRepository = organizationMemberRepository;
        this.courseRepository = courseRepository;
        this.chapterRepository = chapterRepository;
        this.lessonRepository = lessonRepository;
        this.questionRepository = questionRepository;
        this.blockRepository = blockRepository;
        this.quizRepository = quizRepository;
        this.practiceQuizRepository = practiceQuizRepository;
        this.practiceExamRepository = practiceExamRepository;
        this.enrollmentRepository = enrollmentRepository;
        this.gamificationService = gamificationService;
        this.jdbcTemplate = jdbcTemplate;
    }

    public static void main(
            String[] args
    ) {

        try (ConfigurableApplicationContext context =
                     new SpringApplicationBuilder(LmsApplication.class)
                             .web(WebApplicationType.NONE)
                             .run(args)) {

            context.getBean(TempDummyDataSeeder.class)
                    .seed();
        }
    }

    @Transactional
    public void seed() {

        User student =
                upsertUser(
                        STUDENT_USER_ID,
                        "dummy-student-1",
                        "Dummy Student"
                );

        User owner =
                upsertUser(
                        OWNER_USER_ID,
                        "dummy-owner-900001",
                        "Dummy Owner"
                );

        Organization organization =
                upsertOrganization(owner);

        upsertOrganizationMember(
                organization,
                owner,
                Role.OWNER
        );

        upsertOrganizationMember(
                organization,
                student,
                Role.STUDENT
        );

        Course course =
                upsertCourse(organization);

        Chapter chapterOne =
                upsertChapter(
                        course,
                        "Dummy Chapter 1 - Foundations",
                        1
                );

        Chapter chapterTwo =
                upsertChapter(
                        course,
                        "Dummy Chapter 2 - Practice",
                        2
                );

        Lesson lessonOne =
                upsertLesson(
                        chapterOne,
                        "Dummy Lesson 1 - XP Basics"
                );

        Lesson lessonTwo =
                upsertLesson(
                        chapterTwo,
                        "Dummy Lesson 2 - Leveling Up"
                );

        List<Question> questions =
                upsertQuestions(course);

        Block firstBlock =
                upsertBlock(
                        lessonOne,
                        "Dummy Block 1 - What XP Means",
                        "XP is earned from meaningful learning actions.",
                        questions.get(0),
                        1
                );

        Block secondBlock =
                upsertBlock(
                        lessonOne,
                        "Dummy Block 2 - Why Levels Matter",
                        "Levels turn XP into visible long-term progress.",
                        questions.get(1),
                        2
                );

        Block thirdBlock =
                upsertBlock(
                        lessonTwo,
                        "Dummy Block 3 - Quizzes",
                        "Quizzes validate learning and can award XP.",
                        questions.get(2),
                        1
                );

        upsertPracticeQuiz(
                course,
                questions
        );

        upsertPracticeExam(
                course,
                questions
        );

        upsertFinalQuiz(
                course,
                questions
        );

        course.setStatus(CourseStatus.PUBLISHED);
        courseRepository.save(course);

        CourseEnrollment enrollment =
                enrollmentRepository
                        .findByUserIdAndCourseId(
                                student.getId(),
                                course.getId()
                        )
                        .orElseGet(() ->
                                CourseEnrollment.builder()
                                        .user(student)
                                        .course(course)
                                        .status(EnrollmentStatus.ACTIVE)
                                        .progressPercentage(0)
                                        .lastAccessedLesson(lessonOne)
                                        .lastAccessedBlock(firstBlock)
                                        .build()
                        );

        enrollment.setStatus(EnrollmentStatus.ACTIVE);
        enrollment.setLastAccessedLesson(lessonOne);
        enrollment.setLastAccessedBlock(firstBlock);
        enrollmentRepository.save(enrollment);

        gamificationService.getProgress(student);

        System.out.println();
        System.out.println("Dummy LMS data seeded.");
        System.out.println("studentUserId=" + student.getId());
        System.out.println("ownerUserId=" + owner.getId());
        System.out.println("organizationId=" + organization.getId());
        System.out.println("organizationSlug=" + organization.getSlug());
        System.out.println("courseId=" + course.getId());
        System.out.println("courseSlug=" + course.getSlug());
        System.out.println("chapterOneId=" + chapterOne.getId());
        System.out.println("chapterTwoId=" + chapterTwo.getId());
        System.out.println("lessonOneId=" + lessonOne.getId());
        System.out.println("lessonTwoId=" + lessonTwo.getId());
        System.out.println("blockIds=" + List.of(
                firstBlock.getId(),
                secondBlock.getId(),
                thirdBlock.getId()
        ));
        System.out.println("questionIds=" + questions.stream()
                .map(Question::getId)
                .toList());
        System.out.println();
    }

    private User upsertUser(
            Long id,
            String telegramId,
            String name
    ) {

        if (userRepository.findById(id).isEmpty()) {
            jdbcTemplate.update(
                    """
                            insert into users (
                                id,
                                name,
                                telegram_id,
                                picture,
                                picture_file_id
                            )
                            values (?, ?, ?, null, null)
                            """,
                    id,
                    name,
                    telegramId
            );
        }

        User user =
                userRepository.findById(id)
                        .orElseThrow();

        user.setTelegramId(telegramId);
        user.setName(name);
        user.setPicture(null);
        user.setPictureFileId(null);

        return userRepository.save(user);
    }

    private Organization upsertOrganization(
            User owner
    ) {

        Organization organization =
                organizationRepository
                        .findBySlug(ORGANIZATION_SLUG)
                        .orElseGet(Organization::new);

        organization.setName("Dummy Gamification Organization");
        organization.setSlug(ORGANIZATION_SLUG);
        organization.setDescription("Seeded organization for dummy course data.");
        organization.setVisibility(Visibility.PUBLIC);
        organization.setOwner(owner);

        return organizationRepository.save(organization);
    }

    private void upsertOrganizationMember(
            Organization organization,
            User user,
            Role role
    ) {

        OrganizationMember member =
                organizationMemberRepository
                        .findByOrganizationIdAndUserId(
                                organization.getId(),
                                user.getId()
                        )
                        .orElseGet(OrganizationMember::new);

        member.setOrganization(organization);
        member.setUser(user);
        member.setRole(role);

        organizationMemberRepository.save(member);
    }

    private Course upsertCourse(
            Organization organization
    ) {

        Course course =
                courseRepository
                        .findByOrganizationIdAndSlug(
                                organization.getId(),
                                COURSE_SLUG
                        )
                        .orElseGet(Course::new);

        course.setTitle("Dummy Gamification Course");
        course.setSlug(COURSE_SLUG);
        course.setDescription("Seeded course with chapters, lessons, blocks, questions, and quizzes.");
        course.setOrganization(organization);
        course.setStatus(CourseStatus.DRAFT);

        return courseRepository.save(course);
    }

    private Chapter upsertChapter(
            Course course,
            String title,
            Integer position
    ) {

        return chapterRepository
                .findAllByCourseId(course.getId())
                .stream()
                .filter(chapter -> position.equals(chapter.getPosition()))
                .findFirst()
                .map(chapter -> {
                    chapter.setTitle(title);
                    return chapterRepository.save(chapter);
                })
                .orElseGet(() ->
                        chapterRepository.save(
                                Chapter.builder()
                                        .course(course)
                                        .title(title)
                                        .position(position)
                                        .build()
                        )
                );
    }

    private Lesson upsertLesson(
            Chapter chapter,
            String title
    ) {

        return lessonRepository
                .findAllByChapterId(chapter.getId())
                .stream()
                .filter(lesson -> ((Integer) 1).equals(lesson.getPosition()))
                .findFirst()
                .map(lesson -> {
                    lesson.setTitle(title);
                    return lessonRepository.save(lesson);
                })
                .orElseGet(() ->
                        lessonRepository.save(
                                Lesson.builder()
                                        .chapter(chapter)
                                        .title(title)
                                        .position(1)
                                        .build()
                        )
                );
    }

    private List<Question> upsertQuestions(
            Course course
    ) {

        List<Question> existing =
                questionRepository.findAllByCourseIdOrderByIdDesc(
                        course.getId()
                );

        List<Question> questions =
                new ArrayList<>(existing);

        for (int index = questions.size(); index < 10; index++) {
            int correctIndex =
                    index % 3;

            questions.add(
                    questionRepository.save(
                            Question.builder()
                                    .course(course)
                                    .content("Dummy final quiz question " + (index + 1) + "?")
                                    .options(List.of(
                                            "Option A",
                                            "Option B",
                                            "Option C"
                                    ))
                                    .correctAnswerIndex(correctIndex)
                                    .difficulty(QuestionDifficulty.EASY)
                                    .build()
                    )
            );
        }

        return questions.stream()
                .sorted(Comparator.comparing(Question::getId))
                .limit(10)
                .toList();
    }

    private Block upsertBlock(
            Lesson lesson,
            String title,
            String content,
            Question question,
            Integer position
    ) {

        return blockRepository
                .findAllByLessonId(lesson.getId())
                .stream()
                .filter(block -> position.equals(block.getPosition()))
                .findFirst()
                .map(block -> {
                    block.setTitle(title);
                    block.setContent(content);
                    block.setQuestion(question);
                    return blockRepository.save(block);
                })
                .orElseGet(() ->
                        blockRepository.save(
                                Block.builder()
                                        .lesson(lesson)
                                        .title(title)
                                        .content(content)
                                        .question(question)
                                        .position(position)
                                        .build()
                        )
                );
    }

    private void upsertPracticeQuiz(
            Course course,
            List<Question> questions
    ) {

        PracticeQuiz practiceQuiz =
                practiceQuizRepository
                        .findAllByCourseIdOrderByCreatedAtDesc(
                                course.getId()
                        )
                        .stream()
                        .filter(quiz -> "Dummy Practice Quiz".equals(quiz.getTitle()))
                        .findFirst()
                        .orElseGet(PracticeQuiz::new);

        practiceQuiz.setCourse(course);
        practiceQuiz.setTitle("Dummy Practice Quiz");
        practiceQuiz.setDescription("Seeded practice quiz.");
        practiceQuiz.getQuestions().clear();
        practiceQuiz.getQuestions().addAll(
                questions.subList(0, 3)
        );

        practiceQuizRepository.save(practiceQuiz);
    }

    private void upsertPracticeExam(
            Course course,
            List<Question> questions
    ) {

        PracticeExam practiceExam =
                practiceExamRepository
                        .findAllByCourseIdOrderByCreatedAtDesc(
                                course.getId()
                        )
                        .stream()
                        .filter(exam -> "Dummy Practice Exam".equals(exam.getTitle()))
                        .findFirst()
                        .orElseGet(PracticeExam::new);

        practiceExam.setCourse(course);
        practiceExam.setTitle("Dummy Practice Exam");
        practiceExam.setDescription("Seeded practice exam.");
        practiceExam.getQuestions().clear();
        practiceExam.getQuestions().addAll(
                questions.subList(0, 5)
        );

        practiceExamRepository.save(practiceExam);
    }

    private void upsertFinalQuiz(
            Course course,
            List<Question> questions
    ) {

        Quiz quiz =
                quizRepository
                        .findByCourseId(course.getId())
                        .orElseGet(Quiz::new);

        quiz.setCourse(course);
        quiz.setTitle("Dummy Final Quiz");
        quiz.getQuestions().clear();
        quiz.getQuestions().addAll(questions);

        quizRepository.save(quiz);
    }
}
