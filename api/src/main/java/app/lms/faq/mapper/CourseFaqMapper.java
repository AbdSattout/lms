package app.lms.faq.mapper;

import app.lms.common.dto.BaseEntityResponse;
import app.lms.faq.dto.CourseFaqResponse;
import app.lms.faq.model.CourseFaq;
import org.springframework.stereotype.Component;

@Component
public class CourseFaqMapper {

    public CourseFaqResponse toResponse(CourseFaq faq) {
        return new CourseFaqResponse(
                faq.getId(),
                faq.getQuestion(),
                faq.getAnswer(),
                faq.getPosition(),
                BaseEntityResponse.from(faq)
        );
    }
}
