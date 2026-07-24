package app.lms.analytics.course.dto;

import lombok.Builder;

@Builder
public record CourseOverviewResponse(

        long enrollmentsCount,

        long completedEnrollmentsCount,

        long activeEnrollmentsCount,

        long droppedEnrollmentsCount,

        long chaptersCount,

        long lessonsCount,

        long blocksCount,

        long questionsCount,

        long certificatesCount

) {}
