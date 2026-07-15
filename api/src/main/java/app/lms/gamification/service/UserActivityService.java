package app.lms.gamification.service;

import app.lms.common.dto.BaseEntityResponse;
import app.lms.gamification.dto.UserActivityDayResponse;
import app.lms.gamification.dto.UserStreakResponse;
import app.lms.gamification.enums.XPEventType;
import app.lms.gamification.model.UserActivityDay;
import app.lms.gamification.repository.UserActivityDayRepository;
import app.lms.user.model.User;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;

@Service
@RequiredArgsConstructor
public class UserActivityService {

    private final UserActivityDayRepository userActivityDayRepository;

    @Transactional
    public void recordAward(
            User user,
            XPEventType type,
            Integer xpAwarded
    ) {

        LocalDate today =
                LocalDate.now();

        UserActivityDay activityDay =
                userActivityDayRepository
                        .findByUserIdAndActivityDate(
                                user.getId(),
                                today
                        )
                        .orElseGet(() ->
                                createActivityDay(
                                        user,
                                        today
                                )
                        );

        activityDay.setXpEarned(
                activityDay.getXpEarned() + xpAwarded
        );

        incrementEventCounter(
                activityDay,
                type
        );

        userActivityDayRepository.save(
                activityDay
        );
    }

    public List<UserActivityDayResponse> getActivity(
            User user,
            LocalDate from,
            LocalDate to
    ) {

        LocalDate resolvedTo =
                to != null
                        ? to
                        : LocalDate.now();

        LocalDate resolvedFrom =
                from != null
                        ? from
                        : resolvedTo.minusDays(364);

        return userActivityDayRepository
                .findAllByUserIdAndActivityDateBetweenOrderByActivityDateAsc(
                        user.getId(),
                        resolvedFrom,
                        resolvedTo
                )
                .stream()
                .map(this::toResponse)
                .toList();
    }

    public UserStreakResponse getStreak(
            User user
    ) {

        List<UserActivityDay> activityDays =
                userActivityDayRepository
                        .findAllByUserIdOrderByActivityDateAsc(
                                user.getId()
                        );

        int longestStreak =
                calculateLongestStreak(
                        activityDays
                );

        int currentStreak =
                calculateCurrentStreak(
                        activityDays
                );

        LocalDate lastActiveDate =
                activityDays.isEmpty()
                        ? null
                        : activityDays
                                .getLast()
                                .getActivityDate();

        return UserStreakResponse.builder()
                .currentStreak(currentStreak)
                .longestStreak(longestStreak)
                .activeDays(activityDays.size())
                .lastActiveDate(lastActiveDate)
                .build();
    }

    private UserActivityDay createActivityDay(
            User user,
            LocalDate activityDate
    ) {

        return UserActivityDay.builder()
                .user(user)
                .activityDate(activityDate)
                .xpEarned(0)
                .completedBlocks(0)
                .completedLessons(0)
                .completedChapters(0)
                .completedCourses(0)
                .completedPracticeQuizzes(0)
                .completedFinalQuizzes(0)
                .completedQuizzes(0)
                .correctQuestions(0)
                .enrollments(0)
                .build();
    }

    private void incrementEventCounter(
            UserActivityDay activityDay,
            XPEventType type
    ) {

        switch (type) {
            case COURSE_ENROLL ->
                    activityDay.setEnrollments(
                            activityDay.getEnrollments() + 1
                    );
            case BLOCK_COMPLETE ->
                    activityDay.setCompletedBlocks(
                            activityDay.getCompletedBlocks() + 1
                    );
            case LESSON_COMPLETE ->
                    activityDay.setCompletedLessons(
                            activityDay.getCompletedLessons() + 1
                    );
            case CHAPTER_COMPLETE ->
                    activityDay.setCompletedChapters(
                            activityDay.getCompletedChapters() + 1
                    );
            case COURSE_COMPLETE ->
                    activityDay.setCompletedCourses(
                            activityDay.getCompletedCourses() + 1
                    );
            case PRACTICE_QUIZ_COMPLETE ->
                    activityDay.setCompletedPracticeQuizzes(
                            activityDay.getCompletedPracticeQuizzes() + 1
                    );
            case FINAL_QUIZ_COMPLETE ->
                    activityDay.setCompletedFinalQuizzes(
                            activityDay.getCompletedFinalQuizzes() + 1
                    );
            case QUIZ_COMPLETE ->
                    activityDay.setCompletedQuizzes(
                            activityDay.getCompletedQuizzes() + 1
                    );
            case QUESTION_CORRECT ->
                    activityDay.setCorrectQuestions(
                            activityDay.getCorrectQuestions() + 1
                    );
            case DAILY_STREAK -> {
            }
        }
    }

    private UserActivityDayResponse toResponse(
            UserActivityDay activityDay
    ) {

        return UserActivityDayResponse.builder()
                .date(activityDay.getActivityDate())
                .xpEarned(activityDay.getXpEarned())
                .completedBlocks(activityDay.getCompletedBlocks())
                .completedLessons(activityDay.getCompletedLessons())
                .completedChapters(activityDay.getCompletedChapters())
                .completedCourses(activityDay.getCompletedCourses())
                .completedPracticeQuizzes(
                        activityDay.getCompletedPracticeQuizzes()
                )
                .completedFinalQuizzes(
                        activityDay.getCompletedFinalQuizzes()
                )
                .completedQuizzes(activityDay.getCompletedQuizzes())
                .correctQuestions(activityDay.getCorrectQuestions())
                .enrollments(activityDay.getEnrollments())
                .totalActions(
                        calculateTotalActions(activityDay)
                )
                .baseEntity(
                        BaseEntityResponse.from(activityDay)
                )
                .build();
    }

    private int calculateTotalActions(
            UserActivityDay activityDay
    ) {

        return activityDay.getCompletedBlocks()
                + activityDay.getCompletedLessons()
                + activityDay.getCompletedChapters()
                + activityDay.getCompletedCourses()
                + activityDay.getCompletedPracticeQuizzes()
                + activityDay.getCompletedFinalQuizzes()
                + activityDay.getCompletedQuizzes()
                + activityDay.getCorrectQuestions()
                + activityDay.getEnrollments();
    }

    private int calculateLongestStreak(
            List<UserActivityDay> activityDays
    ) {

        int longestStreak = 0;
        int currentStreak = 0;
        LocalDate previousDate = null;

        for (UserActivityDay activityDay : activityDays) {
            LocalDate currentDate =
                    activityDay.getActivityDate();

            if (
                    previousDate == null ||
                            currentDate.equals(
                                    previousDate.plusDays(1)
                            )
            ) {
                currentStreak++;
            } else {
                currentStreak = 1;
            }

            longestStreak =
                    Math.max(
                            longestStreak,
                            currentStreak
                    );

            previousDate = currentDate;
        }

        return longestStreak;
    }

    private int calculateCurrentStreak(
            List<UserActivityDay> activityDays
    ) {

        if (activityDays.isEmpty()) {
            return 0;
        }

        LocalDate expectedDate =
                LocalDate.now();

        int currentStreak = 0;

        for (int index = activityDays.size() - 1; index >= 0; index--) {
            LocalDate activityDate =
                    activityDays
                            .get(index)
                            .getActivityDate();

            if (!activityDate.equals(expectedDate)) {
                break;
            }

            currentStreak++;
            expectedDate =
                    expectedDate.minusDays(1);
        }

        return currentStreak;
    }
}
