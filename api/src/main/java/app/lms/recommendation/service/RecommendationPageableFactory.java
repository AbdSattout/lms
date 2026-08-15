package app.lms.recommendation.service;

import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Component;

@Component
public class RecommendationPageableFactory {

    public Pageable forRanking(
            Pageable pageable
    ) {

        if (pageable.isUnpaged()) {
            return pageable;
        }

        return PageRequest.of(
                pageable.getPageNumber(),
                pageable.getPageSize()
        );
    }
}
