package app.lms.placementTest.dto;

import app.lms.common.dto.BaseEntityResponse;

import java.util.List;

public record PlacementTestQuestionResponse(
        Long blockId,
        Long lessonId,
        Long chapterId,
        Long questionId,
        String content,
        List<String> options,
        BaseEntityResponse baseEntity
) {
}
