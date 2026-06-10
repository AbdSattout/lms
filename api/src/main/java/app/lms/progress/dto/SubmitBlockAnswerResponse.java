package app.lms.progress.dto;

public record SubmitBlockAnswerResponse(

        Boolean correct,

        Boolean completed,

        Long nextBlockId,

        Long nextLessonId,

        Long nextChapterId,

        Boolean courseCompleted

) {
}