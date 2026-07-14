package app.lms.media.service;

import app.lms.media.dto.OrganizationMediaResponse;
import app.lms.media.dto.OrganizationMediaSummaryResponse;
import app.lms.media.mapper.OrganizationMediaMapper;
import app.lms.media.repository.OrganizationMediaRepository;
import app.lms.organization.model.Organization;
import app.lms.organization.service.OrganizationAccessService;
import app.lms.user.model.User;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class OrganizationMediaService {

    private final OrganizationAccessService organizationAccessService;
    private final OrganizationMediaRepository organizationMediaRepository;
    private final OrganizationMediaMapper organizationMediaMapper;

    public Page<OrganizationMediaResponse> list(
            String slug,
            Pageable pageable,
            User user
    ) {

        Organization organization =
                organizationAccessService
                        .getManageableOrganization(
                                slug,
                                user
                        );

        return organizationMediaRepository
                .findAllByOrganizationIdOrderByCreatedAtDesc(
                        organization.getId(),
                        pageable
                )
                .map(
                        organizationMediaMapper::toResponse
                );
    }

    public OrganizationMediaSummaryResponse summary(
            String slug,
            User user
    ) {

        Organization organization =
                organizationAccessService
                        .getManageableOrganization(
                                slug,
                                user
                        );

        return new OrganizationMediaSummaryResponse(
                organization.getId(),
                organizationMediaRepository.countByOrganizationId(
                        organization.getId()
                ),
                organizationMediaRepository.sumSizeBytesByOrganizationId(
                        organization.getId()
                )
        );
    }
}
