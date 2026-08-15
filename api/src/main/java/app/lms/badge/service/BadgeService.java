package app.lms.badge.service;

import app.lms.badge.dto.BadgeResponse;
import app.lms.badge.mapper.BadgeMapper;
import app.lms.badge.repository.BadgeRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class BadgeService {

    private final BadgeRepository badgeRepository;
    private final BadgeMapper badgeMapper;

    @Transactional(readOnly = true)
    public List<BadgeResponse> getBadges() {

        return badgeRepository
                .findAllByActiveTrueOrderBySortOrderAsc()
                .stream()
                .map(badgeMapper::toResponse)
                .toList();
    }
}
