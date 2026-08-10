package app.lms.course.service;

import app.lms.block.repository.BlockRepository;
import app.lms.chapter.repository.ChapterRepository;
import app.lms.common.quiz.service.QuizDifficultyService;
import app.lms.course.dto.CourseLearningSummary;
import app.lms.gamification.service.LearningXpPolicy;
import app.lms.question.enums.QuestionDifficulty;
import app.lms.quiz.repository.QuizRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class CourseLearningSummaryService {

    private final ChapterRepository chapterRepository;
    private final BlockRepository blockRepository;
    private final QuizRepository quizRepository;
    private final QuizDifficultyService quizDifficultyService;

    public CourseLearningSummary summarize(
            Long courseId
    ) {

        long chaptersCount =
                chapterRepository.countByCourseId(
                        courseId
                );

        long rewardableLessonsCount =
                blockRepository.countLessonsWithBlocksByCourseId(
                        courseId
                );

        long rewardableChaptersCount =
                blockRepository.countChaptersWithBlocksByCourseId(
                        courseId
                );

        List<QuestionDifficulty> blockDifficulties =
                blockRepository.findQuestionDifficultiesByCourseId(
                        courseId
                );

        int lessonCompletionXp =
                Math.toIntExact(rewardableLessonsCount)
                        * LearningXpPolicy.LESSON_COMPLETE_XP;

        int chapterCompletionXp =
                Math.toIntExact(rewardableChaptersCount)
                        * LearningXpPolicy.CHAPTER_COMPLETE_XP;

        int completionXp =
                blockCompletionXpFor(blockDifficulties)
                        + lessonCompletionXp
                        + chapterCompletionXp
                        + finalQuizCompletionXpFor(courseId);

        return new CourseLearningSummary(
                quizDifficultyService.calculate(
                        blockDifficulties,
                        difficulty -> difficulty
                ),
                completionXp,
                chaptersCount
        );
    }

    private int blockCompletionXpFor(
            List<QuestionDifficulty> blockDifficulties
    ) {

        return blockDifficulties
                .stream()
                .mapToInt(
                        LearningXpPolicy::maxBlockCompleteXpFor
                )
                .sum();
    }

    private int finalQuizCompletionXpFor(
            Long courseId
    ) {

        if (quizRepository.countQuestionsByCourseId(courseId) == 0) {
            return 0;
        }

        return LearningXpPolicy.FINAL_QUIZ_COMPLETE_XP
                + LearningXpPolicy.COURSE_COMPLETE_XP;
    }
}
