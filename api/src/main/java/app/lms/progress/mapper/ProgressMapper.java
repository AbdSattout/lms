package app.lms.progress.mapper;


import app.lms.block.model.Block;
import app.lms.progress.dto.SubmitBlockAnswerResponse;
import org.springframework.stereotype.Component;

@Component
public class ProgressMapper {

    public SubmitBlockAnswerResponse toNextStepResponse(
            Block block
    ) {

        return new SubmitBlockAnswerResponse(
                true,
                true,
                block.getLesson()
                        .getChapter()
                        .getId(),
                block.getLesson()
                        .getId(),
                block.getId(),
                false
        );
    }

    public SubmitBlockAnswerResponse incorrectAnswer() {

        return new SubmitBlockAnswerResponse(
                false,
                false,
                null,
                null,
                null,
                false
        );
    }

    public SubmitBlockAnswerResponse courseCompleted() {

        return new SubmitBlockAnswerResponse(
                true,
                true,
                null,
                null,
                null,
                true
        );
    }
}
